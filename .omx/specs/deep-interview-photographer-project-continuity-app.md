# Deep Interview Spec: Photographer Project Continuity App

## Metadata

- Slug: `photographer-project-continuity-app`
- Generated at: `2026-04-13T11:53:22Z`
- Profile: `standard`
- Rounds: `7`
- Context type: `greenfield`
- Final ambiguity: `0.17`
- Threshold: `0.20`
- Interview transcript: `.omx/interviews/photographer-project-continuity-app-20260413T115322Z.md`
- Context snapshot: `.omx/context/photographer-project-continuity-app-20260413T111113Z.md`

## Clarity Breakdown

| Dimension | Score |
| --- | ---: |
| Intent | 0.92 |
| Outcome | 0.86 |
| Scope | 0.83 |
| Constraints | 0.82 |
| Success | 0.68 |

Readiness gates:
- Non-goals: explicit
- Decision boundaries: explicit
- Pressure pass: complete

## Intent

为长期摄影项目提供一个“天生结构化”的创作系统，让摄影师能把零散灵感持续组织回项目叙事，避免在数月到一年以上的创作周期中逐步偏离主题，或遗漏本应构成作品的关键元素与关系。

核心不是“记录”，而是“把创作线索收束成一个持续成形的摄影作品”。

## Desired Outcome

摄影师可以围绕一个摄影项目逐步维护：

- 主题
- 结构
- 元素
- 关系
- 照片
- 创作过程中的文字想法

并且在任何阶段都能直观看到：

- 这个项目现在的整体结构是什么
- 哪些元素已经被满足，哪些还未完成
- 哪些照片在呼应、对比、重复或支撑某些结构
- 整个项目是如何随时间演化的

## Core Product Thesis

Word、Markdown、普通笔记的问题不是不能记，而是随着项目拉长，它们会逐步失去结构，最后需要靠作者自己不断维护秩序。

这个产品的价值在于：

- 结构是原生的，不靠后期手动整理文档秩序
- 摄影项目的关键对象和关系是第一等公民
- 长期使用后仍能保持清晰，不会退化成混乱文本堆

## In Scope

第一版应该覆盖以下核心能力：

1. 项目主题定义
2. 项目结构定义
   - 结构可以是顺序型
   - 结构也可以是零散型
3. 元素定义
   - 一个元素可以由一张或多张照片共同满足
4. 关系定义
   - 例如对比、呼应、重复、转折
5. 照片导入到项目
6. 摄影师手动将照片与结构、元素、关系挂接
7. 手动消项
   - 元素可被逐步完成
   - 关系也可被逐步满足
8. 创作想法记录
   - 现场快速文字记录
   - 回家后补充关联思路
9. 项目展示视图
   - 结构、元素、关系的总览
   - 创作历程时间线

## Out of Scope / Non-goals

第一版明确不做：

- 照片编辑 / 修图
- 云盘备份
- 客户管理
- 作品发布
- 通用笔记系统
- 拍摄参数管理
- AI 自动选片
- 社交协作

补充边界：

- 不是 Lightroom 替代品
- 不是文件管理器
- 不是为了泛化所有摄影工作流

## Decision Boundaries

工具不能替摄影师做这些判断：

- 是否偏题
- 哪张照片更“正确”
- 哪个元素是否真正成立
- 哪种呼应、对比、转折在创作上是否有效

工具可以做的仅是：

- 提供结构化容器
- 提供挂接与消项机制
- 提供项目整体可视化
- 保留时间线与创作过程痕迹

原则：
- 创作判断权始终属于摄影师
- 工具服务于主观判断，不干预主观判断

## Key Constraints

### Workflow constraint

产品必须支持双阶段工作流：

1. 外拍阶段
   - 只允许低摩擦采集
   - 主要是录入照片和短文字
2. 回家整理阶段
   - 才进行结构化挂接、消项、补关系与创作整理

### Complexity constraint

用户愿意投入整理时间，但不能接受高认知负担。

第一版只应保留这些可接受动作：

- 导入照片
- 消项元素
- 关联元素
- 必要的编辑
- 写创作阶段想法
- 关联思路

用户不能接受：

- 复杂多步骤流程
- 录入前必须先搭建复杂系统
- 过多页面跳转
- 比 Word/Markdown 更重的维护成本

## Information Model

建议将以下对象作为一等公民建模：

- `Project`
  - 主题
  - 描述
  - 时间范围
- `StructureNode`
  - 章节、段落、片段、组块，既可顺序也可非顺序
- `Element`
  - 项目中需要反复出现或被完成的视觉/叙事对象
- `Relation`
  - 对比、呼应、重复、转折等
- `Photo`
  - 项目内候选照片
- `Note`
  - 现场灵感、回家整理时的思路
- `TimelineEvent`
  - 创作推进的重要事件

关键关系：

- `Photo -> StructureNode`
- `Photo -> Element`
- `Photo -> Relation`
- `Element -> StructureNode`
- `Relation -> StructureNode`
- `Note -> Project / Element / Relation / Photo`

## Minimal Viable Loop

MVP 不是“管理所有照片”，而是完成这一条闭环：

1. 创建一个摄影项目并定义主题
2. 定义该项目的结构
3. 为项目列出若干元素
4. 定义若干关系
5. 外拍时快速录入照片和文字
6. 回家后把照片挂到结构、元素和关系上
7. 通过手动消项看到项目逐步成形
8. 最终看到一个兼具结构视图与时间线视图的作品演化面板

## Testable Acceptance Criteria

若第一版成功，至少应满足：

1. 摄影师可以在一个项目中定义“主题、结构、元素、关系”这四层对象。
2. 摄影师可以导入照片，并手动把照片关联到结构、元素、关系中的任意一层或多层。
3. 摄影师可以对元素和关系进行“已满足 / 已完成”式消项。
4. 摄影师可以在外拍时快速记录照片和文字，而不需要进入复杂整理流程。
5. 摄影师回家后可以在一个清晰界面里完成挂接与整理，而不是在多个分散页面中来回跳转。
6. 项目可以展示结构、元素、关系的整体状态，而不仅是文本列表。
7. 项目可以展示创作时间线，让用户回看作品如何逐步形成。
8. 用户在 3 个月后仍能维持项目秩序，不会像 Word/Markdown 那样退化成难以整理的长文档。

## Success Criteria

最关键的产品成功信号不是“功能多”，而是以下体验是否成立：

- 项目更连贯
- 项目更直观
- 长期创作中不容易失去主题
- 摄影师更容易知道作品还缺什么
- 比 Word/Markdown 更结构化，但不比它们更复杂

## Assumptions Exposed + Resolutions

### Assumption 1

“全部由摄影师手动判断”是否会导致工具太重？

Resolution:
- 现场与整理分离
- 现场只做低摩擦采集
- 整理阶段承担结构化工作

### Assumption 2

“天生结构化”是否会让系统比 Word/Markdown 更复杂？

Resolution:
- 第一版严格限制在创作构思闭环
- 不做通用笔记、资产管理、修图、发布等扩展能力
- 交互必须围绕导入、挂接、消项、记录思路这几个核心动作

## Recommended MVP Shape

更适合的第一版形态不是“完整摄影平台”，而是：

`轻量但高度结构化的摄影项目创作工作台`

它应该具备：

- 一个项目主页
- 一个结构/元素/关系总览板
- 一个照片导入与挂接面板
- 一个时间线 / 创作历程视图

它不应该具备：

- 多余模块堆叠
- 大而全的摄影工作流覆盖
- 复杂权限和多人协作逻辑

## Residual Risks

- 如果结构、元素、关系的建模过于抽象，用户初次创建项目时会卡住。
- 如果挂接流程需要过多点击，用户会回退到 Word/Markdown。
- 如果总览可视化不够直观，产品最关键的差异化会消失。
- 如果照片导入体验不好，用户不会形成稳定工作流。

## Next Planning Focus

建议下一步在 `ralplan` / PRD 阶段优先解决：

1. 首屏信息架构
2. 项目对象模型与关系设计
3. 外拍采集流与回家整理流的界面分离
4. “消项”交互的表现形式
5. 结构视图与时间线视图的最小 UI
6. MVP 是否优先做桌面端还是 Web 端
