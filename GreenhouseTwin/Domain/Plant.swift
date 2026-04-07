import Foundation

struct PlantSpecies: Identifiable, Hashable, Sendable {
    let id: String
    var commonName: String
    var scientificName: String
    var targetEnvironment: EnvironmentTargets
    var baseDailyBiomassGain: Double
    var stressPenaltyRate: Double
    var maxBiomassProxy: Double
    var maxSizeIndex: Double
    var stageThresholds: PlantStageThresholds
}

enum PlantStage: String, CaseIterable, Codable, Hashable, Sendable {
    case seedling
    case vegetative
    case flowering
    case fruiting
    case harvestable
}

struct PlantStageThresholds: Hashable, Sendable {
    var vegetativeAgeDays: Double
    var vegetativeBiomass: Double
    var floweringAgeDays: Double
    var floweringBiomass: Double
    var fruitingAgeDays: Double
    var fruitingBiomass: Double
    var harvestAgeDays: Double
    var harvestBiomass: Double

    func stage(forAgeDays ageDays: Double, biomassProxy: Double) -> PlantStage {
        if ageDays >= harvestAgeDays && biomassProxy >= harvestBiomass {
            return .harvestable
        }
        if ageDays >= fruitingAgeDays && biomassProxy >= fruitingBiomass {
            return .fruiting
        }
        if ageDays >= floweringAgeDays && biomassProxy >= floweringBiomass {
            return .flowering
        }
        if ageDays >= vegetativeAgeDays && biomassProxy >= vegetativeBiomass {
            return .vegetative
        }
        return .seedling
    }
}

struct Plant: Identifiable, Hashable, Sendable {
    let id: String
    var displayName: String
    var speciesID: String
    var plantedOn: Date
    var zoneID: String
    var position: PlantPosition
}

struct PlantPosition: Hashable, Sendable {
    var x: Double
    var z: Double
}

struct PlantState: Hashable, Sendable {
    var ageDays: Double
    var sizeIndex: Double
    var biomassProxy: Double
    var healthScore: Double
    var stage: PlantStage
    var lastGrowthRate: Double
}
