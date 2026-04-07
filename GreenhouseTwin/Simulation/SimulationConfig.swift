import Foundation

struct SimulationConfig: Hashable, Sendable {
    var defaultStepHours: Double
    var playbackIntervalSeconds: Double
    var retainedSnapshotLimit: Int

    static let researchDefault = SimulationConfig(
        defaultStepHours: 1,
        playbackIntervalSeconds: 1.0,
        retainedSnapshotLimit: 48
    )
}
