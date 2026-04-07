import XCTest
@testable import GreenhouseTwin

@MainActor
final class GreenhouseTwinTests: XCTestCase {
    func testSimulatorStepIsDeterministic() {
        let study = ResearchBaseline.study
        let simulator = GreenhouseSimulator()

        let first = simulator.advance(
            snapshot: study.initialSnapshot,
            greenhouse: study.greenhouse,
            speciesCatalog: study.speciesByID,
            scenario: study.scenario,
            deltaHours: 1
        )
        let second = simulator.advance(
            snapshot: study.initialSnapshot,
            greenhouse: study.greenhouse,
            speciesCatalog: study.speciesByID,
            scenario: study.scenario,
            deltaHours: 1
        )

        XCTAssertEqual(first, second)
    }

    func testOptimalConditionsIncreaseBiomass() throws {
        let study = ResearchBaseline.study
        let species = try XCTUnwrap(study.speciesByID["tomato"])
        let model = PlantGrowthModel()
        let current = PlantState(ageDays: 12, sizeIndex: 0.3, biomassProxy: 0.25, healthScore: 0.8, stage: .vegetative, lastGrowthRate: 0)
        let environment = EnvironmentState(
            timestamp: study.initialSnapshot.timestamp,
            temperatureC: species.targetEnvironment.temperatureC.midpoint,
            relativeHumidityPercent: species.targetEnvironment.relativeHumidityPercent.midpoint,
            co2PPM: species.targetEnvironment.co2PPM.midpoint,
            lightPPFD: species.targetEnvironment.lightPPFD.midpoint,
            substrateMoisturePercent: species.targetEnvironment.substrateMoisturePercent.midpoint
        )

        let next = model.nextState(species: species, currentState: current, environment: environment, deltaHours: 24)

        XCTAssertGreaterThan(next.biomassProxy, current.biomassProxy)
        XCTAssertGreaterThanOrEqual(next.healthScore, current.healthScore)
    }

    func testStressSuppressesGrowthAndHealth() throws {
        let study = ResearchBaseline.study
        let species = try XCTUnwrap(study.speciesByID["lettuce"])
        let model = PlantGrowthModel()
        let current = PlantState(ageDays: 10, sizeIndex: 0.2, biomassProxy: 0.18, healthScore: 0.85, stage: .vegetative, lastGrowthRate: 0)
        let environment = EnvironmentState(
            timestamp: study.initialSnapshot.timestamp,
            temperatureC: species.targetEnvironment.temperatureC.minimum - 8.0,
            relativeHumidityPercent: species.targetEnvironment.relativeHumidityPercent.minimum,
            co2PPM: species.targetEnvironment.co2PPM.minimum,
            lightPPFD: 20,
            substrateMoisturePercent: species.targetEnvironment.substrateMoisturePercent.minimum - 25.0
        )

        let next = model.nextState(species: species, currentState: current, environment: environment, deltaHours: 24)

        XCTAssertLessThan(next.healthScore, current.healthScore)
        XCTAssertLessThan(next.lastGrowthRate, 0)
    }

    func testNightRespirationOutpacesPhotosynthesisUnderHeatStress() throws {
        let study = ResearchBaseline.study
        let species = try XCTUnwrap(study.speciesByID["tomato"])
        let model = PlantGrowthModel()
        let current = PlantState(
            ageDays: 18,
            sizeIndex: 0.34,
            biomassProxy: 0.31,
            healthScore: 0.82,
            stage: .vegetative,
            lastGrowthRate: 0
        )
        let environment = EnvironmentState(
            timestamp: study.initialSnapshot.timestamp,
            temperatureC: species.targetEnvironment.temperatureC.maximum + 7.0,
            relativeHumidityPercent: species.targetEnvironment.relativeHumidityPercent.midpoint,
            co2PPM: species.targetEnvironment.co2PPM.midpoint,
            lightPPFD: 0,
            substrateMoisturePercent: species.targetEnvironment.substrateMoisturePercent.midpoint
        )

        let next = model.nextState(species: species, currentState: current, environment: environment, deltaHours: 12)

        XCTAssertLessThan(next.biomassProxy, current.biomassProxy)
        XCTAssertLessThan(next.lastGrowthRate, 0)
    }

    func testStageTransitionsReachHarvestableUnderStableConditions() throws {
        let study = ResearchBaseline.study
        let species = try XCTUnwrap(study.speciesByID["tomato"])
        let model = PlantGrowthModel()
        let environment = EnvironmentState(
            timestamp: study.initialSnapshot.timestamp,
            temperatureC: species.targetEnvironment.temperatureC.midpoint,
            relativeHumidityPercent: species.targetEnvironment.relativeHumidityPercent.midpoint,
            co2PPM: species.targetEnvironment.co2PPM.midpoint,
            lightPPFD: species.targetEnvironment.lightPPFD.midpoint,
            substrateMoisturePercent: species.targetEnvironment.substrateMoisturePercent.midpoint
        )

        var state = PlantState(ageDays: 0, sizeIndex: 0.1, biomassProxy: 0.05, healthScore: 0.9, stage: .seedling, lastGrowthRate: 0)

        for _ in 0..<1_600 {
            state = model.nextState(species: species, currentState: state, environment: environment, deltaHours: 1)
        }

        XCTAssertEqual(state.stage, .harvestable)
        XCTAssertGreaterThan(state.biomassProxy, species.stageThresholds.harvestBiomass)
    }

    func testCriticalHealthPersistenceTransitionsPlantToDead() throws {
        let study = ResearchBaseline.study
        let species = try XCTUnwrap(study.speciesByID["lettuce"])
        let model = PlantGrowthModel()
        let environment = EnvironmentState(
            timestamp: study.initialSnapshot.timestamp,
            temperatureC: species.targetEnvironment.temperatureC.maximum + 10.0,
            relativeHumidityPercent: species.targetEnvironment.relativeHumidityPercent.minimum - 20.0,
            co2PPM: species.targetEnvironment.co2PPM.minimum,
            lightPPFD: 0,
            substrateMoisturePercent: species.targetEnvironment.substrateMoisturePercent.minimum - 35.0
        )

        var state = PlantState(
            ageDays: 9,
            sizeIndex: 0.18,
            biomassProxy: 0.15,
            healthScore: 0.09,
            stage: .vegetative,
            lastGrowthRate: 0
        )

        for _ in 0..<25 {
            state = model.nextState(species: species, currentState: state, environment: environment, deltaHours: 1)
        }

        XCTAssertEqual(state.stage, .dead)
        XCTAssertEqual(state.healthScore, 0)
        XCTAssertGreaterThan(state.lowHealthDurationHours, 24)
    }

    func testScenarioClampsOutOfBoundsEnvironmentValues() {
        let zone = GreenhouseZone(
            id: "clamp-zone",
            name: "Clamp Zone",
            description: "Used to validate scenario output bounds.",
            layout: ZoneLayout(originX: 0, originZ: 0, width: 1, depth: 1),
            targets: EnvironmentTargets(
                temperatureC: TargetRange(18, 22),
                relativeHumidityPercent: TargetRange(50, 70),
                co2PPM: TargetRange(600, 900),
                lightPPFD: TargetRange(200, 400),
                substrateMoisturePercent: TargetRange(45, 65)
            )
        )

        let scenario = EnvironmentScenario(
            id: "extreme",
            name: "Extreme",
            summary: "Bounds-checking scenario",
            sunriseHour: 6,
            sunsetHour: 18,
            zoneProfiles: [
                "clamp-zone": ZoneEnvironmentProfile(
                    dayTemperatureC: 90,
                    nightTemperatureC: -50,
                    dayRelativeHumidityPercent: 180,
                    nightRelativeHumidityPercent: -20,
                    dayCO2PPM: 5_000,
                    nightCO2PPM: 50,
                    peakLightPPFD: 8_000,
                    nightLightPPFD: -120,
                    maximumSubstrateMoisturePercent: 140,
                    minimumSubstrateMoisturePercent: -30,
                    irrigationHour: 6
                )
            ]
        )

        let sample = scenario.environment(for: zone, at: Date(timeIntervalSince1970: 0))

        XCTAssertLessThanOrEqual(sample.temperatureC, 60)
        XCTAssertGreaterThanOrEqual(sample.temperatureC, -20)
        XCTAssertLessThanOrEqual(sample.relativeHumidityPercent, 100)
        XCTAssertGreaterThanOrEqual(sample.relativeHumidityPercent, 0)
        XCTAssertLessThanOrEqual(sample.lightPPFD, 1_500)
        XCTAssertGreaterThanOrEqual(sample.substrateMoisturePercent, 0)
    }

    func testExperienceViewModelRetainsTwentyFourStepsOfHistory() {
        let viewModel = GreenhouseExperienceViewModel(study: ResearchBaseline.study)

        for _ in 0..<30 {
            viewModel.step()
        }

        XCTAssertEqual(viewModel.averageHealthHistory.count, 24)
        let plantTrends = viewModel.plantPanelModels.map(\.growthTrend.count)
        XCTAssertTrue(plantTrends.allSatisfy { $0 == 24 })
    }
}
