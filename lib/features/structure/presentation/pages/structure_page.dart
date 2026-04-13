import 'package:echo/shared/widgets/placeholder_feature_view.dart';
import 'package:echo/shared/widgets/module_card.dart';
import 'package:echo/app/router/route_names.dart';
import 'package:flutter/material.dart';

class StructurePage extends StatelessWidget {
  const StructurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureView(
      title: '结构',
      description: '结构分区先把骨架和材料拆开，用两个模块原型页确认各自边界与职责。',
      badge: 'Structure',
      icon: Icons.account_tree_outlined,
      sections: [
        ModuleCard(
          title: '结构构思',
          badge: 'Structure',
          description: '章节、段落、组块骨架的原型页。',
          routeName: RouteNames.structureModule,
          icon: Icons.account_tree_outlined,
          highlights: [
            '创建结构节点',
            '维护顺序与层级',
            '查看结构详情',
          ],
        ),
        ModuleCard(
          title: '元素管理',
          badge: 'Element',
          description: '视觉与叙事材料的原型页。',
          routeName: RouteNames.elementModule,
          icon: Icons.auto_awesome_outlined,
          highlights: [
            '创建元素',
            '查看元素状态',
            '执行消项',
          ],
        ),
      ],
    );
  }
}
