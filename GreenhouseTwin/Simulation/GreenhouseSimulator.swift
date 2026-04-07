import Foundation

struct GreenhouseSimulator: Sendable {
    private let growthModel = PlantGrowthModel()

    func advance(
        snapshot: GreenhouseSnapshot,
        greenhouse: Greenhouse,
        speciesCatalog: [String: PlantSpecies],
        scenario: EnvironmentScenario,
        deltaHours: Double
    ) -> GreenhouseSnapshot {
        let nextTimestamp = snapshot.timestamp.addingTimeInterval(deltaHours * 3_600.0)

        let nextZoneEnvironments = Dictionary(uniqueKeysWithValues: greenhouse.zones.map { zone in
            (zone.id, scenario.environment(for: zone, at: nextTimestamp))
        })

        let nextPlantStates = Dictionary(uniqueKeysWithValues: greenhouse.plants.map { plant in
            let currentState = snapshot.plantStates[plant.id] ?? PlantState(
                ageDays: 0,
                sizeIndex: 0.1,
                biomassProxy: 0.05,
                healthScore: 0.8,
                stage: .seedling,
                lastGrowthRate: 0
            )
            let species = speciesCatalog[plant.speciesID]
            let environment = nextZoneEnvironments[plant.zoneID]

            if let species, let environment {
                let nextState = growthModel.nextState(
                    species: species,
                    currentState: currentState,
                    environment: environment,
                    deltaHours: deltaHours
                )
                return (plant.id, nextState)
            }

            return (plant.id, currentState)
        })

        let provisionalSnapshot = GreenhouseSnapshot(
            timestamp: nextTimestamp,
            zoneEnvironments: nextZoneEnvironments,
            plantStates: nextPlantStates,
            alerts: []
        )

        return GreenhouseSnapshot(
            timestamp: provisionalSnapshot.timestamp,
            zoneEnvironments: provisionalSnapshot.zoneEnvironments,
            plantStates: provisionalSnapshot.plantStates,
            alerts: alerts(for: greenhouse, speciesCatalog: speciesCatalog, snapshot: provisionalSnapshot)
        )
    }

    func alerts(
        for greenhouse: Greenhouse,
        speciesCatalog: [String: PlantSpecies],
        snapshot: GreenhouseSnapshot
    ) -> [GreenhouseAlert] {
        var results: [GreenhouseAlert] = []

        for zone in greenhouse.zones {
            guard let environment = snapshot.zoneEnvironments[zone.id] else {
                continue
            }

            let driftedMetrics = zoneDriftedMetrics(for: environment, targets: zone.targets)
            guard !driftedMetrics.isEmpty else {
                continue
            }

            results.append(
                GreenhouseAlert(
                    id: "zone-\(zone.id)",
                    severity: driftedMetrics.count >= 2 ? .critical : .warning,
                    title: "\(zone.name) is outside target range",
                    detail: driftedMetrics.joined(separator: ", "),
                    sourceID: zone.id
                )
            )
        }

        for plant in greenhouse.plants {
            guard let state = snapshot.plantStates[plant.id] else {
                continue
            }

            guard state.healthScore < 0.65 else {
                continue
            }

            let speciesName = speciesCatalog[plant.speciesID]?.commonName ?? plant.speciesID
            let severity: GreenhouseAlertSeverity = state.healthScore < 0.4 ? .critical : .warning

            results.append(
                GreenhouseAlert(
                    id: "plant-\(plant.id)",
                    severity: severity,
                    title: "\(plant.displayName) needs attention",
                    detail: "\(speciesName) health score is \(state.healthScore.formatted(.number.precision(.fractionLength(2))))",
                    sourceID: plant.id
                )
            )
        }

        return results.sorted {
            if $0.severity == $1.severity {
                return $0.title < $1.title
            }
            return $0.severity.rawValue > $1.severity.rawValue
        }
    }

    private func zoneDriftedMetrics(for environment: EnvironmentState, targets: EnvironmentTargets) -> [String] {
        var driftedMetrics: [String] = []

        if !targets.temperatureC.contains(environment.temperatureC) {
            driftedMetrics.append("temperature \(environment.temperatureC.formatted(.number.precision(.fractionLength(1))))C")
        }
        if !targets.relativeHumidityPercent.contains(environment.relativeHumidityPercent) {
            driftedMetrics.append("humidity \(environment.relativeHumidityPercent.formatted(.number.precision(.fractionLength(0))))%")
        }
        if !targets.lightPPFD.contains(environment.lightPPFD) {
            driftedMetrics.append("light \(environment.lightPPFD.formatted(.number.precision(.fractionLength(0)))) PPFD")
        }
        if !targets.substrateMoisturePercent.contains(environment.substrateMoisturePercent) {
            driftedMetrics.append("moisture \(environment.substrateMoisturePercent.formatted(.number.precision(.fractionLength(0))))%")
        }

        return driftedMetrics
    }
}
