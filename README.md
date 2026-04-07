# GreenhouseTwin

GreenhouseTwin is a visionOS research prototype for a greenhouse digital twin. It is being built as a maintainable, simulation-first project rather than a flashy demo: the goal is to validate architecture, physiological logic, and spatial data presentation before moving toward real greenhouse integration.

## Current milestone

The current project state is `v0.3`.

`v0.3` is intentionally pre-v1. It is useful as a prototype and portfolio piece, but it is still in the stage of proving:

- the core domain model
- the simulation loop
- the immersive panel UX
- the overall project structure for future expansion

## What the app currently includes

- A visionOS control window for entering and controlling the immersive scene
- An `ImmersiveSpace` with greenhouse zones and plant markers rendered using simple RealityKit primitives
- Floating SwiftUI panels attached to zones and plants
- A simplified plant model using photosynthesis gain, respiration cost, and stress effects
- Climate target gauges for zone panels
- Short growth-trend history for plant panels
- Unit tests for deterministic stepping, stress behavior, death transition, and history retention

## What it does not include yet

- Real sensor ingestion
- Networking, databases, or cloud services
- Detailed greenhouse geometry
- Photoreal plant rendering
- Computer vision or AR reconstruction
- Production-grade crop physiology

## Project structure

- `GreenhouseTwin/App`: app lifecycle and root app state
- `GreenhouseTwin/Domain`: greenhouse, plant, environment, and snapshot models
- `GreenhouseTwin/Simulation`: simulation engine and plant growth logic
- `GreenhouseTwin/SampleData`: mock study data, species presets, and scenario definitions
- `GreenhouseTwin/Presentation`: SwiftUI control window, floating panels, gauges, and trend views
- `GreenhouseTwin/Spatial`: RealityKit scene setup, attachment anchoring, and spatial interaction
- `GreenhouseTwinTests`: unit tests for domain and simulation behavior
- `Docs`: architecture notes and forward-looking project guidance

## Running locally

1. Open `GreenhouseTwin.xcodeproj` in Xcode.
2. Select the `GreenhouseTwin` scheme.
3. Run it on a visionOS simulator.

The project does not require Vision Pro hardware, a backend, or any external services.

## Running tests

Use Xcode’s test action for the `GreenhouseTwin` scheme, or run:

```bash
xcodebuild -project GreenhouseTwin.xcodeproj -scheme GreenhouseTwin -destination 'platform=visionOS Simulator,id=<SIMULATOR-ID>' test
```

## Near-term direction

- Improve spatial dashboard readability and attachment behavior
- Refine physiological heuristics with better research grounding
- Add clearer separation between simulated state and future observed greenhouse data
- Expand the prototype without collapsing domain and simulation logic into the UI layer
