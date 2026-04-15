# Data Schema Draft: Photographer Project Continuity App

## Metadata

- Slug: `photographer-project-continuity-app`
- Created at: `2026-04-13T12:34:41Z`
- Related Tech Architecture: `.omx/plans/tech-architecture-photographer-project-continuity-app.md`
- Related PRD: `.omx/plans/prd-photographer-project-continuity-app.md`

## Goal

定义 MVP 的本地 SQLite schema 草案，满足以下条件：

- 单机单设备
- 无账号
- 无同步
- 支撑项目、结构、元素、外拍信息流、照片、想法、时间线
- 支撑照片对结构和元素的挂接
- 保持 `StructureNode` 与 `Element` 的严格区分

## Schema Principles

1. 先服务 MVP  
   不为未来云同步、多用户、协作预留字段。

2. 一张表只表达一种职责  
   不把结构、元素、照片混成一个超级表。

3. 关系轻量化  
   `RelationTag` 放在挂接记录上，不做独立关系实体表。

4. 时间线由行为派生  
   时间线事件单独存储，但来自真实操作，不依赖手工维护。

## Enumerations

这些枚举建议在 Dart 层定义，并以字符串或整数形式入库：

- `project_stage`
  - `draft`
  - `active`
  - `paused`
  - `completed`

- `element_status`
  - `open`
  - `completed`

- `timeline_event_type`
  - `capture_entry_created`
  - `capture_entry_updated`
  - `photo_imported`
  - `structure_created`
  - `structure_updated`
  - `element_created`
  - `element_completed`
  - `note_added`
  - `photo_linked`

- `note_type`
  - `capture_note`
  - `project_idea`
  - `photo_note`
  - `curation_note`

- `relation_tag`
  - `echo`
  - `contrast`
  - `repeat`
  - `turn`

说明：
- 名称可后续再本地化成中文展示
- 数据层建议保持稳定、简短、可迁移

## Tables

### 1. projects

用途：
- 项目主表

字段建议：

- `id` TEXT PRIMARY KEY
- `title` TEXT NOT NULL
- `theme_statement` TEXT NOT NULL
- `description` TEXT NULL
- `stage` TEXT NOT NULL DEFAULT 'draft'
- `created_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL

约束：

- `title` 不为空
- `theme_statement` 不为空

### 2. structure_nodes

用途：
- 作品结构节点

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `parent_id` TEXT NULL
- `title` TEXT NOT NULL
- `description` TEXT NULL
- `sort_order` INTEGER NOT NULL DEFAULT 0
- `created_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL

外键：

- `project_id -> projects.id`
- `parent_id -> structure_nodes.id`

说明：
- `parent_id` 允许未来表达轻量层级，但不强迫必须树状

### 3. elements

用途：
- 项目中的视觉 / 叙事元素

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `structure_node_id` TEXT NULL
- `title` TEXT NOT NULL
- `description` TEXT NULL
- `status` TEXT NOT NULL DEFAULT 'open'
- `created_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL
- `completed_at` INTEGER NULL

外键：

- `project_id -> projects.id`
- `structure_node_id -> structure_nodes.id`

说明：
- `structure_node_id` 允许元素归属于某个结构节点
- 元素仍然是独立对象，不与结构节点合并

### 4. capture_entries

用途：
- 外拍信息流节点

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `started_at` INTEGER NOT NULL
- `ended_at` INTEGER NOT NULL
- `location_label` TEXT NULL
- `latitude` REAL NULL
- `longitude` REAL NULL
- `text_summary` TEXT NULL
- `created_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL

外键：

- `project_id -> projects.id`

说明：
- 一条节点表示一次外拍信息流片段
- 10 分钟内相近记录会落到同一节点，因此需要 `started_at` / `ended_at`
- `text_summary` 用于信息流列表摘要展示

### 5. photos

用途：
- 已导入到项目中的照片记录

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `capture_entry_id` TEXT NULL
- `source_uri` TEXT NOT NULL
- `origin_type` TEXT NOT NULL
- `capture_link_mode` TEXT NOT NULL DEFAULT 'unlinked'
- `thumbnail_path` TEXT NULL
- `preview_path` TEXT NULL
- `note_text` TEXT NULL
- `taken_at` INTEGER NULL
- `imported_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL
- `is_curated` INTEGER NOT NULL DEFAULT 0

外键：

- `project_id -> projects.id`
- `capture_entry_id -> capture_entries.id`

说明：
- `source_uri` 指向设备资源，不复制原图
- `is_curated` 用于标记是否至少完成过一次整理
- `origin_type` 建议至少区分 `quick_capture` 和 `imported`
- `capture_link_mode` 建议至少区分 `unlinked` / `auto` / `manual`

### 6. photo_structure_links

用途：
- 照片与结构节点的挂接记录

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `photo_id` TEXT NOT NULL
- `structure_node_id` TEXT NOT NULL
- `relation_tags` TEXT NULL
- `created_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL

外键：

- `project_id -> projects.id`
- `photo_id -> photos.id`
- `structure_node_id -> structure_nodes.id`

说明：
- `relation_tags` 可先使用 JSON 字符串或逗号分隔方案
- 第一版建议优先 JSON，后续迁移更稳

唯一约束建议：

- `UNIQUE(photo_id, structure_node_id)`

### 7. photo_element_links

用途：
- 照片与元素的挂接记录

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `photo_id` TEXT NOT NULL
- `element_id` TEXT NOT NULL
- `relation_tags` TEXT NULL
- `created_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL

外键：

- `project_id -> projects.id`
- `photo_id -> photos.id`
- `element_id -> elements.id`

唯一约束建议：

- `UNIQUE(photo_id, element_id)`

### 8. notes

用途：
- 项目层和照片层创作想法记录

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `capture_entry_id` TEXT NULL
- `photo_id` TEXT NULL
- `body` TEXT NOT NULL
- `note_type` TEXT NOT NULL
- `created_at` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL

外键：

- `project_id -> projects.id`
- `capture_entry_id -> capture_entries.id`
- `photo_id -> photos.id`

说明：
- 如果 `capture_entry_id` 存在，说明这条记录属于某个外拍信息流节点
- 如果 `photo_id` 为空，说明这是项目层想法
- 如果存在 `photo_id`，说明这是照片相关想法

### 9. timeline_events

用途：
- 创作历程事件

字段建议：

- `id` TEXT PRIMARY KEY
- `project_id` TEXT NOT NULL
- `event_type` TEXT NOT NULL
- `related_entity_type` TEXT NULL
- `related_entity_id` TEXT NULL
- `payload_json` TEXT NULL
- `created_at` INTEGER NOT NULL

外键：

- `project_id -> projects.id`

说明：
- `payload_json` 保存展示所需的轻量快照
- 避免时间线回放完全依赖当前实体状态

## Suggested Indexes

### projects

- `INDEX projects_updated_at_idx(updated_at)`

### structure_nodes

- `INDEX structure_nodes_project_id_idx(project_id)`
- `INDEX structure_nodes_parent_id_idx(parent_id)`
- `INDEX structure_nodes_project_sort_idx(project_id, sort_order)`

### elements

- `INDEX elements_project_id_idx(project_id)`
- `INDEX elements_structure_node_id_idx(structure_node_id)`
- `INDEX elements_status_idx(project_id, status)`

### capture_entries

- `INDEX capture_entries_project_time_idx(project_id, started_at DESC)`
- `INDEX capture_entries_project_end_idx(project_id, ended_at DESC)`

### photos

- `INDEX photos_project_id_idx(project_id)`
- `INDEX photos_capture_entry_id_idx(capture_entry_id)`
- `INDEX photos_project_curated_idx(project_id, is_curated)`
- `INDEX photos_imported_at_idx(project_id, imported_at DESC)`

### photo_structure_links

- `INDEX photo_structure_links_photo_id_idx(photo_id)`
- `INDEX photo_structure_links_structure_node_id_idx(structure_node_id)`

### photo_element_links

- `INDEX photo_element_links_photo_id_idx(photo_id)`
- `INDEX photo_element_links_element_id_idx(element_id)`

### notes

- `INDEX notes_project_id_idx(project_id)`
- `INDEX notes_photo_id_idx(photo_id)`
- `INDEX notes_created_at_idx(project_id, created_at DESC)`

### timeline_events

- `INDEX timeline_events_project_time_idx(project_id, created_at DESC)`
- `INDEX timeline_events_type_idx(project_id, event_type)`

## Data Integrity Rules

1. 一个 `StructureNode` 只能属于一个项目
2. 一个 `Element` 只能属于一个项目
3. 一个 `Photo` 只能属于一个项目
4. 一个 `CaptureEntry` 只能属于一个项目
5. 挂接表的 `project_id` 必须与所关联实体属于同一项目
6. `StructureNode` 与 `Element` 不能用同一张表表达
7. 元素完成状态只能由 `elements.status` 和 `completed_at` 体现，不单独再造状态表
8. 一张照片最多只归属一个信息流节点，但可手动重新指派

## Recommended Timeline Event Payloads

### capture_entry_created

建议包含：

- `captureEntryId`
- `startedAt`
- `locationLabel`
- `textPreview`

### photo_imported

建议包含：

- `photoId`
- `captureEntryId`
- `thumbnailPath`
- `notePreview`

### structure_created

- `structureNodeId`
- `title`

### element_created

- `elementId`
- `title`

### element_completed

- `elementId`
- `title`

### note_added

- `noteId`
- `noteType`
- `bodyPreview`

### photo_linked

- `photoId`
- `targetType`
- `targetId`
- `relationTags`

## Drift Table Grouping Suggestion

建议在 `data/db/tables/` 中按表拆文件：

```text
tables/
  projects_table.dart
  structure_nodes_table.dart
  elements_table.dart
  capture_entries_table.dart
  photos_table.dart
  photo_structure_links_table.dart
  photo_element_links_table.dart
  notes_table.dart
  timeline_events_table.dart
```

## Migration Strategy

第一版就应考虑 migration，不要等 schema 复杂后再补。

建议：

- v1: 建立全部核心表
- v2 以后如新增字段或关系能力，再做明确迁移

注意：

- 因为是单机单设备 app，迁移失败会直接影响用户本地数据
- 必须保留本地迁移日志

## Explicitly Not Needed

第一版明确不需要：

- `users`
- `accounts`
- `sessions`
- `devices`
- `sync_jobs`
- `remote_changes`
- `upload_queue`

这些表的不存在本身就是产品边界的一部分。

## Open Questions for Implementation Planning

1. `relation_tags` 用 JSON 数组还是压缩字符串更合适？
2. `capture_entries.text_summary` 是只做展示缓存，还是作为节点主文本？
3. `notes` 是否需要再区分“项目思路”和“整理备注”的展示策略？
4. `timeline_events.payload_json` 是否要保存更多快照，以避免实体变更后时间线失真？
5. `photos.preview_path` 在 MVP 是否真的需要，还是只保留 `thumbnail_path`？

## Recommendation

如果继续往实现规划推进，下一步最值得细化的是：

1. `curation` 页面状态机
2. drift table 定义草案
3. repository 接口方法清单
