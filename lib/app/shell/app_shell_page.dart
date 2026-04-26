import 'dart:io';
import 'dart:ui';

import 'package:echo/core/platform/app_storage_directory.dart';
import 'package:echo/core/platform/project_bundle_file_transfer.dart';
import 'package:echo/data/media/media_importer.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/domain/models/capture_mode.dart';
import 'package:echo/features/capture/domain/models/save_capture_request.dart';
import 'package:echo/features/capture/domain/models/save_capture_result.dart';
import 'package:echo/features/capture/domain/repositories/capture_record_repository.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/beacon/domain/repositories/beacon_task_repository.dart';
import 'package:echo/features/beacon/presentation/pages/beacon_page_prototype.dart';
import 'package:echo/features/beacon/presentation/pages/beacon_task_editor_page.dart';
import 'package:echo/features/curation/presentation/pages/global_arrange_page.dart';
import 'package:echo/features/curation/presentation/models/pending_organize_models.dart';
import 'package:echo/features/curation/presentation/pages/pending_organize_page.dart';
import 'package:echo/features/project/presentation/pages/project_edit_page.dart';
import 'package:echo/features/project/presentation/pages/no_project_prompt_page.dart';
import 'package:echo/features/project/presentation/pages/project_wizard_page.dart';
import 'package:echo/features/project/presentation/utils/project_cover_picker.dart';
import 'package:echo/features/project/presentation/widgets/project_sidebar.dart';
import 'package:echo/features/settings/domain/entities/app_settings.dart';
import 'package:echo/features/settings/domain/services/export_project_bundle.dart';
import 'package:echo/features/settings/domain/services/import_project_bundle.dart';
import 'package:echo/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:echo/features/settings/infrastructure/services/local_media_ingest_policy.dart';
import 'package:echo/features/settings/presentation/pages/settings_placeholder_page.dart';
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
import 'package:echo/features/structure_elements_relations/presentation/widgets/editor_confirmation_dialog.dart';
import 'package:echo/features/timeline/presentation/models/timeline_item.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page_prototype.dart';
import 'package:echo/shared/models/content_preview_item.dart';
import 'package:echo/shared/models/photo_processing_registry.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/quick_record_overlay_prototype.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef SaveCaptureRecordRunner =
    Future<SaveCaptureResult> Function(SaveCaptureRequest request);

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    super.key,
    required this.projectRepository,
    required this.structureChapterRepository,
    required this.narrativeElementRepository,
    required this.projectRelationRepository,
    required this.beaconTaskRepository,
    required this.appSettingsRepository,
    required this.exportProjectBundle,
    required this.importProjectBundle,
    required this.captureRecordRepository,
    required this.projectBundleFileTransfer,
    this.narrativeElementPhotoPicker,
    this.narrativeElementPhotoImporter,
    this.capturePhotoPicker,
    required this.onSaveCaptureRecord,
  });

  final ProjectRepository projectRepository;
  final StructureChapterRepository structureChapterRepository;
  final NarrativeElementRepository narrativeElementRepository;
  final ProjectRelationRepository projectRelationRepository;
  final BeaconTaskRepository beaconTaskRepository;
  final AppSettingsRepository appSettingsRepository;
  final ExportProjectBundle exportProjectBundle;
  final ImportProjectBundle importProjectBundle;
  final CaptureRecordRepository captureRecordRepository;
  final ProjectBundleFileTransfer projectBundleFileTransfer;
  final PickGalleryImages? narrativeElementPhotoPicker;
  final ImportNarrativePhoto? narrativeElementPhotoImporter;
  final PickCapturedPhoto? capturePhotoPicker;
  final SaveCaptureRecordRunner onSaveCaptureRecord;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  static const String _syntheticUnassignedPhotoRecordText = '整理页未归属照片';

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
  List<CaptureRecord> _captureRecords = const <CaptureRecord>[];
  List<BeaconTask> _beaconTasks = const <BeaconTask>[];
  List<StructureChapterCardData> _chapterCards =
      const <StructureChapterCardData>[];
  List<Map<String, dynamic>> _narrativeElementGroups =
      const <Map<String, dynamic>>[];
  final PhotoProcessingRegistry _photoProcessingRegistry =
      PhotoProcessingRegistry();
  GlobalArrangePhotoLandingRequest? _globalArrangeLandingRequest;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _photoProcessingRegistry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPopShellRoute,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleShellBackNavigation();
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildCurrentPage(),
            AnimatedBuilder(
              animation: _photoProcessingRegistry,
              builder: (context, child) {
                final hasProcessing = _photoProcessingRegistry.refs.any(
                  (ref) => ref.isProcessing,
                );
                if (!hasProcessing) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 18,
                  child: _buildProcessingBusyPill(),
                );
              },
            ),
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
                  onPickGalleryPhotos:
                      widget.narrativeElementPhotoPicker ??
                      pickGalleryImagesFromGallery,
                  onPickCapturedPhoto:
                      widget.capturePhotoPicker ?? pickCapturedPhotoFromCamera,
                  onImportPhoto: _resolvedNarrativeElementPhotoImporter,
                  photoProcessingRegistry: _photoProcessingRegistry,
                  photoProcessingContextId:
                      'quick-record-${_currentProject?.projectId ?? 'none'}',
                  onSaveRecord: _handleSaveCaptureRecord,
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
                                final persistedCoverImagePath =
                                    await _persistProjectCoverImage(
                                      coverImagePath,
                                      unchangedPath: project.coverImagePath,
                                    );
                                await widget.projectRepository.updateProject(
                                  projectId: project.projectId,
                                  title: title,
                                  themeStatement: themeStatement,
                                  coverImagePath: persistedCoverImagePath,
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

  bool get _canPopShellRoute {
    return !_showAddOverlay &&
        !_sidebarOpen &&
        _currentTab == PrototypeTab.structure;
  }

  void _handleShellBackNavigation() {
    if (_showAddOverlay) {
      setState(() {
        _showAddOverlay = false;
      });
      return;
    }
    if (_sidebarOpen) {
      setState(() {
        _sidebarOpen = false;
      });
      return;
    }
    if (_currentTab != PrototypeTab.structure) {
      setState(() {
        _currentTab = PrototypeTab.structure;
        _globalArrangeLandingRequest = null;
      });
    }
  }

  Widget _buildProcessingBusyPill() {
    return Container(
      key: const ValueKey('shellPhotoProcessingBusyPill'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.black.withValues(alpha: 0.34),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '显 影 中',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 2.0,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveCaptureRecord({
    required CaptureMode mode,
    required String rawText,
    required List<String> photoPaths,
  }) async {
    if (_currentProject == null) {
      return;
    }

    await widget.onSaveCaptureRecord(
      SaveCaptureRequest(
        projectId: _currentProject!.projectId,
        mode: mode,
        rawText: rawText,
        photoPaths: photoPaths,
      ),
    );
    if (!mounted) {
      return;
    }
    await _refreshProjects();
    if (!mounted) {
      return;
    }
    setState(() {
      _showAddOverlay = false;
    });
  }

  bool _isTimelineEligibleRecord(CaptureRecord record) {
    if (record.rawText.trim() == _syntheticUnassignedPhotoRecordText) {
      return false;
    }
    final photoPaths = _normalizedPhotoPaths(record.photoPaths);
    if (record.captureModeValue == CaptureMode.portfolio) {
      return photoPaths.isNotEmpty;
    }
    return record.rawText.trim().isNotEmpty || photoPaths.isNotEmpty;
  }

  List<String> _normalizedPhotoPaths(List<String> photoPaths) {
    return photoPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
  }

  List<TimelineItem> _buildTimelineItems() {
    final items = <TimelineItem>[];
    for (final record in _captureRecords) {
      if (!_isTimelineEligibleRecord(record)) {
        continue;
      }
      final trimmedText = record.rawText.trim();
      final photoPaths = _normalizedPhotoPaths(record.photoPaths);
      if (record.captureModeValue == CaptureMode.portfolio) {
        final primaryPhotoPath = photoPaths.first;
        items.add(
          TimelineItem(
            id: 'timeline-photo-${record.recordId}',
            recordId: record.recordId,
            createdAt: record.createdAt,
            type: TimelineItemType.photo,
            content: trimmedText,
            images: photoPaths,
            photoTarget: TimelinePhotoTarget(
              recordId: record.recordId,
              photoPath: primaryPhotoPath,
            ),
          ),
        );
        continue;
      }
      items.add(
        TimelineItem(
          id: 'timeline-note-${record.recordId}',
          recordId: record.recordId,
          createdAt: record.createdAt,
          type: TimelineItemType.note,
          content: trimmedText,
          images: photoPaths,
        ),
      );
    }
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  void _handleTimelineItemTap(TimelineItem item) {
    final photoTarget = item.photoTarget;
    if (photoTarget == null) {
      return;
    }
    setState(() {
      _currentTab = PrototypeTab.curation;
      _sidebarOpen = false;
      _showAddOverlay = false;
      _globalArrangeLandingRequest = GlobalArrangePhotoLandingRequest(
        requestId:
            '${photoTarget.recordId}::${photoTarget.photoPath}::${DateTime.now().microsecondsSinceEpoch}',
        sourceRecordId: photoTarget.recordId,
        photoPath: photoTarget.photoPath,
      );
    });
  }

  Future<void> _handleTimelineItemLongPress(TimelineItem item) async {
    await _confirmAndDeleteTimelineRecord(item);
  }

  void _handleGlobalArrangeLandingRequestConsumed(String requestId) {
    if (_globalArrangeLandingRequest?.requestId != requestId) {
      return;
    }
    setState(() {
      _globalArrangeLandingRequest = null;
    });
  }

  Widget _buildCurrentPage() {
    if (_projects.isEmpty) {
      return NoProjectPromptPage(
        onOpenSidebar: () => setState(() => _sidebarOpen = true),
        onCreateProject: _openProjectWizard,
        onOpenSettings: _openSettingsPage,
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
                  onImportPhoto: _resolvedNarrativeElementPhotoImporter,
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
                  onImportPhoto: _resolvedNarrativeElementPhotoImporter,
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
                  onImportPhoto: _resolvedNarrativeElementPhotoImporter,
                  photoProcessingRegistry: _photoProcessingRegistry,
                  photoProcessingContextId:
                      'narrative-create-${_currentProject!.projectId}',
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
          onOpenSettings: _openSettingsPage,
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
          onOpenSettings: _openSettingsPage,
          landingRequest: _globalArrangeLandingRequest,
          onLandingRequestConsumed: _handleGlobalArrangeLandingRequestConsumed,
          onDeletePhoto: _confirmAndDeletePhoto,
        );
      case PrototypeTab.overview:
        return BeaconPagePrototype(
          projectTitle: _currentProject?.title ?? '',
          tasks: _beaconTasks,
          elements: _narrativeElements,
          chapterTitleById: _buildChapterTitleById(_structureChapters),
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
          onOpenSettings: _openSettingsPage,
          onCreateTask: _openCreateBeaconTaskPage,
          onOpenTask: _openBeaconTaskPage,
        );
      case PrototypeTab.timeline:
        return TimelinePagePrototype(
          projectTitle: _currentProject?.title ?? '',
          items: _buildTimelineItems(),
          onOpenSidebar: () => setState(() => _sidebarOpen = true),
          onBottomTabChanged: _changeTab,
          onOpenSettings: _openSettingsPage,
          onTimelineItemTap: _handleTimelineItemTap,
          onTimelineItemLongPress: _handleTimelineItemLongPress,
        );
    }
  }

  Future<void> _openSettingsPage() async {
    final initialSettings = await widget.appSettingsRepository.load();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsPlaceholderPage(
          initialSettings: initialSettings,
          canExportCurrentProject: _currentProject != null,
          onUpdateCompressionLevel: (compressionLevel) => widget
              .appSettingsRepository
              .update(compressionLevel: compressionLevel),
          onUpdateExportIncludesSettings: (include) => widget
              .appSettingsRepository
              .update(includeSettingsInExportsByDefault: include),
          onExportProject: _handleExportProject,
          onPickImportBundle: _pickImportBundle,
          onInspectImportBundle: _inspectImportBundle,
          onImportProject: _handleImportProject,
        ),
      ),
    );
  }

  Future<ProjectBundleExportReceipt?> _handleExportProject(
    bool includeSettings,
  ) async {
    final currentProject = _currentProject;
    if (currentProject == null || _isFileBundleUnsupportedPlatform) {
      return null;
    }

    final storageRoot = await getAppStorageDirectoryPath();
    final stagingDirectoryPath =
        '$storageRoot/bundle_exports/${DateTime.now().millisecondsSinceEpoch}';
    final stagingDirectory = Directory(stagingDirectoryPath);

    try {
      final result = await widget.exportProjectBundle.execute(
        ExportProjectBundleRequest(
          projectId: currentProject.projectId,
          bundleDirectoryPath: stagingDirectory.path,
          includeSettings: includeSettings,
        ),
      );
      return await widget.projectBundleFileTransfer.exportBundleDirectory(
        bundleDirectoryPath: result.bundleDirectoryPath,
        suggestedBundleName: _buildProjectBundleDirectoryName(currentProject),
      );
    } finally {
      if (await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
    }
  }

  Future<ProjectBundleImportSelection?> _pickImportBundle() {
    if (_isFileBundleUnsupportedPlatform) {
      return Future.value();
    }
    return widget.projectBundleFileTransfer.pickImportBundleDirectory();
  }

  Future<AppSettings> _handleImportProject(
    ProjectBundleImportSelection selection,
    bool applySettingsPayload,
  ) async {
    if (_isFileBundleUnsupportedPlatform) {
      return widget.appSettingsRepository.load();
    }

    await widget.importProjectBundle.execute(
      ImportProjectBundleRequest(
        bundleDirectoryPath: selection.bundleDirectoryPath,
        applyImportedSettings: applySettingsPayload,
      ),
    );
    await _refreshProjects();
    return widget.appSettingsRepository.load();
  }

  Future<ImportProjectBundleInspection> _inspectImportBundle(
    ProjectBundleImportSelection selection,
  ) {
    return widget.importProjectBundle.inspect(selection.bundleDirectoryPath);
  }

  bool get _isFileBundleUnsupportedPlatform {
    return kIsWeb;
  }

  String _buildProjectBundleDirectoryName(Project project) {
    final trimmedTitle = project.title.trim();
    final normalizedTitle = trimmedTitle.isEmpty ? '未命名项目' : trimmedTitle;
    final sanitizedTitle = normalizedTitle.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      ' ',
    );
    final compactTitle = sanitizedTitle
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();
    final timestamp = DateTime.now().toLocal().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final bundleTitle = compactTitle.isEmpty ? '未命名项目' : compactTitle;
    return 'Echo-$bundleTitle-$timestamp.echo-bundle';
  }

  Future<String?> _persistProjectCoverImage(
    String? selectedPath, {
    String? unchangedPath,
  }) async {
    final trimmedPath = selectedPath?.trim();
    if (trimmedPath == null || trimmedPath.isEmpty) {
      return null;
    }
    if (trimmedPath == unchangedPath) {
      return unchangedPath;
    }
    return importMediaFile(
      sourcePath: trimmedPath,
      collection: 'project_covers',
      policy: LocalMediaIngestPolicy(
        settingsRepository: widget.appSettingsRepository,
      ),
    );
  }

  ImportNarrativePhoto get _resolvedNarrativeElementPhotoImporter {
    return widget.narrativeElementPhotoImporter ?? _importNarrativePhoto;
  }

  Future<String> _importNarrativePhoto(String sourcePath) {
    return _importNarrativePhotoWithPrompt(sourcePath);
  }

  Future<String> _importNarrativePhotoWithPrompt(String sourcePath) async {
    return importMediaFile(
      sourcePath: sourcePath,
      collection: 'narrative_elements',
      policy: LocalMediaIngestPolicy(
        settingsRepository: widget.appSettingsRepository,
      ),
    );
  }

  void _changeTab(PrototypeTab tab) {
    if (tab == PrototypeTab.add) {
      setState(() {
        _showAddOverlay = true;
        _sidebarOpen = false;
        _globalArrangeLandingRequest = null;
      });
      return;
    }

    setState(() {
      _currentTab = tab;
      _sidebarOpen = false;
      _showAddOverlay = false;
      if (tab != PrototypeTab.curation) {
        _globalArrangeLandingRequest = null;
      }
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
            final persistedCoverImagePath = await _persistProjectCoverImage(
              coverImagePath,
            );
            await widget.projectRepository.createProject(
              title: title,
              themeStatement: themeStatement,
              coverImagePath: persistedCoverImagePath,
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
    final captureRecords = currentProject == null
        ? const <CaptureRecord>[]
        : await _loadCaptureRecordsSafe(currentProject.projectId);
    final beaconTasks = currentProject == null
        ? const <BeaconTask>[]
        : await _loadBeaconTasksSafe(currentProject.projectId);
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
      _captureRecords = captureRecords;
      _beaconTasks = beaconTasks;
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

  Future<List<CaptureRecord>> _loadCaptureRecordsSafe(String projectId) async {
    try {
      return await widget.captureRecordRepository.listRecordsForProject(
        projectId,
      );
    } catch (_) {
      return const <CaptureRecord>[];
    }
  }

  Future<List<BeaconTask>> _loadBeaconTasksSafe(String projectId) async {
    try {
      return await widget.beaconTaskRepository.listTasksForProject(projectId);
    } catch (_) {
      return const <BeaconTask>[];
    }
  }

  Map<String, String> _buildChapterTitleById(List<StructureChapter> chapters) {
    return <String, String>{
      for (final chapter in chapters) chapter.chapterId: chapter.title,
    };
  }

  Future<void> _openCreateBeaconTaskPage() async {
    if (_currentProject == null) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BeaconTaskEditorPage(
          chapters: _structureChapters,
          elements: _narrativeElements,
          onSave:
              ({
                required String title,
                required String description,
                required List<String> linkedElementIds,
              }) async {
                await widget.beaconTaskRepository.createTask(
                  projectId: _currentProject!.projectId,
                  title: title,
                  description: description,
                  linkedElementIds: linkedElementIds,
                );
                await _refreshProjects();
              },
        ),
      ),
    );
  }

  Future<void> _openBeaconTaskPage(BeaconTask task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BeaconTaskEditorPage(
          task: task,
          chapters: _structureChapters,
          elements: _narrativeElements,
          onSave:
              ({
                required String title,
                required String description,
                required List<String> linkedElementIds,
              }) async {
                await widget.beaconTaskRepository.updateTask(
                  taskId: task.taskId,
                  title: title,
                  description: description,
                  linkedElementIds: linkedElementIds,
                );
                await _refreshProjects();
              },
          onDelete: () async {
            await widget.beaconTaskRepository.deleteTask(task.taskId);
            await _refreshProjects();
          },
          onArchive: () async {
            await widget.beaconTaskRepository.archiveTask(task.taskId);
            await _refreshProjects();
          },
          onRestore: () => _confirmAndRestoreTask(task),
        ),
      ),
    );
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
        'previewItems': _elementPreviewItems(element),
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
              : '',
          statusLabel: _normalizeChapterStatus(chapters[index].statusLabel),
          elementCount:
              elementsByChapter[chapters[index].chapterId]?.length ?? 0,
          previewItems: _chapterPreviewItems(
            elements:
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
    for (final photoPath in element.photoPaths) {
      await _appendPhotoToUnassignedPool(photoPath: photoPath);
    }
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

  CaptureRecord? _captureRecordForPhotoPath(String photoPath) {
    for (final record in _captureRecords) {
      if (record.unorganizedPhotoPaths.contains(photoPath) ||
          record.photoPaths.contains(photoPath)) {
        return record;
      }
    }
    return null;
  }

  Future<void> _appendPhotoToUnassignedPool({
    required String photoPath,
    String? preferredRecordId,
  }) async {
    CaptureRecord? targetRecord;
    if (preferredRecordId != null) {
      for (final record in _captureRecords) {
        if (record.recordId == preferredRecordId) {
          targetRecord = record;
          break;
        }
      }
    }
    targetRecord ??= _captureRecordForPhotoPath(photoPath);

    if (targetRecord != null) {
      final pending = List<String>.from(targetRecord.unorganizedPhotoPaths);
      if (!pending.contains(photoPath)) {
        pending.add(photoPath);
        await widget.captureRecordRepository.updatePendingPhotoPaths(
          recordId: targetRecord.recordId,
          pendingPhotoPaths: pending,
        );
      }
      return;
    }

    final project = _currentProject;
    if (project == null) {
      return;
    }
    await widget.captureRecordRepository.createRecord(
      projectId: project.projectId,
      mode: CaptureMode.record.storageValue,
      rawText: _syntheticUnassignedPhotoRecordText,
      photoPaths: <String>[photoPath],
    );
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
          photoProcessingRegistry: _photoProcessingRegistry,
          photoProcessingContextId: 'narrative-edit-${element.elementId}',
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

  List<ContentPreviewItem> _elementPreviewItems(NarrativeElement element) {
    return <ContentPreviewItem>[
      for (var index = 0; index < element.photoPaths.length; index++)
        ContentPreviewItem.photo(
          stableId: element.photoPaths[index],
          imageSource: element.photoPaths[index],
        ),
    ];
  }

  List<ContentPreviewItem> _chapterPreviewItems({
    required List<NarrativeElement> elements,
  }) {
    final previewItems = <_ChronologicalPreviewItem>[];
    for (final element in elements) {
      for (var index = element.photoPaths.length - 1; index >= 0; index--) {
        previewItems.add(
          _ChronologicalPreviewItem(
            item: ContentPreviewItem.photo(
              stableId: element.photoPaths[index],
              imageSource: element.photoPaths[index],
            ),
            sortTime: element.updatedAt,
            order: index,
          ),
        );
      }
    }

    previewItems.sort((left, right) {
      final timeCompare = right.sortTime.compareTo(left.sortTime);
      if (timeCompare != 0) {
        return timeCompare;
      }
      return right.order.compareTo(left.order);
    });

    return previewItems.map((item) => item.item).toList(growable: false);
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
                  sourceRecordId: _captureRecordForPhotoPath(
                    element.photoPaths[index],
                  )?.recordId,
                ),
            ],
          ),
      ];
    }

    List<GlobalArrangePhotoData> buildUnassignedPhotos() {
      final photoSeeds =
          <({DateTime updatedAt, GlobalArrangePhotoData photo})>[];
      for (final record in _captureRecords) {
        for (
          var index = 0;
          index < record.unorganizedPhotoPaths.length;
          index++
        ) {
          final photoPath = record.unorganizedPhotoPaths[index];
          photoSeeds.add((
            updatedAt: record.updatedAt,
            photo: GlobalArrangePhotoData(
              photoId: '${record.recordId}::$index::$photoPath',
              imageSource: photoPath,
              relationTags: const <String>[],
              sourceRecordId: record.recordId,
            ),
          ));
        }
      }
      photoSeeds.sort(
        (left, right) => right.updatedAt.compareTo(left.updatedAt),
      );
      return [for (final seed in photoSeeds) seed.photo];
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
      unassignedPhotos: buildUnassignedPhotos(),
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
    final sourceIsLoosePool =
        sourceElementId == globalArrangeLoosePhotoBucketId;
    final targetIsLoosePool =
        targetElementId == globalArrangeLoosePhotoBucketId;

    if (sourceIsLoosePool && targetIsLoosePool) {
      return;
    }

    if (sourceIsLoosePool) {
      final loosePhotos = _buildGlobalArrangeBoardData().unassignedPhotos;
      if (sourcePhotoIndex < 0 || sourcePhotoIndex >= loosePhotos.length) {
        return;
      }
      final sourcePhoto = loosePhotos[sourcePhotoIndex];
      final sourceRecordId = sourcePhoto.sourceRecordId;
      if (sourceRecordId == null) {
        return;
      }

      NarrativeElement? targetElement;
      for (final element in _narrativeElements) {
        if (element.elementId == targetElementId) {
          targetElement = element;
          break;
        }
      }
      if (targetElement == null) {
        return;
      }

      final updatedTargetPhotos = List<String>.from(targetElement.photoPaths);
      final normalizedTargetIndex = targetPhotoIndex.clamp(
        0,
        updatedTargetPhotos.length,
      );
      updatedTargetPhotos.insert(
        normalizedTargetIndex,
        sourcePhoto.imageSource,
      );
      await widget.narrativeElementRepository.updateElement(
        elementId: targetElement.elementId,
        title: targetElement.title,
        description: targetElement.description,
        chapterId: targetElement.owningChapterId,
        status: targetElement.status,
        photoPaths: updatedTargetPhotos,
      );

      final sourceRecord = _captureRecords.firstWhere(
        (record) => record.recordId == sourceRecordId,
      );
      final remainingPending = List<String>.from(
        sourceRecord.unorganizedPhotoPaths,
      )..remove(sourcePhoto.imageSource);
      await widget.captureRecordRepository.updatePendingPhotoPaths(
        recordId: sourceRecord.recordId,
        pendingPhotoPaths: remainingPending,
      );
      await _refreshProjects();
      return;
    }

    NarrativeElement? sourceElement;
    NarrativeElement? targetElement;
    for (final element in _narrativeElements) {
      if (element.elementId == sourceElementId) {
        sourceElement = element;
      }
      if (!targetIsLoosePool && element.elementId == targetElementId) {
        targetElement = element;
      }
    }
    if (sourceElement == null) {
      return;
    }
    if (sourcePhotoIndex < 0 ||
        sourcePhotoIndex >= sourceElement.photoPaths.length) {
      return;
    }

    final movedPhotoPath = sourceElement.photoPaths[sourcePhotoIndex];
    final updatedSourcePhotos = List<String>.from(sourceElement.photoPaths)
      ..removeAt(sourcePhotoIndex);

    if (targetIsLoosePool) {
      await widget.narrativeElementRepository.updateElement(
        elementId: sourceElement.elementId,
        title: sourceElement.title,
        description: sourceElement.description,
        chapterId: sourceElement.owningChapterId,
        status: sourceElement.status,
        photoPaths: updatedSourcePhotos,
      );
      await _appendPhotoToUnassignedPool(photoPath: movedPhotoPath);
      await _removePhotoMembers(
        sourceElementId: sourceElement.elementId,
        photoPath: movedPhotoPath,
      );
      await _refreshProjects();
      return;
    }

    if (targetElement == null) {
      return;
    }

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

  Future<void> _removePhotoMembers({
    required String sourceElementId,
    required String photoPath,
  }) async {
    final affectedGroupIds = _relationMembers
        .where(
          (member) =>
              member.kind == ProjectRelationTargetKind.photo.name &&
              member.linkedSourceElementId == sourceElementId &&
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
          if (!(member.kind == ProjectRelationTargetKind.photo.name &&
              member.linkedSourceElementId == sourceElementId &&
              member.linkedPhotoPath == photoPath))
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
                sourceElementId: member.linkedSourceElementId!,
              ),
      ];

      if (draftMembers.length < 2) {
        await widget.projectRelationRepository.deleteRelationGroup(groupId);
        continue;
      }

      await widget.projectRelationRepository.updateRelationGroup(
        relationGroupId: relationGroup.relationGroupId,
        title: relationGroup.title,
        description: relationGroup.description,
        members: draftMembers,
      );
    }
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

  Future<bool> _confirmAndDeletePhoto(String photoPath) async {
    final trimmedPath = photoPath.trim();
    if (trimmedPath.isEmpty) {
      return false;
    }
    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '删除照片',
      content: '删除后，这张照片会从整理页、历程和相关关系中移除，并删除本机图片文件。',
      actionText: '删除',
    );
    if (!confirmed) {
      return false;
    }

    try {
      await _removePhotoFromElementsAndRelations(trimmedPath);
      await _removePhotoFromCaptureRecords(trimmedPath);
      await _refreshProjects();
      await _deletePhysicalPhotoFiles(<String>{trimmedPath});
      return true;
    } catch (_) {
      if (mounted) {
        _showPassiveHint('删除照片失败');
      }
      await _refreshProjects();
      return false;
    }
  }

  Future<void> _confirmAndDeleteTimelineRecord(TimelineItem item) async {
    CaptureRecord? record;
    for (final currentRecord in _captureRecords) {
      if (currentRecord.recordId == item.recordId) {
        record = currentRecord;
        break;
      }
    }
    if (record == null) {
      await _refreshProjects();
      return;
    }
    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '删除历程',
      content: '删除后，这条历程及其关联照片会从项目中移除，并清理不再使用的本机图片文件。',
      actionText: '删除',
    );
    if (!confirmed) {
      return;
    }

    final photoPaths = <String>{
      ..._normalizedPhotoPaths(record.photoPaths),
      ..._normalizedPhotoPaths(record.unorganizedPhotoPaths),
    };
    try {
      for (final photoPath in photoPaths) {
        await _removePhotoFromElementsAndRelations(photoPath);
      }
      final deleted = await widget.captureRecordRepository.deleteRecord(
        record.recordId,
      );
      if (!deleted) {
        throw StateError('Failed to delete capture record: ${record.recordId}');
      }
      await _refreshProjects();
      await _deletePhysicalPhotoFilesIfUnreferenced(photoPaths);
    } catch (_) {
      if (mounted) {
        _showPassiveHint('删除历程失败');
      }
      await _refreshProjects();
    }
  }

  Future<bool> _confirmAndRestoreTask(BeaconTask task) async {
    final confirmed = await showEditorConfirmationDialog(
      context: context,
      title: '恢复任务',
      content: '恢复后，这条任务会回到“待执行”列表。',
      actionText: '恢复',
    );
    if (!confirmed) {
      return false;
    }

    final restored = await widget.beaconTaskRepository.restoreTask(task.taskId);
    if (restored == null) {
      _showPassiveHint('恢复任务失败');
      await _refreshProjects();
      return false;
    }
    await _refreshProjects();
    return true;
  }

  Future<void> _removePhotoFromElementsAndRelations(String photoPath) async {
    for (final element in _narrativeElements) {
      if (!element.photoPaths.contains(photoPath)) {
        continue;
      }
      await _removePhotoMembers(
        sourceElementId: element.elementId,
        photoPath: photoPath,
      );
      final updatedPhotos = [
        for (final currentPath in element.photoPaths)
          if (currentPath != photoPath) currentPath,
      ];
      await widget.narrativeElementRepository.updateElement(
        elementId: element.elementId,
        title: element.title,
        description: element.description,
        chapterId: element.owningChapterId,
        status: element.status,
        photoPaths: updatedPhotos,
      );
    }
  }

  Future<void> _removePhotoFromCaptureRecords(String photoPath) async {
    for (final record in _captureRecords) {
      if (!record.photoPaths.contains(photoPath) &&
          !record.unorganizedPhotoPaths.contains(photoPath)) {
        continue;
      }
      final updatedPhotos = [
        for (final currentPath in record.photoPaths)
          if (currentPath != photoPath) currentPath,
      ];
      final updatedPendingPhotos = [
        for (final currentPath in record.unorganizedPhotoPaths)
          if (currentPath != photoPath) currentPath,
      ];
      await widget.captureRecordRepository.updateRecordPhotos(
        recordId: record.recordId,
        photoPaths: updatedPhotos,
        pendingPhotoPaths: updatedPendingPhotos,
      );
    }
  }

  Future<void> _deletePhysicalPhotoFilesIfUnreferenced(
    Set<String> photoPaths,
  ) async {
    final referencedPaths = <String>{
      for (final element in _narrativeElements) ...element.photoPaths,
      for (final record in _captureRecords) ...record.photoPaths,
      for (final record in _captureRecords) ...record.unorganizedPhotoPaths,
    };
    final deletablePaths = {
      for (final photoPath in photoPaths)
        if (!referencedPaths.contains(photoPath)) photoPath,
    };
    await _deletePhysicalPhotoFiles(deletablePaths);
  }

  Future<void> _deletePhysicalPhotoFiles(Set<String> photoPaths) {
    return Future<void>.sync(() {
      for (final photoPath in photoPaths) {
        final trimmedPath = photoPath.trim();
        if (trimmedPath.isEmpty ||
            ((Uri.tryParse(trimmedPath)?.hasScheme ?? false) &&
                !trimmedPath.startsWith('/'))) {
          continue;
        }
        final file = File(trimmedPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    });
  }

  Future<void> _openPendingOrganizePage() async {
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return PendingOrganizePage(
            data: _buildPendingOrganizePageData(),
            onSavePhoto: _savePendingOrganizeEntry,
          );
        },
      ),
    );
  }

  PendingOrganizePageData _buildPendingOrganizePageData() {
    final chapterTitles = <String?, String>{
      null: '未归属',
      for (var index = 0; index < _structureChapters.length; index++)
        _structureChapters[index].chapterId:
            'CH ${(index + 1).toString().padLeft(2, '0')} / ${_structureChapters[index].title}',
    };
    final chapterById = <String, StructureChapter>{
      for (final chapter in _structureChapters) chapter.chapterId: chapter,
    };
    final relationGroupsByPhotoKey = _pendingRelationGroupIdsByPhotoKey();

    final chapters = [
      for (final chapter in _structureChapters)
        () {
          final previewItems = _chapterPreviewItems(
            elements: _narrativeElements
                .where(
                  (element) => element.owningChapterId == chapter.chapterId,
                )
                .toList(),
          );
          return PendingOrganizeChapterOption(
            chapterId: chapter.chapterId,
            label:
                'CH ${(chapter.sortOrder + 1).toString().padLeft(2, '0')} / ${chapter.title}',
            sortOrder: chapter.sortOrder,
            coverPreviewItem: previewItems.isEmpty ? null : previewItems.first,
          );
        }(),
    ];

    final elements = [
      for (final element in _narrativeElements)
        PendingOrganizeElementOption(
          elementId: element.elementId,
          title: element.title,
          description: element.description?.trim() ?? '',
          chapterId: element.owningChapterId,
          chapterLabel:
              chapterTitles[element.owningChapterId] ?? chapterTitles[null]!,
          sortOrder: element.sortOrder,
          previewItems: _elementPreviewItems(element),
        ),
    ];

    final entries = <_PendingOrganizeEntrySeed>[
      for (final element in _narrativeElements)
        if (element.owningChapterId == null)
          for (var index = 0; index < element.photoPaths.length; index++)
            _PendingOrganizeEntrySeed(
              createdAt: element.updatedAt,
              entry: PendingOrganizeEntryData.photo(
                entryId:
                    '${element.elementId}::$index::${element.photoPaths[index]}',
                imageSource: element.photoPaths[index],
                photoPath: element.photoPaths[index],
                sourceElementId: element.elementId,
                sourceChapterId: element.owningChapterId,
                title: element.title,
                description: element.description?.trim() ?? '',
                sourceRelationGroupIds:
                    relationGroupsByPhotoKey['${element.elementId}::${element.photoPaths[index]}']
                        ?.toList() ??
                    const <String>[],
              ),
            ),
      for (final record in _captureRecords)
        for (
          var index = 0;
          index < record.unorganizedPhotoPaths.length;
          index++
        )
          _PendingOrganizeEntrySeed(
            createdAt: record.updatedAt,
            entry: PendingOrganizeEntryData.photo(
              entryId:
                  '${record.recordId}::$index::${record.unorganizedPhotoPaths[index]}',
              imageSource: record.unorganizedPhotoPaths[index],
              photoPath: record.unorganizedPhotoPaths[index],
              sourceRecordId: record.recordId,
              sourceChapterId: null,
              title: _deriveRecordPreviewTitle(record.rawText),
              description: record.rawText.trim(),
            ),
          ),
    ];
    entries.sort((left, right) => right.createdAt.compareTo(left.createdAt));

    final relationTypes = [
      for (final relationType in _relationTypes)
        PendingOrganizeRelationTypeOption(
          relationTypeId: relationType.relationTypeId,
          name: relationType.name,
          groups: [
            for (final group in _relationGroups)
              if (group.linkedRelationTypeId == relationType.relationTypeId)
                PendingOrganizeRelationGroupOption(
                  groupId: group.relationGroupId,
                  relationTypeId: relationType.relationTypeId,
                  title: _buildRelationGroupDisplayTitle(
                    relationGroup: group,
                    chapterById: chapterById,
                  ),
                  previewItems: _buildRelationGroupPreviewItems(
                    group.relationGroupId,
                  ),
                ),
          ],
        ),
    ];

    return PendingOrganizePageData(
      entries: [for (final entry in entries) entry.entry],
      chapters: chapters,
      elements: elements,
      relationTypes: relationTypes,
    );
  }

  String _deriveRecordPreviewTitle(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      return '未归属照片';
    }
    return lines.first;
  }

  Map<String, Set<String>> _pendingRelationGroupIdsByPhotoKey() {
    final groupsByPhotoKey = <String, Set<String>>{};
    for (final member in _relationMembers) {
      if (member.kind != ProjectRelationTargetKind.photo.name ||
          member.linkedSourceElementId == null ||
          member.linkedPhotoPath == null) {
        continue;
      }
      final key = '${member.linkedSourceElementId}::${member.linkedPhotoPath}';
      groupsByPhotoKey.putIfAbsent(key, () => <String>{});
      groupsByPhotoKey[key]!.add(member.owningGroupId);
    }
    return groupsByPhotoKey;
  }

  List<ContentPreviewItem> _buildRelationGroupPreviewItems(
    String relationGroupId,
  ) {
    final previewItems = <ContentPreviewItem>[];
    final members =
        _relationMembers
            .where((member) => member.owningGroupId == relationGroupId)
            .toList()
          ..sort(
            (left, right) =>
                left.memberSortOrder.compareTo(right.memberSortOrder),
          );
    for (final member in members) {
      if (member.kind == ProjectRelationTargetKind.photo.name &&
          member.linkedPhotoPath != null) {
        previewItems.add(
          ContentPreviewItem.photo(
            stableId: member.linkedPhotoPath!,
            imageSource: member.linkedPhotoPath!,
          ),
        );
      }
    }
    return previewItems;
  }

  String _buildRelationGroupDisplayTitle({
    required ProjectRelationGroup relationGroup,
    required Map<String, StructureChapter> chapterById,
  }) {
    final explicitTitle = relationGroup.title?.trim();
    if (explicitTitle != null && explicitTitle.isNotEmpty) {
      return explicitTitle;
    }

    final elementById = <String, NarrativeElement>{
      for (final element in _narrativeElements) element.elementId: element,
    };
    final titles = <String>[];
    final members =
        _relationMembers
            .where(
              (member) => member.owningGroupId == relationGroup.relationGroupId,
            )
            .toList()
          ..sort(
            (left, right) =>
                left.memberSortOrder.compareTo(right.memberSortOrder),
          );
    for (final member in members) {
      if (member.kind == ProjectRelationTargetKind.element.name &&
          member.linkedElementId != null) {
        final element = elementById[member.linkedElementId!];
        if (element != null) {
          titles.add(element.title);
        }
        continue;
      }
      if (member.kind == ProjectRelationTargetKind.photo.name &&
          member.linkedSourceElementId != null) {
        final sourceElement = elementById[member.linkedSourceElementId!];
        if (sourceElement == null) {
          continue;
        }
        final chapter = chapterById[sourceElement.owningChapterId];
        final chapterPrefix = chapter == null
            ? '未归属'
            : 'CH ${(chapter.sortOrder + 1).toString().padLeft(2, '0')}';
        titles.add('$chapterPrefix · ${sourceElement.title}');
      }
    }
    if (titles.isEmpty) {
      return '未命名关系组';
    }
    if (titles.length == 1) {
      return titles.first;
    }
    if (titles.length == 2) {
      return '${titles[0]} / ${titles[1]}';
    }
    return '${titles[0]} / ${titles[1]} / +${titles.length - 2}';
  }

  Future<PendingOrganizePageData> _savePendingOrganizeEntry(
    PendingOrganizeSaveRequest request,
  ) async {
    await _savePendingPhotoEntry(request);
    await _refreshProjects();
    return _buildPendingOrganizePageData();
  }

  Future<void> _savePendingPhotoEntry(
    PendingOrganizeSaveRequest request,
  ) async {
    final targetElementId = request.targetElementId;
    final photoPath = request.photoPath;
    if (targetElementId == null || photoPath == null) {
      return;
    }

    final targetElement = _narrativeElements.firstWhere(
      (element) => element.elementId == targetElementId,
    );

    if (request.sourceElementId != null) {
      final sourceElement = _narrativeElements.firstWhere(
        (element) => element.elementId == request.sourceElementId,
      );
      if (request.sourceElementId != targetElementId) {
        final sourcePhotoIndex = sourceElement.photoPaths.indexOf(photoPath);
        if (sourcePhotoIndex >= 0) {
          await _movePhoto(
            sourceElementId: request.sourceElementId!,
            sourcePhotoIndex: sourcePhotoIndex,
            targetElementId: targetElementId,
            targetPhotoIndex: targetElement.photoPaths.length,
          );
        }
      }

      await _syncPendingPhotoRelationGroups(
        sourceElementId: targetElementId,
        photoPath: photoPath,
        desiredGroupIds: request.relationGroupIds.toSet(),
      );
      return;
    }

    if (request.sourceRecordId == null) {
      return;
    }

    final updatedTargetPhotos = List<String>.from(targetElement.photoPaths)
      ..add(photoPath);
    await widget.narrativeElementRepository.updateElement(
      elementId: targetElement.elementId,
      title: targetElement.title,
      description: targetElement.description,
      chapterId: targetElement.owningChapterId,
      status: targetElement.status,
      photoPaths: updatedTargetPhotos,
    );

    final sourceRecord = _captureRecords.firstWhere(
      (record) => record.recordId == request.sourceRecordId,
    );
    final remainingPending = List<String>.from(
      sourceRecord.unorganizedPhotoPaths,
    )..remove(photoPath);
    await widget.captureRecordRepository.updatePendingPhotoPaths(
      recordId: sourceRecord.recordId,
      pendingPhotoPaths: remainingPending,
    );

    await _syncPendingPhotoRelationGroups(
      sourceElementId: targetElementId,
      photoPath: photoPath,
      desiredGroupIds: request.relationGroupIds.toSet(),
    );
  }

  Future<void> _syncPendingPhotoRelationGroups({
    required String sourceElementId,
    required String photoPath,
    required Set<String> desiredGroupIds,
  }) async {
    final currentGroupIds = _relationMembers
        .where(
          (member) =>
              member.kind == ProjectRelationTargetKind.photo.name &&
              member.linkedSourceElementId == sourceElementId &&
              member.linkedPhotoPath == photoPath,
        )
        .map((member) => member.owningGroupId)
        .toSet();
    final impactedGroupIds = <String>{...currentGroupIds, ...desiredGroupIds};

    for (final groupId in impactedGroupIds) {
      final relationGroup = _relationGroups.firstWhere(
        (group) => group.relationGroupId == groupId,
      );
      final currentMembers =
          _relationMembers
              .where((member) => member.owningGroupId == groupId)
              .toList()
            ..sort(
              (left, right) =>
                  left.memberSortOrder.compareTo(right.memberSortOrder),
            );

      final nextMembers = <ProjectRelationDraftMember>[];
      var hasCurrentPhotoMember = false;
      for (final member in currentMembers) {
        final isCurrentPhotoMember =
            member.kind == ProjectRelationTargetKind.photo.name &&
            member.linkedSourceElementId == sourceElementId &&
            member.linkedPhotoPath == photoPath;
        if (isCurrentPhotoMember) {
          hasCurrentPhotoMember = true;
          if (desiredGroupIds.contains(groupId)) {
            nextMembers.add(
              ProjectRelationDraftMember.photo(
                photoPath: photoPath,
                sourceElementId: sourceElementId,
              ),
            );
          }
          continue;
        }
        if (member.kind == ProjectRelationTargetKind.element.name &&
            member.linkedElementId != null) {
          nextMembers.add(
            ProjectRelationDraftMember.element(
              elementId: member.linkedElementId!,
            ),
          );
          continue;
        }
        if (member.kind == ProjectRelationTargetKind.photo.name &&
            member.linkedPhotoPath != null &&
            member.linkedSourceElementId != null) {
          nextMembers.add(
            ProjectRelationDraftMember.photo(
              photoPath: member.linkedPhotoPath!,
              sourceElementId: member.linkedSourceElementId!,
            ),
          );
        }
      }

      if (!hasCurrentPhotoMember && desiredGroupIds.contains(groupId)) {
        nextMembers.add(
          ProjectRelationDraftMember.photo(
            photoPath: photoPath,
            sourceElementId: sourceElementId,
          ),
        );
      }

      if (nextMembers.length < 2) {
        await widget.projectRelationRepository.deleteRelationGroup(groupId);
        continue;
      }

      final currentDraftMembers = _buildDraftMembersForGroup(groupId);
      if (_sameDraftMembers(currentDraftMembers, nextMembers)) {
        continue;
      }

      await widget.projectRelationRepository.updateRelationGroup(
        relationGroupId: groupId,
        title: relationGroup.title,
        description: relationGroup.description,
        members: nextMembers,
      );
    }
  }

  List<ProjectRelationDraftMember> _buildDraftMembersForGroup(String groupId) {
    final members =
        _relationMembers
            .where((member) => member.owningGroupId == groupId)
            .toList()
          ..sort(
            (left, right) =>
                left.memberSortOrder.compareTo(right.memberSortOrder),
          );
    return [
      for (final member in members)
        if (member.kind == ProjectRelationTargetKind.element.name &&
            member.linkedElementId != null)
          ProjectRelationDraftMember.element(elementId: member.linkedElementId!)
        else if (member.kind == ProjectRelationTargetKind.photo.name &&
            member.linkedPhotoPath != null &&
            member.linkedSourceElementId != null)
          ProjectRelationDraftMember.photo(
            photoPath: member.linkedPhotoPath!,
            sourceElementId: member.linkedSourceElementId!,
          ),
    ];
  }

  bool _sameDraftMembers(
    List<ProjectRelationDraftMember> left,
    List<ProjectRelationDraftMember> right,
  ) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (_draftMemberKey(left[index]) != _draftMemberKey(right[index])) {
        return false;
      }
    }
    return true;
  }

  String _draftMemberKey(ProjectRelationDraftMember member) {
    switch (member.kind) {
      case ProjectRelationTargetKind.element:
        return 'element:${member.elementId}';
      case ProjectRelationTargetKind.photo:
        return 'photo:${member.sourceElementId}:${member.photoPath}';
    }
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

class _ChronologicalPreviewItem {
  const _ChronologicalPreviewItem({
    required this.item,
    required this.sortTime,
    required this.order,
  });

  final ContentPreviewItem item;
  final DateTime sortTime;
  final int order;
}

class _PendingOrganizeEntrySeed {
  const _PendingOrganizeEntrySeed({
    required this.createdAt,
    required this.entry,
  });

  final DateTime createdAt;
  final PendingOrganizeEntryData entry;
}
