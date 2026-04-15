# Deep Interview Spec: Prototype Restructure Into Feature Folders

## Metadata

- Slug: `prototype-restructure-into-feature-folders`
- Generated at: `2026-04-15T11:27:54Z`
- Profile: `standard`
- Rounds: `5`
- Context type: `brownfield`
- Final ambiguity: `0.12`
- Threshold: `0.20`
- Interview transcript: `.omx/interviews/prototype-restructure-into-feature-folders-20260415T112751Z.md`
- Context snapshot: `.omx/context/prototype-restructure-into-feature-folders-20260415T110157Z.md`

## Clarity Breakdown

| Dimension | Score |
| --- | ---: |
| Intent | 0.86 |
| Outcome | 0.84 |
| Scope | 0.92 |
| Constraints | 0.90 |
| Success | 0.82 |
| Context | 0.94 |

Readiness gates:
- Non-goals: explicit
- Decision boundaries: explicit
- Pressure pass: complete

## Intent

将当前“单文件堆积的原型工程”重构成真正可维护的 Flutter 工程结构，为后续详情页、编辑页和业务逻辑持续落地提供稳定边界。

重点不在新增功能，而在于：

- 让页面归属清晰
- 让 feature 边界稳定
- 让共享层与应用层职责合理
- 让后续继续开发不再依赖一个超大原型文件

## Desired Outcome

得到一个按业务功能拆分、文件边界清晰、便于后续扩展的 Flutter 工程结构，同时保持当前应用已呈现的 UI/UX 完全不变。

## In-Scope

本轮允许做：

1. 重新组织 `lib/` 目录
2. 将当前原型页从集中式大文件中拆分到 feature 目录
3. 重组路由和导航组织
4. 抽取共享组件与页面壳
5. 调整 provider / state / 页面私有组件的放置位置
6. 为 `设置` 预留目录与入口

## Out-of-Scope / Non-goals

本轮明确不做：

1. 改现有原型页的视觉表现
2. 改现有页面交互方式
3. 顺手优化现有页面布局
4. 顺手新增业务功能
5. 重新参考 `temp_file` 文件来回退或对齐现有页面

## Decision Boundaries

以下事项可由系统在本轮重构中自行决定：

- 页面文件名和目录名
- 公共组件抽取边界
- 路由组织方式
- state/provider 所在层
- 大页面拆成多少个私有子组件文件

但必须满足：

- 不改变现有 UI
- 不改变现有 UX
- 不改变当前页面呈现结果

## Acceptance Standard

当前工程运行出来的页面效果是唯一真相源。

这意味着：

- 后续不再以 `temp_file` 里的页面文件为验收标准
- 重构后的效果必须和“当前工程跑出来的效果”一致
- 如果两者冲突，以当前工程现状为准

## Folder Plan

本轮重构目标按 6 个主目录规划：

1. `项目`
2. `章节/元素/关系`
3. `整理`
4. `历程`
5. `信标`
6. `设置`

其中：

- `章节/元素/关系` 外层是一个主目录
- 其内部拆成三个子 feature
- `设置` 是独立主目录，但当前阶段可以先预留目录和入口

## Proposed Technical Organization

建议的工程拆分方向：

- `app/`：应用入口、主题、路由和 app-level glue
- `features/project/`
- `features/structure_elements_relations/chapters/`
- `features/structure_elements_relations/elements/`
- `features/structure_elements_relations/relations/`
- `features/curation/`
- `features/timeline/`
- `features/beacon/`
- `features/settings/`
- `shared/`：真正跨页面复用的 UI 组件
- `core/`：通用常量、错误、工具

## Brownfield Facts

- 当前工程已经是 brownfield
- 现有页面与 glue code 主要集中在 `lib/features/prototype/prototype_shell_page.dart`
- 原型页已经基本齐备，只差部分详情页和编辑页
- 重构目标是拆分，不是再做页面设计

## Testable Acceptance Criteria

1. `lib/features/prototype/prototype_shell_page.dart` 不再承担主要页面实现主体
2. 主要页面按 6 个主目录的目标归属被拆开
3. `章节/元素/关系` 主目录内部确实拆成 3 个子 feature
4. `设置` 目录和入口存在，即使当前仍是占位
5. 重构后应用运行效果与当前工程现状一致
6. 重构后 `flutter analyze` 与 `flutter test` 通过

## Assumptions Exposed + Resolutions

### Assumption 1

“以后还要不要继续以 `temp_file` 作为参考基准？”

Resolution:
- 不需要
- 当前工程页面效果是唯一真相源

### Assumption 2

“这轮重构是否允许顺手改页面？”

Resolution:
- 不允许
- 只做工程层拆分

### Assumption 3

“设置页是不是必须现在就完整实现？”

Resolution:
- 不必
- 当前阶段可先预留目录和入口

## Recommended Handoff

最适合下一步进入：

`$ralplan`

原因：

- 需求已经清楚
- 当前是高风险重构任务
- 需要先给出明确的目录迁移计划、路由迁移计划、共享组件拆分策略和验证顺序
- 不应直接实施拆分而没有计划

## Residual Risks

1. 如果页面拆分粒度过粗，会把“大文件问题”换个目录继续保留
2. 如果页面拆分粒度过细，会产生新的工程碎片化
3. 如果没有明确“拆分顺序”，容易在半拆状态打断运行
4. 如果重构过程顺手改了页面，会违反当前最重要的边界
