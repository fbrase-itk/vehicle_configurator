# 6. three.js with in-place material updates

Date: 2025-04-02

## Status

Accepted

## Context

Quality Goal 1 demands that the 3D preview responds to option changes
in under 200 ms. Re-loading the GLB on every paint/wheel/caliper change
would introduce visible stalls and flashing.

## Decision

Load the car once on mount and keep the scene alive for the component's
entire lifetime. Store references to the scene, camera, renderer,
controls, and relevant materials / rim meshes as **non-reactive**
instance fields in the Vue component's `created()` hook. Vue `watch`ers
on each prop call small update methods:

- `updateBodyColor()`     — mutates the body material's `color`.
- `updateWheelColor()`    — mutates the wheel material's `color`.
- `updateCaliperColor()`  — mutates the caliper material's `color`.
- `switchWheelDesign()`   — toggles `visible` on `Obj_Rim_T0A` ↔
  `Obj_Rim_T0B` meshes that both ship inside the GLB.

## Consequences

- Every prop change updates the canvas on the next animation frame —
  feels native.
- Vue must NOT wrap three.js objects in reactive proxies (breaks
  `instanceof`, ray-casting, and performance). Storing them in
  `created()` rather than `data()` sidesteps this.
- `CarPreview3D.vue` is unusually long (~870 lines) because material
  and mesh references are discovered once and cached; mitigated by
  explicit method names for each kind of update.
