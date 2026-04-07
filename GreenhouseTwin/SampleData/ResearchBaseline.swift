import Foundation

struct GreenhouseStudy: Sendable {
    var title: String
    var summary: String
    var greenhouse: Greenhouse
    var speciesCatalog: [PlantSpecies]
    var initialSnapshot: GreenhouseSnapshot
    var scenario: EnvironmentScenario

    var speciesByID: [String: PlantSpecies] {
        Dictionary(uniqueKeysWithValues: speciesCatalog.map { ($0.id, $0) })
    }
}

enum ResearchBaseline {
    static let study: GreenhouseStudy = {
        let tomatoTargets = EnvironmentTargets(
            temperatureC: TargetRange(20, 27),
            relativeHumidityPercent: TargetRange(60, 78),
            co2PPM: TargetRange(700, 950),
            lightPPFD: TargetRange(350, 650),
            substrateMoisturePercent: TargetRange(48, 70)
        )
        let lettuceTargets = EnvironmentTargets(
            temperatureC: TargetRange(17, 23),
            relativeHumidityPercent: TargetRange(58, 74),
            co2PPM: TargetRange(650, 900),
            lightPPFD: TargetRange(220, 420),
            substrateMoisturePercent: TargetRange(55, 74)
        )

        let greenhouse = Greenhouse(
            id: "research-bay-01",
            name: "GreenhouseTwin Research Bay",
            description: "Two-zone mock greenhouse used to validate data flow, simulation, and spatial mapping before any real hardware integration.",
            zones: [
                GreenhouseZone(
                    id: "zone-seedlings",
                    name: "Seedling Bench",
                    description: "Cooler, higher-moisture nursery bench for leafy greens.",
                    layout: ZoneLayout(originX: 0.05, originZ: 0.12, width: 0.42, depth: 0.7),
                    targets: lettuceTargets
                ),
                GreenhouseZone(
                    id: "zone-vines",
                    name: "Vine Row",
                    description: "Warmer productive row for vining crops and later canopy experiments.",
                    layout: ZoneLayout(originX: 0.53, originZ: 0.12, width: 0.42, depth: 0.7),
                    targets: tomatoTargets
                )
            ],
            plants: [
                Plant(
                    id: "lettuce-01",
                    displayName: "Lettuce A",
                    speciesID: "lettuce",
                    plantedOn: referenceDate(dayOffset: -12),
                    zoneID: "zone-seedlings",
                    position: PlantPosition(x: 0.25, z: 0.35)
                ),
                Plant(
                    id: "lettuce-02",
                    displayName: "Lettuce B",
                    speciesID: "lettuce",
                    plantedOn: referenceDate(dayOffset: -10),
                    zoneID: "zone-seedlings",
                    position: PlantPosition(x: 0.7, z: 0.6)
                ),
                Plant(
                    id: "tomato-01",
                    displayName: "Tomato A",
                    speciesID: "tomato",
                    plantedOn: referenceDate(dayOffset: -20),
                    zoneID: "zone-vines",
                    position: PlantPosition(x: 0.22, z: 0.3)
                ),
                Plant(
                    id: "tomato-02",
                    displayName: "Tomato B",
                    speciesID: "tomato",
                    plantedOn: referenceDate(dayOffset: -18),
                    zoneID: "zone-vines",
                    position: PlantPosition(x: 0.68, z: 0.55)
                )
            ]
        )

        let speciesCatalog = [
            PlantSpecies(
                id: "lettuce",
                commonName: "Butterhead Lettuce",
                scientificName: "Lactuca sativa",
                targetEnvironment: lettuceTargets,
                baseDailyBiomassGain: 0.045,
                stressPenaltyRate: 0.9,
                maxBiomassProxy: 1.1,
                maxSizeIndex: 0.7,
                stageThresholds: PlantStageThresholds(
                    vegetativeAgeDays: 8,
                    vegetativeBiomass: 0.18,
                    floweringAgeDays: 20,
                    floweringBiomass: 0.52,
                    fruitingAgeDays: 26,
                    fruitingBiomass: 0.7,
                    harvestAgeDays: 32,
                    harvestBiomass: 0.88
                )
            ),
            PlantSpecies(
                id: "tomato",
                commonName: "Tomato",
                scientificName: "Solanum lycopersicum",
                targetEnvironment: tomatoTargets,
                baseDailyBiomassGain: 0.055,
                stressPenaltyRate: 1.1,
                maxBiomassProxy: 1.5,
                maxSizeIndex: 1.0,
                stageThresholds: PlantStageThresholds(
                    vegetativeAgeDays: 10,
                    vegetativeBiomass: 0.2,
                    floweringAgeDays: 24,
                    floweringBiomass: 0.5,
                    fruitingAgeDays: 38,
                    fruitingBiomass: 0.82,
                    harvestAgeDays: 52,
                    harvestBiomass: 1.12
                )
            )
        ]

        let scenario = EnvironmentScenario(
            id: "spring-baseline",
            name: "Spring Baseline Scenario",
            summary: "Deterministic diurnal climate pattern with simple daily irrigation reset and no closed-loop control.",
            sunriseHour: 6.0,
            sunsetHour: 18.5,
            zoneProfiles: [
                "zone-seedlings": ZoneEnvironmentProfile(
                    dayTemperatureC: 21.5,
                    nightTemperatureC: 17.8,
                    dayRelativeHumidityPercent: 63,
                    nightRelativeHumidityPercent: 71,
                    dayCO2PPM: 760,
                    nightCO2PPM: 690,
                    peakLightPPFD: 360,
                    nightLightPPFD: 0,
                    maximumSubstrateMoisturePercent: 74,
                    minimumSubstrateMoisturePercent: 58,
                    irrigationHour: 5.5
                ),
                "zone-vines": ZoneEnvironmentProfile(
                    dayTemperatureC: 24.8,
                    nightTemperatureC: 20.5,
                    dayRelativeHumidityPercent: 65,
                    nightRelativeHumidityPercent: 73,
                    dayCO2PPM: 840,
                    nightCO2PPM: 720,
                    peakLightPPFD: 610,
                    nightLightPPFD: 0,
                    maximumSubstrateMoisturePercent: 68,
                    minimumSubstrateMoisturePercent: 46,
                    irrigationHour: 6.0
                )
            ]
        )

        let timestamp = referenceDate()
        let zoneEnvironments = Dictionary(uniqueKeysWithValues: greenhouse.zones.map { zone in
            (zone.id, scenario.environment(for: zone, at: timestamp))
        })

        let initialSnapshot = GreenhouseSnapshot(
            timestamp: timestamp,
            zoneEnvironments: zoneEnvironments,
            plantStates: [
                "lettuce-01": PlantState(ageDays: 12, sizeIndex: 0.28, biomassProxy: 0.26, healthScore: 0.92, stage: .vegetative, lastGrowthRate: 0.03),
                "lettuce-02": PlantState(ageDays: 10, sizeIndex: 0.24, biomassProxy: 0.21, healthScore: 0.89, stage: .vegetative, lastGrowthRate: 0.028),
                "tomato-01": PlantState(ageDays: 20, sizeIndex: 0.38, biomassProxy: 0.34, healthScore: 0.86, stage: .vegetative, lastGrowthRate: 0.031),
                "tomato-02": PlantState(ageDays: 18, sizeIndex: 0.34, biomassProxy: 0.3, healthScore: 0.83, stage: .vegetative, lastGrowthRate: 0.029)
            ],
            alerts: []
        )

        let simulator = GreenhouseSimulator()
        let hydratedSnapshot = GreenhouseSnapshot(
            timestamp: initialSnapshot.timestamp,
            zoneEnvironments: initialSnapshot.zoneEnvironments,
            plantStates: initialSnapshot.plantStates,
            alerts: simulator.alerts(
                for: greenhouse,
                speciesCatalog: Dictionary(uniqueKeysWithValues: speciesCatalog.map { ($0.id, $0) }),
                snapshot: initialSnapshot
            )
        )

        return GreenhouseStudy(
            title: "GreenhouseTwin v1 Research Foundation",
            summary: "A window-first digital twin baseline focused on domain clarity, deterministic simulation, and minimal spatial context.",
            greenhouse: greenhouse,
            speciesCatalog: speciesCatalog,
            initialSnapshot: hydratedSnapshot,
            scenario: scenario
        )
    }()

    private static func referenceDate(dayOffset: Int = 0) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 2026
        components.month = 3
        components.day = 24 + dayOffset
        components.hour = 8
        components.minute = 0
        return components.date ?? Date(timeIntervalSince1970: 0)
    }
}
