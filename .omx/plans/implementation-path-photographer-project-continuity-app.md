# Implementation Path: Photographer Project Continuity App

## Metadata

- Slug: `photographer-project-continuity-app`
- Created at: `2026-04-15T12:55:00Z`
- Source requirements: `.omx/specs/deep-interview-production-implementation-path.md`
- Related functional spec: `.omx/plans/functional-spec-photographer-project-continuity-app.md`
- Related tech architecture: `.omx/plans/tech-architecture-photographer-project-continuity-app.md`
- Related data schema draft: `.omx/plans/data-schema-photographer-project-continuity-app.md`

## Purpose

这不是任务清单，也不是产品分期计划。

这份文档回答的是：

- 当前原型工程如何进入生产实现
- 什么能力链应先被做“真”
- 各层实现应以什么顺序替换原型
- 哪些模块当前明确保持原型状态
- 每推进一层，怎样判断它已经达到“生产实现”的标准

## North Star

整个应用从原型进入生产实现的目标，不是“先把所有页面都做完”，而是：

`先把核心创作主链做成可靠的正式能力，再逐步把外围能力从原型替换为真实实现。`

这里的“核心创作主链”已经明确为：

1. 项目新增
2. 结构配置
   - 添加章节
   - 添加元素
3. 整理
   - 上传照片
   - 配置所属章节 / 元素
   - 配置关系

## Implementation Philosophy

### 1. Replace behavior, not pages

当前页面骨架已经具备。

真正需要被“实现”的，不是再做一套新页面，而是让当前页面从：

- prototype 展示态

变成：

- 真实状态驱动
- 真实数据落库
- 真实业务规则生效

也就是说，实现路径优先替换的是：

- 状态
- 数据
- 业务规则
- 页面 glue code

而不是重新设计界面。

### 2. Preserve current UI/UX as contract

当前工程已经跑出来的 UI/UX 是唯一真相源。

因此：

- 页面结构不重做
- 交互路径不重做
- 正式实现必须嵌入现有页面，而不是推翻它们

### 3. Prioritize the narrowest valuable chain

不要从“全应用”开始做真。

实现时必须沿着最短但最有价值的用户链推进：

`创建项目 -> 建章节 -> 建元素 -> 上传照片 -> 关联章节/元素 -> 配置关系`

只要这条链先稳定下来，应用就已经从“展示原型”变成“真正能工作的创作工具”。

## What Becomes Real First

### A. Project creation becomes real first

这是所有后续能力的锚点。

为什么必须先做：

- 没有项目实体，就没有主题、结构和后续所有挂接的容器
- 结构、元素、照片、关系都必须归属于项目
- 当前工程中的新建项目页已经存在，最适合从这里替换 prototype 状态

它进入真实实现后，至少应具备：

- 表单状态与校验
- 创建项目实体
- 本地持久化
- 成功创建后回到结构页并加载该项目上下文

### B. Structure configuration becomes real second

结构配置包括两条能力：

- 添加章节
- 添加元素

为什么第二步就做它：

- 它直接定义后续整理时的挂接目标
- 没有章节和元素，上传照片只是素材收集，不是创作系统
- 当前结构页已经是整个应用的默认首页，非常适合作为核心工作区

它进入真实实现后，至少应具备：

- 章节新增 / 编辑 / 排序
- 元素新增 / 编辑 / 状态管理
- 元素归属于章节
- 当前结构页真正从数据库读取内容，而不是使用 mock 数据

### C. Curation becomes real third

整理是第一条完整业务闭环的完成点。

为什么放在第三步：

- 它依赖项目、章节、元素先存在
- 它是把照片真正纳入创作结构的动作
- 它是从“原型页”变成“生产工具”的决定性一步

它进入真实实现后，至少应具备：

- 本地照片导入
- 照片记录入库
- 选择所属章节
- 多选关联元素
- 点击关系后选择关联照片
- 结果持久化

## What Must Stay Prototype For Now

在核心主链做通之前，这些模块明确保持原型：

### 1. Capture feed

理由：

- 它很重要，但不是第一条生产闭环必需
- 如果过早引入，会把“正式照片导入”和“现场信息流”两条链同时拉起，复杂度过高

### 2. Timeline

理由：

- 它依赖大量真实事件数据
- 如果核心链还没有真实事件产生，先做 timeline 只会重复搭原型

### 3. Beacon

理由：

- 它属于任务组织与执行辅助能力
- 不先解决核心创作数据链，就很难判断它需要消费哪些真实状态

### 4. Settings

理由：

- 它当前没有原型页
- 而且对主链无阻塞
- 保留目录和入口即可

## Engineering Replacement Order

这部分不是任务步骤，而是“替换层”的顺序。

### Layer 1: Local persistence primitives

先建立：

- 项目表
- 章节表
- 元素表
- 照片表
- 关系挂接表 / 字段

注意：

- 不要在这个阶段把 capture feed、timeline、settings 的 schema 一起做复杂
- 只实现当前主链真正需要的持久化事实

### Layer 2: Repository / use case interfaces

在有最小 schema 后，建立当前主链需要的接口：

- createProject
- listProjects / getCurrentProject
- createChapter / listChapters / reorderChapters
- createElement / listElements / updateElementStatus
- importPhotos
- linkPhotoToChapter
- linkPhotoToElements
- attachRelationToPhoto

关键要求：

- 接口必须服务当前页面，不要过度抽象成“未来一切都能用”的万能仓储

### Layer 3: State replacement inside existing pages

把页面里的 mock 状态逐步换成真实状态：

- 新建项目页：从 local controller -> real createProject
- 结构页：从 hardcoded mock -> repository-backed state
- 整理页：从 local selection demo -> real curation state

原则：

- 页面布局不变
- 只替换数据来源和事件处理

### Layer 4: Validation / error handling / empty states

当主链已经能“走通”后，再补：

- 表单校验
- 导入失败处理
- 空状态
- 数据异常提示

这些不应先于主链真实化。

## Implementation Path by User Journey

### Journey 1: Create project

目标：
- 用户可以真的创建项目，而不是只经过一个向导页面

完成标准：
- 创建后本地落库
- 返回结构页时已加载新项目
- 结构页上下文真实切换

### Journey 2: Add chapters and elements

目标：
- 结构页中的章节和元素变成可持续编辑的真实数据

完成标准：
- 新增后立即可见
- 重启应用后仍存在
- 章节与元素关系正确保存

### Journey 3: Curate photos into structure

目标：
- 整理页能把真实照片挂进真实章节/元素

完成标准：
- 照片导入成功
- 章节关联可保存
- 元素多选可保存
- 关系入口可用，并能绑定到一张真实照片

## Quality Gates

每一条能力进入“生产实现”时，至少应满足这些门槛：

### Functional gate

- 真数据流通
- 真状态更新
- 真持久化

### Recovery gate

- 失败路径可见
- 异常不会导致页面失控
- 重启后状态可恢复

### UI preservation gate

- 当前页面视觉不变
- 当前交互路径不变
- 当前导航节奏不变

### Developer gate

- 页面不直接操作底层存储
- 业务规则不散落在 widget tree
- 每条主链都有可跑的表征测试

## Test Strategy Along the Path

### 1. Characterization tests first

先锁住当前页面表现与核心交互：

- 新建项目入口
- 结构页默认行为
- 整理页核心控件存在

### 2. Replace one behavior at a time

不要一次替换整个页面。

例如：

- 先让项目创建真实化
- 再让结构读取真实化
- 再让照片导入真实化

每换一块，都跑：

- `flutter analyze`
- `flutter test`

### 3. Add narrow persistence assertions

在 UI 测试之外，增加更窄的用例测试：

- 创建项目是否写入
- 添加章节是否持久化
- 元素多选是否保存
- 关系照片关联是否保存

## Risks to Avoid

### Risk 1: Start from too many modules

如果一开始同时做 project / structure / curation / timeline / beacon，会把当前清晰主链重新打散。

### Risk 2: Over-abstract repositories too early

如果为未来所有模块预设计完整仓储体系，主链会变慢，而且接口会失真。

### Risk 3: Mix page cleanup with productionization

如果一边做正式实现，一边顺手整理页面布局，会破坏当前“UI/UX 冻结”的边界。

### Risk 4: Let prototype data survive too long

如果 project 已经真实化，但 structure / curation 还在继续大量依赖 mock，就会出现混合态，难以判断问题归属。

## Recommended Document Shape

后续真正写“实现路径文档”时，最适合采用这种结构：

1. 当前状态
2. 北极星目标
3. 主链优先顺序
4. 各层替换顺序
5. 延后模块说明
6. 质量门槛
7. 风险与避免方式

这样它会是“实现路径”，而不是“任务分解表”。

## Recommendation

下一步最合适进入：

`$ralplan`

目标：
- 基于这份 spec 正式写出实现路径文档
- 而不是继续问需求或直接开工实现
