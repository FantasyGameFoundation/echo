import 'package:echo/shared/widgets/placeholder_feature_view.dart';
import 'package:echo/shared/widgets/module_card.dart';
import 'package:echo/app/router/route_names.dart';
import 'package:flutter/material.dart';

class ProjectHomePage extends StatelessWidget {
  const ProjectHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureView(
      title: '项目',
      description: '项目分区先承载顶层业务模块原型，帮助确认主题、结构与元素三类核心能力的边界。',
      badge: 'Project',
      icon: Icons.home_outlined,
      sections: [
        ModuleCard(
          title: '项目定义',
          badge: 'Project',
          description: '主题、说明、阶段和项目摘要的原型页。',
          routeName: RouteNames.projectModule,
          icon: Icons.home_outlined,
          highlights: [
            '定义项目最高约束',
            '展示项目摘要',
            '承接主题陈述',
          ],
        ),
      ],
    );
  }
}
