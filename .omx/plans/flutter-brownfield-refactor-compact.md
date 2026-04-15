# Brownfield Flutter Refactor Plan

## Requirements Summary
- Keep current UI/UX as the single source of truth with no intentional visual, copy, interaction, or navigation changes.
- Refactor only architecture and file structure from `lib/features/prototype/prototype_shell_page.dart`.
- Target top-level feature groups:
  - `项目`
  - `章节元素关系` with `chapters`, `elements`, `relations`
  - `整理`
  - `历程`
  - `信标`
  - `设置` reserved only for now

## Evidence
- Current implementation is a single 3597-line file at `lib/features/prototype/prototype_shell_page.dart`.
- The file currently contains shell state/routing plus page widgets for structure, organize, beacon, timeline, overlay, sidebar, wizard, and shared UI primitives.

## Implementation Steps
1. Freeze behavior with characterization/widget tests around shell routing, overlay/sidebar behavior, and first extracted page before each move.
2. Extract shared shell concerns first into stable boundaries:
   - shell page/state
   - navigation/tab enum
   - overlay/sidebar coordinators
   - shared prototype data/models used by multiple pages
3. Extract feature pages one by one with no UI edits, wiring each new file back into the same shell:
   - `项目`
   - `章节元素关系` (`chapters`, `elements`, `relations`)
   - `整理`
   - `历程`
   - `信标`
   - `设置` placeholder folder/entry only
4. Move shared leaf widgets/utilities only after their owning page extraction is stable, keeping constructor APIs unchanged until the end.

## Acceptance Criteria
- App behavior and rendered UI remain unchanged for existing prototype flows.
- `prototype_shell_page.dart` is reduced to shell orchestration or replaced by a thin feature-shell entrypoint.
- New folders match the requested top-level feature grouping.
- Each extraction step is covered by characterization/widget tests that pass before and after the move.

## Risks and Mitigations
- Risk: accidental UI drift from renaming props, changing defaults, or moving state ownership.
- Mitigation: extract boundaries without redesign, keep public widget inputs stable, and compare test snapshots/golden behavior per step.

## Verification
- Run Flutter widget/characterization tests for shell navigation, sidebar, overlay, and each extracted page.
- Run formatter, analyzer, and the relevant test subset after every page extraction.
