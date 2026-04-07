import RealityKit
import SwiftUI
import UIKit

struct GreenhouseSpatialOverview: View {
    let viewModel: GreenhouseExperienceViewModel

    @State
    private var sceneState = SpatialSceneState()

    var body: some View {
        RealityView { content, attachments in
            sceneState.installIfNeeded(in: &content, greenhouse: viewModel.greenhouse)
            sceneState.applySnapshot(viewModel.snapshot, greenhouse: viewModel.greenhouse)
            sceneState.applyAttachments(using: attachments, greenhouse: viewModel.greenhouse, activePlantPanelID: viewModel.activePlantPanelID)
        } update: { _, attachments in
            sceneState.applySnapshot(viewModel.snapshot, greenhouse: viewModel.greenhouse)
            sceneState.applyAttachments(using: attachments, greenhouse: viewModel.greenhouse, activePlantPanelID: viewModel.activePlantPanelID)
        } attachments: {
            Attachment(id: GreenhouseSpatialIDs.globalControlAttachment) {
                GlobalControlPanel(
                    model: viewModel.globalControlModel,
                    density: .spatial,
                    onTogglePlayback: viewModel.togglePlayback,
                    onStep: viewModel.step,
                    onReset: viewModel.reset
                )
            }

            if viewModel.zonePanelModels.indices.contains(0) {
                let model = viewModel.zonePanelModels[0]
                Attachment(id: GreenhouseSpatialIDs.zoneAttachment(zoneID: model.id)) {
                    ZoneClimatePanel(model: model)
                }
            }
            if viewModel.zonePanelModels.indices.contains(1) {
                let model = viewModel.zonePanelModels[1]
                Attachment(id: GreenhouseSpatialIDs.zoneAttachment(zoneID: model.id)) {
                    ZoneClimatePanel(model: model)
                }
            }
            if viewModel.zonePanelModels.indices.contains(2) {
                let model = viewModel.zonePanelModels[2]
                Attachment(id: GreenhouseSpatialIDs.zoneAttachment(zoneID: model.id)) {
                    ZoneClimatePanel(model: model)
                }
            }
            if viewModel.zonePanelModels.indices.contains(3) {
                let model = viewModel.zonePanelModels[3]
                Attachment(id: GreenhouseSpatialIDs.zoneAttachment(zoneID: model.id)) {
                    ZoneClimatePanel(model: model)
                }
            }
            if viewModel.zonePanelModels.indices.contains(4) {
                let model = viewModel.zonePanelModels[4]
                Attachment(id: GreenhouseSpatialIDs.zoneAttachment(zoneID: model.id)) {
                    ZoneClimatePanel(model: model)
                }
            }
            if viewModel.zonePanelModels.indices.contains(5) {
                let model = viewModel.zonePanelModels[5]
                Attachment(id: GreenhouseSpatialIDs.zoneAttachment(zoneID: model.id)) {
                    ZoneClimatePanel(model: model)
                }
            }

            if viewModel.plantPanelModels.indices.contains(0) {
                let model = viewModel.plantPanelModels[0]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(1) {
                let model = viewModel.plantPanelModels[1]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(2) {
                let model = viewModel.plantPanelModels[2]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(3) {
                let model = viewModel.plantPanelModels[3]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(4) {
                let model = viewModel.plantPanelModels[4]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(5) {
                let model = viewModel.plantPanelModels[5]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(6) {
                let model = viewModel.plantPanelModels[6]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(7) {
                let model = viewModel.plantPanelModels[7]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(8) {
                let model = viewModel.plantPanelModels[8]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(9) {
                let model = viewModel.plantPanelModels[9]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(10) {
                let model = viewModel.plantPanelModels[10]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
            if viewModel.plantPanelModels.indices.contains(11) {
                let model = viewModel.plantPanelModels[11]
                Attachment(id: GreenhouseSpatialIDs.plantAttachment(plantID: model.id)) {
                    PlantDataPanel(model: model)
                }
            }
        }
        .gesture(
            SpatialEventGesture()
                .onChanged(handleSpatialEvents(_:))
                .onEnded(handleSpatialEvents(_:))
        )
        .simultaneousGesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { gesture in
                    guard let plantID = sceneState.plantID(for: gesture.entity) else {
                        return
                    }

                    viewModel.togglePinnedPlant(plantID)
                }
        )
    }

    private func handleSpatialEvents(_ events: SpatialEventCollection) {
        if let activePlantID = events
            .reversed()
            .compactMap({ sceneState.plantID(for: $0.targetedEntity) })
            .first {
            viewModel.setFocusedPlant(activePlantID)
            return
        }

        let endedWithoutPlant = events.contains { event in
            event.targetedEntity == nil || sceneState.plantID(for: event.targetedEntity) == nil
        }

        if endedWithoutPlant, viewModel.pinnedPlantID == nil {
            viewModel.clearTransientFocus()
        }
    }
}

@MainActor
private final class SpatialSceneState {
    private let floorDepth: Float = 4.8
    private let floorWidth: Float = 5.2
    private let globalControlScale: Float = 0.92
    private let zonePanelScale: Float = 0.92
    private let plantPanelScale: Float = 0.86

    private var root: Entity?
    private var globalControlAnchor: Entity?
    private var zoneBeds: [String: ModelEntity] = [:]
    private var zonePanelAnchors: [String: Entity] = [:]
    private var plantMarkers: [String: ModelEntity] = [:]
    private var plantPanelAnchors: [String: Entity] = [:]

    func installIfNeeded(in content: inout RealityViewContent, greenhouse: Greenhouse) {
        guard root == nil else {
            return
        }

        let sceneRoot = Entity()
        sceneRoot.name = GreenhouseSpatialIDs.sceneRoot

        let floor = ModelEntity(
            mesh: .generateBox(size: SIMD3<Float>(floorWidth, 0.06, floorDepth)),
            materials: [SimpleMaterial(color: UIColor(white: 0.16, alpha: 1.0), isMetallic: false)]
        )
        floor.position = [0, -0.03, -2.1]
        sceneRoot.addChild(floor)

        let walkway = ModelEntity(
            mesh: .generateBox(size: SIMD3<Float>(1.0, 0.02, floorDepth - 0.7)),
            materials: [SimpleMaterial(color: UIColor(white: 0.32, alpha: 1.0), isMetallic: false)]
        )
        walkway.position = [0, 0.02, -2.1]
        sceneRoot.addChild(walkway)

        let controlAnchor = Entity()
        controlAnchor.name = GreenhouseSpatialIDs.globalControlAnchor
        controlAnchor.position = [0, 1.16, -0.72]
        sceneRoot.addChild(controlAnchor)
        globalControlAnchor = controlAnchor

        for zone in greenhouse.zones {
            let zoneRoot = Entity()
            zoneRoot.name = GreenhouseSpatialIDs.zoneRoot(zoneID: zone.id)
            zoneRoot.position = zonePosition(for: zone)

            let bedSize = zoneBedSize(for: zone)
            let bed = ModelEntity(
                mesh: .generateBox(size: SIMD3<Float>(bedSize.x, 0.18, bedSize.y)),
                materials: [SimpleMaterial(color: UIColor(red: 0.32, green: 0.55, blue: 0.33, alpha: 1.0), isMetallic: false)]
            )
            bed.name = GreenhouseSpatialIDs.zoneEntity(zoneID: zone.id)
            bed.position = [0, 0.09, 0]
            zoneRoot.addChild(bed)
            zoneBeds[zone.id] = bed

            let zonePanelAnchor = Entity()
            zonePanelAnchor.name = GreenhouseSpatialIDs.zonePanelAnchor(zoneID: zone.id)
            zonePanelAnchor.position = [
                zone.layout.centerX < 0.5 ? (bedSize.x / 2.0) + 0.24 : -(bedSize.x / 2.0) - 0.24,
                1.12,
                -0.06
            ]
            zoneRoot.addChild(zonePanelAnchor)
            zonePanelAnchors[zone.id] = zonePanelAnchor

            for plant in greenhouse.plants where plant.zoneID == zone.id {
                let plantRoot = Entity()
                plantRoot.name = GreenhouseSpatialIDs.plantRoot(plantID: plant.id)
                plantRoot.position = plantLocalPosition(for: plant, in: zone, bedSize: bedSize)

                let marker = ModelEntity(
                    mesh: .generateSphere(radius: 0.12),
                    materials: [SimpleMaterial(color: UIColor.green, isMetallic: false)]
                )
                marker.name = GreenhouseSpatialIDs.plantEntity(plantID: plant.id)
                marker.position = [0, 0.16, 0]
                marker.components.set(InputTargetComponent())
                marker.components.set(HoverEffectComponent())
                marker.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.18)]))
                plantRoot.addChild(marker)
                plantMarkers[plant.id] = marker

                let panelAnchor = Entity()
                panelAnchor.name = GreenhouseSpatialIDs.plantPanelAnchor(plantID: plant.id)
                panelAnchor.position = [
                    zone.layout.centerX < 0.5 ? 0.42 : -0.42,
                    0.58,
                    0.06
                ]
                plantRoot.addChild(panelAnchor)
                plantPanelAnchors[plant.id] = panelAnchor

                zoneRoot.addChild(plantRoot)
            }

            sceneRoot.addChild(zoneRoot)
        }

        root = sceneRoot
        content.add(sceneRoot)
    }

    func applySnapshot(_ snapshot: GreenhouseSnapshot, greenhouse: Greenhouse) {
        for zone in greenhouse.zones {
            guard let bed = zoneBeds[zone.id] else {
                continue
            }

            let environment = snapshot.zoneEnvironments[zone.id]
            setMaterial(
                for: bed,
                color: zoneColor(for: environment, targets: zone.targets)
            )
        }

        for plant in greenhouse.plants {
            guard
                let marker = plantMarkers[plant.id],
                let state = snapshot.plantStates[plant.id]
            else {
                continue
            }

            let scale = max(0.65, 0.75 + (Float(state.sizeIndex) * 0.95))
            marker.scale = SIMD3<Float>(repeating: scale)
            marker.position.y = 0.12 * scale + 0.08
            setMaterial(for: marker, color: plantColor(for: state))
        }
    }

    func applyAttachments(
        using attachments: RealityViewAttachments,
        greenhouse: Greenhouse,
        activePlantPanelID: String?
    ) {
        if
            let globalControlAnchor,
            let controlAttachment = attachments.entity(for: GreenhouseSpatialIDs.globalControlAttachment)
        {
            attach(controlAttachment, to: globalControlAnchor, scale: globalControlScale)
        }

        for zone in greenhouse.zones {
            guard
                let anchor = zonePanelAnchors[zone.id],
                let attachment = attachments.entity(for: GreenhouseSpatialIDs.zoneAttachment(zoneID: zone.id))
            else {
                continue
            }

            attach(attachment, to: anchor, scale: zonePanelScale)
        }

        for plant in greenhouse.plants {
            let attachmentID = GreenhouseSpatialIDs.plantAttachment(plantID: plant.id)
            guard let attachment = attachments.entity(for: attachmentID) else {
                continue
            }

            if plant.id == activePlantPanelID, let anchor = plantPanelAnchors[plant.id] {
                attach(attachment, to: anchor, scale: plantPanelScale)
            } else {
                attachment.removeFromParent()
                attachment.isEnabled = false
            }
        }
    }

    func plantID(for entity: Entity?) -> String? {
        var currentEntity = entity

        while let current = currentEntity {
            if let plantID = GreenhouseSpatialIDs.plantID(fromEntityName: current.name) {
                return plantID
            }
            currentEntity = current.parent
        }

        return nil
    }

    private func attach(_ attachment: ViewAttachmentEntity, to anchor: Entity, scale: Float) {
        if attachment.parent !== anchor {
            anchor.addChild(attachment)
        }

        attachment.position = .zero
        attachment.scale = SIMD3<Float>(repeating: scale)
        attachment.isEnabled = true
    }

    private func setMaterial(for entity: ModelEntity, color: UIColor) {
        guard var model = entity.model else {
            return
        }

        model.materials = [SimpleMaterial(color: color, isMetallic: false)]
        entity.model = model
    }

    private func zonePosition(for zone: GreenhouseZone) -> SIMD3<Float> {
        let laneCenterX: Float = zone.layout.centerX < 0.5 ? -1.3 : 1.3
        let laneOffset = zone.layout.centerX < 0.5
            ? Float((zone.layout.centerX / 0.5) - 0.5)
            : Float(((zone.layout.centerX - 0.5) / 0.5) - 0.5)

        return [
            laneCenterX + (laneOffset * 0.35),
            0,
            -2.0 + (Float(zone.layout.centerZ - 0.5) * 1.5)
        ]
    }

    private func zoneBedSize(for zone: GreenhouseZone) -> SIMD2<Float> {
        SIMD2<Float>(
            max(1.0, Float(zone.layout.width) * 2.6),
            max(2.2, Float(zone.layout.depth) * 3.4)
        )
    }

    private func plantLocalPosition(for plant: Plant, in zone: GreenhouseZone, bedSize: SIMD2<Float>) -> SIMD3<Float> {
        let x = (Float(plant.position.x) - 0.5) * (bedSize.x * 0.78)
        let z = (Float(plant.position.z) - 0.5) * (bedSize.y * 0.82)
        return [x, 0, z]
    }

    private func zoneColor(for environment: EnvironmentState?, targets: EnvironmentTargets) -> UIColor {
        guard let environment else {
            return UIColor(red: 0.32, green: 0.55, blue: 0.33, alpha: 1.0)
        }

        let drift = max(
            targets.temperatureC.normalizedDeviation(from: environment.temperatureC),
            targets.lightPPFD.normalizedDeviation(from: environment.lightPPFD),
            targets.substrateMoisturePercent.normalizedDeviation(from: environment.substrateMoisturePercent)
        )
        let normalizedDrift = min(max(drift, 0), 1)

        let red = 0.22 + ((0.78 - 0.22) * normalizedDrift)
        let green = 0.62 + ((0.38 - 0.62) * normalizedDrift)
        let blue = 0.36 + ((0.22 - 0.36) * normalizedDrift)

        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }

    private func plantColor(for state: PlantState) -> UIColor {
        let stageColor: UIColor

        switch state.stage {
        case .seedling:
            stageColor = UIColor(red: 0.54, green: 0.78, blue: 0.35, alpha: 1.0)
        case .vegetative:
            stageColor = UIColor(red: 0.27, green: 0.66, blue: 0.28, alpha: 1.0)
        case .flowering:
            stageColor = UIColor(red: 0.92, green: 0.78, blue: 0.36, alpha: 1.0)
        case .fruiting:
            stageColor = UIColor(red: 0.88, green: 0.42, blue: 0.25, alpha: 1.0)
        case .harvestable:
            stageColor = UIColor(red: 0.67, green: 0.31, blue: 0.20, alpha: 1.0)
        case .dead:
            stageColor = UIColor(red: 0.36, green: 0.36, blue: 0.38, alpha: 1.0)
        }

        return stageColor.withAlphaComponent(CGFloat(max(state.healthScore, 0.35)))
    }
}
