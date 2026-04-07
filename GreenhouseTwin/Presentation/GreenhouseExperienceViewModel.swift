import Foundation
import Observation

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
    var temperature: String
    var humidity: String
    var light: String
    var moisture: String
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

    @ObservationIgnored
    private let simulator = GreenhouseSimulator()

    @ObservationIgnored
    private let speciesByID: [String: PlantSpecies]

    @ObservationIgnored
    private let zoneByID: [String: GreenhouseZone]

    @ObservationIgnored
    private var playbackTask: Task<Void, Never>?

    init(study: GreenhouseStudy, simulationConfig: SimulationConfig? = nil) {
        self.study = study
        self.greenhouse = study.greenhouse
        self.scenario = study.scenario
        self.snapshot = study.initialSnapshot
        self.simulationConfig = simulationConfig ?? .researchDefault
        self.speciesByID = study.speciesByID
        self.zoneByID = Dictionary(uniqueKeysWithValues: study.greenhouse.zones.map { ($0.id, $0) })
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
                temperature: formattedNumber(environment.temperatureC, fractionDigits: 1) + " C",
                humidity: formattedNumber(environment.relativeHumidityPercent, fractionDigits: 0) + " %",
                light: formattedNumber(environment.lightPPFD, fractionDigits: 0) + " PPFD",
                moisture: formattedNumber(environment.substrateMoisturePercent, fractionDigits: 0) + " %",
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
                isPinned: plant.id == pinnedPlantID
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
    }

    func reset() {
        stopPlayback()
        focusedPlantID = nil
        pinnedPlantID = nil
        snapshot = study.initialSnapshot
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
        guard playbackTask == nil else {
            return
        }

        isRunning = true
        playbackTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(simulationConfig.playbackIntervalSeconds))
                guard !Task.isCancelled else {
                    break
                }
                self.step()
            }
        }
    }

    private func stopPlayback() {
        isRunning = false
        playbackTask?.cancel()
        playbackTask = nil
    }

    private func formattedNumber(_ value: Double, fractionDigits: Int) -> String {
        value.formatted(.number.precision(.fractionLength(fractionDigits)))
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
}
