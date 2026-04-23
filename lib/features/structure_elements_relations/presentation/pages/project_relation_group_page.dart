import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/project_relation_repository.dart';
import 'package:echo/features/content_cards/domain/entities/text_card.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_group_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_thumbnail_provider.dart';
import 'package:flutter/material.dart';

class ProjectRelationGroupPage extends StatefulWidget {
  const ProjectRelationGroupPage({
    super.key,
    required this.projectId,
    required this.projectRelationRepository,
    required this.relationType,
    required this.relationGroups,
    required this.relationMembers,
    required this.narrativeElements,
    required this.textCards,
    required this.chapters,
    required this.onUpdateRelationType,
    required this.onDeleteRelationType,
  });

  final String projectId;
  final ProjectRelationRepository projectRelationRepository;
  final ProjectRelationType relationType;
  final List<ProjectRelationGroup> relationGroups;
  final List<ProjectRelationMember> relationMembers;
  final List<NarrativeElement> narrativeElements;
  final List<TextCard> textCards;
  final List<StructureChapter> chapters;
  final UpdateProjectRelationType onUpdateRelationType;
  final Future<void> Function() onDeleteRelationType;

  @override
  State<ProjectRelationGroupPage> createState() =>
      _ProjectRelationGroupPageState();
}

class _ProjectRelationGroupPageState extends State<ProjectRelationGroupPage> {
  late ProjectRelationType _relationType;
  late List<ProjectRelationGroup> _relationGroups;
  late List<ProjectRelationMember> _relationMembers;
  bool _didDeleteRelationType = false;

  final List<BoxShadow> _subtleNodeShadow = <BoxShadow>[
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
    _relationType = widget.relationType;
    _relationGroups = List<ProjectRelationGroup>.from(widget.relationGroups);
    _relationMembers = List<ProjectRelationMember>.from(widget.relationMembers);
  }

  List<_RelationGroupCardData> get _realGroupCards {
    final chaptersById = <String, StructureChapter>{
      for (final chapter in widget.chapters) chapter.chapterId: chapter,
    };
    final elementsById = <String, NarrativeElement>{
      for (final element in widget.narrativeElements)
        element.elementId: element,
    };
    final textCardsById = <String, TextCard>{
      for (final card in widget.textCards) card.textCardId: card,
    };

    return _relationGroups
        .where(
          (group) => group.linkedRelationTypeId == _relationType.relationTypeId,
        )
        .map((group) {
          final members =
              _relationMembers
                  .where(
                    (member) => member.owningGroupId == group.relationGroupId,
                  )
                  .toList()
                ..sort(
                  (left, right) =>
                      left.memberSortOrder.compareTo(right.memberSortOrder),
                );
          final nodes = members
              .map(
                (member) => _buildNodeData(
                  member: member,
                  elementsById: elementsById,
                  textCardsById: textCardsById,
                  chaptersById: chaptersById,
                ),
              )
              .toList();

          return _RelationGroupCardData(
            id: group.relationGroupId,
            title: group.title?.trim().isNotEmpty == true
                ? group.title!.trim()
                : _buildRealGroupTitle(nodes),
            description: group.description?.trim() ?? '',
            nodes: nodes,
          );
        })
        .toList();
  }

  _RelationNodeData _buildNodeData({
    required ProjectRelationMember member,
    required Map<String, NarrativeElement> elementsById,
    required Map<String, TextCard> textCardsById,
    required Map<String, StructureChapter> chaptersById,
  }) {
    if (member.kind == 'photo') {
      final sourceElement = elementsById[member.linkedSourceElementId];
      return _RelationNodeData(
        kind: _RelationNodeKind.photo,
        title: sourceElement?.title ?? '未命名照片',
        chapterSeq: _chapterSequence(
          chaptersById[sourceElement?.owningChapterId]?.sortOrder,
        ),
        imageSource: member.linkedPhotoPath,
      );
    }

    if (member.kind == 'textCard') {
      final textCard = textCardsById[member.linkedTextCardId];
      return _RelationNodeData(
        kind: _RelationNodeKind.element,
        title: textCard?.title ?? '未命名文字卡片',
        chapterSeq: _chapterSequence(
          chaptersById[textCard?.owningChapterId]?.sortOrder,
        ),
        imageSource: null,
      );
    }

    final element = elementsById[member.linkedElementId];
    return _RelationNodeData(
      kind: _RelationNodeKind.element,
      title: element?.title ?? '未命名对象',
      chapterSeq: _chapterSequence(
        chaptersById[element?.owningChapterId]?.sortOrder,
      ),
      imageSource: null,
    );
  }

  String _buildRealGroupTitle(List<_RelationNodeData> nodes) {
    if (nodes.isEmpty) {
      return '未命名关联组';
    }
    if (nodes.length == 1) {
      return nodes.first.title;
    }
    if (nodes.length == 2) {
      return '${nodes[0].title} / ${nodes[1].title}';
    }
    return '${nodes[0].title} / ${nodes[1].title} / +${nodes.length - 2}';
  }

  String _chapterSequence(int? sortOrder) {
    if (sortOrder == null) {
      return '--';
    }
    return (sortOrder + 1).toString().padLeft(2, '0');
  }

  int get _availableRelationSelectionCount {
    var count = 0;
    for (final element in widget.narrativeElements) {
      count += 1;
      count += element.photoPaths.length;
    }
    return count;
  }

  Future<void> _openEditRelationTypePage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectRelationCreatePage.edit(
          relationType: _relationType,
          onUpdateRelationType: ({required name, required description}) async {
            final updatedRelationType = await widget.onUpdateRelationType(
              name: name,
              description: description,
            );
            if (mounted) {
              setState(() {
                _relationType = updatedRelationType;
              });
            }
            return updatedRelationType;
          },
          onDeleteRelationType: () async {
            await widget.onDeleteRelationType();
            _didDeleteRelationType = true;
          },
        ),
      ),
    );

    if (_didDeleteRelationType && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openCreateRelationGroupPage() async {
    if (_availableRelationSelectionCount < 2) {
      _showPassiveHint('请先准备至少 2 个可关联对象（元素或照片）');
      return;
    }

    final result = await Navigator.of(context)
        .push<ProjectRelationGroupEditorResult>(
          MaterialPageRoute(
            builder: (_) => ProjectRelationGroupCreatePage(
              relationType: _relationType,
              narrativeElements: widget.narrativeElements,
              textCards: widget.textCards,
              chapters: widget.chapters,
              onCreateRelationGroup:
                  ({
                    required title,
                    required description,
                    required members,
                  }) async {
                    await widget.projectRelationRepository.createRelationGroup(
                      projectId: widget.projectId,
                      relationTypeId: _relationType.relationTypeId,
                      title: title,
                      description: description,
                      members: members,
                    );
                  },
            ),
          ),
        );

    if (result != ProjectRelationGroupEditorResult.saved || !mounted) {
      return;
    }

    final relationGroups = await widget.projectRelationRepository
        .listRelationGroupsForProject(widget.projectId);
    final relationMembers = await widget.projectRelationRepository
        .listRelationMembersForProject(widget.projectId);

    if (!mounted) {
      return;
    }
    setState(() {
      _relationGroups = relationGroups;
      _relationMembers = relationMembers;
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

  ProjectRelationDraftMember? _toDraftMember(ProjectRelationMember member) {
    assert(() {
      if (member.kind == 'photo' &&
          (member.linkedPhotoPath == null ||
              member.linkedSourceElementId == null)) {
        debugPrint(
          'Invalid photo relation member ${member.relationMemberId}: '
          'linkedPhotoPath and linkedSourceElementId are required.',
        );
      }
      if (member.kind == 'textCard' && member.linkedTextCardId == null) {
        debugPrint(
          'Invalid text-card relation member ${member.relationMemberId}: '
          'linkedTextCardId is required.',
        );
      }
      if (member.kind != 'photo' &&
          member.kind != 'textCard' &&
          member.linkedElementId == null) {
        debugPrint(
          'Invalid element relation member ${member.relationMemberId}: '
          'linkedElementId is required.',
        );
      }
      return true;
    }());

    switch (member.kind) {
      case 'photo':
        final photoPath = member.linkedPhotoPath;
        final sourceElementId = member.linkedSourceElementId;
        if (photoPath == null || sourceElementId == null) {
          return null;
        }
        return ProjectRelationDraftMember.photo(
          photoPath: photoPath,
          sourceElementId: sourceElementId,
        );
      case 'textCard':
        final textCardId = member.linkedTextCardId;
        if (textCardId == null) {
          return null;
        }
        return ProjectRelationDraftMember.textCard(textCardId: textCardId);
      default:
        final elementId = member.linkedElementId;
        if (elementId == null) {
          return null;
        }
        return ProjectRelationDraftMember.element(elementId: elementId);
    }
  }

  List<ProjectRelationDraftMember> _toDraftMembers(
    Iterable<ProjectRelationMember> members,
  ) {
    final draftMembers = <ProjectRelationDraftMember>[];
    for (final member in members) {
      final draftMember = _toDraftMember(member);
      if (draftMember != null) {
        draftMembers.add(draftMember);
      }
    }
    return draftMembers;
  }

  Future<void> _openEditRelationGroupPage(_RelationGroupCardData group) async {
    final relationGroup = _relationGroups.firstWhere(
      (item) => item.relationGroupId == group.id,
    );
    final initialMembers =
        _relationMembers
            .where((member) => member.owningGroupId == group.id)
            .toList()
          ..sort(
            (left, right) =>
                left.memberSortOrder.compareTo(right.memberSortOrder),
          );

    final result = await Navigator.of(context)
        .push<ProjectRelationGroupEditorResult>(
          MaterialPageRoute(
            builder: (_) => ProjectRelationGroupCreatePage(
              relationType: _relationType,
              narrativeElements: widget.narrativeElements,
              textCards: widget.textCards,
              chapters: widget.chapters,
              initialTitle: relationGroup.title,
              initialDescription: relationGroup.description,
              initialMembers: _toDraftMembers(initialMembers),
              onCreateRelationGroup:
                  ({
                    required title,
                    required description,
                    required members,
                  }) async {},
              onUpdateRelationGroup:
                  ({
                    required title,
                    required description,
                    required members,
                  }) async {
                    await widget.projectRelationRepository.updateRelationGroup(
                      relationGroupId: relationGroup.relationGroupId,
                      title: title,
                      description: description,
                      members: members,
                    );
                  },
              onDeleteRelationGroup: () async {
                await widget.projectRelationRepository.deleteRelationGroup(
                  relationGroup.relationGroupId,
                );
              },
            ),
          ),
        );

    if ((result != ProjectRelationGroupEditorResult.saved &&
            result != ProjectRelationGroupEditorResult.deleted) ||
        !mounted) {
      return;
    }

    final relationGroups = await widget.projectRelationRepository
        .listRelationGroupsForProject(widget.projectId);
    final relationMembers = await widget.projectRelationRepository
        .listRelationMembersForProject(widget.projectId);

    if (!mounted) {
      return;
    }
    setState(() {
      _relationGroups = relationGroups;
      _relationMembers = relationMembers;
    });
  }

  void _openFullScreenViewer(_RelationGroupCardData group, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _RelationGroupFullScreenViewer(
            relationTypeName: _relationType.name,
            group: group,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final realGroupCards = _realGroupCards;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 64),
                children: [
                  for (final card in realGroupCards) _buildGroupCard(card),
                  _buildAddGroupButton(),
                ],
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
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
                  '关系类型',
                  key: const ValueKey('relationGroupPageScopeLabel'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _relationType.name,
                  key: const ValueKey('relationGroupPageTitle'),
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
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _openEditRelationTypePage,
              child: Container(
                key: const ValueKey('editRelationTypeButton'),
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: const Text(
                  '编辑关系类型',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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

  Widget _buildGroupCard(_RelationGroupCardData group) {
    return InkWell(
      onTap: () => _openEditRelationGroupPage(group),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildThumbnailsChain(group),
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.black.withValues(alpha: 0.03),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (group.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      group.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildThumbnailsChain(_RelationGroupCardData group) {
    final children = <Widget>[];
    for (var index = 0; index < group.nodes.length; index++) {
      children.add(
        _buildThumbnail(group: group, node: group.nodes[index], index: index),
      );
      if (index < group.nodes.length - 1) {
        children.add(const SizedBox(width: 12));
      }
    }
    children.add(const SizedBox(width: 4));
    return children;
  }

  Widget _buildThumbnail({
    required _RelationGroupCardData group,
    required _RelationNodeData node,
    required int index,
  }) {
    final tile = node.kind == _RelationNodeKind.element
        ? _buildElementTile(node)
        : _buildPhotoTile(node);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (node.kind == _RelationNodeKind.photo)
          GestureDetector(
            key: ValueKey('relationGroupThumbnail-${group.id}-$index'),
            onTap: () => _openFullScreenViewer(group, index),
            child: tile,
          )
        else
          tile,
      ],
    );
  }

  Widget _buildPhotoTile(_RelationNodeData node) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12, width: 0.5),
        color: const Color(0xFFF7F7F9),
      ),
      child: node.imageSource != null
          ? Image(
              image: narrativeThumbnailProvider(node.imageSource!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.black26,
                    size: 20,
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'MISSING\nRECORD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7,
                  letterSpacing: 1.0,
                  color: Colors.black26,
                ),
              ),
            ),
    );
  }

  Widget _buildElementTile(_RelationNodeData node) {
    return Container(
      key: ValueKey('relationGroupElementTile-${node.title}'),
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: _subtleNodeShadow,
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
    );
  }

  Widget _buildAddGroupButton() {
    return InkWell(
      key: const ValueKey('addRelationGroupButton'),
      onTap: _openCreateRelationGroupPage,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12, width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: Colors.black54),
            SizedBox(width: 8),
            Text(
              '添 加 关 系 组',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelationGroupCardData {
  const _RelationGroupCardData({
    required this.id,
    required this.title,
    required this.description,
    required this.nodes,
  });

  final String id;
  final String title;
  final String description;
  final List<_RelationNodeData> nodes;
}

class _RelationNodeData {
  const _RelationNodeData({
    required this.kind,
    required this.title,
    required this.chapterSeq,
    required this.imageSource,
  });

  final _RelationNodeKind kind;
  final String title;
  final String chapterSeq;
  final String? imageSource;
}

enum _RelationNodeKind { photo, element }

class _RelationGroupFullScreenViewer extends StatefulWidget {
  const _RelationGroupFullScreenViewer({
    required this.relationTypeName,
    required this.group,
    required this.initialIndex,
  });

  final String relationTypeName;
  final _RelationGroupCardData group;
  final int initialIndex;

  @override
  State<_RelationGroupFullScreenViewer> createState() =>
      _RelationGroupFullScreenViewerState();
}

class _RelationGroupFullScreenViewerState
    extends State<_RelationGroupFullScreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            PageView.builder(
              key: const ValueKey('relationFullscreenPageView'),
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.group.nodes.length,
              itemBuilder: (context, index) {
                final node = widget.group.nodes[index];
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: node.imageSource != null
                        ? Image(
                            image: narrativeThumbnailProvider(
                              node.imageSource!,
                            ),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFullScreenErrorPlaceholder();
                            },
                          )
                        : _buildFullScreenPlaceholder(),
                  ),
                );
              },
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showUI ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        key: const ValueKey('relationFullscreenCloseButton'),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          widget.relationTypeName,
                          key: const ValueKey('relationFullscreenTypeLabel'),
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 4.0,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showUI ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      40,
                      24,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                widget.group.nodes[_currentIndex].chapterSeq ==
                                        '--'
                                    ? 'CH.--'
                                    : 'CH.${widget.group.nodes[_currentIndex].chapterSeq}',
                                key: const ValueKey(
                                  'relationFullscreenChapterBadge',
                                ),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.group.nodes[_currentIndex].title,
                                key: const ValueKey(
                                  'relationFullscreenNodeTitle',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_currentIndex + 1} / ${widget.group.nodes.length}',
                              key: const ValueKey('relationFullscreenCounter'),
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 2.0,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildFullScreenPlaceholder() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: const AspectRatio(
        aspectRatio: 3 / 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.crop_free, color: Colors.white24, size: 48),
              SizedBox(height: 24),
              _ViewerLabel(text: 'MISSING RECORD'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenErrorPlaceholder() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: const AspectRatio(
        aspectRatio: 3 / 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                color: Colors.white24,
                size: 48,
              ),
              SizedBox(height: 24),
              _ViewerLabel(text: 'IMAGE UNAVAILABLE'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewerLabel extends StatelessWidget {
  const _ViewerLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 4.0,
          color: Colors.white38,
        ),
      ),
    );
  }
}
