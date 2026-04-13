import 'package:echo/shared/widgets/prototype_module_page.dart';
import 'package:flutter/material.dart';

class NotesModulePage extends StatelessWidget {
  const NotesModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrototypeModulePage(
      title: '创作想法',
      badge: 'Notes',
      icon: Icons.edit_note_outlined,
      objective: '记录项目级、照片级和外拍现场级的创作想法。',
      summary: '这个模块不做通用笔记系统，而是服务于项目构思、外拍线索和整理过程中的关联思路沉淀。',
      coreActions: [
        '记录项目级想法',
        '记录照片相关想法',
        '记录外拍节点相关想法',
        '在后续阶段回看想法',
      ],
      businessRules: [
        '想法记录服务于项目创作，不扩展成通用笔记库',
        '项目、照片、信息流节点三种上下文都要能挂接想法',
      ],
      nextSteps: [
        '明确 note_type 的显示策略',
        '确定想法在时间线中的呈现规则',
        '细化编辑与回看流转',
      ],
    );
  }
}
