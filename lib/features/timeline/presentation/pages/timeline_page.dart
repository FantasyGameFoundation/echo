import 'package:echo/shared/widgets/placeholder_feature_view.dart';
import 'package:echo/shared/widgets/module_card.dart';
import 'package:echo/app/router/route_names.dart';
import 'package:flutter/material.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureView(
      title: '历程',
      description: '历程分区先验证时间线模块本身，确认它如何把外拍与正式整理串成连续创作过程。',
      badge: 'Timeline',
      icon: Icons.timeline_outlined,
      sections: [
        ModuleCard(
          title: '创作历程',
          badge: 'Timeline',
          description: '时间线与事件回看的原型页。',
          routeName: RouteNames.timelineModule,
          icon: Icons.timeline_outlined,
          highlights: [
            '回看外拍信息流',
            '回看正式导入',
            '回看元素完成',
          ],
        ),
      ],
    );
  }
}
