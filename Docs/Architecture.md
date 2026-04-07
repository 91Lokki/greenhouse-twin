# Architecture

## Intent

GreenhouseTwin v1 is structured as a research foundation rather than a polished product demo. The design goal is to keep domain and simulation logic plain, testable, and reusable while still giving the project a spatial UI surface that is appropriate for visionOS.

## Layers

### Domain

- Stable model vocabulary for greenhouse layout, plant definitions, environment state, and runtime snapshots
- No UI or RealityKit dependencies
- Designed to remain readable to human collaborators and future coding agents

### Simulation

- Deterministic discrete-time stepping with a default cadence of one simulated hour
- Scenario-driven environment values instead of control-system or HVAC physics
- Proxy plant-growth logic based on temperature, light, and moisture response factors

### SampleData

- One small research baseline dataset with two zones, two species, and four plants
- Explicitly mock inputs that make it easy to iterate on simulation and presentation without real hardware

### Presentation

- Dashboard-oriented SwiftUI window UI
- `DashboardViewModel` owns playback, reset, and snapshot stepping
- Views consume derived summary data instead of embedding simulation rules

### Spatial

- Minimal RealityKit rendering using generated primitives
- Zone blocks and plant markers are schematic placeholders, not final geometry
- The goal is to validate data-to-3D mapping early without committing to immersive scope

## State flow

1. `ResearchBaseline` creates the greenhouse definition, species presets, scenario, and initial snapshot.
2. `AppModel` owns a single `DashboardViewModel`.
3. `DashboardViewModel` advances `GreenhouseSnapshot` through `GreenhouseSimulator`.
4. SwiftUI dashboard sections and the RealityKit overview render directly from the current snapshot.

## Why this stays simple

- No networking, persistence, or cloud services
- No protocol-heavy abstraction layers
- No attempt to present the simulation as a full scientific greenhouse model
- No immersive or hardware-specific features in v1
