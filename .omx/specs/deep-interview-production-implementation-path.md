# Deep Interview Spec: Production Implementation Path

## Metadata

- Slug: `production-implementation-path`
- Generated at: `2026-04-15T12:41:03Z`
- Profile: `standard`
- Rounds: `2`
- Context type: `brownfield`
- Final ambiguity: `0.16`
- Threshold: `0.20`
- Interview transcript: `.omx/interviews/production-implementation-path-20260415T124100Z.md`
- Context snapshot: `.omx/context/production-implementation-path-20260415T123218Z.md`

## Clarity Breakdown

| Dimension | Score |
| --- | ---: |
| Intent | 0.88 |
| Outcome | 0.84 |
| Scope | 0.84 |
| Constraints | 0.82 |
| Success | 0.72 |
| Context | 0.94 |

Readiness gates:
- Non-goals: explicit
- Decision boundaries: explicit
- Pressure pass: complete

## Intent

在当前原型工程和现有页面基本成型的前提下，开始面向生产标准推进实现，但不是一股脑把所有模块都同时做成正式能力，而是先围绕一条业务主链把底层实现做实。

## Desired Outcome

输出一份“实现路径文档”，说明：

- 现有原型工程如何进入正式实现
- 哪条能力链应优先落地
- 哪些模块在主链完成前继续维持原型
- 技术实现和工程组织应如何逐步替换原型壳

## In-Scope

这份实现路径文档应覆盖：

1. 当前工程从原型到生产实现的总体推进逻辑
2. 正式实现的优先能力链
3. 技术和工程层的替换顺序
4. 每一层能力进入真实实现时的质量门槛
5. 当前哪些模块延后

## Out-of-Scope / Non-goals

在核心主链做通之前，以下能力不进入真实实现：

- 外拍信息流
- 历程
- 信标
- 设置

它们当前保持原型 / 占位状态即可，后续单独介入。

## Decision Boundaries

实现路径文档中，以下事项可以由系统自行组织和排序：

- 用什么结构来表达“实现路径”
- 主链各子能力的技术替换顺序
- 数据层、状态层、页面层、共享层的落地顺序

但必须遵守：

- 不用 MVP / 阶段化产品语言来定义优先级
- 以“能力链先后”来表达推进顺序
- 不把延后模块混入主链实现目标

## Core Priority Chain

先做通的正式实现主链是：

1. 项目新增
2. 结构配置
   - 添加章节
   - 添加元素
3. 整理
   - 上传照片
   - 配置所属章节 / 元素
   - 配置关系

## Brownfield Facts

- 当前工程已经完成了原型工程拆分
- 当前页面表现是唯一真相源
- 技术前提已确定为：Flutter + 单机单设备 + 本地优先 + 无账号 + 无后端
- `structure / curation / timeline / beacon / project wizard / overlay` 等页面都已经接进工程

## Assumptions Exposed + Resolutions

### Assumption 1

“不分阶段”是否意味着所有模块同时正式实现？

Resolution:
- 否
- 可以有明确先后顺序，只是不以 MVP / 阶段化语言来表达

### Assumption 2

`外拍信息流 / 历程 / 信标 / 设置` 是否也要现在同步做真？

Resolution:
- 否
- 在核心主链打通前，保持原型即可

## Testable Acceptance Criteria

一份合格的实现路径文档至少应满足：

1. 明确主链优先顺序：项目新增 -> 结构配置 -> 整理
2. 明确延后能力：外拍信息流 / 历程 / 信标 / 设置
3. 明确从原型工程替换到正式实现的工程层顺序
4. 不使用产品分期语言偷换成 MVP 计划
5. 能指导后续实现而不是停留在抽象原则

## Recommended Handoff

最适合下一步进入：

`$ralplan`

原因：

- 问题已经收敛，不需要继续 interview
- 当前需要的是一份结构化“实现路径文档”
- 这类文档需要架构/依赖顺序/风险控制的明确表达，适合进入共识规划
