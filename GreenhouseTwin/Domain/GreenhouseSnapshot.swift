import Foundation

enum GreenhouseAlertSeverity: Int, CaseIterable, Hashable, Sendable {
    case info = 0
    case warning = 1
    case critical = 2

    var label: String {
        switch self {
        case .info:
            return "Info"
        case .warning:
            return "Warning"
        case .critical:
            return "Critical"
        }
    }
}

struct GreenhouseAlert: Identifiable, Hashable, Sendable {
    let id: String
    var severity: GreenhouseAlertSeverity
    var title: String
    var detail: String
    var sourceID: String
}

struct GreenhouseSnapshot: Hashable, Sendable {
    var timestamp: Date
    var zoneEnvironments: [String: EnvironmentState]
    var plantStates: [String: PlantState]
    var alerts: [GreenhouseAlert]

    func environment(for zoneID: String) -> EnvironmentState? {
        zoneEnvironments[zoneID]
    }

    func plantState(for plantID: String) -> PlantState? {
        plantStates[plantID]
    }

    var averageHealthScore: Double {
        let scores = plantStates.values.map(\.healthScore)
        guard !scores.isEmpty else {
            return 0
        }
        return scores.reduce(0, +) / Double(scores.count)
    }

    var totalBiomassProxy: Double {
        plantStates.values.map(\.biomassProxy).reduce(0, +)
    }
}
