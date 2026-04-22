import 'dart:ui';

import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/beacon/presentation/pages/beacon_page_prototype.dart';
import 'package:echo/features/curation/presentation/pages/global_arrange_page.dart';
import 'package:echo/features/curation/presentation/pages/organize_page_prototype.dart';
import 'package:echo/features/project/presentation/pages/project_edit_page.dart';
import 'package:echo/features/project/presentation/pages/no_project_prompt_page.dart';
import 'package:echo/features/project/presentation/pages/project_wizard_page.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/project/presentation/widgets/project_sidebar.dart';
import 'package:echo/features/structure_elements_relations/domain/element_status.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/project_relation_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/structure_chapter_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/narrative_element_draft.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_chapter_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_relation_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/chapter_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/narrative_element_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_group_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/structure_page_prototype.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page_prototype.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/quick_record_overlay_prototype.dart';
import 'package:flutter/material.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    super.key,
    required this.projectRepository,
    required this.structureChapterRepository,
    required this.narrativeElementRepository,
    required this.projectRelationRepository,
    this.narrativeElementPhotoPicker,
    this.narrativeElementPhotoImporter,
  });

  final ProjectRepository projectRepository;
  final StructureChapterRepository structureChapterRepository;
  final NarrativeElementRepository narrativeElementRepository;
  final ProjectRelationRepository projectRelationRepository;
  final PickGalleryImages? narrativeElementPhotoPicker;
  final ImportNarrativePhoto? narrativeElementPhotoImporter;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  PrototypeTab _currentTab = PrototypeTab.structure;
  bool _sidebarOpen = false;
  bool _showAddOverlay = false;
  int _currentTabIndex = 0;
  Project? _currentProject;
  List<Project> _projects = const <Project>[];
  List<StructureChapter> _structureChapters = const <StructureChapter>[];
  List<NarrativeElement> _narrativeElements = const <NarrativeElement>[];
  List<ProjectRelationType> _relationTypes = const <ProjectRelationType>[];
  List<ProjectRelationGroup> _relationGroups = const <ProjectRelationGroup>[];
  List<ProjectRelationMember> _relationMembers =
      const <ProjectRelationMember>[];
  List<StructureChapterCardData> _chapterCards =
      const <StructureChapterCardData>[];
  List<Map<String, dynamic>> _narrativeElementGroups =
      const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showAddOverlay,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showAddOverlay) {
          setState(() {
            _showAddOverlay = false;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildCurrentPage(),
            if (_showAddOverlay) ...[
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(color: Colors.white.withValues(alpha: 0.18)),
                ),
              ),
              Positioned(
                top: 120,
                left: 20,
                right: 20,
                bottom: 80,
                child: QuickRecordOverlayPrototype(
                  onClose: () => setState(() => _showAddOverlay = false),
                  onBottomTabChanged: (_) {},
                ),
              ),
            ],
            if (_sidebarOpen) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _sidebarOpen = false),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: ProjectSidebar(
                  projects: _projects,
                  currentProjectId: _currentProject?.projectId,
                  onNewProject: () async {
                    setState(() {
                      _sidebarOpen = false;
                      _currentTab = PrototypeTab.structure;
                      _currentTabIndex = 0;
                    });
                    await _openProjectWizard();
                  },
                  onEditProject: (project) async {
                    if (!mounted) {
                      return;
                    }
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProjectEditPage(
                          project: project,
                          onSave:
                              (title, themeStatement, coverImagePath) async {
                                await widget.projectRepository.updateProject(
                                  projectId: project.projectId,
                                  title: title,
                                  themeStatement: themeStatement,
                                  coverImagePath: coverImagePath,
                                );
                                await _refreshProjects();
                              },
                        ),
                      ),
                    );
                  },
                  onArchiveProject: (project) async {
                    await widget.projectRepository.archiveProject(
                      project.projectId,
                    );
                    await _refreshProjects();
                  },
                  onDeleteProject: (project) async {
                    await widget.projectRepository.deleteProject(
                      project.projectId,
                    );
                    await _refreshProjects();
                  },
                  onSelectProject: (projectId) async {
                    await widget.projectRepository.setCurrentProject(projectId);
                    await _refreshProjects();
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _currentTab = PrototypeTab.structure;
                      _currentTabIndex = 0;
                      _sidebarOpen = false;
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    if (_projects.isEmpty) {
      return NoProjectPromptPage(
        onOpenSidebar: () => setState(() => _sidebarOpen = true),
        onCreateProject: _openProjectWizard,
      );
    }

    switch (_currentTab) {
      case PrototypeTab.structure:
      case PrototypeTab.add:
        return StructurePagePrototype(
          currentTabIndex: _currentTabIndex,
          chapterCards: _chapterCards,
          elementGroups: _narrativeElementGroups,
          relationCards: _buildRelationCards(),
          projectTitle: _currentProject?.title ?? '',
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onAddChapter: () async {
            if (_currentProject == null) {
              return;
            }
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChapterCreatePage(
                  existingChapters: _structureChapters,
                  onSave:
                      ({
                        required String title,
                        required String description,
                        required int sortOrder,
                        required String statusLabel,
                        required List<NarrativeElementDraft> elements,
                      }) async {
                        final chapter = await widget.structureChapterRepository
                            .createChapter(
                              projectId: _currentProject!.projectId,
                              title: title,
                              description: description,
                              sortOrder: sortOrder,
                            );
                        for (final element in elements) {
                          await widget.narrativeElementRepository.createElement(
                            projectId: _currentProject!.projectId,
                            chapterId: chapter.chapterId,
                            title: element.title,
                            description: element.description,
                            status: element.status,
                            photoPaths: element.photoPaths,
                          );
                        }
                        await _refreshProjects();
                      },
                ),
              ),
            );
          },
          onOpenChapter: (index) async {
            if (_currentProject == null ||
                index < 0 ||
                index >= _structureChapters.length) {
              return;
            }
            final chapter = _structureChapters[index];
            final chapterElements = _narrativeElements
                .where(
                  (element) => element.owningChapterId == chapter.chapterId,
                )
                .toList();
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChapterEditPage(
                  existingChapters: _structureChapters,
                  chapter: chapter,
                  existingElements: chapterElements,
                  onOpenExistingElement: (element) async {
                    return _openNarrativeElementEditor(
                      element: element,
                      allowChapterSelection: false,
                    );
                  },
                  onSave:
                      ({
                        required String title,
                        required String description,
                        required int sortOrder,
                        required String statusLabel,
                        required List<NarrativeElementDraft> elements,
                      }) async {
                        await _persistChapterEdits(
                          chapter: chapter,
                          title: title,
                          description: description,
                          sortOrder: sortOrder,
                          statusLabel: statusLabel,
                          newElements: elements,
                        );
                      },
                  onDelete: () async {
                    await _deleteChapter(chapter);
                  },
                  onComplete:
                      ({
                        required String title,
                        required String description,
                        required int sortOrder,
                        required String statusLabel,
                        required List<NarrativeElementDraft> elements,
                      }) async {
                        await _persistChapterEdits(
                          chapter: chapter,
                          title: title,
                          description: description,
                          sortOrder: sortOrder,
                          statusLabel: statusLabel,
                          newElements: elements,
                          persistChapterLast: true,
                        );
                      },
                ),
              ),
            );
          },
          onAddElement: () async {
            if (_currentProject == null) {
              return;
            }
            if (_structureChapters.isEmpty) {
              _showPassiveHint('请先添加章节');
              return;
            }
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NarrativeElementCreatePage(
                  chapters: _structureChapters,
                  onSave:
                      ({
                        required String title,
                        required String description,
                        required String? chapterId,
                        required String status,
                        required String? unlockChapterId,
                        required List<String> photoPaths,
                      }) async {
                        await widget.narrativeElementRepository.createElement(
                          projectId: _currentProject!.projectId,
                          chapterId: chapterId,
                          title: title,
                          description: description,
                          status: status,
                          photoPaths: photoPaths,
                        );
                        if (unlockChapterId != null) {
                          await _unlockStructureChapterById(unlockChapterId);
                        }
                        await _refreshProjects();
                      },
                  onPickPhoto: widget.narrativeElementPhotoPicker,
                  onImportPhoto: widget.narrativeElementPhotoImporter,
                ),
              ),
            );
          },
          onOpenElement: (elementId) async {
            if (_currentProject == null) {
              return;
            }
            NarrativeElement? selectedElement;
            for (final element in _narrativeElements) {
              if (element.elementId == elementId) {
                selectedElement = element;
                break;
              }
            }
            if (selectedElement == null) {
              return;
            }
            await _openNarrativeElementEditor(
              element: selectedElement,
              allowChapterSelection: true,
            );
          },
          onAddRelation: () async {
            if (_currentProject == null) {
              return;
            }
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectRelationCreatePage(
                  onCreateRelationType:
                      ({required name, required description}) async {
                        final relationType = await widget
                            .projectRelationRepository
                            .createRelationType(
                              projectId: _currentProject!.projectId,
                              name: name,
                              description: description,
                            );
                        await _refreshProjects();
                        return relationType;
                      },
                ),
              ),
            );
          },
          onOpenRelation: (index) async {
            if (_currentProject == null ||
                index < 0 ||
                index >= _relationTypes.length) {
              return;
            }
            final relationType = _relationTypes[index];
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectRelationGroupPage(
                  projectId: _currentProject!.projectId,
                  projectRelationRepository: widget.projectRelationRepository,
                  relationType: relationType,
                  relationGroups: _relationGroups,
                  relationMembers: _relationMembers,
                  narrativeElements: _narrativeElements,
                  chapters: _structureChapters,
                  onUpdateRelationType:
                      ({required name, required description}) async {
                        final updatedRelationType = await widget
                            .projectRelationRepository
                            .updateRelationType(
                              relationTypeId: relationType.relationTypeId,
                              name: name,
                              description: description,
                            );
                        await _refreshProjects();
                        return updatedRelationType;
                      },
                  onDeleteRelationType: () async {
                    await _deleteRelationType(relationType);
                  },
                ),
              ),
            );
            await _refreshProjects();
          },
          onTabChanged: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.curation:
        return GlobalArrangePage(
          projectTitle: _currentProject?.title ?? '',
          boardData: _buildGlobalArrangeBoardData(),
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
          onOpenPendingOrganize: _openPendingOrganizePage,
          onMoveChapter: _moveChapter,
          onMoveElement: _moveElement,
          onMovePhoto: _movePhoto,
        );
      case PrototypeTab.overview:
        return BeaconPagePrototype(
          projectTitle: _currentProject?.title ?? '',
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.timeline:
        return TimelinePagePrototype(
          projectTitle: _currentProject?.title ?? '',
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
        );
    }
  }

  void _changeTab(PrototypeTab tab) {
    if (tab == PrototypeTab.add) {
      setState(() {
        _showAddOverlay = true;
        _sidebarOpen = false;
      });
      return;
    }

    setState(() {
      _currentTab = tab;
      _sidebarOpen = false;
      _showAddOverlay = false;
    });
  }

  Future<void> _loadProjects() async {
    await _refreshProjects();
  }

  Future<void> _openProjectWizard() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectWizardPage(
          onFinish: (title, themeStatement, coverImagePath) async {
            await widget.projectRepository.createProject(
              title: title,
              themeStatement: themeStatement,
              coverImagePath: coverImagePath,
            );
            await _refreshProjects();
            if (!mounted) {
              return;
            }
            setState(() {
              _currentTab = PrototypeTab.structure;
              _currentTabIndex = 0;
              _sidebarOpen = false;
              _showAddOverlay = false;
            });
          },
        ),
      ),
    );
  }

  Future<void> _refreshProjects() async {
    final currentProject = await widget.projectRepository.getCurrentProject();
    final projects = await widget.projectRepository.listProjects();
    final chapters = currentProject == null
        ? const <StructureChapter>[]
        : await widget.structureChapterRepository.listChaptersForProject(
            currentProject.projectId,
          );
    final elements = currentProject == null
        ? const <NarrativeElement>[]
        : await widget.narrativeElementRepository.listElementsForProject(
            currentProject.projectId,
          );
    final relationTypes = currentProject == null
        ? const <ProjectRelationType>[]
        : await widget.projectRelationRepository.listRelationTypesForProject(
            currentProject.projectId,
          );
    final relationGroups = currentProject == null
        ? const <ProjectRelationGroup>[]
        : await widget.projectRelationRepository.listRelationGroupsForProject(
            currentProject.projectId,
          );
    final relationMembers = currentProject == null
        ? const <ProjectRelationMember>[]
        : await widget.projectRelationRepository.listRelationMembersForProject(
            currentProject.projectId,
          );
    if (!mounted) {
      return;
    }

    setState(() {
      _currentProject = currentProject;
      _projects = projects;
      _structureChapters = chapters;
      _narrativeElements = elements;
      _relationTypes = relationTypes;
      _relationGroups = relationGroups;
      _relationMembers = relationMembers;
      _chapterCards = _buildChapterCards(
        chapters: chapters,
        elements: elements,
      );
      _narrativeElementGroups = _groupNarrativeElements(
        chapters: chapters,
        elements: elements,
      );
    });
  }

  List<Map<String, dynamic>> _groupNarrativeElements({
    required List<StructureChapter> chapters,
    required List<NarrativeElement> elements,
  }) {
    final chapterTitles = <String, String>{
      for (var index = 0; index < chapters.length; index++)
        chapters[index].chapterId:
            'C H A P T E R  ${(index + 1).toString().padLeft(2, '0')}  /  ${chapters[index].title}',
    };

    final grouped = <String?, List<Map<String, dynamic>>>{};
    for (final element in elements) {
      final chapterKey = chapterTitles.containsKey(element.owningChapterId)
          ? element.owningChapterId
          : null;
      grouped.putIfAbsent(chapterKey, () => <Map<String, dynamic>>[]);
      grouped[chapterKey]!.add(<String, dynamic>{
        'id': element.elementId,
        'title': element.title,
        'desc': element.description?.trim() ?? '',
        'status': element.status == 'ready'
            ? ElementStatus.ready
            : ElementStatus.finding,
        'images': element.photoPaths,
      });
    }

    final orderedGroups = <Map<String, dynamic>>[];
    for (final chapter in chapters) {
      final chapterElements = grouped[chapter.chapterId];
      if (chapterElements == null || chapterElements.isEmpty) {
        continue;
      }
      orderedGroups.add(<String, dynamic>{
        'chapter': chapterTitles[chapter.chapterId] ?? '未 分 配 章 节',
        'elements': chapterElements,
      });
    }

    final unassignedElements = grouped[null];
    if (unassignedElements != null && unassignedElements.isNotEmpty) {
      orderedGroups.add(<String, dynamic>{
        'chapter': '未 分 配 章 节',
        'elements': unassignedElements,
      });
    }

    return orderedGroups;
  }

  List<StructureChapterCardData> _buildChapterCards({
    required List<StructureChapter> chapters,
    required List<NarrativeElement> elements,
  }) {
    final elementsByChapter = <String, List<NarrativeElement>>{};
    for (final element in elements) {
      final chapterId = element.owningChapterId;
      if (chapterId == null) {
        continue;
      }
      elementsByChapter.putIfAbsent(chapterId, () => <NarrativeElement>[]);
      elementsByChapter[chapterId]!.add(element);
    }

    return [
      for (var index = 0; index < chapters.length; index++)
        StructureChapterCardData(
          chapterNumber: (index + 1).toString().padLeft(2, '0'),
          title: chapters[index].title,
          description: chapters[index].description?.trim().isNotEmpty == true
              ? chapters[index].description!
              : '暂无章节说明',
          statusLabel: _normalizeChapterStatus(chapters[index].statusLabel),
          elementCount:
              elementsByChapter[chapters[index].chapterId]?.length ?? 0,
          previewImageSources: _chapterPreviewImageSources(
            elementsByChapter[chapters[index].chapterId] ??
                const <NarrativeElement>[],
          ),
        ),
    ];
  }

  String _normalizeChapterStatus(String statusLabel) {
    return statusLabel == '完成' ? '完成' : '进行';
  }

  Future<void> _persistChapterEdits({
    required StructureChapter chapter,
    required String title,
    required String description,
    required int sortOrder,
    required String statusLabel,
    required List<NarrativeElementDraft> newElements,
    bool persistChapterLast = false,
  }) async {
    Future<void> persistChapter() async {
      await widget.structureChapterRepository.updateChapter(
        chapterId: chapter.chapterId,
        title: title,
        description: description,
        sortOrder: sortOrder,
        statusLabel: statusLabel,
      );
    }

    Future<void> persistNewElements() async {
      for (final element in newElements) {
        await widget.narrativeElementRepository.createElement(
          projectId: chapter.owningProjectId,
          chapterId: chapter.chapterId,
          title: element.title,
          description: element.description,
          status: element.status,
          photoPaths: element.photoPaths,
        );
      }
    }

    Future<void> markExistingElementsReady() async {
      if (statusLabel != '完成') {
        return;
      }
      for (final element in _narrativeElements) {
        if (element.owningChapterId != chapter.chapterId) {
          continue;
        }
        await widget.narrativeElementRepository.updateElement(
          elementId: element.elementId,
          title: element.title,
          description: element.description,
          chapterId: element.owningChapterId,
          status: 'ready',
          photoPaths: element.photoPaths,
        );
      }
    }

    if (persistChapterLast) {
      await markExistingElementsReady();
      await persistNewElements();
      await persistChapter();
    } else {
      await persistChapter();
      await persistNewElements();
    }

    await _refreshProjects();
  }

  Future<void> _deleteChapter(StructureChapter chapter) async {
    final chapterElements = _narrativeElements
        .where((element) => element.owningChapterId == chapter.chapterId)
        .toList();

    for (final element in chapterElements) {
      await widget.narrativeElementRepository.updateElement(
        elementId: element.elementId,
        title: element.title,
        description: element.description,
        chapterId: null,
        status: element.status,
        photoPaths: element.photoPaths,
      );
    }

    final deleted = await widget.structureChapterRepository.deleteChapter(
      chapter.chapterId,
    );
    if (!deleted) {
      throw StateError(
        'Failed to delete structure chapter: ${chapter.chapterId}',
      );
    }

    await _refreshProjects();
  }

  Future<void> _persistElementEdits({
    required NarrativeElement element,
    required String title,
    required String description,
    required String? chapterId,
    required String status,
    required String? unlockChapterId,
    required List<String> photoPaths,
  }) async {
    await widget.narrativeElementRepository.updateElement(
      elementId: element.elementId,
      title: title,
      description: description,
      chapterId: chapterId,
      status: status,
      photoPaths: photoPaths,
    );
    if (unlockChapterId != null) {
      await _unlockStructureChapterById(unlockChapterId);
    }
    await _refreshProjects();
  }

  Future<void> _unlockStructureChapterById(String unlockChapterId) async {
    StructureChapter? chapterToUnlock;
    for (final chapter in _structureChapters) {
      if (chapter.chapterId == unlockChapterId) {
        chapterToUnlock = chapter;
        break;
      }
    }
    if (chapterToUnlock == null) {
      throw StateError('Structure chapter not found: $unlockChapterId');
    }
    final updatedChapter = await widget.structureChapterRepository
        .updateChapter(
          chapterId: chapterToUnlock.chapterId,
          title: chapterToUnlock.title,
          description: chapterToUnlock.description,
          sortOrder: chapterToUnlock.sortOrder,
          statusLabel: '进行',
        );
    if (updatedChapter == null) {
      throw StateError('Failed to unlock structure chapter: $unlockChapterId');
    }
  }

  Future<void> _deleteElement(NarrativeElement element) async {
    await _deleteRelationGroupsReferencingElement(element.elementId);

    final deleted = await widget.narrativeElementRepository.deleteElement(
      element.elementId,
    );
    if (!deleted) {
      throw StateError(
        'Failed to delete narrative element: ${element.elementId}',
      );
    }

    await _refreshProjects();
  }

  Future<void> _deleteRelationGroupsReferencingElement(String elementId) async {
    final relationGroupIds = _relationMembers
        .where(
          (member) =>
              member.linkedElementId == elementId ||
              member.linkedSourceElementId == elementId,
        )
        .map((member) => member.owningGroupId)
        .toSet();

    for (final relationGroupId in relationGroupIds) {
      await widget.projectRelationRepository.deleteRelationGroup(
        relationGroupId,
      );
    }
  }

  Future<void> _deleteRelationType(ProjectRelationType relationType) async {
    final deleted = await widget.projectRelationRepository.deleteRelationType(
      relationType.relationTypeId,
    );
    if (!deleted) {
      throw StateError(
        'Failed to delete project relation type: ${relationType.relationTypeId}',
      );
    }

    await _refreshProjects();
  }

  Future<ChapterElementEditorResult?> _openNarrativeElementEditor({
    required NarrativeElement element,
    required bool allowChapterSelection,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NarrativeElementEditPage(
          chapters: _structureChapters,
          element: element,
          allowChapterSelection: allowChapterSelection,
          onSave:
              ({
                required String title,
                required String description,
                required String? chapterId,
                required String status,
                required String? unlockChapterId,
                required List<String> photoPaths,
              }) async {
                await _persistElementEdits(
                  element: element,
                  title: title,
                  description: description,
                  chapterId: chapterId,
                  status: status,
                  unlockChapterId: unlockChapterId,
                  photoPaths: photoPaths,
                );
              },
          onDelete: () async {
            await _deleteElement(element);
          },
          onComplete:
              ({
                required String title,
                required String description,
                required String? chapterId,
                required String status,
                required String? unlockChapterId,
                required List<String> photoPaths,
              }) async {
                await _persistElementEdits(
                  element: element,
                  title: title,
                  description: description,
                  chapterId: chapterId,
                  status: status,
                  unlockChapterId: unlockChapterId,
                  photoPaths: photoPaths,
                );
              },
        ),
      ),
    );

    for (final updatedElement in _narrativeElements) {
      if (updatedElement.elementId == element.elementId) {
        return ChapterElementEditorResult.updated(updatedElement);
      }
    }
    return ChapterElementEditorResult.deleted(element.elementId);
  }

  List<String> _chapterPreviewImageSources(List<NarrativeElement> elements) {
    final previewPhotos = <_ChapterPreviewPhoto>[];

    for (final element in elements) {
      if (element.photoPaths.isEmpty) {
        continue;
      }

      for (var index = element.photoPaths.length - 1; index >= 0; index--) {
        previewPhotos.add(
          _ChapterPreviewPhoto(
            source: element.photoPaths[index],
            sortTime: element.updatedAt,
            photoOrder: index,
          ),
        );
      }
    }

    previewPhotos.sort((left, right) {
      final timeCompare = right.sortTime.compareTo(left.sortTime);
      if (timeCompare != 0) {
        return timeCompare;
      }
      return right.photoOrder.compareTo(left.photoOrder);
    });

    return previewPhotos.map((photo) => photo.source).toList();
  }

  List<StructureRelationCardData> _buildRelationCards() {
    final groupCounts = <String, int>{};
    for (final group in _relationGroups) {
      groupCounts.update(
        group.linkedRelationTypeId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return [
      for (final relationType in _relationTypes)
        StructureRelationCardData(
          relationTypeId: relationType.relationTypeId,
          name: relationType.name,
          description: relationType.description,
          setCount: groupCounts[relationType.relationTypeId] ?? 0,
        ),
    ];
  }

  GlobalArrangeBoardData _buildGlobalArrangeBoardData() {
    final relationTypeNamesById = <String, String>{
      for (final relationType in _relationTypes)
        relationType.relationTypeId: relationType.name,
    };
    final relationTagOrderByName = <String, int>{
      for (final relationType in _relationTypes)
        relationType.name: relationType.sortOrder,
    };
    final elementTagsById = <String, Set<String>>{};
    final photoTagsByKey = <String, Set<String>>{};

    for (final relationGroup in _relationGroups) {
      final relationTag =
          relationTypeNamesById[relationGroup.linkedRelationTypeId];
      if (relationTag == null) {
        continue;
      }
      for (final member in _relationMembers) {
        if (member.owningGroupId != relationGroup.relationGroupId) {
          continue;
        }
        if (member.kind == ProjectRelationTargetKind.element.name &&
            member.linkedElementId != null) {
          elementTagsById.putIfAbsent(
            member.linkedElementId!,
            () => <String>{},
          );
          elementTagsById[member.linkedElementId!]!.add(relationTag);
        }
        if (member.kind == ProjectRelationTargetKind.photo.name &&
            member.linkedSourceElementId != null &&
            member.linkedPhotoPath != null) {
          final key =
              '${member.linkedSourceElementId}::${member.linkedPhotoPath}';
          photoTagsByKey.putIfAbsent(key, () => <String>{});
          photoTagsByKey[key]!.add(relationTag);
        }
      }
    }

    List<String> sortTags(Iterable<String> tags) {
      final sortedTags = tags.toList(growable: false);
      sortedTags.sort((left, right) {
        final orderCompare = (relationTagOrderByName[left] ?? 1 << 20)
            .compareTo(relationTagOrderByName[right] ?? 1 << 20);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return left.compareTo(right);
      });
      return sortedTags;
    }

    List<GlobalArrangeElementData> buildElements(String? chapterId) {
      final chapterElements =
          _narrativeElements
              .where((element) => element.owningChapterId == chapterId)
              .toList()
            ..sort((left, right) {
              final sortCompare = left.sortOrder.compareTo(right.sortOrder);
              if (sortCompare != 0) {
                return sortCompare;
              }
              return left.createdAt.compareTo(right.createdAt);
            });

      return [
        for (final element in chapterElements)
          GlobalArrangeElementData(
            elementId: element.elementId,
            title: element.title,
            relationTags: sortTags(
              elementTagsById[element.elementId] ?? const <String>{},
            ),
            photos: [
              for (var index = 0; index < element.photoPaths.length; index++)
                GlobalArrangePhotoData(
                  photoId:
                      '${element.elementId}::$index::${element.photoPaths[index]}',
                  imageSource: element.photoPaths[index],
                  relationTags: sortTags(
                    photoTagsByKey['${element.elementId}::${element.photoPaths[index]}'] ??
                        const <String>{},
                  ),
                ),
            ],
          ),
      ];
    }

    return GlobalArrangeBoardData(
      chapters: [
        for (final chapter in _structureChapters)
          GlobalArrangeChapterData(
            chapterId: chapter.chapterId,
            title: chapter.title,
            elements: buildElements(chapter.chapterId),
          ),
      ],
      unassignedElements: buildElements(null),
    );
  }

  Future<void> _moveChapter({
    required String chapterId,
    required int targetIndex,
  }) async {
    StructureChapter? chapter;
    for (final currentChapter in _structureChapters) {
      if (currentChapter.chapterId == chapterId) {
        chapter = currentChapter;
        break;
      }
    }
    if (chapter == null) {
      return;
    }

    await widget.structureChapterRepository.updateChapter(
      chapterId: chapter.chapterId,
      title: chapter.title,
      description: chapter.description,
      sortOrder: targetIndex,
      statusLabel: chapter.statusLabel,
    );
    await _refreshProjects();
  }

  Future<void> _moveElement({
    required String elementId,
    required String? targetChapterId,
    required int targetIndex,
  }) async {
    NarrativeElement? element;
    for (final currentElement in _narrativeElements) {
      if (currentElement.elementId == elementId) {
        element = currentElement;
        break;
      }
    }
    if (element == null) {
      return;
    }

    await widget.narrativeElementRepository.updateElement(
      elementId: element.elementId,
      title: element.title,
      description: element.description,
      chapterId: targetChapterId,
      status: element.status,
      sortOrder: targetIndex,
      photoPaths: element.photoPaths,
    );
    await _refreshProjects();
  }

  Future<void> _movePhoto({
    required String sourceElementId,
    required int sourcePhotoIndex,
    required String targetElementId,
    required int targetPhotoIndex,
  }) async {
    NarrativeElement? sourceElement;
    NarrativeElement? targetElement;
    for (final element in _narrativeElements) {
      if (element.elementId == sourceElementId) {
        sourceElement = element;
      }
      if (element.elementId == targetElementId) {
        targetElement = element;
      }
    }
    if (sourceElement == null || targetElement == null) {
      return;
    }
    if (sourcePhotoIndex < 0 ||
        sourcePhotoIndex >= sourceElement.photoPaths.length) {
      return;
    }

    final movedPhotoPath = sourceElement.photoPaths[sourcePhotoIndex];
    final updatedSourcePhotos = List<String>.from(sourceElement.photoPaths)
      ..removeAt(sourcePhotoIndex);

    if (sourceElementId == targetElementId) {
      final normalizedTargetIndex = targetPhotoIndex.clamp(
        0,
        updatedSourcePhotos.length,
      );
      updatedSourcePhotos.insert(normalizedTargetIndex, movedPhotoPath);
      await widget.narrativeElementRepository.updateElement(
        elementId: sourceElement.elementId,
        title: sourceElement.title,
        description: sourceElement.description,
        chapterId: sourceElement.owningChapterId,
        status: sourceElement.status,
        photoPaths: updatedSourcePhotos,
      );
      await _refreshProjects();
      return;
    }

    final updatedTargetPhotos = List<String>.from(targetElement.photoPaths);
    final normalizedTargetIndex = targetPhotoIndex.clamp(
      0,
      updatedTargetPhotos.length,
    );
    updatedTargetPhotos.insert(normalizedTargetIndex, movedPhotoPath);

    await widget.narrativeElementRepository.updateElement(
      elementId: sourceElement.elementId,
      title: sourceElement.title,
      description: sourceElement.description,
      chapterId: sourceElement.owningChapterId,
      status: sourceElement.status,
      photoPaths: updatedSourcePhotos,
    );
    await widget.narrativeElementRepository.updateElement(
      elementId: targetElement.elementId,
      title: targetElement.title,
      description: targetElement.description,
      chapterId: targetElement.owningChapterId,
      status: targetElement.status,
      photoPaths: updatedTargetPhotos,
    );

    await _relinkPhotoMembers(
      oldSourceElementId: sourceElementId,
      newSourceElementId: targetElementId,
      photoPath: movedPhotoPath,
    );
    await _refreshProjects();
  }

  Future<void> _relinkPhotoMembers({
    required String oldSourceElementId,
    required String newSourceElementId,
    required String photoPath,
  }) async {
    if (oldSourceElementId == newSourceElementId) {
      return;
    }

    final affectedGroupIds = _relationMembers
        .where(
          (member) =>
              member.kind == ProjectRelationTargetKind.photo.name &&
              member.linkedSourceElementId == oldSourceElementId &&
              member.linkedPhotoPath == photoPath,
        )
        .map((member) => member.owningGroupId)
        .toSet();

    for (final groupId in affectedGroupIds) {
      ProjectRelationGroup? relationGroup;
      for (final group in _relationGroups) {
        if (group.relationGroupId == groupId) {
          relationGroup = group;
          break;
        }
      }
      if (relationGroup == null) {
        continue;
      }

      final groupMembers =
          _relationMembers
              .where((member) => member.owningGroupId == groupId)
              .toList()
            ..sort(
              (left, right) =>
                  left.memberSortOrder.compareTo(right.memberSortOrder),
            );

      final draftMembers = <ProjectRelationDraftMember>[
        for (final member in groupMembers)
          if (member.kind == ProjectRelationTargetKind.element.name &&
              member.linkedElementId != null)
            ProjectRelationDraftMember.element(
              elementId: member.linkedElementId!,
            )
          else if (member.kind == ProjectRelationTargetKind.photo.name &&
              member.linkedPhotoPath != null &&
              member.linkedSourceElementId != null)
            ProjectRelationDraftMember.photo(
              photoPath: member.linkedPhotoPath!,
              sourceElementId:
                  member.linkedSourceElementId == oldSourceElementId &&
                      member.linkedPhotoPath == photoPath
                  ? newSourceElementId
                  : member.linkedSourceElementId!,
            ),
      ];

      await widget.projectRelationRepository.updateRelationGroup(
        relationGroupId: relationGroup.relationGroupId,
        title: relationGroup.title,
        description: relationGroup.description,
        members: draftMembers,
      );
    }
  }

  Future<void> _openPendingOrganizePage() async {
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) {
          return OrganizePagePrototype(
            projectTitle: _currentProject?.title ?? '',
            onOpenSidebar: () {},
            onBottomTabChanged: (tab) {
              Navigator.of(routeContext).pop();
              if (tab != PrototypeTab.curation) {
                _changeTab(tab);
              }
            },
          );
        },
      ),
    );
  }

  void _showPassiveHint(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(left: 88, right: 88, bottom: 96),
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(),
      ),
    );
  }
}

class _ChapterPreviewPhoto {
  const _ChapterPreviewPhoto({
    required this.source,
    required this.sortTime,
    required this.photoOrder,
  });

  final String source;
  final DateTime sortTime;
  final int photoOrder;
}
