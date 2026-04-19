import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
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
       onUpdateRelationType = null;

  const ProjectRelationCreatePage.edit({
    super.key,
    required this.relationType,
    required this.onUpdateRelationType,
  }) : onCreateRelationType = null;

  final ProjectRelationType? relationType;
  final CreateProjectRelationType? onCreateRelationType;
  final UpdateProjectRelationType? onUpdateRelationType;

  bool get isEditMode => relationType != null;

  @override
  State<ProjectRelationCreatePage> createState() =>
      _ProjectRelationCreatePageState();
}

enum _RelationTargetType { element, photo, both }

class _ProjectRelationCreatePageState extends State<ProjectRelationCreatePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final String _initialName;
  late final String _initialDescription;
  _RelationTargetType _selectedType = _RelationTargetType.both;
  bool _isSaving = false;

  bool get _hasChanges {
    return _nameController.text.trim() != _initialName ||
        _descController.text.trim() != _initialDescription;
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_isSaving;

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

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          decoration: _buildInputDecoration('例如：视觉呼应、时空对比...'),
                        ),
                        const SizedBox(height: 48),
                        _buildSectionLabel('关 联 类 型'),
                        const SizedBox(height: 16),
                        _buildTypeSelector(),
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
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  ignoring: !_hasChanges || !_canSave,
                  child: AnimatedOpacity(
                    opacity: _hasChanges ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: GestureDetector(
                      key: const ValueKey('relationTypeSaveButton'),
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(color: Colors.black),
                        child: Text(
                          _isSaving ? '保 存 中' : '保 存',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 4.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            widget.isEditMode ? '编 辑 关 联 关 系' : '添 加 关 联 关 系',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: Colors.black87,
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

  Widget _buildTypeSelector() {
    final typeSelector = LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 3;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTypeItem('照片', _RelationTargetType.photo, itemWidth),
            _buildTypeItem('元素', _RelationTargetType.element, itemWidth),
            _buildTypeItem('自由组合', _RelationTargetType.both, itemWidth),
          ],
        );
      },
    );

    if (!widget.isEditMode) {
      return typeSelector;
    }

    return Opacity(
      opacity: 0.45,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            typeSelector,
            const SizedBox(height: 8),
            Text(
              '编辑时不可修改关联类型',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeItem(String label, _RelationTargetType type, double width) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black12,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.black38,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
