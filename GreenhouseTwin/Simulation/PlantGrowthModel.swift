import Foundation

struct PlantGrowthModel: Sendable {
    private let criticalHealthThreshold = 0.1
    private let deathPersistenceHours = 24.0

    func nextState(
        species: PlantSpecies,
        currentState: PlantState,
        environment: EnvironmentState,
        deltaHours: Double
    ) -> PlantState {
        let deltaDays = max(deltaHours / 24.0, 0.0001)

        guard currentState.stage != .dead else {
            return PlantState(
                ageDays: currentState.ageDays + deltaDays,
                sizeIndex: currentState.sizeIndex,
                biomassProxy: currentState.biomassProxy,
                healthScore: 0,
                stage: .dead,
                lastGrowthRate: 0,
                lowHealthDurationHours: currentState.lowHealthDurationHours + deltaHours
            )
        }

        let temperatureFactor = responseFactor(
            value: environment.temperatureC,
            preferredRange: species.targetEnvironment.temperatureC,
            softness: 1.15
        )
        let humidityFactor = responseFactor(
            value: environment.relativeHumidityPercent,
            preferredRange: species.targetEnvironment.relativeHumidityPercent,
            softness: 1.3
        )
        let lightFactor = responseFactor(
            value: environment.lightPPFD,
            preferredRange: species.targetEnvironment.lightPPFD,
            softness: 1.0
        )
        let moistureFactor = responseFactor(
            value: environment.substrateMoisturePercent,
            preferredRange: species.targetEnvironment.substrateMoisturePercent,
            softness: 0.95
        )
        let carbonFactor = responseFactor(
            value: environment.co2PPM,
            preferredRange: species.targetEnvironment.co2PPM,
            softness: 1.2
        )

        let heatStress = upperDeviation(value: environment.temperatureC, preferredRange: species.targetEnvironment.temperatureC)
        let coldStress = lowerDeviation(value: environment.temperatureC, preferredRange: species.targetEnvironment.temperatureC)

        let photosynthesisSignal = geometricMean([
            lightFactor,
            carbonFactor,
            temperatureFactor
        ]) * moistureFactor
        let photosynthesisGain = species.baseDailyBiomassGain
            * photosynthesisSignal
            * max(currentState.healthScore, 0.18)
            * deltaDays

        let respirationLoad = species.baseDailyBiomassGain
            * 0.34
            * temperatureRespirationMultiplier(
                value: environment.temperatureC,
                preferredRange: species.targetEnvironment.temperatureC
            )
            * (1.0 + (heatStress * 1.35))
            * (1.0 + ((1.0 - moistureFactor) * 0.4))
            * deltaDays

        let biomassDelta = photosynthesisGain - respirationLoad
        let nextBiomass = clamp(
            currentState.biomassProxy + biomassDelta,
            minimum: 0.02,
            maximum: species.maxBiomassProxy
        )

        let stressIndex = weightedAverage([
            (1.0 - temperatureFactor, 0.26),
            (1.0 - moistureFactor, 0.26),
            (1.0 - lightFactor, 0.16),
            (1.0 - carbonFactor, 0.12),
            (1.0 - humidityFactor, 0.10),
            (heatStress, 0.10)
        ])
        let recoveryBoost = max(photosynthesisSignal - 0.55, 0.0) * 0.16 * deltaDays
        let carbonDeficitPenalty = max(-biomassDelta, 0.0) * 0.5
        let healthDrag = ((stressIndex * species.stressPenaltyRate * 0.16) + (heatStress * 0.12) + (coldStress * 0.05)) * deltaDays
        let nextHealth = clamp(
            currentState.healthScore + recoveryBoost - healthDrag - carbonDeficitPenalty,
            minimum: 0.0,
            maximum: 1.0
        )

        let nextAgeDays = currentState.ageDays + deltaDays
        let normalizedSize = sqrt(nextBiomass / species.maxBiomassProxy)
        let targetSize = normalizedSize * species.maxSizeIndex
        let sizeAdjustment = (targetSize - currentState.sizeIndex) * min(deltaDays * 2.0, 1.0)
        let nextSize = clamp(
            currentState.sizeIndex + sizeAdjustment,
            minimum: 0.05,
            maximum: species.maxSizeIndex
        )
        let nextLowHealthDuration = nextHealth < criticalHealthThreshold
            ? currentState.lowHealthDurationHours + deltaHours
            : 0
        let dailyGrowthRate = biomassDelta / deltaDays

        if nextLowHealthDuration > deathPersistenceHours {
            return PlantState(
                ageDays: nextAgeDays,
                sizeIndex: max(nextSize * 0.96, 0.05),
                biomassProxy: max(nextBiomass * 0.97, 0.02),
                healthScore: 0,
                stage: .dead,
                lastGrowthRate: dailyGrowthRate,
                lowHealthDurationHours: nextLowHealthDuration
            )
        }

        let nextStage = species.stageThresholds.stage(forAgeDays: nextAgeDays, biomassProxy: nextBiomass)

        return PlantState(
            ageDays: nextAgeDays,
            sizeIndex: nextSize,
            biomassProxy: nextBiomass,
            healthScore: nextHealth,
            stage: nextStage,
            lastGrowthRate: dailyGrowthRate,
            lowHealthDurationHours: nextLowHealthDuration
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

    private func geometricMean(_ values: [Double]) -> Double {
        guard !values.isEmpty else {
            return 0
        }

        let clampedValues = values.map { clamp($0, minimum: 0.0001, maximum: 1.0) }
        let product = clampedValues.reduce(1.0, *)
        return pow(product, 1.0 / Double(clampedValues.count))
    }

    private func temperatureRespirationMultiplier(value: Double, preferredRange: TargetRange) -> Double {
        let midpoint = preferredRange.midpoint
        let q10Scaled = pow(2.0, (value - midpoint) / 10.0)
        return clamp(q10Scaled, minimum: 0.35, maximum: 6.0)
    }

    private func upperDeviation(value: Double, preferredRange: TargetRange) -> Double {
        guard value > preferredRange.maximum else {
            return 0
        }

        return clamp((value - preferredRange.maximum) / preferredRange.span, minimum: 0.0, maximum: 1.0)
    }

    private func lowerDeviation(value: Double, preferredRange: TargetRange) -> Double {
        guard value < preferredRange.minimum else {
            return 0
        }

        return clamp((preferredRange.minimum - value) / preferredRange.span, minimum: 0.0, maximum: 1.0)
    }

    private func clamp(_ value: Double, minimum: Double, maximum: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}
