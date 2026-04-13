import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class ProjectModulePage extends StatelessWidget {
  const ProjectModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '项目定义',
      badge: 'Project',
      icon: Icons.home_outlined,
      objective: '定义一个摄影项目的最高约束，并维持项目整体摘要。',
      summary: '项目模块负责主题、说明、阶段和整体摘要，它是整个作品的顶层容器。',
      coreActions: [
        '创建项目',
        '编辑项目标题',
        '编辑主题陈述',
        '编辑项目说明',
        '查看项目摘要',
      ],
      businessRules: [
        '项目必须有主题陈述',
        '主题是整个项目的最高约束，不是普通备注',
      ],
      nextSteps: [
        '定义项目阶段枚举与切换规则',
        '明确项目首页摘要字段',
        '确定项目总览需要暴露哪些进度指标',
      ],
    );
  }
}
