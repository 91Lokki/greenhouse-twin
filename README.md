# GreenhouseTwin

GreenhouseTwin is an early-stage visionOS research prototype for a greenhouse digital twin. The current milestone is `v0.3`: a conservative immersive build that combines plain Swift domain models, a deterministic simulation core, lightweight physiological heuristics, and floating spatial dashboards anchored to greenhouse entities.

## Version status

- `v0.3` is intentionally pre-v1.
- The app is useful as a research and portfolio prototype, but it is still validating architecture, simulation behavior, and immersive UI readability.
- It should not be described as a finished `v1` product baseline yet.

## Current scope

- Compact SwiftUI control window for entering and controlling the immersive experience
- Immersive visionOS scene with attached zone and plant data panels
- Simplified plant growth simulation using photosynthesis vs. respiration heuristics
- Gauge-based climate indicators and short growth-trend history in plant panels
- Unit tests for deterministic simulation, stress response, death transition, and history retention

## Repo map

- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/App`: app composition and root model
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Domain`: pure model vocabulary
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Simulation`: deterministic simulation logic
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/SampleData`: mock greenhouse layouts, species presets, and scenarios
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Presentation`: control window, floating panels, gauges, and trend views
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Spatial`: RealityKit scene, attachment anchoring, and plant/zone panel placement
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwinTests`: unit tests
- `/Users/mike/Desktop/GreenhouseTwin/Docs`: architecture notes and next steps

## Running

Open `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin.xcodeproj` in Xcode and run the `GreenhouseTwin` scheme against a visionOS simulator. The app does not require Vision Pro hardware, networking, or backend services.
