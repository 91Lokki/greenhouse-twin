import Observation

enum ImmersivePhase: Equatable {
    case closed
    case opening
    case open
    case error(String)

    var statusText: String {
        switch self {
        case .closed:
            return "Immersive space is closed."
        case .opening:
            return "Opening immersive greenhouse..."
        case .open:
            return "Immersive greenhouse is active."
        case .error(let message):
            return message
        }
    }
}

@MainActor
@Observable
final class AppModel {
    static let immersiveSpaceID = "greenhouse-immersive-space"

    let experienceViewModel: GreenhouseExperienceViewModel
    var immersivePhase: ImmersivePhase = .closed

    init() {
        experienceViewModel = GreenhouseExperienceViewModel(study: ResearchBaseline.study)
    }

    init(study: GreenhouseStudy) {
        experienceViewModel = GreenhouseExperienceViewModel(study: study)
    }

    func markImmersiveOpening() {
        immersivePhase = .opening
    }

    func markImmersiveOpen() {
        immersivePhase = .open
    }

    func markImmersiveClosed() {
        immersivePhase = .closed
    }

    func markImmersiveError(_ message: String) {
        immersivePhase = .error(message)
    }
}
