import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class ElementModulePage extends StatelessWidget {
  const ElementModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '元素管理',
      badge: 'Element',
      icon: Icons.auto_awesome_outlined,
      objective: '持续追踪作品需要哪些视觉或叙事材料被逐步建立起来。',
      summary: '元素是作品内容材料，不是章节。这个模块负责元素的创建、归属、完成状态和支撑照片查看。',
      coreActions: [
        '创建元素',
        '编辑元素描述',
        '把元素归属到结构节点',
        '查看元素状态',
        '对元素执行消项',
      ],
      businessRules: [
        '元素和结构节点严格分开',
        '一个元素可以由多张照片共同支撑',
        '元素状态至少区分未完成和已完成',
      ],
      nextSteps: [
        '确定元素状态是否需要细分阶段',
        '定义元素与结构节点的可视化关系',
        '明确支撑照片的展示规则',
      ],
    );
  }
}
