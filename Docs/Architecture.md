# Architecture

## Intent

GreenhouseTwin `v0.3` is an immersive research prototype rather than a polished product release. The design goal is to keep domain and simulation logic plain, testable, and reusable while validating a readable visionOS spatial UI around that core.

## Layers

### Domain

- Stable model vocabulary for greenhouse layout, plant definitions, environment state, and runtime snapshots
- No UI or RealityKit dependencies
- Designed to remain readable to human collaborators and future coding agents

### Simulation

- Deterministic discrete-time stepping with a default cadence of one simulated hour
- Scenario-driven environment values instead of control-system or HVAC physics
- Proxy plant-growth logic based on photosynthesis gain, respiration cost, and stress penalties

### SampleData

- One small research baseline dataset with two zones, two species, and four plants
- Explicitly mock inputs that make it easy to iterate on simulation and presentation without real hardware

### Presentation

- A compact SwiftUI control window stays available outside the immersive space
- `GreenhouseExperienceViewModel` owns playback, reset, snapshot stepping, focus state, and lightweight history buffers
- Floating SwiftUI panels consume derived summary data instead of embedding simulation rules

### Spatial

- Immersive RealityKit rendering still uses generated primitives
- Zone blocks and plant markers are schematic placeholders, not final geometry
- SwiftUI attachments are anchored near greenhouse entities to validate data-to-3D mapping and spatial readability

## State flow

1. `ResearchBaseline` creates the greenhouse definition, species presets, scenario, and initial snapshot.
2. `AppModel` owns a single `GreenhouseExperienceViewModel`.
3. `GreenhouseExperienceViewModel` advances `GreenhouseSnapshot` through `GreenhouseSimulator`.
4. The control window, floating panels, and RealityKit scene all render directly from the current snapshot.

## Why this stays simple

- No networking, persistence, or cloud services
- No protocol-heavy abstraction layers
- No attempt to present the simulation as a full scientific greenhouse model
- No photoreal greenhouse geometry, backend integration, or production hardware assumptions
