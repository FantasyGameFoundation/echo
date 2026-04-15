import 'dart:ui';

import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/beacon/presentation/pages/beacon_page_prototype.dart';
import 'package:echo/features/curation/presentation/pages/organize_page_prototype.dart';
import 'package:echo/features/project/presentation/pages/project_edit_page.dart';
import 'package:echo/features/project/presentation/pages/no_project_prompt_page.dart';
import 'package:echo/features/project/presentation/pages/project_wizard_page.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/project/presentation/widgets/project_sidebar.dart';
import 'package:echo/features/structure_elements_relations/domain/element_status.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/structure_chapter_repository.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/narrative_element_draft.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_chapter_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/chapter_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/narrative_element_create_page.dart';
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
    this.narrativeElementPhotoPicker,
    this.narrativeElementPhotoImporter,
  });

  final ProjectRepository projectRepository;
  final StructureChapterRepository structureChapterRepository;
  final NarrativeElementRepository narrativeElementRepository;
  final PickProjectCoverImage? narrativeElementPhotoPicker;
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
                            photoPaths: element.photoPaths,
                          );
                        }
                        await _refreshProjects();
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
                        required List<String> photoPaths,
                      }) async {
                        await widget.narrativeElementRepository.createElement(
                          projectId: _currentProject!.projectId,
                          chapterId: chapterId,
                          title: title,
                          description: description,
                          photoPaths: photoPaths,
                        );
                        await _refreshProjects();
                      },
                  onPickPhoto: widget.narrativeElementPhotoPicker,
                  onImportPhoto: widget.narrativeElementPhotoImporter,
                ),
              ),
            );
          },
          onTabChanged: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          onBottomTabChanged: _changeTab,
        );
      case PrototypeTab.curation:
        return OrganizePagePrototype(
          projectTitle: _currentProject?.title ?? '',
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
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
    if (!mounted) {
      return;
    }

    setState(() {
      _currentProject = currentProject;
      _projects = projects;
      _structureChapters = chapters;
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
        'title': element.title,
        'desc': element.description?.trim().isNotEmpty == true
            ? element.description!
            : '暂无叙事元素说明',
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
