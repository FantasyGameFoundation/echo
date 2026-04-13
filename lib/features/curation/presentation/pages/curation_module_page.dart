import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class CurationModulePage extends StatelessWidget {
  const CurationModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '整理与消项',
      badge: 'Curation',
      icon: Icons.auto_stories_outlined,
      objective: '把正式照片真正纳入项目叙事，并推动元素完成。',
      summary: '整理模块承接信息流节点、正式照片、结构、元素和关系属性，是整个产品的核心生产流程。',
      coreActions: [
        '把照片挂接到结构节点',
        '把照片挂接到一个或多个元素',
        '附加关系属性',
        '对已满足的元素执行消项',
        '补充整理过程中的创作想法',
      ],
      businessRules: [
        'Relation 只是轻量挂接属性，不是独立复杂系统',
        '工具不替摄影师判断是否消项',
        '整理链路必须让信息流节点与正式照片的连接可见',
      ],
      nextSteps: [
        '细化单张照片整理状态机',
        '定义结构/元素挂接的保存策略',
        '明确消项反馈与撤销逻辑',
      ],
    );
  }
}
