import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_bottom_action_bar.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_confirmation_dialog.dart';
import 'package:flutter/material.dart';

typedef CreateProjectRelationType =
    Future<ProjectRelationType> Function({
      required String name,
      required String description,
    });

typedef UpdateProjectRelationType = CreateProjectRelationType;

class ProjectRelationCreatePage extends StatefulWidget {
  const ProjectRelationCreatePage({
    super.key,
    required this.onCreateRelationType,
  }) : relationType = null,
       onUpdateRelationType = null,
       onDeleteRelationType = null;

  const ProjectRelationCreatePage.edit({
    super.key,
    required this.relationType,
    required this.onUpdateRelationType,
    required this.onDeleteRelationType,
  }) : onCreateRelationType = null;

  final ProjectRelationType? relationType;
  final CreateProjectRelationType? onCreateRelationType;
  final UpdateProjectRelationType? onUpdateRelationType;
  final Future<void> Function()? onDeleteRelationType;

  bool get isEditMode => relationType != null;

  @override
  State<ProjectRelationCreatePage> createState() =>
      _ProjectRelationCreatePageState();
}

class _ProjectRelationCreatePageState extends State<ProjectRelationCreatePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final String _initialName;
  late final String _initialDescription;
  bool _isSaving = false;
  bool _didFinishEditing = false;

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_isSaving;

  bool get _hasUnsavedChanges =>
      _nameController.text.trim() != _initialName ||
      _descController.text.trim() != _initialDescription;

  @override
  void initState() {
    super.initState();
    _initialName = widget.relationType?.name.trim() ?? '';
    _initialDescription = widget.relationType?.description.trim() ?? '';
    _nameController = TextEditingController(text: _initialName)
      ..addListener(_handleChanged);
    _descController = TextEditingController(text: _initialDescription)
      ..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleChanged);
    _descController.removeListener(_handleChanged);
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

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
    _didFinishEditing = true;
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (widget.isEditMode) {
      await widget.onUpdateRelationType!(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
      );
    } else {
      await widget.onCreateRelationType!(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
      );
    }

    if (!mounted) {
      return;
    }

    _didFinishEditing = true;
    Navigator.of(context).pop();
  }

  Future<void> _deleteRelationType() async {
    if (_isSaving || widget.onDeleteRelationType == null) {
      return;
    }

    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '确 认 删 除',
      content: '删除后，仅当前关系类型及其下属关联组会移除；元素、照片与章节内容会保留，当前页面将返回列表。',
      actionText: '删 除',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.onDeleteRelationType!();
    if (!mounted) {
      return;
    }
    _didFinishEditing = true;
    Navigator.of(context).pop();
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
        backgroundColor: const Color(0xFFF7F7F9),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 40.0,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('关 系 名 称'),
                          const SizedBox(height: 8),
                          TextField(
                            key: const ValueKey('relationTypeNameField'),
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.black87,
                            ),
                            decoration: _buildInputDecoration(
                              '例如：视觉呼应、时空对比...',
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildSectionLabel('关 系 描 述'),
                          const SizedBox(height: 12),
                          TextField(
                            key: const ValueKey('relationTypeDescriptionField'),
                            controller: _descController,
                            maxLines: null,
                            minLines: 3,
                            style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300,
                              color: Colors.black54,
                              height: 1.8,
                            ),
                            decoration: const InputDecoration(
                              hintText: '描述这组关系背后的叙事逻辑...',
                              hintStyle: TextStyle(
                                color: Colors.black12,
                                fontStyle: FontStyle.italic,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: EditorBottomActionBar(
                    leftLabel: _isSaving ? '保 存 中' : '保 存',
                    leftKey: const ValueKey('relationTypeSaveButton'),
                    leftTone: EditorBottomActionTone.primary,
                    leftEnabled: _canSave,
                    onLeftTap: _save,
                    rightLabel: widget.isEditMode ? '删 除' : null,
                    rightKey: widget.isEditMode
                        ? const ValueKey('relationTypeDeleteButton')
                        : null,
                    rightEnabled: !_isSaving,
                    onRightTap: widget.isEditMode ? _deleteRelationType : null,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 18,
            ),
            onPressed: _handleBackNavigation,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.isEditMode ? '编 辑 关 系 类 型' : '添 加 关 联 关 系',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.0,
                    color: Colors.black87,
                  ),
                ),
                if (!widget.isEditMode)
                  const IgnorePointer(
                    child: Opacity(
                      opacity: 0,
                      child: Text(
                        '添 加 关 系 类 型',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade400,
        letterSpacing: 4.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return const InputDecoration().copyWith(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black12,
        fontWeight: FontWeight.normal,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black12, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black87, width: 1.5),
      ),
    );
  }
}
