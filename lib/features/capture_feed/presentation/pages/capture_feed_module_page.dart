import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class CaptureFeedModulePage extends StatelessWidget {
  const CaptureFeedModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '外拍信息流',
      badge: 'Capture Feed',
      icon: Icons.place_outlined,
      objective: '在现场没有时间导入正式照片时，仍然把关键线索钉住。',
      summary: '这个模块承接外拍现场的低摩擦记录，形成按时间排序、自动记录地点的信息流节点，作为后续正式照片导入和整理的锚点。',
      coreActions: [
        '快速创建信息流节点',
        '只写一段文字',
        '直接拍一张临时照片',
        '从相册临时选一张放进节点',
        '查看信息流历史',
      ],
      businessRules: [
        '10 分钟内相近记录自动合并为同一节点',
        '节点必须自动记录时间和地点',
        '用户可以只写文字，不必强制带照片',
        '信息流节点是正式业务对象，不是临时备注',
      ],
      nextSteps: [
        '细化 10 分钟自动合并的判定逻辑',
        '明确地点精度与地点名称展示策略',
        '定义节点内多条记录的追加方式',
      ],
    );
  }
}
