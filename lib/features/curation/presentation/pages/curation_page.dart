import 'package:echo/shared/widgets/placeholder_feature_view.dart';
import 'package:echo/shared/widgets/module_card.dart';
import 'package:echo/app/router/route_names.dart';
import 'package:flutter/material.dart';

class CurationPage extends StatelessWidget {
  const CurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureView(
      title: '整理',
      description: '整理分区集中放置最关键的生产模块原型：外拍信息流、正式照片导入、整理消项和创作想法。',
      badge: 'Curation',
      icon: Icons.auto_stories_outlined,
      sections: [
        ModuleCard(
          title: '外拍信息流',
          badge: 'Capture Feed',
          description: '现场快速记录与时间地点锚点的原型页。',
          routeName: RouteNames.captureFeedModule,
          icon: Icons.place_outlined,
          highlights: [
            '快速记一笔',
            '10 分钟内自动合并',
            '自动记录地点',
          ],
        ),
        ModuleCard(
          title: '正式照片导入',
          badge: 'Photo Import',
          description: '导入正式照片并接回现场信息流的原型页。',
          routeName: RouteNames.photoImportModule,
          icon: Icons.photo_library_outlined,
          highlights: [
            '正式导入',
            '自动时间关联',
            '人工修正归属',
          ],
        ),
        ModuleCard(
          title: '整理与消项',
          badge: 'Curation',
          description: '把正式照片挂接到结构和元素的原型页。',
          routeName: RouteNames.curationModule,
          icon: Icons.auto_stories_outlined,
          highlights: [
            '挂接结构',
            '挂接元素',
            '关系属性与消项',
          ],
        ),
        ModuleCard(
          title: '创作想法',
          badge: 'Notes',
          description: '项目、照片、现场节点三类想法记录的原型页。',
          routeName: RouteNames.notesModule,
          icon: Icons.edit_note_outlined,
          highlights: [
            '项目级想法',
            '照片级想法',
            '现场节点想法',
          ],
        ),
      ],
    );
  }
}
