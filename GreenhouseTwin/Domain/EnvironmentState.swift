import Foundation

struct EnvironmentState: Hashable, Sendable {
    var timestamp: Date
    var temperatureC: Double
    var relativeHumidityPercent: Double
    var co2PPM: Double
    var lightPPFD: Double
    var substrateMoisturePercent: Double

    func clamped() -> EnvironmentState {
        EnvironmentState(
            timestamp: timestamp,
            temperatureC: min(max(temperatureC, -20), 60),
            relativeHumidityPercent: min(max(relativeHumidityPercent, 0), 100),
            co2PPM: min(max(co2PPM, 250), 2_500),
            lightPPFD: min(max(lightPPFD, 0), 1_500),
            substrateMoisturePercent: min(max(substrateMoisturePercent, 0), 100)
        )
    }
}
