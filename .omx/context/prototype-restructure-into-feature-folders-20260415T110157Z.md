## Task Statement

基于当前已经基本成型的 Flutter 原型工程，重新构建整个项目架构，把现有原型页拆分到更合理的 feature 目录中，形成可长期维护的工程结构。

## Desired Outcome

得到一份足够清晰的重构目标定义，明确文件夹边界、页面归属、拆分粒度、路由与共享层范围，避免重构过程中目录和职责再次混乱。

## Stated Solution

将页面分组到“项目、章节/元素/关系、整理、历程、信标、设置”等目录中，再把现有原型页按功能拆分进去。

## Probable Intent Hypothesis

用户希望从“单文件原型拼装态”过渡到“真正可维护的 Flutter 工程”，重点不是新增功能，而是先把页面、模块和工程结构稳定下来，为后续继续实现详情页、编辑页和真实业务逻辑做准备。

## Known Facts / Evidence

- 当前工程已经是 brownfield，不是空项目。
- `lib/features/prototype/prototype_shell_page.dart` 目前承载了大量原型页与 glue code。
- 现有 `lib/features/` 下已经有多个预留 feature 目录，但多数还未真正承接页面实现。
- 用户明确表示现有原型页基本够用了，当前重点是“重新构建整个项目工程”。
- 用户给出的分组描述存在歧义：“分为5个文件夹”后又列出“项目、章节/元素/关系、整理、历程、信标、设置”。

## Constraints

- 当前阶段是工程重构，不应大幅重做业务与视觉。
- 需要尽量复用现有原型页成果，而不是全部重写。
- 后续仍需承载详情页、编辑页扩展。

## Unknowns / Open Questions

- `章节/元素/关系` 是一个 folder 还是三个 sibling features。
- “5个文件夹” 与实际列出的组数不一致，最终要以哪个为准。
- `设置` 是独立 feature，还是暂时占位。
- 当前底部导航与页面分组之间，哪些是一一对应，哪些只是 feature 内子页面。
- 是否接受保留 `shared/`、`app/`、`core/` 这类非页面 folder。

## Decision-Boundary Unknowns

- leader 是否可以自行定义 feature 粒度与共享层边界。
- 页面组件拆分到什么程度才算合理。

## Likely Codebase Touchpoints

- `/Users/erjiguan/codex_project/echo/lib/app/`
- `/Users/erjiguan/codex_project/echo/lib/features/`
- `/Users/erjiguan/codex_project/echo/lib/features/prototype/prototype_shell_page.dart`
- `/Users/erjiguan/codex_project/echo/lib/shared/`
