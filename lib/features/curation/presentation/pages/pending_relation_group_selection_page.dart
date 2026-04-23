import 'dart:ui';

import 'package:echo/features/curation/presentation/models/pending_organize_models.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:flutter/material.dart';

class PendingRelationGroupSelectionPage extends StatefulWidget {
  const PendingRelationGroupSelectionPage({
    super.key,
    required this.relationType,
    required this.initialSelectedGroupIds,
  });

  final PendingOrganizeRelationTypeOption relationType;
  final Set<String> initialSelectedGroupIds;

  @override
  State<PendingRelationGroupSelectionPage> createState() =>
      _PendingRelationGroupSelectionPageState();
}

class _PendingRelationGroupSelectionPageState
    extends State<PendingRelationGroupSelectionPage> {
  late final Set<String> _selectedGroupIds;

  final List<BoxShadow> _subtleShadow = <BoxShadow>[
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 18,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedGroupIds = <String>{...widget.initialSelectedGroupIds};
  }

  void _toggleGroup(String groupId) {
    setState(() {
      if (_selectedGroupIds.contains(groupId)) {
        _selectedGroupIds.remove(groupId);
      } else {
        _selectedGroupIds.add(groupId);
      }
    });
  }

  void _completeSelection() {
    Navigator.of(context).pop(_selectedGroupIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: widget.relationType.groups.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 64),
                      itemCount: widget.relationType.groups.length,
                      itemBuilder: (context, index) {
                        final group = widget.relationType.groups[index];
                        return _buildGroupCard(group);
                      },
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '选择关联组',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color: Colors.black.withValues(alpha: 0.36),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.relationType.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey('pendingRelationSelectionCompleteButton'),
              onPressed: _completeSelection,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '完成',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          '当前关系类型下还没有关联组',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.4),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(PendingOrganizeRelationGroupOption group) {
    final isSelected = _selectedGroupIds.contains(group.groupId);

    return InkWell(
      key: ValueKey('pendingRelationGroupCard-${group.groupId}'),
      onTap: () => _toggleGroup(group.groupId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: _subtleShadow,
          border: Border.all(
            color: isSelected
                ? Colors.black.withValues(alpha: 0.14)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomCheckbox(
                  key: ValueKey(
                    'pendingRelationGroupCheckbox-${group.groupId}',
                  ),
                  isSelected: isSelected,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.title.trim().isEmpty ? '未命名关系组' : group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: Colors.black87,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (group.imageSources.isEmpty)
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F9),
                  border: Border.all(color: Colors.black12, width: 0.8),
                ),
                child: Text(
                  'NO\nPHOTO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.0,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (
                      var index = 0;
                      index < group.imageSources.length;
                      index++
                    )
                      Padding(
                        padding: EdgeInsets.only(
                          right: index == group.imageSources.length - 1 ? 0 : 8,
                        ),
                        child: _buildPhotoThumb(group.imageSources[index]),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumb(String imageSource) {
    return Container(
      width: 64,
      height: 64,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        border: Border.all(color: Colors.black12, width: 0.8),
      ),
      child: Image(
        image: ResizeImage.resizeIfNeeded(
          180,
          null,
          narrativeThumbnailProvider(imageSource),
        ),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.black26,
              size: 18,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomCheckbox({required Key key, required bool isSelected}) {
    return Container(
      key: key,
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: _subtleShadow,
      ),
      child: ClipOval(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: isSelected
              ? Container(
                  key: const ValueKey('checked'),
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                )
              : BackdropFilter(
                  key: const ValueKey('unchecked'),
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    color: const Color(0xFFEAEAEA).withValues(alpha: 0.65),
                  ),
                ),
        ),
      ),
    );
  }
}
