## Task Statement

基于当前已经完成的 Flutter 原型工程与页面拆分结构，开始规划“脱离原型阶段、以生产环境为目标和标准实现”的完整实现路径文档。

## Desired Outcome

得到一份面向正式实现的“实现路径文档”，说明后续应如何从当前原型工程推进到生产质量应用。该文档不是任务清单，而是实现顺序、能力分层、依赖关系、质量门槛与风险控制的说明。

## Stated Solution

参考当前原型页、现有工程结构、功能文档和技术架构文档，规划一份生产实现路径，而不是继续讨论原型页结构。

## Probable Intent Hypothesis

用户认为原型阶段已经基本结束，接下来最需要的是“正式实现的路线图逻辑”，用来指导后续从 UI 原型逐步替换成真实数据、状态管理、持久化、导入链路和业务规则实现。

## Known Facts / Evidence

- 当前工程已经拆成 `app/shell + features/*` 结构。
- 当前 UI/UX 以“当前工程跑出来的效果”为唯一真相源。
- 现有页面多数仍是 prototype 实现，但已经具备完整骨架。
- 功能文档、技术架构文档、数据 schema 草案都已存在于 `.omx/plans/`。
- 技术前提已确定为：Flutter + 单机单设备 + 本地优先 + 无账号 + 无后端。
- 用户现在明确要求输出“实现路径文档”，而不是任务计划。
- 用户明确说“不分 MVP 或任何项目阶段”，但实现路径本身仍需要合理排序。

## Constraints

- 不能把文档写成简单任务清单。
- 必须面向生产质量标准，而不是原型质量。
- 当前工程是 brownfield，不能忽视已有代码和现有页面结构。
- 需要考虑实现顺序，但不能直接套用“MVP/阶段1/阶段2”这种产品分期语言。

## Unknowns / Open Questions

- 在生产实现中，哪条能力链应该最先被拉到真实可用标准。
- 用户对“生产标准”的首要关注点是什么：稳定性、数据可靠性、导入性能、离线能力、交互一致性、可维护性，还是其他。
- 实现路径文档最终更偏“按能力域推进”还是“按工程层推进”。

## Decision-Boundary Unknowns

- leader 是否可以自行定义正式实现的先后顺序。
- leader 是否可以用“能力优先级 / 依赖顺序”来替代产品分期语言。

## Likely Codebase Touchpoints

- `/Users/erjiguan/codex_project/echo/lib/app/`
- `/Users/erjiguan/codex_project/echo/lib/features/`
- `/Users/erjiguan/codex_project/echo/.omx/plans/functional-spec-photographer-project-continuity-app.md`
- `/Users/erjiguan/codex_project/echo/.omx/plans/tech-architecture-photographer-project-continuity-app.md`
- `/Users/erjiguan/codex_project/echo/.omx/plans/data-schema-photographer-project-continuity-app.md`
