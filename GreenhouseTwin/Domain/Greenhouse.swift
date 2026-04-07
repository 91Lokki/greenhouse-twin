import Foundation

struct Greenhouse: Identifiable, Hashable, Sendable {
    let id: String
    var name: String
    var description: String
    var zones: [GreenhouseZone]
    var plants: [Plant]

    func zone(id: String) -> GreenhouseZone? {
        zones.first { $0.id == id }
    }

    func plant(id: String) -> Plant? {
        plants.first { $0.id == id }
    }
}

struct GreenhouseZone: Identifiable, Hashable, Sendable {
    let id: String
    var name: String
    var description: String
    var layout: ZoneLayout
    var targets: EnvironmentTargets
}

struct ZoneLayout: Hashable, Sendable {
    var originX: Double
    var originZ: Double
    var width: Double
    var depth: Double

    var centerX: Double {
        originX + (width / 2.0)
    }

    var centerZ: Double {
        originZ + (depth / 2.0)
    }
}

struct EnvironmentTargets: Hashable, Sendable {
    var temperatureC: TargetRange
    var relativeHumidityPercent: TargetRange
    var co2PPM: TargetRange
    var lightPPFD: TargetRange
    var substrateMoisturePercent: TargetRange
}

struct TargetRange: Hashable, Sendable {
    var minimum: Double
    var maximum: Double

    init(_ minimum: Double, _ maximum: Double) {
        self.minimum = Swift.min(minimum, maximum)
        self.maximum = Swift.max(minimum, maximum)
    }

    var midpoint: Double {
        (minimum + maximum) / 2.0
    }

    var span: Double {
        max(maximum - minimum, 0.0001)
    }

    func contains(_ value: Double) -> Bool {
        minimum...maximum ~= value
    }

    func clamped(_ value: Double) -> Double {
        min(max(value, minimum), maximum)
    }

    func normalizedDeviation(from value: Double) -> Double {
        guard !contains(value) else {
            return 0
        }

        let distance = value < minimum ? minimum - value : value - maximum
        return distance / span
    }
}
