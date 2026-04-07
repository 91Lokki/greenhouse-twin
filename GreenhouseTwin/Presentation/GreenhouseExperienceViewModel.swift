import Foundation
import Observation

enum GaugeDeviationDirection: Hashable {
    case belowTarget
    case withinTarget
    case aboveTarget
}

struct ZoneMetricGaugeModel: Identifiable, Hashable {
    let id: String
    var title: String
    var valueText: String
    var positionRatio: Double
    var deviationRatio: Double
    var deviationDirection: GaugeDeviationDirection
}

struct GlobalControlPanelModel: Hashable {
    var scenarioName: String
    var timestamp: String
    var averageHealth: String
    var alertCount: String
    var biomassProxy: String
    var statusLine: String
    var isRunning: Bool
}

struct ZoneClimatePanelModel: Identifiable, Hashable {
    let id: String
    var name: String
    var detail: String
    var indicators: [ZoneMetricGaugeModel]
    var driftSummary: String
}

struct PlantDataPanelModel: Identifiable, Hashable {
    let id: String
    var name: String
    var speciesName: String
    var zoneName: String
    var stage: String
    var health: String
    var biomass: String
    var growthRate: String
    var isPinned: Bool
    var isDead: Bool
    var growthTrend: [Double]
}

@MainActor
@Observable
final class GreenhouseExperienceViewModel {
    let study: GreenhouseStudy
    let greenhouse: Greenhouse
    let scenario: EnvironmentScenario
    let simulationConfig: SimulationConfig

    var snapshot: GreenhouseSnapshot
    var isRunning = false
    var focusedPlantID: String?
    var pinnedPlantID: String?
    var averageHealthHistory: [Double] = []

    @ObservationIgnored
    private let simulator = GreenhouseSimulator()

    @ObservationIgnored
    private let speciesByID: [String: PlantSpecies]

    @ObservationIgnored
    private let zoneByID: [String: GreenhouseZone]

    @ObservationIgnored
    private var playbackTimer: Timer?

    @ObservationIgnored
    private let historyLimit = 24

    @ObservationIgnored
    private var growthRateHistoryByPlantID: [String: [Double]] = [:]

    init(study: GreenhouseStudy, simulationConfig: SimulationConfig? = nil) {
        self.study = study
        self.greenhouse = study.greenhouse
        self.scenario = study.scenario
        self.snapshot = study.initialSnapshot
        self.simulationConfig = simulationConfig ?? .researchDefault
        self.speciesByID = study.speciesByID
        self.zoneByID = Dictionary(uniqueKeysWithValues: study.greenhouse.zones.map { ($0.id, $0) })
        seedHistory(with: study.initialSnapshot)
    }

    deinit {
        playbackTimer?.invalidate()
    }

    var activePlantPanelID: String? {
        pinnedPlantID ?? focusedPlantID
    }

    var globalControlModel: GlobalControlPanelModel {
        let cadence = simulationConfig.defaultStepHours.formatted(.number.precision(.fractionLength(0)))

        return GlobalControlPanelModel(
            scenarioName: scenario.name,
            timestamp: snapshot.timestamp.formatted(date: .abbreviated, time: .shortened),
            averageHealth: snapshot.averageHealthScore.formatted(.percent.precision(.fractionLength(0))),
            alertCount: "\(snapshot.alerts.count)",
            biomassProxy: snapshot.totalBiomassProxy.formatted(.number.precision(.fractionLength(2))),
            statusLine: "Discrete simulator stepping in \(cadence)-hour increments",
            isRunning: isRunning
        )
    }

    var zonePanelModels: [ZoneClimatePanelModel] {
        greenhouse.zones.map { zone in
            let environment = snapshot.zoneEnvironments[zone.id] ?? scenario.environment(for: zone, at: snapshot.timestamp)

            return ZoneClimatePanelModel(
                id: zone.id,
                name: zone.name,
                detail: zone.description,
                indicators: [
                    makeMetricGauge(
                        id: "\(zone.id)-temperature",
                        title: "Temperature",
                        value: environment.temperatureC,
                        preferredRange: zone.targets.temperatureC,
                        suffix: " C",
                        fractionDigits: 1
                    ),
                    makeMetricGauge(
                        id: "\(zone.id)-humidity",
                        title: "Humidity",
                        value: environment.relativeHumidityPercent,
                        preferredRange: zone.targets.relativeHumidityPercent,
                        suffix: " %",
                        fractionDigits: 0
                    ),
                    makeMetricGauge(
                        id: "\(zone.id)-light",
                        title: "Light",
                        value: environment.lightPPFD,
                        preferredRange: zone.targets.lightPPFD,
                        suffix: " PPFD",
                        fractionDigits: 0
                    ),
                    makeMetricGauge(
                        id: "\(zone.id)-substrate",
                        title: "Substrate",
                        value: environment.substrateMoisturePercent,
                        preferredRange: zone.targets.substrateMoisturePercent,
                        suffix: " %",
                        fractionDigits: 0
                    )
                ],
                driftSummary: zoneDriftSummary(for: environment, targets: zone.targets)
            )
        }
    }

    var plantPanelModels: [PlantDataPanelModel] {
        greenhouse.plants.compactMap { plant in
            guard let state = snapshot.plantStates[plant.id] else {
                return nil
            }

            let speciesName = speciesByID[plant.speciesID]?.commonName ?? plant.speciesID
            let zoneName = zoneByID[plant.zoneID]?.name ?? plant.zoneID

            return PlantDataPanelModel(
                id: plant.id,
                name: plant.displayName,
                speciesName: speciesName,
                zoneName: zoneName,
                stage: state.stage.rawValue.capitalized,
                health: state.healthScore.formatted(.percent.precision(.fractionLength(0))),
                biomass: state.biomassProxy.formatted(.number.precision(.fractionLength(2))),
                growthRate: state.lastGrowthRate.formatted(.number.precision(.fractionLength(2))) + " / day",
                isPinned: plant.id == pinnedPlantID,
                isDead: state.stage == .dead,
                growthTrend: growthRateHistoryByPlantID[plant.id] ?? [state.lastGrowthRate]
            )
        }
    }

    func togglePlayback() {
        if isRunning {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    func step() {
        snapshot = simulator.advance(
            snapshot: snapshot,
            greenhouse: greenhouse,
            speciesCatalog: speciesByID,
            scenario: scenario,
            deltaHours: simulationConfig.defaultStepHours
        )
        recordHistory(for: snapshot)
    }

    func reset() {
        stopPlayback()
        focusedPlantID = nil
        pinnedPlantID = nil
        snapshot = study.initialSnapshot
        seedHistory(with: snapshot)
    }

    func setFocusedPlant(_ plantID: String?) {
        focusedPlantID = plantID
    }

    func togglePinnedPlant(_ plantID: String) {
        if pinnedPlantID == plantID {
            pinnedPlantID = nil
        } else {
            pinnedPlantID = plantID
            focusedPlantID = plantID
        }
    }

    func clearPinnedPlant() {
        pinnedPlantID = nil
    }

    func clearTransientFocus() {
        focusedPlantID = nil
    }

    func plantPanelModel(for plantID: String) -> PlantDataPanelModel? {
        plantPanelModels.first { $0.id == plantID }
    }

    func zonePanelModel(for zoneID: String) -> ZoneClimatePanelModel? {
        zonePanelModels.first { $0.id == zoneID }
    }

    private func startPlayback() {
        guard playbackTimer == nil else {
            return
        }

        isRunning = true
        playbackTimer = Timer.scheduledTimer(withTimeInterval: simulationConfig.playbackIntervalSeconds, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.step()
            }
        }
    }

    private func stopPlayback() {
        isRunning = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func seedHistory(with snapshot: GreenhouseSnapshot) {
        averageHealthHistory = [snapshot.averageHealthScore]
        growthRateHistoryByPlantID = Dictionary(
            uniqueKeysWithValues: snapshot.plantStates.map { plantID, state in
                (plantID, [state.lastGrowthRate])
            }
        )
    }

    private func recordHistory(for snapshot: GreenhouseSnapshot) {
        averageHealthHistory.append(snapshot.averageHealthScore)
        averageHealthHistory = trimmed(averageHealthHistory)

        for (plantID, state) in snapshot.plantStates {
            growthRateHistoryByPlantID[plantID, default: []].append(state.lastGrowthRate)
            growthRateHistoryByPlantID[plantID] = trimmed(growthRateHistoryByPlantID[plantID] ?? [])
        }
    }

    private func trimmed(_ values: [Double]) -> [Double] {
        Array(values.suffix(historyLimit))
    }

    private func formattedNumber(_ value: Double, fractionDigits: Int) -> String {
        value.formatted(.number.precision(.fractionLength(fractionDigits)))
    }

    private func makeMetricGauge(
        id: String,
        title: String,
        value: Double,
        preferredRange: TargetRange,
        suffix: String,
        fractionDigits: Int
    ) -> ZoneMetricGaugeModel {
        ZoneMetricGaugeModel(
            id: id,
            title: title,
            valueText: formattedNumber(value, fractionDigits: fractionDigits) + suffix,
            positionRatio: clamp((value - preferredRange.minimum) / preferredRange.span, minimum: 0.0, maximum: 1.0),
            deviationRatio: clamp(preferredRange.normalizedDeviation(from: value), minimum: 0.0, maximum: 1.0),
            deviationDirection: gaugeDirection(for: value, preferredRange: preferredRange)
        )
    }

    private func zoneDriftSummary(for environment: EnvironmentState, targets: EnvironmentTargets) -> String {
        var drifts: [String] = []

        if !targets.temperatureC.contains(environment.temperatureC) {
            drifts.append("temperature")
        }
        if !targets.relativeHumidityPercent.contains(environment.relativeHumidityPercent) {
            drifts.append("humidity")
        }
        if !targets.lightPPFD.contains(environment.lightPPFD) {
            drifts.append("light")
        }
        if !targets.substrateMoisturePercent.contains(environment.substrateMoisturePercent) {
            drifts.append("moisture")
        }

        return drifts.isEmpty ? "Within current target ranges" : "Drifted: " + drifts.joined(separator: ", ")
    }

    private func gaugeDirection(for value: Double, preferredRange: TargetRange) -> GaugeDeviationDirection {
        if value < preferredRange.minimum {
            return .belowTarget
        }
        if value > preferredRange.maximum {
            return .aboveTarget
        }
        return .withinTarget
    }

    private func clamp(_ value: Double, minimum: Double, maximum: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}
