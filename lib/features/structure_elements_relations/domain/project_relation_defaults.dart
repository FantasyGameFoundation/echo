class ProjectRelationDefaultDefinition {
  const ProjectRelationDefaultDefinition({
    required this.name,
    required this.description,
    required this.sortOrder,
  });

  final String name;
  final String description;
  final int sortOrder;
}

const List<ProjectRelationDefaultDefinition> defaultProjectRelationDefinitions =
    <ProjectRelationDefaultDefinition>[
      ProjectRelationDefaultDefinition(
        name: '对比',
        description: '跨章节的色彩冷暖或几何构图冲突，强调环境的异质性。',
        sortOrder: 0,
      ),
      ProjectRelationDefaultDefinition(
        name: '重复',
        description: '特定视觉符号的规律性再现，构建叙事韵律。',
        sortOrder: 1,
      ),
      ProjectRelationDefaultDefinition(
        name: '呼应',
        description: '不同地理位置间的情感共鸣，将碎片化的河岸串联为整体。',
        sortOrder: 2,
      ),
      ProjectRelationDefaultDefinition(
        name: '转折',
        description: '叙事节奏在工业遗迹与纯粹自然间的突然切换。',
        sortOrder: 3,
      ),
    ];
