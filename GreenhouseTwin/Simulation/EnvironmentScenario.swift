import Foundation

struct EnvironmentScenario: Identifiable, Hashable, Sendable {
    let id: String
    var name: String
    var summary: String
    var sunriseHour: Double
    var sunsetHour: Double
    var zoneProfiles: [String: ZoneEnvironmentProfile]

    func environment(for zone: GreenhouseZone, at timestamp: Date) -> EnvironmentState {
        let profile = zoneProfiles[zone.id] ?? ZoneEnvironmentProfile.fallback(for: zone.targets)
        let hour = Self.hourOfDay(for: timestamp)
        let daylight = daylightFactor(at: hour)
        let moistureRetention = moistureRetentionFactor(at: hour, irrigationHour: profile.irrigationHour)

        let environment = EnvironmentState(
            timestamp: timestamp,
            temperatureC: interpolate(night: profile.nightTemperatureC, day: profile.dayTemperatureC, factor: daylight),
            relativeHumidityPercent: interpolate(night: profile.nightRelativeHumidityPercent, day: profile.dayRelativeHumidityPercent, factor: daylight),
            co2PPM: interpolate(night: profile.nightCO2PPM, day: profile.dayCO2PPM, factor: daylight),
            lightPPFD: interpolate(night: profile.nightLightPPFD, day: profile.peakLightPPFD, factor: daylight),
            substrateMoisturePercent: interpolate(
                night: profile.minimumSubstrateMoisturePercent,
                day: profile.maximumSubstrateMoisturePercent,
                factor: moistureRetention
            )
        )

        return environment.clamped()
    }

    private static func hourOfDay(for timestamp: Date) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone(abbreviation: "UTC") ?? .current

        let hour = calendar.component(.hour, from: timestamp)
        let minute = calendar.component(.minute, from: timestamp)
        return Double(hour) + (Double(minute) / 60.0)
    }

    private func daylightFactor(at hour: Double) -> Double {
        guard sunriseHour < sunsetHour, hour >= sunriseHour, hour <= sunsetHour else {
            return 0
        }

        let progress = (hour - sunriseHour) / (sunsetHour - sunriseHour)
        return sin(progress * .pi)
    }

    private func moistureRetentionFactor(at hour: Double, irrigationHour: Double) -> Double {
        let hoursSinceIrrigation = wrappedHours(from: irrigationHour, to: hour)
        let normalizedDecay = min(max(hoursSinceIrrigation / 24.0, 0), 1)
        return 1.0 - normalizedDecay
    }

    private func wrappedHours(from startHour: Double, to endHour: Double) -> Double {
        let delta = endHour - startHour
        return delta >= 0 ? delta : delta + 24.0
    }

    private func interpolate(night: Double, day: Double, factor: Double) -> Double {
        night + ((day - night) * factor)
    }
}

struct ZoneEnvironmentProfile: Hashable, Sendable {
    var dayTemperatureC: Double
    var nightTemperatureC: Double
    var dayRelativeHumidityPercent: Double
    var nightRelativeHumidityPercent: Double
    var dayCO2PPM: Double
    var nightCO2PPM: Double
    var peakLightPPFD: Double
    var nightLightPPFD: Double
    var maximumSubstrateMoisturePercent: Double
    var minimumSubstrateMoisturePercent: Double
    var irrigationHour: Double

    static func fallback(for targets: EnvironmentTargets) -> ZoneEnvironmentProfile {
        ZoneEnvironmentProfile(
            dayTemperatureC: targets.temperatureC.midpoint + 1.0,
            nightTemperatureC: targets.temperatureC.midpoint - 2.0,
            dayRelativeHumidityPercent: targets.relativeHumidityPercent.midpoint - 5.0,
            nightRelativeHumidityPercent: targets.relativeHumidityPercent.midpoint + 5.0,
            dayCO2PPM: targets.co2PPM.midpoint + 30.0,
            nightCO2PPM: targets.co2PPM.midpoint - 20.0,
            peakLightPPFD: targets.lightPPFD.maximum,
            nightLightPPFD: 0,
            maximumSubstrateMoisturePercent: targets.substrateMoisturePercent.maximum,
            minimumSubstrateMoisturePercent: targets.substrateMoisturePercent.minimum,
            irrigationHour: 6.0
        )
    }
}
