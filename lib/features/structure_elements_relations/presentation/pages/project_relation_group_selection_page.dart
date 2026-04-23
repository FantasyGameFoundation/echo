import 'dart:ui';

import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:flutter/material.dart';

class ProjectRelationGroupSelectionPage extends StatefulWidget {
  const ProjectRelationGroupSelectionPage({
    super.key,
    required this.chapters,
    required this.narrativeElements,
    required this.relationTypeName,
    required this.relationGroupTitle,
    required this.initialSelectionKeys,
  });

  final List<StructureChapter> chapters;
  final List<NarrativeElement> narrativeElements;
  final String relationTypeName;
  final String relationGroupTitle;
  final Set<String> initialSelectionKeys;

  @override
  State<ProjectRelationGroupSelectionPage> createState() =>
      _ProjectRelationGroupSelectionPageState();
}

class _ProjectRelationGroupSelectionPageState
    extends State<ProjectRelationGroupSelectionPage> {
  late final List<_ArchiveChapter> _chapters;
  late int _selectedTotalCount;

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
    _chapters = _buildArchiveChapters();
    _selectedTotalCount = _countSelected(_chapters);
  }

  List<_ArchiveChapter> _buildArchiveChapters() {
    final orderedChapters = List<StructureChapter>.from(widget.chapters)
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));

    final elementsByChapter = <String?, List<NarrativeElement>>{};
    for (final element in widget.narrativeElements) {
      elementsByChapter.putIfAbsent(
        element.owningChapterId,
        () => <NarrativeElement>[],
      );
      elementsByChapter[element.owningChapterId]!.add(element);
    }
    for (final elements in elementsByChapter.values) {
      elements.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    }

    final chapters = <_ArchiveChapter>[
      for (final chapter in orderedChapters)
        _ArchiveChapter(
          id: chapter.chapterId,
          seq: (chapter.sortOrder + 1).toString().padLeft(2, '0'),
          title: chapter.title,
          elements: _buildArchiveElements(
            elementsByChapter[chapter.chapterId] ?? const <NarrativeElement>[],
          ),
        ),
    ];

    final unassignedElements =
        elementsByChapter[null] ?? const <NarrativeElement>[];
    if (unassignedElements.isNotEmpty) {
      chapters.add(
        _ArchiveChapter(
          id: 'unassigned',
          seq: '--',
          title: '未分配章节',
          elements: _buildArchiveElements(unassignedElements),
        ),
      );
    }

    return chapters;
  }

  List<_ArchiveElement> _buildArchiveElements(List<NarrativeElement> elements) {
    return [
      for (final element in elements)
        _ArchiveElement(
          id: element.elementId,
          title: element.title,
          member: ProjectRelationDraftMember.element(
            elementId: element.elementId,
          ),
          isSelected: widget.initialSelectionKeys.contains(
            _memberKey(
              ProjectRelationDraftMember.element(elementId: element.elementId),
            ),
          ),
          photos: [
            for (final photoPath in element.photoPaths)
              _ArchivePhoto(
                id: '${element.elementId}::$photoPath',
                imageSource: photoPath,
                member: ProjectRelationDraftMember.photo(
                  photoPath: photoPath,
                  sourceElementId: element.elementId,
                ),
                isSelected: widget.initialSelectionKeys.contains(
                  _memberKey(
                    ProjectRelationDraftMember.photo(
                      photoPath: photoPath,
                      sourceElementId: element.elementId,
                    ),
                  ),
                ),
              ),
          ],
        ),
    ];
  }

  int _countSelected(List<_ArchiveChapter> chapters) {
    var count = 0;
    for (final chapter in chapters) {
      for (final element in chapter.elements) {
        if (element.isSelected) {
          count += 1;
        }
        for (final photo in element.photos) {
          if (photo.isSelected) {
            count += 1;
          }
        }
      }
    }
    return count;
  }

  bool get _canCompleteSelection => _selectedTotalCount >= 2;

  String _memberKey(ProjectRelationDraftMember member) {
    switch (member.kind) {
      case ProjectRelationTargetKind.element:
        return 'element:${member.elementId}';
      case ProjectRelationTargetKind.textCard:
        return 'text-card:${member.textCardId}';
      case ProjectRelationTargetKind.photo:
        return 'photo:${member.sourceElementId}:${member.photoPath}';
    }
  }

  void _toggleElement(_ArchiveElement element) {
    setState(() {
      element.isSelected = !element.isSelected;
      _selectedTotalCount = _countSelected(_chapters);
    });
  }

  void _togglePhoto(_ArchivePhoto photo) {
    setState(() {
      photo.isSelected = !photo.isSelected;
      _selectedTotalCount = _countSelected(_chapters);
    });
  }

  void _completeSelection() {
    final selectedMembers = <ProjectRelationDraftMember>[];
    for (final chapter in _chapters) {
      for (final element in chapter.elements) {
        if (element.isSelected) {
          selectedMembers.add(element.member);
        }
        for (final photo in element.photos) {
          if (photo.isSelected) {
            selectedMembers.add(photo.member);
          }
        }
      }
    }
    Navigator.of(context).pop(selectedMembers);
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
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 64),
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  return _buildChapterSection(_chapters[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final displayGroupTitle = widget.relationGroupTitle.trim().isNotEmpty
        ? widget.relationGroupTitle.trim()
        : '新关系组';

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
                  '选择关联内容 · ${widget.relationTypeName}',
                  key: const ValueKey('relationGroupSelectionContextLabel'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                    color: Colors.black.withValues(alpha: 0.38),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayGroupTitle,
                  key: const ValueKey('relationGroupSelectionTitle'),
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
            child: GestureDetector(
              onTap: _canCompleteSelection ? _completeSelection : null,
              child: Container(
                key: const ValueKey('completeRelationGroupSelectionButton'),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  _canCompleteSelection
                      ? '完成 ($_selectedTotalCount)'
                      : _selectedTotalCount == 1
                      ? '至少 2 个'
                      : '完 成',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _canCompleteSelection
                        ? Colors.black87
                        : Colors.black26,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterSection(_ArchiveChapter chapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
          child: Text(
            'C H A P T E R   ${chapter.seq}   /   ${chapter.title}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3.0,
              color: Colors.black45,
            ),
          ),
        ),
        ...chapter.elements.map(_buildElementItem),
      ],
    );
  }

  Widget _buildElementItem(_ArchiveElement element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _toggleElement(element),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
            child: Row(
              children: [
                _buildCustomCheckbox(element.isSelected),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 4,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: _subtleShadow,
                  ),
                  child: const Text(
                    '元 素',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4.0,
                      color: Colors.black38,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    key: ValueKey(
                      'relationSelectionElementTitle-${element.id}',
                    ),
                    element.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: element.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: element.isSelected ? Colors.black : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (element.photos.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 60, right: 24, bottom: 10),
            child: Row(
              children: element.photos
                  .map(
                    (photo) => Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _buildPhotoItem(photo),
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPhotoItem(_ArchivePhoto photo) {
    return GestureDetector(
      onTap: () => _togglePhoto(photo),
      child: Stack(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: _subtleShadow,
              border: Border.all(
                color: photo.isSelected ? Colors.black87 : Colors.transparent,
                width: photo.isSelected ? 2.0 : 0.0,
              ),
            ),
            child: photo.imageSource != null
                ? Image(
                    image: narrativeThumbnailProvider(photo.imageSource!),
                    fit: BoxFit.cover,
                    color: photo.isSelected
                        ? Colors.black.withValues(alpha: 0.2)
                        : null,
                    colorBlendMode: photo.isSelected ? BlendMode.darken : null,
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
          Positioned(
            top: 6,
            right: 6,
            child: _buildCustomCheckbox(photo.isSelected),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(bool isSelected) {
    return Container(
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

class _ArchiveChapter {
  const _ArchiveChapter({
    required this.id,
    required this.seq,
    required this.title,
    required this.elements,
  });

  final String id;
  final String seq;
  final String title;
  final List<_ArchiveElement> elements;
}

class _ArchiveElement {
  _ArchiveElement({
    required this.id,
    required this.title,
    required this.member,
    required this.isSelected,
    required this.photos,
  });

  final String id;
  final String title;
  final ProjectRelationDraftMember member;
  bool isSelected;
  final List<_ArchivePhoto> photos;
}

class _ArchivePhoto {
  _ArchivePhoto({
    required this.id,
    required this.imageSource,
    required this.member,
    required this.isSelected,
  });

  final String id;
  final String? imageSource;
  final ProjectRelationDraftMember member;
  bool isSelected;
}
