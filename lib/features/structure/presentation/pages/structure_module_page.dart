import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class StructureModulePage extends StatelessWidget {
  const StructureModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '结构构思',
      badge: 'Structure',
      icon: Icons.account_tree_outlined,
      objective: '表达这本作品的章节、段落和组块骨架。',
      summary: '结构模块负责作品骨架的创建、排序和查看，不承担元素或照片管理职责。',
      coreActions: [
        '创建结构节点',
        '编辑结构节点',
        '调整结构顺序',
        '查看结构节点详情',
      ],
      businessRules: [
        '结构节点是章节骨架，不是素材标签',
        '结构节点和元素不能混用',
      ],
      nextSteps: [
        '确定是否需要轻量层级关系',
        '定义结构顺序的编辑交互',
        '明确结构详情中的元素和照片摘要方式',
      ],
    );
  }
}
