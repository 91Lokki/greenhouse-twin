# Next Steps

## Simulation refinement

- Replace the current weighted-response growth model with better crop-specific heuristics or literature-backed parameters.
- Introduce richer zone-level dynamics such as irrigation events, setpoint changes, or disturbance scenarios.
- Separate observed data from simulated state once real greenhouse measurements are available.

## Data integration

- Add a thin adapter layer for ingesting CSV logs, local JSON fixtures, or future sensor feeds.
- Keep ingestion outside the simulation core so the domain model stays reusable in tests and previews.

## Spatial visualization

- Replace schematic boxes and spheres with better greenhouse geometry only after the data mapping is stable.
- Improve attachment readability with distance-aware scaling, better occlusion handling, and cleaner comparative panels.
- Add richer annotations and spatial drill-downs on top of the current immersive foundation instead of rebuilding the scene model again.

## Research and portfolio value

- Keep assumptions documented so the project is honest about model limitations.
- Favor incremental commits that show architecture, test coverage, and reasoning quality over visual spectacle.
