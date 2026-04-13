import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class PhotoImportModulePage extends StatelessWidget {
  const PhotoImportModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '正式照片导入',
      badge: 'Photo Import',
      icon: Icons.photo_library_outlined,
      objective: '回家后把正式照片导入项目，并接回当时的现场记录。',
      summary: '这个模块负责正式照片入库、基础备注、自动关联到最近的信息流节点，以及后续人工修正。',
      coreActions: [
        '导入正式照片',
        '给照片写简短备注',
        '按时间自动关联到最近信息流节点',
        '手动修正照片归属节点',
        '查看照片当前归属',
      ],
      businessRules: [
        '自动关联基于最近时间点，不要求严格前后最近',
        '自动关联只是初始建议，最终由用户修正',
        '一张照片最多只归属一个信息流节点',
      ],
      nextSteps: [
        '细化自动关联算法',
        '确定导入批量策略',
        '确定人工修正后的状态标记方式',
      ],
    );
  }
}
