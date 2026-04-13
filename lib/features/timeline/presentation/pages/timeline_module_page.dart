import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class TimelineModulePage extends StatelessWidget {
  const TimelineModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '创作历程',
      badge: 'Timeline',
      icon: Icons.timeline_outlined,
      objective: '回看作品是如何慢慢形成的，而不是只看一串操作日志。',
      summary: '时间线模块把外拍信息流、正式照片导入、元素完成和创作想法串成连续的创作过程。',
      coreActions: [
        '查看信息流节点历史',
        '查看正式照片导入记录',
        '查看元素完成记录',
        '查看创作想法记录',
      ],
      businessRules: [
        '时间线不是普通日志',
        '必须把外拍和回家整理两阶段串起来',
      ],
      nextSteps: [
        '定义事件类型与排序规则',
        '明确时间线详情页需要展示的上下文',
        '确定时间线与模块详情页的跳转关系',
      ],
    );
  }
}
