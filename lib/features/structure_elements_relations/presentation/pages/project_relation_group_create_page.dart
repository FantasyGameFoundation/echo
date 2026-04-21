import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_group_selection_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/compact_remove_button.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_bottom_action_bar.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_confirmation_dialog.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef CreateProjectRelationGroup =
    Future<void> Function({
      required String title,
      required String description,
      required List<ProjectRelationDraftMember> members,
    });

typedef UpdateProjectRelationGroup = CreateProjectRelationGroup;
typedef DeleteProjectRelationGroup = Future<void> Function();

enum ProjectRelationGroupEditorResult { saved, deleted }

class ProjectRelationGroupCreatePage extends StatefulWidget {
  const ProjectRelationGroupCreatePage({
    super.key,
    required this.relationType,
    required this.narrativeElements,
    required this.chapters,
    required this.onCreateRelationGroup,
    this.onUpdateRelationGroup,
    this.onDeleteRelationGroup,
    this.initialTitle,
    this.initialDescription,
    this.initialMembers,
  });

  final ProjectRelationType relationType;
  final List<NarrativeElement> narrativeElements;
  final List<StructureChapter> chapters;
  final CreateProjectRelationGroup onCreateRelationGroup;
  final UpdateProjectRelationGroup? onUpdateRelationGroup;
  final DeleteProjectRelationGroup? onDeleteRelationGroup;
  final String? initialTitle;
  final String? initialDescription;
  final List<ProjectRelationDraftMember>? initialMembers;

  bool get isEditMode => onUpdateRelationGroup != null;

  @override
  State<ProjectRelationGroupCreatePage> createState() =>
      _ProjectRelationGroupCreatePageState();
}

enum _AssemblyNodeType { photo, element, addPlaceholder }

class _ProjectRelationGroupCreatePageState
    extends State<ProjectRelationGroupCreatePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late List<_AssemblyNode> _draftNodes;
  late final String _initialTitle;
  late final String _initialDescription;
  late final List<String> _initialMemberKeys;
  bool _isSaving = false;
  bool _didFinishEditing = false;

  bool get _hasEnoughMembers =>
      _draftNodes
          .where((node) => node.type != _AssemblyNodeType.addPlaceholder)
          .length >=
      2;

  bool get _canSave =>
      !_isSaving &&
      _hasEnoughMembers &&
      _titleController.text.trim().isNotEmpty;

  bool get _hasUnsavedChanges =>
      _titleController.text.trim() != _initialTitle ||
      _descriptionController.text.trim() != _initialDescription ||
      !listEquals(_currentMemberKeys, _initialMemberKeys);

  String get _displayTitle {
    final currentTitle = _titleController.text.trim();
    if (currentTitle.isNotEmpty) {
      return currentTitle;
    }
    final initialTitle = widget.initialTitle?.trim() ?? '';
    if (initialTitle.isNotEmpty) {
      return initialTitle;
    }
    return widget.isEditMode ? '未命名关系组' : '新关系组';
  }

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.initialTitle?.trim() ?? '';
    _initialDescription = widget.initialDescription?.trim() ?? '';
    _initialMemberKeys = [
      for (final member
          in widget.initialMembers ?? const <ProjectRelationDraftMember>[])
        _memberKey(member),
    ];
    _titleController = TextEditingController(text: widget.initialTitle ?? '')
      ..addListener(_handleChanged);
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    )..addListener(_handleChanged);
    _draftNodes = [
      ..._buildNodesFromMembers(widget.initialMembers ?? const []),
      const _AssemblyNode.addPlaceholder(),
    ];
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleChanged);
    _descriptionController.removeListener(_handleChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<String> get _currentMemberKeys => [
    for (final node in _draftNodes)
      if (node.draftMember != null) _memberKey(node.draftMember!),
  ];

  Future<bool> _confirmDiscardUnsavedChanges() async {
    if (_didFinishEditing || _isSaving || !_hasUnsavedChanges) {
      return true;
    }
    return showDiscardUnsavedChangesDialog(context: context);
  }

  Future<void> _handleBackNavigation() async {
    final shouldPop = await _confirmDiscardUnsavedChanges();
    if (!mounted || !shouldPop) {
      return;
    }
    Navigator.of(context).pop();
  }

  String _memberKey(ProjectRelationDraftMember member) {
    switch (member.kind) {
      case ProjectRelationTargetKind.element:
        return 'element:${member.elementId}';
      case ProjectRelationTargetKind.photo:
        return 'photo:${member.sourceElementId}:${member.photoPath}';
    }
  }

  String _chapterSequence(int? sortOrder) {
    if (sortOrder == null) {
      return '--';
    }
    return (sortOrder + 1).toString().padLeft(2, '0');
  }

  List<_AssemblyNode> _buildNodesFromMembers(
    List<ProjectRelationDraftMember> members,
  ) {
    final chaptersById = <String, StructureChapter>{
      for (final chapter in widget.chapters) chapter.chapterId: chapter,
    };
    final elementsById = <String, NarrativeElement>{
      for (final element in widget.narrativeElements)
        element.elementId: element,
    };

    final nodes = <_AssemblyNode>[];
    for (final member in members) {
      switch (member.kind) {
        case ProjectRelationTargetKind.element:
          final element = elementsById[member.elementId];
          if (element == null) {
            continue;
          }
          nodes.add(
            _AssemblyNode.element(
              title: element.title,
              chapterSeq: _chapterSequence(
                chaptersById[element.owningChapterId]?.sortOrder,
              ),
              draftMember: member,
            ),
          );
        case ProjectRelationTargetKind.photo:
          final sourceElement = elementsById[member.sourceElementId];
          nodes.add(
            _AssemblyNode.photo(
              title: sourceElement?.title ?? '未命名照片',
              chapterSeq: _chapterSequence(
                chaptersById[sourceElement?.owningChapterId]?.sortOrder,
              ),
              imageSource: member.photoPath,
              draftMember: member,
            ),
          );
      }
    }
    return nodes;
  }

  Future<void> _openSelectionPage() async {
    final selectedMembers = await Navigator.of(context)
        .push<List<ProjectRelationDraftMember>>(
          MaterialPageRoute(
            builder: (_) => ProjectRelationGroupSelectionPage(
              chapters: widget.chapters,
              narrativeElements: widget.narrativeElements,
              relationTypeName: widget.relationType.name,
              relationGroupTitle: _displayTitle,
              initialSelectionKeys: _draftNodes
                  .where((node) => node.draftMember != null)
                  .map((node) => _memberKey(node.draftMember!))
                  .toSet(),
            ),
          ),
        );

    if (selectedMembers == null || !mounted) {
      return;
    }

    setState(() {
      _draftNodes = [
        ..._buildNodesFromMembers(selectedMembers),
        const _AssemblyNode.addPlaceholder(),
      ];
    });
  }

  void _removeNodeAt(int index) {
    if (index < 0 || index >= _draftNodes.length) {
      return;
    }
    if (_draftNodes[index].type == _AssemblyNodeType.addPlaceholder) {
      return;
    }
    setState(() {
      _draftNodes.removeAt(index);
    });
  }

  void _showPassiveHint(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showPassiveHint('请先填写关系组标题');
      return;
    }
    if (!_hasEnoughMembers) {
      _showPassiveHint('至少需要 2 个对象才能建立关联组');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final payload = (
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      members: _draftNodes
          .where((node) => node.draftMember != null)
          .map((node) => node.draftMember!)
          .toList(),
    );

    if (widget.isEditMode) {
      await widget.onUpdateRelationGroup!(
        title: payload.title,
        description: payload.description,
        members: payload.members,
      );
    } else {
      await widget.onCreateRelationGroup(
        title: payload.title,
        description: payload.description,
        members: payload.members,
      );
    }

    if (!mounted) {
      return;
    }
    _didFinishEditing = true;
    Navigator.of(context).pop(ProjectRelationGroupEditorResult.saved);
  }

  Future<void> _delete() async {
    if (_isSaving || widget.onDeleteRelationGroup == null) {
      return;
    }

    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '确 认 删 除',
      content: '删除后，仅当前关系组及其成员会移除；关系类型、元素与照片会保留，当前页面将返回详情。',
      actionText: '删 除',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.onDeleteRelationGroup!();
    if (!mounted) {
      return;
    }
    _didFinishEditing = true;
    Navigator.of(context).pop(ProjectRelationGroupEditorResult.deleted);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: _didFinishEditing || _isSaving || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final shouldPop = await _confirmDiscardUnsavedChanges();
        if (!mounted || !shouldPop) {
          return;
        }
        _didFinishEditing = true;
        navigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFC),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildMetadataInputs(),
                          const SizedBox(height: 48),
                          _buildAssemblyLine(),
                          SizedBox(height: widget.isEditMode ? 160 : 64),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isEditMode)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: EditorBottomActionBar(
                      leftLabel: _isSaving ? '保 存 中' : '保 存',
                      leftKey: const ValueKey('completeRelationGroupButton'),
                      leftTone: EditorBottomActionTone.primary,
                      leftEnabled: _canSave,
                      onLeftTap: _save,
                      rightLabel: '删 除',
                      rightKey: const ValueKey('relationGroupDeleteButton'),
                      rightEnabled: !_isSaving,
                      onRightTap: _delete,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 18,
              ),
              onPressed: _handleBackNavigation,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditMode ? '编辑关系组' : '添加关系组',
                  key: const ValueKey('relationGroupEditorScopeLabel'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayTitle,
                  key: const ValueKey('relationGroupEditorTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isEditMode)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  key: const ValueKey('completeRelationGroupButton'),
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Text(
                    _isSaving ? '保存中' : '完成',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _canSave ? Colors.black87 : Colors.black38,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            )
          else
            const Align(
              alignment: Alignment.centerRight,
              child: SizedBox(width: 48),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataInputs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('relationGroupTitleField'),
            controller: _titleController,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: '关系组标题',
              hintStyle: TextStyle(
                color: Colors.black.withValues(alpha: 0.2),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('relationGroupDescriptionField'),
            controller: _descriptionController,
            maxLines: null,
            minLines: 3,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black.withValues(alpha: 0.6),
            ),
            decoration: InputDecoration(
              hintText: '描述该关系组内各对象的内在逻辑或视觉线索...',
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.25)),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssemblyLine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            '关 系 序 列',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            const totalPadding = 48.0;
            const totalSpacing = 36.0;
            final itemWidth =
                (constraints.maxWidth - totalPadding - totalSpacing) / 4;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 20.0,
                children: [
                  for (var index = 0; index < _draftNodes.length; index++)
                    SizedBox(
                      width: itemWidth,
                      child: _buildNodeItem(
                        _draftNodes[index],
                        itemWidth,
                        index,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNodeItem(_AssemblyNode node, double size, int index) {
    final subtleShadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 18,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];

    if (node.type == _AssemblyNodeType.addPlaceholder) {
      return GestureDetector(
        key: const ValueKey('relationGroupAddNodePlaceholder'),
        onTap: _openSelectionPage,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: subtleShadow,
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.black26, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    if (node.type == _AssemblyNodeType.element) {
      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: subtleShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CH.${node.chapterSeq}',
                      style: const TextStyle(
                        fontSize: 8,
                        letterSpacing: 0.5,
                        color: Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      node.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              _buildNodeRemoveButton(node, index),
            ],
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: subtleShadow,
              ),
              child: node.imageSource != null
                  ? Image(
                      image: narrativeThumbnailProvider(node.imageSource!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.black12,
                            size: 18,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'WAITING',
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.0,
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
            ),
            _buildNodeRemoveButton(node, index),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildNodeRemoveButton(_AssemblyNode node, int index) {
    final member = node.draftMember;
    if (member == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: -8,
      right: -8,
      child: CompactRemoveButton(
        key: ValueKey('relationGroupRemoveNode-${_memberKey(member)}'),
        onTap: () => _removeNodeAt(index),
      ),
    );
  }
}

class _AssemblyNode {
  const _AssemblyNode({
    required this.type,
    required this.title,
    required this.chapterSeq,
    required this.imageSource,
    required this.draftMember,
  });

  const _AssemblyNode.photo({
    required String title,
    required String chapterSeq,
    required String? imageSource,
    required ProjectRelationDraftMember draftMember,
  }) : this(
         type: _AssemblyNodeType.photo,
         title: title,
         chapterSeq: chapterSeq,
         imageSource: imageSource,
         draftMember: draftMember,
       );

  const _AssemblyNode.element({
    required String title,
    required String chapterSeq,
    required ProjectRelationDraftMember draftMember,
  }) : this(
         type: _AssemblyNodeType.element,
         title: title,
         chapterSeq: chapterSeq,
         imageSource: null,
         draftMember: draftMember,
       );

  const _AssemblyNode.addPlaceholder()
    : this(
        type: _AssemblyNodeType.addPlaceholder,
        title: '',
        chapterSeq: '--',
        imageSource: null,
        draftMember: null,
      );

  final _AssemblyNodeType type;
  final String title;
  final String chapterSeq;
  final String? imageSource;
  final ProjectRelationDraftMember? draftMember;
}
