import Foundation

enum GreenhouseSpatialIDs {
    static let immersiveSpaceID = AppModel.immersiveSpaceID
    static let sceneRoot = "scene.root"
    static let globalControlAnchor = "anchor.globalControl"
    static let globalControlAttachment = "attachment.globalControl"

    static func zoneRoot(zoneID: String) -> String {
        "zone.root.\(zoneID)"
    }

    static func zoneEntity(zoneID: String) -> String {
        "zone.entity.\(zoneID)"
    }

    static func zonePanelAnchor(zoneID: String) -> String {
        "zone.panelAnchor.\(zoneID)"
    }

    static func zoneAttachment(zoneID: String) -> String {
        "zone.attachment.\(zoneID)"
    }

    static func plantRoot(plantID: String) -> String {
        "plant.root.\(plantID)"
    }

    static func plantEntity(plantID: String) -> String {
        "plant.entity.\(plantID)"
    }

    static func plantPanelAnchor(plantID: String) -> String {
        "plant.panelAnchor.\(plantID)"
    }

    static func plantAttachment(plantID: String) -> String {
        "plant.attachment.\(plantID)"
    }

    static func plantID(fromEntityName name: String) -> String? {
        extract(suffixFrom: name, prefix: "plant.entity.")
    }

    private static func extract(suffixFrom name: String, prefix: String) -> String? {
        guard name.hasPrefix(prefix) else {
            return nil
        }

        return String(name.dropFirst(prefix.count))
    }
}
