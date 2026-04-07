# GreenhouseTwin

GreenhouseTwin is a window-first visionOS research app for a greenhouse digital twin. This v1 foundation focuses on clear domain modeling, a deterministic simulation loop, lightweight sample data, and a minimal RealityKit overview that can expand later without restructuring the repo.

## Current scope

- SwiftUI dashboard for greenhouse and plant state
- Simplified plant growth simulation driven by scenario-based environment inputs
- Minimal RealityKit spatial overview for zones and plant markers
- Unit tests for core simulation behaviors

## Repo map

- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/App`: app composition and root model
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Domain`: pure model vocabulary
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Simulation`: deterministic simulation logic
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/SampleData`: mock greenhouse layouts, species presets, and scenarios
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Presentation`: dashboard view model and SwiftUI window UI
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin/Spatial`: minimal RealityKit rendering
- `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwinTests`: unit tests
- `/Users/mike/Desktop/GreenhouseTwin/Docs`: architecture notes and next steps

## Running

Open `/Users/mike/Desktop/GreenhouseTwin/GreenhouseTwin.xcodeproj` in Xcode and run the `GreenhouseTwin` scheme against a visionOS simulator. The app does not require Vision Pro hardware, networking, or backend services.
