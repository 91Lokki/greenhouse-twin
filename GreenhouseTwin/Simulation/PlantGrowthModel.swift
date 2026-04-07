import Foundation

struct PlantGrowthModel: Sendable {
    func nextState(
        species: PlantSpecies,
        currentState: PlantState,
        environment: EnvironmentState,
        deltaHours: Double
    ) -> PlantState {
        let deltaDays = max(deltaHours / 24.0, 0.0001)
        let temperatureFactor = responseFactor(value: environment.temperatureC, preferredRange: species.targetEnvironment.temperatureC, softness: 1.4)
        let lightFactor = responseFactor(value: environment.lightPPFD, preferredRange: species.targetEnvironment.lightPPFD, softness: 1.1)
        let moistureFactor = responseFactor(value: environment.substrateMoisturePercent, preferredRange: species.targetEnvironment.substrateMoisturePercent, softness: 1.0)
        let combinedSignal = weightedAverage([
            (temperatureFactor, 0.4),
            (lightFactor, 0.35),
            (moistureFactor, 0.25)
        ])

        let stressFloor = min(temperatureFactor, lightFactor, moistureFactor)
        let stressPenalty = (1.0 - stressFloor) * species.stressPenaltyRate
        let healthDelta = ((combinedSignal - 0.7) * 0.18 * deltaDays) - (stressPenalty * 0.12 * deltaDays)
        let nextHealth = clamp(currentState.healthScore + healthDelta, minimum: 0.05, maximum: 1.0)

        let productiveGrowth = species.baseDailyBiomassGain * combinedSignal * max(nextHealth, 0.3) * deltaDays
        let maintenanceLoss = stressPenalty * 0.04 * deltaDays
        let biomassDelta = productiveGrowth - maintenanceLoss
        let nextBiomass = clamp(
            currentState.biomassProxy + biomassDelta,
            minimum: 0.02,
            maximum: species.maxBiomassProxy
        )

        let nextAgeDays = currentState.ageDays + deltaDays
        let normalizedSize = sqrt(nextBiomass / species.maxBiomassProxy)
        let targetSize = normalizedSize * species.maxSizeIndex
        let nextSize = max(currentState.sizeIndex, min(targetSize, species.maxSizeIndex))
        let nextStage = species.stageThresholds.stage(forAgeDays: nextAgeDays, biomassProxy: nextBiomass)
        let dailyGrowthRate = biomassDelta / deltaDays

        return PlantState(
            ageDays: nextAgeDays,
            sizeIndex: nextSize,
            biomassProxy: nextBiomass,
            healthScore: nextHealth,
            stage: nextStage,
            lastGrowthRate: dailyGrowthRate
        )
    }

    private func responseFactor(value: Double, preferredRange: TargetRange, softness: Double) -> Double {
        let deviation = preferredRange.normalizedDeviation(from: value)
        return clamp(1.0 - (deviation / softness), minimum: 0.0, maximum: 1.0)
    }

    private func weightedAverage(_ values: [(Double, Double)]) -> Double {
        let totalWeight = values.map(\.1).reduce(0, +)
        guard totalWeight > 0 else {
            return 0
        }

        let weightedSum = values.reduce(0.0) { partialResult, pair in
            partialResult + (pair.0 * pair.1)
        }
        return weightedSum / totalWeight
    }

    private func clamp(_ value: Double, minimum: Double, maximum: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}
