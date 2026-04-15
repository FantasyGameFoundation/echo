# Technical Architecture: Photographer Project Continuity App

## Metadata

- Slug: `photographer-project-continuity-app`
- Created at: `2026-04-13T12:22:49Z`
- Revised at: `2026-04-13T12:22:49Z`
- Related PRD: `.omx/plans/prd-photographer-project-continuity-app.md`
- Related IA: `.omx/plans/ia-photographer-project-continuity-app.md`
- Related Test Spec: `.omx/plans/test-spec-photographer-project-continuity-app.md`

## Architecture Goal

为 MVP 选择一套能够稳定支撑以下能力的技术架构：

- 纯手机端使用
- iOS / Android 双端原生体验
- 开发阶段以 Android 为主
- 单用户长期使用
- 单机单设备使用
- 项目级结构化创作
- 本地照片导入与整理
- 不依赖网页端和后端服务完成核心闭环
- 不设计账号体系

同时避免：

- 过早引入 Web 端
- 过早引入账号、同步、云存储、协作型后端
- 把第一版做成重型媒体管理平台
- 技术复杂度超过产品当前验证阶段

## Executive Decision

第一版技术架构建议采用：

`纯移动端 + Flutter + 单机本地优先 + 无 Web + 无后端 + 无账号`

具体形态：

- 产品形态：纯手机端 App
- 运行平台：iOS / Android
- 开发主平台：Android 优先
- 客户端技术：`Flutter + Dart`
- 本地存储：`SQLite`
- 照片文件策略：原图保留在设备本地相册或文件系统，应用只保存引用、结构化数据和缓存
- 应用层架构：UI 层 + 用例层 + 领域层 + 本地仓储层
- 服务端策略：MVP 不提供网页端，不提供后端服务
- 身份策略：MVP 不设计账号体系

## Why This Shape

这次架构决策不再基于“桌面整理优先”，而是基于你明确的产品形态要求：

- 这是一个纯手机端产品
- 必须有 iOS / Android 双端体验
- 开发阶段以 Android 为主
- 不需要网页端
- 不需要后端服务
- 不需要账号

在这个前提下，Flutter 是最合理的选择：

- 一套代码同时覆盖 iOS / Android
- 原生感和 UI 一致性可控
- 适合快速迭代产品交互
- 在未来需要补充平台能力时，也能通过 platform channel 或插件接入原生能力

## Product Form Decision

### Recommended Form

纯手机端 App。

首发运行形态：

- Android 首发优先
- 代码结构保持 iOS 可兼容
- 后续补齐 iOS 适配和体验优化

### Explicitly Out of Scope

第一版明确不做：

- Web 端
- 管理后台
- 云同步服务
- 账号系统
- 登录 / 注册
- 协作系统

### Consequence of This Decision

这会带来三个直接影响：

1. 技术架构显著简化  
   不需要 API、对象存储、鉴权、服务端数据库。

2. 产品交互必须重新尊重手机端限制  
   因为结构、元素、照片、时间线都要在小屏上完成呈现和编辑，信息架构和页面布局必须更克制。

3. 数据生命周期被限制在单机单设备内  
   第一版不考虑用户身份、多设备同步、跨设备迁移或云恢复。

## System Overview

```text
+------------------------------------------------------+
|           Mobile App (Flutter / iOS / Android)       |
|                                                      |
|  +--------------------+    +-----------------------+ |
|  | Flutter UI Layer   | -> | Use Case Layer        | |
|  +--------------------+    +-----------------------+ |
|               |                    |                 |
|               v                    v                 |
|      +-------------------------------------------+   |
|      | Domain Services / Repository Interfaces   |   |
|      +-------------------------------------------+   |
|               |                    |                 |
|      +----------------+    +----------------------+  |
|      | SQLite DB      |    | Device Media / Cache |  |
|      +----------------+    +----------------------+  |
+------------------------------------------------------+
```

## Technology Stack

### App Framework

- `Flutter`
- `Dart`

理由：

- 适合纯移动端产品
- 支持 iOS / Android 双端
- 保持较强的原生体验一致性
- 在产品探索阶段迭代效率高

### State Management

建议：

- `Riverpod`

理由：

- 适合中等复杂度到高复杂度状态组织
- 有利于把 UI 状态、用例状态和数据依赖明确拆开
- 比直接在 Widget 树里散落状态更稳

### Local Database

建议：

- `SQLite`
- Flutter 侧使用 `drift` 作为首选访问层

理由：

- 关系型结构适合表达项目、结构、元素、照片与挂接关系
- `drift` 的类型安全和迁移能力适合长期维护

如果你后面更偏极简，也可以退到：

- `sqflite`

但从长期可维护性看，我更推荐 `drift`。

### File and Media Access

建议能力：

- 设备相册 / 文件系统选择器
- 本地缩略图缓存
- 设备权限管理

典型插件方向：

- 图片选择：`photo_manager` 或 `image_picker`
- 文件路径：按平台能力选择合适插件
- 本地路径管理：`path_provider`

这里先定“能力方向”，不把插件名写死到不可更换。

## Layered Architecture

建议采用 4 层：

### 1. Presentation Layer

负责：

- 页面渲染
- Widget 组合
- 表单与交互
- 页面内导航
- 局部反馈

不负责：

- 直接读写 SQLite
- 直接处理媒体导入业务
- 编排复杂领域规则

### 2. Use Case Layer

负责：

- 组织完整用户动作
- 协调仓储读写
- 派发生命周期事件

典型用例：

- 创建项目
- 编辑项目主题
- 创建结构节点
- 创建元素
- 导入照片到项目
- 为照片添加文字
- 挂接照片到结构节点
- 挂接照片到元素
- 设置关系属性
- 对元素消项
- 记录创作想法
- 生成时间线事件

### 3. Domain Layer

负责：

- 项目核心规则
- 结构与元素的边界约束
- 元素完成状态的规则
- 时间线派生规则

关键约束：

- `StructureNode` 与 `Element` 不能混用
- `Relation` 第一版只作为挂接属性存在
- 一个元素可由多张照片共同满足
- 没有后端时，本地数据库是唯一事实源

### 4. Infrastructure Layer

负责：

- SQLite 持久化
- 图片选择与导入
- 缩略图生成与缓存
- 本地日志
- 权限请求

## State Strategy

建议把状态分成三类：

### 1. UI State

例如：

- 当前选中的项目
- 当前打开的 Tab
- 当前选中的照片
- 当前筛选条件
- 当前是否处于批量整理模式

### 2. Screen / Flow State

例如：

- 一次导入流程的临时状态
- 一次挂接流程的暂存结果
- 正在编辑的元素消项状态

### 3. Persistent State

例如：

- 项目
- 结构节点
- 元素
- 照片
- 笔记
- 时间线事件
- 挂接记录

原则：

- Widget 不直接依赖数据库实现
- 所有持久化操作通过仓储接口完成

## Data Storage Strategy

### Source of Truth

`SQLite` 作为本地唯一事实源。

原因：

- 完全符合单用户、单机单设备、本地优先、无后端、无账号的产品要求
- 能稳定表达结构化对象和轻量关系
- 支持长期项目数据积累

### Photo Storage Policy

第一版不把原图存进数据库。

建议策略：

- 原图保留在设备本地相册或文件系统
- 应用数据库只存引用、项目映射和必要元数据
- 应用自己维护缩略图缓存目录

这样做的好处：

- 避免数据库暴涨
- 避免重复存储大文件
- 更符合手机端存储现实

### Cache Strategy

本地缓存可包含：

- 缩略图
- 预览图
- 最近打开项目索引

缓存原则：

- 缓存可再生
- SQLite 才是结构化事实源
- 原图仍归设备本地存储管理

## Suggested Data Model

### Core Tables

- `projects`
- `structure_nodes`
- `elements`
- `photos`
- `notes`
- `timeline_events`

### Link Tables

- `photo_structure_links`
- `photo_element_links`

### Relation Attribute Strategy

关系属性先作为挂接记录的字段或轻量 JSON 存储，而不是独立关系表。

例如：

- `photo_structure_links.relation_tags`
- `photo_element_links.relation_tags`

原因：

- 保持第一版建模克制
- 避免 UI 和数据层同时过重
- 后续若关系模型升级，仍有迁移空间

### Minimal Field Direction

`projects`
- id
- title
- theme_statement
- description
- stage
- created_at
- updated_at

`structure_nodes`
- id
- project_id
- title
- description
- sort_order
- parent_id

`elements`
- id
- project_id
- structure_node_id nullable
- title
- description
- status
- created_at

`photos`
- id
- project_id
- source_uri
- imported_at
- taken_at nullable
- note_text nullable
- thumbnail_path nullable

`notes`
- id
- project_id
- photo_id nullable
- body
- note_type
- created_at

`timeline_events`
- id
- project_id
- event_type
- related_entity_type
- related_entity_id
- payload_json
- created_at

## Import Pipeline

### Import Flow

1. 用户从设备相册或文件选择器选择照片
2. 系统读取资源引用
3. 系统创建基础照片记录
4. 后台生成缩略图与基础元数据
5. 照片进入待整理状态

### Design Rule

导入流程必须异步，不阻塞用户继续录入或切换页面。

### Extractable Metadata

第一版只建议提取最小必要元数据：

- 资源引用
- 导入时间
- 拍摄时间
- 基础尺寸信息

不建议第一版深做：

- 拍摄参数分析
- 图像识别
- 自动元素推荐

## Timeline Architecture

时间线应由真实用户行为自动派生，不单独做一套复杂系统。

建议写入事件：

- 导入照片
- 创建结构节点
- 创建元素
- 对元素消项
- 写下创作想法
- 调整结构

这样可以保证时间线是“创作过程的结果”，而不是额外维护的日志。

## Offline Strategy

### MVP Strategy

MVP 默认完全离线可用。

这是一个硬原则，因为：

- 没有后端服务
- 没有网页端
- 单用户本地创作是主要场景
- 产品明确是单机单设备 app

### Device Boundary

MVP 是单机单设备应用。

也就是说第一版默认不处理：

- 多设备数据同步
- 云端备份
- 用户账号迁移
- 登录状态
- 跨设备恢复

如果未来一定要补同步或账号，应作为新阶段重新规划，而不是在第一版里预埋复杂度。

## Security and Privacy Direction

第一版以本地隐私为核心。

建议原则：

- 不上传照片
- 不默认联网
- 不依赖第三方云服务
- 权限只在需要时申请

重点注意：

- Android 相册 / 文件访问权限差异
- iOS 媒体库权限模型
- 单机单设备前提下，本地数据丢失风险需要明确由产品边界承担

## Performance Considerations

重点优化对象：

- 大量照片导入
- 缩略图生成
- 项目总览查询
- 页面切换流畅度
- 长列表滚动

建议策略：

- 所有列表优先显示缩略图
- 缩略图生成走后台任务
- 列表与网格都做懒加载
- 重计算和大查询不放在 UI 主线程
- 长操作放 isolate 或原生侧能力处理

## Logging and Diagnostics

MVP 不需要云监控，但至少需要本地可诊断能力：

- 导入失败日志
- 权限请求失败日志
- 数据迁移日志
- 缩略图生成失败日志
- 崩溃恢复提示

这部分可以落到：

- 本地日志文件
- 开发阶段调试面板

## Platform Strategy

### Android First

开发与验证阶段以 Android 为主。

原因：

- 开发调试链路更直接
- 便于快速迭代 MVP

### iOS Compatibility Rule

虽然 Android 优先，但架构与插件选择不能写死 Android-only 方案。

必须确保：

- 数据层与业务层平台无关
- 媒体访问能力可以兼容 iOS
- UI 交互不要强依赖 Android 特定控件逻辑

## Alternatives Considered

### Option A: Flutter Mobile-first Local-first

优点：

- 完全符合纯手机端要求
- 双端可共享主代码
- 无需后端即可交付 MVP

缺点：

- 小屏承载信息密度有限
- 结构化整理交互需要更谨慎设计

结论：
- 选用

### Option B: React Native

优点：

- 跨平台移动端可行

缺点：

- 与 Flutter 相比，对统一 UI 体验和高一致性交互控制略弱
- 既然你已明确希望采用 Flutter，就没有继续权衡的必要

结论：
- 不选

### Option C: Desktop-first App

优点：

- 更适合高密度整理工作面

缺点：

- 与当前产品形态要求冲突
- 不符合“纯手机端 App”的方向

结论：
- 不选

### Option D: Web + Backend

优点：

- 多设备访问与未来协作更容易

缺点：

- 与“无网页端、无后端服务”的目标冲突
- 与“单机单设备、无账号”的目标冲突
- 明显增加 MVP 工程复杂度

结论：
- 不选

## ADR

### Decision

采用 `Flutter + Dart + SQLite` 的纯移动端、单机本地优先技术架构，MVP 不提供网页端，不提供后端服务，也不设计账号体系。

### Drivers

- 产品明确要求纯手机端
- 必须支持 iOS / Android 双端
- Flutter 能提供较好的双端原生体验
- 单用户本地创作是核心场景
- 单机单设备已经足够满足第一版需求
- 必须控制第一版工程复杂度

### Alternatives Considered

- React Native | 不如 Flutter 符合当前明确要求
- Desktop-first | 与产品形态冲突
- Web + Backend | 与“无网页端、无后端、无账号”冲突

### Why Chosen

这套架构最贴合你当前的产品目标，没有任何为了未来可能性而提前背上的系统复杂度。

### Consequences

- 第一版开发路径清晰
- 数据与照片完全本地化
- 数据被明确限定在当前设备内
- 需要在手机小屏上更谨慎地处理信息密度和交互复杂度
- 后续如果补同步，将是新的产品阶段，而不是第一版遗留问题

### Follow-ups

1. 下一步要把 IA 和低保真骨架重新压缩为移动端版本
2. 再下一步明确 Flutter 模块结构、状态管理边界和数据库 schema
3. 需要尽早验证“结构/元素/照片挂接”在小屏上的可操作性
