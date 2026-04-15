# Flutter Modules and Directory Plan: Photographer Project Continuity App

## Metadata

- Slug: `photographer-project-continuity-app`
- Created at: `2026-04-13T12:34:41Z`
- Related Tech Architecture: `.omx/plans/tech-architecture-photographer-project-continuity-app.md`
- Related IA: `.omx/plans/ia-photographer-project-continuity-app.md`
- Related Low-Fi: `.omx/plans/lowfi-photographer-project-continuity-app.md`

## Goal

为纯移动端、单机单设备的 Flutter App 定义一套可长期维护的模块边界和目录结构，避免项目在早期就退化为：

- `screens/` + `widgets/` + `services/` 大杂烩
- Provider / Riverpod 状态四处散落
- 页面直接访问数据库
- 功能边界不清，后续难以扩展

## Module Design Principles

1. Feature first  
   先按业务能力拆模块，而不是按技术类型把所有页面、模型、仓储堆在一起。

2. Domain stays stable  
   页面会变，交互会变，但 `Project / StructureNode / Element / Photo` 这套核心对象和规则应尽量稳定。

3. UI never talks to storage directly  
   Widget 和页面不能直接操作 SQLite 或媒体访问层。

4. Single-device means less indirection  
   既然没有账号、没有同步、没有后端，就不需要预埋 auth、network、sync 这些空层。

5. Shared only when truly shared  
   不要为了“看起来架构化”过早抽象 shared。

6. Capture feed is a first-class feature  
   “外拍先记一笔，回家再补正式照片”不是临时交互，而是核心业务能力。

## Recommended Top-Level Layout

建议 `lib/` 目录按下面组织：

```text
lib/
  app/
    app.dart
    router/
    theme/
    bootstrap/

  core/
    constants/
    errors/
    utils/
    logging/
    permissions/

  shared/
    widgets/
    models/
    providers/

  features/
    capture_feed/
    project/
    structure/
    element/
    photo_import/
    curation/
    timeline/
    notes/

  data/
    db/
    repositories/
    media/
    cache/

  domain/
    entities/
    value_objects/
    repositories/
    services/
    use_cases/
```

## Why This Shape

这个结构的意图是：

- `features/` 承载页面和产品能力
- `domain/` 承载核心规则和用例
- `data/` 承载 SQLite、媒体导入和缓存
- `app/` 承载应用启动、路由和主题
- `core/` 放真正跨全局的基础能力

这样既不会过度工程化，也不会让所有东西都堆在 UI 层。

## app Layer

### Responsibility

负责：

- App 入口
- 全局主题
- 路由
- 启动时初始化
- 全局错误处理接线

### Suggested Structure

```text
app/
  app.dart
  bootstrap/
    bootstrap.dart
  router/
    app_router.dart
    route_names.dart
  theme/
    app_theme.dart
```

### Notes

- 路由层只负责导航，不负责业务判断
- 如果第一版导航简单，可以不用过重的声明式路由方案

## core Layer

### Responsibility

仅放真正跨模块的基础设施：

- 常量
- 通用错误
- 日志
- 权限判断
- 通用工具

### Suggested Structure

```text
core/
  constants/
  errors/
    app_error.dart
  logging/
    app_logger.dart
  permissions/
    media_permissions.dart
  utils/
    date_utils.dart
    id_utils.dart
```

### Important Constraint

不要把所有“懒得归类”的代码都丢进 `core/`。

## shared Layer

### Responsibility

只放跨多个 feature 重复出现且明显稳定的 UI 或轻量模型。

可放：

- 通用页面壳
- 通用按钮、卡片、标签
- 通用空状态组件
- 少量跨模块轻量 view model

不应放：

- 业务仓储
- 项目核心实体
- 页面专属组件

### Suggested Structure

```text
shared/
  widgets/
    app_scaffold.dart
    section_card.dart
    empty_state.dart
    loading_view.dart
  providers/
    selected_project_provider.dart
```

## domain Layer

这是最关键的一层。

### Responsibility

负责：

- 核心实体
- 值对象
- 仓储接口
- 领域服务
- 用例

### Suggested Structure

```text
domain/
  entities/
    project.dart
    capture_entry.dart
    structure_node.dart
    element.dart
    photo_item.dart
    note.dart
    timeline_event.dart

  value_objects/
    element_status.dart
    relation_tag.dart
    project_stage.dart

  repositories/
    project_repository.dart
    capture_entry_repository.dart
    structure_repository.dart
    element_repository.dart
    photo_repository.dart
    note_repository.dart
    timeline_repository.dart

  services/
    timeline_event_factory.dart
    capture_entry_merge_service.dart
    element_completion_service.dart
    photo_linking_service.dart

  use_cases/
    create_project.dart
    create_capture_entry.dart
    append_to_capture_entry.dart
    add_structure_node.dart
    add_element.dart
    import_photos_to_project.dart
    auto_attach_photos_to_capture_entries.dart
    link_photo_to_structure.dart
    link_photo_to_element.dart
    mark_element_completed.dart
    add_project_note.dart
    load_project_overview.dart
    load_timeline.dart
```

### Domain Rules to Preserve

- `StructureNode` 与 `Element` 严格分开
- `CaptureEntry` 是独立对象，不与 Note 或 Photo 混成一个超级记录
- `RelationTag` 是轻量属性，不是独立关系实体
- 一个元素可以被多张照片支撑
- 没有用户实体，没有账号边界

## data Layer

### Responsibility

负责：

- SQLite schema 与迁移
- Repository 实现
- 媒体资源导入
- 缩略图生成
- 本地缓存

### Suggested Structure

```text
data/
  db/
    app_database.dart
    tables/
    mappers/
    migrations/

  repositories/
    drift_project_repository.dart
    drift_structure_repository.dart
    drift_element_repository.dart
    drift_photo_repository.dart
    drift_note_repository.dart
    drift_timeline_repository.dart

  media/
    media_picker_service.dart
    thumbnail_service.dart
    metadata_reader.dart

  cache/
    thumbnail_cache.dart
```

### Important Rule

`data/` 是实现层，不能反过来把数据库模型泄漏到 UI。

## features Layer

这是用户可见能力的组织方式。

建议拆成这些 feature：

### 1. `capture_feed`

负责：

- 外拍信息流节点
- 快速文字记录
- 快速拍照记录
- 临时从相册选图
- 10 分钟内自动合并逻辑
- 正式导入照片与信息流节点的自动关联和手动修正

### 2. `project`

负责：

- 项目主页
- 项目创建 / 编辑
- 项目概览加载

建议目录：

```text
features/project/
  presentation/
    pages/
      project_home_page.dart
      create_project_page.dart
      edit_project_page.dart
    widgets/
    providers/
  application/
```

### 3. `structure`

负责：

- 结构页中的结构部分
- 结构节点创建
- 结构详情
- 排序调整

### 4. `element`

负责：

- 元素页中的元素部分
- 元素创建
- 元素详情
- 元素完成状态管理

说明：
- `structure` 和 `element` 可以共享一个上层页面入口，但模块内部仍应分开

### 5. `photo_import`

负责：

- 从相册 / 文件选择照片
- 创建待整理照片记录
- 读取基础元数据

### 6. `curation`

这是 MVP 最关键的 feature。

负责：

- 整理页
- 信息流节点与正式照片的连接上下文
- 单张照片挂接
- 结构选择
- 元素选择
- 关系属性选择
- 消项动作
- 当前照片相关创作想法

### 7. `timeline`

负责：

- 时间线列表
- 时间线筛选
- 事件详情

### 8. `notes`

负责：

- 项目层想法记录
- 照片相关想法记录

如果第一版规模很小，也可以把 `notes` 临时并入 `curation`，但数据模型仍应保留独立实体。

## Feature Internal Shape

每个 feature 建议统一形状：

```text
features/<feature_name>/
  presentation/
    pages/
    widgets/
    providers/
  application/
    controllers/
    view_models/
```

说明：

- `presentation/` 放页面与组件
- `application/` 放该 feature 的协调逻辑
- 真正的业务规则仍放在 `domain/`

## Riverpod Usage Boundary

建议用 Riverpod，但边界要清楚：

### Good Uses

- 页面级状态
- 当前筛选
- 当前选中照片
- 当前整理上下文
- 从 use case 拉取的异步数据

### Avoid

- 把领域规则写进 provider
- 在 provider 里直接写 SQL
- 用 provider 代替实体和 use case

## Recommended Main Screens Mapping

```text
项目主页        -> features/project
外拍信息流      -> features/capture_feed
结构页          -> features/structure + features/element
整理页          -> features/capture_feed + features/curation + features/photo_import + features/notes
创作时间线      -> features/timeline
```

## Bootstrap Sequence

建议启动顺序：

1. 初始化 Flutter binding
2. 初始化本地日志
3. 初始化 SQLite / drift
4. 初始化媒体权限状态
5. 注入 repositories 与 use cases
6. 启动 app

## Dependency Direction

必须保持：

```text
features -> domain
features -> shared
data -> domain
app -> features
app -> core
```

必须避免：

```text
domain -> features
domain -> data
shared -> feature-specific code
presentation -> sqlite
```

## Anti-Slop Rules

1. 不创建 `auth/`、`account/`、`sync/` 模块
2. 不创建无意义的 `base_service.dart`、`base_repository.dart`
3. 不为每个页面机械生成 controller / service / repository 三件套
4. 不把结构和元素糊成一个 `content_item`
5. 不把外拍信息流偷偷塞回 `notes` 里当作临时补丁
6. 不提前设计云端 DTO

## Next Step Recommendation

下一步适合继续做：

1. SQLite schema 草案
2. drift tables 与 migration 规划
3. `curation` feature 的页面状态机
