// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:async';

import 'package:echo/app/app.dart';
import 'package:echo/features/beacon/domain/entities/beacon_task.dart';
import 'package:echo/features/beacon/domain/repositories/beacon_task_repository.dart';
import 'package:echo/features/beacon/infrastructure/repositories/local_beacon_task_repository.dart';
import 'package:echo/features/capture/domain/entities/capture_record.dart';
import 'package:echo/features/capture/domain/models/capture_mode.dart';
import 'package:echo/features/capture/domain/models/save_capture_request.dart';
import 'package:echo/features/capture/domain/models/save_capture_result.dart';
import 'package:echo/features/capture/domain/repositories/capture_record_repository.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/repositories/local_project_repository.dart';
import 'package:echo/features/project/presentation/pages/project_edit_page.dart';
import 'package:echo/features/project/presentation/pages/project_wizard_page.dart';
import 'package:echo/features/project/presentation/widgets/project_sidebar.dart';
import 'package:echo/features/beacon/presentation/pages/beacon_task_editor_page.dart';
import 'package:echo/features/curation/presentation/models/pending_organize_models.dart';
import 'package:echo/features/curation/presentation/pages/global_arrange_page.dart';
import 'package:echo/features/curation/presentation/pages/pending_organize_page.dart';
import 'package:echo/features/structure_elements_relations/domain/element_status.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_group.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_member.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/project_relation_type.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/narrative_element_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/project_relation_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/structure_chapter_repository.dart';
import 'package:echo/features/structure_elements_relations/domain/project_relation_defaults.dart';
import 'package:echo/features/structure_elements_relations/domain/models/project_relation_draft_member.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/narrative_element_draft.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_chapter_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/models/structure_relation_card_data.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/chapter_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/chapter_narrative_element_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/narrative_element_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_group_create_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/project_relation_group_selection_page.dart';
import 'package:echo/features/structure_elements_relations/presentation/pages/structure_page_prototype.dart';
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_list_tile.dart';
import 'package:echo/features/timeline/presentation/models/timeline_item.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page_prototype.dart';
import 'package:echo/shared/models/content_preview_item.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:echo/shared/widgets/quick_record_overlay_prototype.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets(
    'quick record inserts developing placeholders before import resolves',
    (tester) async {
      final firstImport = Completer<String>();
      final secondImport = Completer<String>();
      SaveCaptureRequest? savedRequest;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickRecordOverlayPrototype(
              onClose: () {},
              onPickGalleryPhotos: () async => <String>[
                '/tmp/source-a.jpg',
                '/tmp/source-b.jpg',
              ],
              onImportPhoto: (sourcePath) {
                return sourcePath.endsWith('a.jpg')
                    ? firstImport.future
                    : secondImport.future;
              },
              onSaveRecord:
                  ({
                    required mode,
                    required rawText,
                    required photoPaths,
                  }) async {
                    savedRequest = SaveCaptureRequest(
                      projectId: 'project-test',
                      mode: mode,
                      rawText: rawText,
                      photoPaths: photoPaths,
                    );
                  },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('quickRecordGalleryButton')));
      await tester.pump();

      expect(find.text('显 影 中'), findsNWidgets(3));
      expect(
        tester
            .widget<InkWell>(
              find.byKey(const ValueKey('quickRecordSaveButton')),
            )
            .onTap,
        isNotNull,
      );

      firstImport.complete('/tmp/imported-a.jpg');
      await tester.pump();
      expect(find.text('显 影 中'), findsNWidgets(2));

      secondImport.complete('/tmp/imported-b.jpg');
      await tester.pump();
      expect(find.text('显 影 中'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('quickRecordSaveButton')));
      await tester.pump();
      expect(savedRequest?.photoPaths, <String>[
        '/tmp/imported-a.jpg',
        '/tmp/imported-b.jpg',
      ]);
    },
  );

  testWidgets(
    'narrative element save is locked while selected photos are processing',
    (tester) async {
      final importCompleter = Completer<String>();
      var saveCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-test',
                projectId: 'project-test',
                chapterTitle: '章节',
              ),
            ],
            onPickPhoto: () async => <String>['/tmp/source.jpg'],
            onImportPhoto: (_) => importCompleter.future,
            onSave:
                ({
                  required title,
                  required description,
                  required chapterId,
                  required status,
                  required unlockChapterId,
                  required photoPaths,
                }) async {
                  saveCount += 1;
                },
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '元素',
      );
      await tester.tap(
        find.byKey(const ValueKey('narrativeMountedPhotoAddButton')),
      );
      await tester.pump();

      expect(find.text('显 影 中'), findsWidgets);
      expect(
        tester
            .widget<InkWell>(find.byKey(const ValueKey('narrativeSaveButton')))
            .onTap,
        isNull,
      );
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pump();
      expect(saveCount, 0);

      importCompleter.complete('/tmp/imported.jpg');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pump();
      expect(saveCount, 1);
    },
  );

  testWidgets(
    'chapter draft element save is locked while selected photos are processing',
    (tester) async {
      final importCompleter = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: ChapterNarrativeElementCreatePage(
            onPickPhoto: () async => <String>['/tmp/source.jpg'],
            onImportPhoto: (_) => importCompleter.future,
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('chapterDraftElementNameField')),
        '章节内元素',
      );
      await tester.tap(find.byType(InkWell).last);
      await tester.pump();

      expect(find.text('显 影 中'), findsWidgets);
      await tester.tap(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(find.byType(ChapterNarrativeElementCreatePage), findsOneWidget);

      importCompleter.complete('/tmp/imported.jpg');
      await tester.pump();
      expect(find.text('显 影 中'), findsNothing);
    },
  );

  testWidgets(
    'pending organize removes placement button and keeps relation data',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: PendingOrganizePage(
            data: PendingOrganizePageData(
              entries: const <PendingOrganizeEntryData>[
                PendingOrganizeEntryData.photo(
                  entryId: 'entry-1',
                  imageSource: '/tmp/photo.jpg',
                  photoPath: '/tmp/photo.jpg',
                  sourceRecordId: 'record-1',
                  sourceRelationGroupIds: <String>['group-1'],
                ),
              ],
              relationTypes: const <PendingOrganizeRelationTypeOption>[
                PendingOrganizeRelationTypeOption(
                  relationTypeId: 'type-1',
                  name: '关系',
                  groups: <PendingOrganizeRelationGroupOption>[
                    PendingOrganizeRelationGroupOption(
                      groupId: 'group-1',
                      relationTypeId: 'type-1',
                      title: '关系组',
                      previewItems: <ContentPreviewItem>[],
                    ),
                  ],
                ),
              ],
            ),
            onSavePhoto: (_) async => const PendingOrganizePageData(),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('pendingOrganizePlaceOnBoardButton')),
        findsNothing,
      );
      expect(find.text('关系'), findsOneWidget);
    },
  );

  testWidgets('pending organize back leaves source pending data unchanged', (
    tester,
  ) async {
    var saveCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: PendingOrganizePage(
          data: const PendingOrganizePageData(
            entries: <PendingOrganizeEntryData>[
              PendingOrganizeEntryData.photo(
                entryId: 'entry-1',
                imageSource: '/tmp/photo.jpg',
                photoPath: '/tmp/photo.jpg',
                sourceRecordId: 'record-1',
              ),
            ],
          ),
          onSavePhoto: (_) async {
            saveCalled = true;
            return const PendingOrganizePageData();
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pump();

    expect(saveCalled, isFalse);
  });

  testWidgets(
    'global arrange sticky filter pill clears active relation state after scroll',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: _CurationInteractionHarness()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('呼应').first);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('globalArrangeStickyFilterPill')),
        findsOneWidget,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('globalArrangeStickyFilterPill')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('globalArrangeStickyFilterClearButton')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('globalArrangeStickyFilterPill')),
        findsNothing,
      );
    },
  );

  testWidgets('global arrange keeps bottom nav visible during scroll', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: _CurationInteractionHarness.large()),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, -600),
      1000,
    );
    await tester.pump(const Duration(milliseconds: 320));
    expect(
      tester
          .getSize(find.byKey(const ValueKey('globalArrangeBottomNavShell')))
          .height,
      80,
    );

    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .getSize(find.byKey(const ValueKey('globalArrangeBottomNavShell')))
          .height,
      80,
    );
  });

  testWidgets(
    'fullscreen viewer dismisses only on dominant vertical drag at base scale',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: _CurationInteractionHarness()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('globalArrangePhotoOpenArea-photo-1')),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(0, 190));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsNothing);
    },
  );

  testWidgets(
    'fullscreen viewer keeps horizontal paging and zoom from triggering dismiss',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: _CurationInteractionHarness()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('globalArrangePhotoOpenArea-photo-1')),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(PageView), const Offset(-520, 0));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);
    },
  );

  test(
    'local project repository restores projects from isar persistence',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-project-repo-test',
      );
      Future<Isar> openIsar() => openProjectIsar(
        name: 'echo_project_test_db',
        directoryPath: directory.path,
      );
      final firstRepository = LocalProjectRepository(openIsar: openIsar);

      final createdProject = await firstRepository.createProject(
        title: '山体边缘',
        themeStatement: '追踪山体与工业边缘的视觉张力',
        coverImagePath: '/tmp/cover-a.jpg',
      );
      await firstRepository.close();

      final restoredRepository = LocalProjectRepository(openIsar: openIsar);
      final restoredCurrentProject = await restoredRepository
          .getCurrentProject();
      final restoredProjects = await restoredRepository.listProjects();

      expect(restoredCurrentProject?.projectId, createdProject.projectId);
      expect(restoredCurrentProject?.title, '山体边缘');
      expect(restoredCurrentProject?.coverImagePath, '/tmp/cover-a.jpg');
      expect(restoredProjects.map((project) => project.projectId), [
        createdProject.projectId,
      ]);

      await restoredRepository.close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'local beacon task repository persists tasks and archive/delete changes',
    () async {
      await Isar.initializeIsarCore(
        libraries: <Abi, String>{
          Abi.current(): await _resolveIsarLibraryPath(),
        },
      );
      final directory = await Directory.systemTemp.createTemp(
        'echo-beacon-task-repo-test',
      );
      Future<Isar> openIsar() => openProjectIsar(
        name: 'echo_beacon_task_test_db',
        directoryPath: directory.path,
      );

      final firstRepository = LocalBeaconTaskRepository(openIsar: openIsar);
      final createdTask = await firstRepository.createTask(
        projectId: 'project-a',
        title: '剧院放映孔微光',
        description: '注意灰尘和投影孔中的弱光层次。',
        linkedElementIds: <String>['element-1', 'element-2'],
      );
      await firstRepository.archiveTask(createdTask.taskId);
      await firstRepository.close();

      final restoredRepository = LocalBeaconTaskRepository(openIsar: openIsar);
      final restoredTasks = await restoredRepository.listTasksForProject(
        'project-a',
      );

      expect(restoredTasks, hasLength(1));
      expect(restoredTasks.single.taskId, createdTask.taskId);
      expect(restoredTasks.single.title, '剧院放映孔微光');
      expect(restoredTasks.single.isArchived, isTrue);
      expect(restoredTasks.single.linkedElementIds, <String>[
        'element-1',
        'element-2',
      ]);

      final deleted = await restoredRepository.deleteTask(createdTask.taskId);
      expect(deleted, isTrue);
      expect(
        await restoredRepository.listTasksForProject('project-a'),
        isEmpty,
      );

      await restoredRepository.close();
      await directory.delete(recursive: true);
    },
  );

  test('beacon task schema ids match the generated xxh3 values', () {
    expect(BeaconTaskSchema.id, -5558700412993255369);
    expect(BeaconTaskSchema.indexes['taskId']?.id, -6391211041487498726);
    expect(
      BeaconTaskSchema.indexes['owningProjectId']?.id,
      8853439974620037944,
    );
    expect(BeaconTaskSchema.indexes['status']?.id, -107785170620420283);
  });

  test('in-memory repository archives and deletes projects', () async {
    final repository = _InMemoryProjectRepository(
      initialProjects: <Project>[
        Project.create(
          id: 'project-a',
          projectTitle: '江岸计划',
          projectThemeStatement: '记录河流与工业废墟之间的关系',
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
        Project.create(
          id: 'project-b',
          projectTitle: '编辑目标项目',
          projectThemeStatement: '用于测试删除',
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ],
      currentProjectId: 'project-a',
    );

    await repository.archiveProject('project-a');
    expect(
      repository.projects
          .singleWhere((project) => project.projectId == 'project-a')
          .stage,
      'completed',
    );

    await repository.archiveProject('project-a');
    expect(
      repository.projects
          .singleWhere((project) => project.projectId == 'project-a')
          .stage,
      'draft',
    );

    await repository.deleteProject('project-b');
    expect(repository.projects.map((project) => project.projectId), <String>[
      'project-a',
    ]);
  });

  testWidgets('app renders structure page by default', (tester) async {
    await tester.pumpWidget(
      EchoApp(
        projectRepository: _InMemoryProjectRepository(),
        structureChapterRepository: _InMemoryStructureChapterRepository(),
        narrativeElementRepository: _InMemoryNarrativeElementRepository(),
        projectRelationRepository: _InMemoryProjectRelationRepository(),
      ),
    );

    expect(find.text('新 建 项 目'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byType(CustomBottomNavBar), findsNothing);
    expect(find.text('章节骨架'), findsNothing);
  });

  testWidgets(
    'no-project top-right settings button opens a real settings page',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('图片压缩'), findsOneWidget);
      expect(find.text('项目数据导出 / 导入'), findsOneWidget);
      expect(find.text('新 建 项 目'), findsNothing);
    },
  );

  testWidgets(
    'settings page shows exactly three compression options with no resolution copy',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('图片压缩'), findsOneWidget);
      expect(find.text('无压缩'), findsOneWidget);
      expect(find.text('高质量'), findsOneWidget);
      expect(find.text('标准'), findsOneWidget);
      expect(find.text('高性能'), findsNothing);
      expect(find.textContaining('2160'), findsNothing);
      expect(find.textContaining('3840'), findsNothing);
      expect(find.textContaining('1080'), findsNothing);
      expect(find.textContaining('1920'), findsNothing);
      expect(find.byType(RadioListTile<Object?>), findsNWidgets(3));
      expect(_findSelectedCompressionOption('无压缩'), findsOneWidget);
    },
  );

  testWidgets(
    'compression choice stays selected after closing and reopening settings page',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(_findSelectedCompressionOption('无压缩'), findsOneWidget);

      await tester.tap(find.text('高质量'));
      await tester.pumpAndSettle();
      expect(_findSelectedCompressionOption('高质量'), findsOneWidget);
      expect(find.textContaining('保 存'), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('新 建 项 目'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(_findSelectedCompressionOption('高质量'), findsOneWidget);
      expect(_findSelectedCompressionOption('无压缩'), findsNothing);
    },
  );

  testWidgets('shell back from top-level tabs returns to structure page', (
    tester,
  ) async {
    await tester.pumpWidget(
      EchoApp(
        projectRepository: _InMemoryProjectRepository(
          initialProjects: <Project>[
            Project.create(
              id: 'project-shell-back',
              projectTitle: '返回测试',
              projectThemeStatement: '验证一级页面返回逻辑',
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
          ],
          currentProjectId: 'project-shell-back',
        ),
        structureChapterRepository: _InMemoryStructureChapterRepository(),
        narrativeElementRepository: _InMemoryNarrativeElementRepository(),
        projectRelationRepository: _InMemoryProjectRelationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('章节骨架'), findsOneWidget);

    await tester.tap(find.text('整理'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('globalArrangeBottomNavShell')),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('章节骨架'), findsOneWidget);

    await tester.tap(find.text('历程'));
    await tester.pumpAndSettle();
    expect(find.text('暂无记录'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('章节骨架'), findsOneWidget);

    await tester.tap(find.text('信标'));
    await tester.pumpAndSettle();
    expect(find.text('待执行'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('章节骨架'), findsOneWidget);
  });

  testWidgets(
    'no-project page opens wizard from center button and then lands on new project structure page',
    (tester) async {
      final repository = _InMemoryProjectRepository();

      await tester.pumpWidget(
        EchoApp(
          projectRepository: repository,
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('新 建 项 目'), findsOneWidget);
      expect(find.byType(CustomBottomNavBar), findsNothing);

      await tester.tap(find.text('新 建 项 目'));
      await tester.pumpAndSettle();

      expect(find.text('输入你的创作意图'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '记录河流与工业废墟之间的关系');
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '江岸计划');
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.tap(find.text('详 细 编 辑'));
      await tester.pumpAndSettle();

      expect(find.text('章节骨架'), findsOneWidget);
      expect(find.text('江岸计划'), findsOneWidget);
      expect((await repository.getCurrentProject())?.title, '江岸计划');
    },
  );

  testWidgets(
    'add button opens overlay with default record mode and close button dismisses it',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-overlay',
                projectTitle: '覆盖层项目',
                projectThemeStatement: '用于测试底部加号覆盖层',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: 'project-overlay',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('保 存 记 录'), findsOneWidget);
      expect(find.text('在此输入记录内容...'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('quickRecordModeSelector')),
        findsOneWidget,
      );
      expect(find.text('记录'), findsOneWidget);
      expect(find.text('上海·静安'), findsNothing);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('保 存 记 录'), findsNothing);
    },
  );

  testWidgets(
    'add overlay reuses gallery import seam and passes selected mode to save callback',
    (tester) async {
      SaveCaptureRequest? capturedRequest;
      String? importedSourcePath;

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-overlay-save',
                projectTitle: '采集项目',
                projectThemeStatement: '用于测试加号保存接线',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: 'project-overlay-save',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          narrativeElementPhotoPicker: () async => <String>['/tmp/source.jpg'],
          narrativeElementPhotoImporter: (sourcePath) async {
            importedSourcePath = sourcePath;
            return '/tmp/imported.jpg';
          },
          saveCaptureRecord: (request) async {
            capturedRequest = request;
            return const SaveCaptureResult(recordId: 'record-1');
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('quickRecordModeSelector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('作品').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('quickRecordGalleryButton')));
      await tester.pumpAndSettle();

      expect(importedSourcePath, '/tmp/source.jpg');
      expect(
        find.byKey(const ValueKey('quickRecordPhotoStrip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quickRecordPhotoTile-0')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('quickRecordTextField')),
        '现场文字',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quickRecordSaveButton')));
      await tester.pumpAndSettle();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest?.mode, CaptureMode.portfolio);
      expect(capturedRequest?.rawText, '现场文字');
      expect(capturedRequest?.photoPaths, <String>['/tmp/imported.jpg']);
      expect(find.text('保 存 记 录'), findsNothing);
    },
  );

  testWidgets(
    'portfolio mode keeps save disabled until at least one photo is mounted',
    (tester) async {
      SaveCaptureRequest? capturedRequest;

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-overlay-portfolio-guard',
                projectTitle: '作品模式项目',
                projectThemeStatement: '验证作品模式保存约束',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: 'project-overlay-portfolio-guard',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          narrativeElementPhotoPicker: () async => <String>['/tmp/source.jpg'],
          narrativeElementPhotoImporter: (sourcePath) async =>
              '/tmp/imported.jpg',
          saveCaptureRecord: (request) async {
            capturedRequest = request;
            return const SaveCaptureResult(recordId: 'record-guard');
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('quickRecordModeSelector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('作品').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('quickRecordTextField')),
        '只有文字不能保存作品',
      );
      await tester.pumpAndSettle();

      final disabledSaveButton = tester.widget<InkWell>(
        find.byKey(const ValueKey('quickRecordSaveButton')),
      );
      expect(disabledSaveButton.onTap, isNotNull);

      await tester.tap(find.byKey(const ValueKey('quickRecordSaveButton')));
      await tester.pumpAndSettle();
      expect(find.text('请先添加照片'), findsOneWidget);
      expect(capturedRequest, isNull);

      await tester.tap(find.byKey(const ValueKey('quickRecordGalleryButton')));
      await tester.pumpAndSettle();

      final enabledSaveButton = tester.widget<InkWell>(
        find.byKey(const ValueKey('quickRecordSaveButton')),
      );
      expect(enabledSaveButton.onTap, isNotNull);
    },
  );

  testWidgets(
    'quick record mode menu uses square corners and airy typography',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-overlay-style',
                projectTitle: '覆盖层样式项目',
                projectThemeStatement: '验证记录模式菜单视觉样式',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: 'project-overlay-style',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pumpAndSettle();

      final selector = tester.widget<PopupMenuButton<CaptureMode>>(
        find.byKey(const ValueKey('quickRecordModeSelector')),
      );
      final shape = selector.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, const BorderRadius.all(Radius.circular(12)));
      expect(selector.menuPadding, const EdgeInsets.symmetric(vertical: 4));
      expect(
        selector.constraints,
        const BoxConstraints(minWidth: 96, maxWidth: 104),
      );

      final triggerLabel = tester.widget<Text>(
        find.byKey(const ValueKey('quickRecordModeLabel')),
      );
      expect(triggerLabel.style?.fontWeight, FontWeight.w300);
      expect(triggerLabel.style?.fontSize, 17);
      expect(triggerLabel.style?.letterSpacing, 2.2);

      await tester.tap(find.byKey(const ValueKey('quickRecordModeSelector')));
      await tester.pumpAndSettle();

      final portfolioLabel = tester.widget<Text>(find.text('作品').last);
      expect(portfolioLabel.textAlign, TextAlign.center);
      expect(portfolioLabel.style?.fontWeight, FontWeight.w300);
      expect(portfolioLabel.style?.fontSize, 16);
      expect(portfolioLabel.style?.letterSpacing, 1.6);
    },
  );

  testWidgets(
    'add overlay shows mounted photos as a horizontal strip and supports removal',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-overlay-strip',
                projectTitle: '采集条带',
                projectThemeStatement: '验证照片条带',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: 'project-overlay-strip',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          captureRecordRepository: _InMemoryCaptureRecordRepository(),
          narrativeElementPhotoPicker: () async => <String>[
            '/tmp/source-a.jpg',
            '/tmp/source-b.jpg',
          ],
          narrativeElementPhotoImporter: (sourcePath) async {
            return sourcePath == '/tmp/source-a.jpg'
                ? '/tmp/imported-a.jpg'
                : '/tmp/imported-b.jpg';
          },
          saveCaptureRecord: (request) async =>
              const SaveCaptureResult(recordId: 'record-strip'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('quickRecordGalleryButton')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('quickRecordPhotoStrip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quickRecordPhotoTile-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quickRecordPhotoTile-1')),
        findsOneWidget,
      );
      final stripRect = tester.getRect(
        find.byKey(const ValueKey('quickRecordPhotoStrip')),
      );
      final removeButtonRect = tester.getRect(
        find.byKey(const ValueKey('quickRecordPhotoRemoveButton-0')),
      );
      expect(stripRect.contains(removeButtonRect.topLeft), isTrue);
      expect(stripRect.contains(removeButtonRect.bottomRight), isTrue);

      await tester.tap(
        find.byKey(const ValueKey('quickRecordPhotoRemoveButton-0')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('quickRecordPhotoTile-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quickRecordPhotoTile-1')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'photo capture from add overlay does not create an element and appears in pending organize',
    (tester) async {
      const projectId = 'project-overlay-to-pending';
      final captureRecordRepository = _InMemoryCaptureRecordRepository();

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '从加号到待整理',
                projectThemeStatement: '验证照片采集不落元素',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          captureRecordRepository: captureRecordRepository,
          narrativeElementPhotoPicker: () async => <String>[
            '/tmp/source-a.jpg',
          ],
          narrativeElementPhotoImporter: (_) async => '/tmp/imported-a.jpg',
          saveCaptureRecord: (request) async {
            final record = await captureRecordRepository.createRecord(
              projectId: request.projectId,
              mode: request.mode.storageValue,
              rawText: request.rawText,
              photoPaths: request.photoPaths,
            );
            return SaveCaptureResult(recordId: record.recordId);
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('quickRecordModeSelector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('作品').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quickRecordGalleryButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quickRecordSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('采集照片'), findsNothing);

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('globalArrangePendingButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PendingOrganizePage), findsOneWidget);
      expect(
        tester
            .widget<Text>(
              find.byKey(
                const ValueKey('pendingOrganizePhotoCounter'),
                skipOffstage: false,
              ),
            )
            .data,
        '1 / 1',
      );
      expect(
        find.byKey(
          const ValueKey('pendingPhoto-record-1::0::/tmp/imported-a.jpg'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('sidebar opens and new project entry launches wizard', (
    tester,
  ) async {
    await tester.pumpWidget(
      EchoApp(
        projectRepository: _InMemoryProjectRepository(),
        structureChapterRepository: _InMemoryStructureChapterRepository(),
        narrativeElementRepository: _InMemoryNarrativeElementRepository(),
        projectRelationRepository: _InMemoryProjectRelationRepository(),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu).first);
    await tester.pumpAndSettle();

    expect(find.text('项目中心'), findsOneWidget);
    expect(find.text('新建项目'), findsOneWidget);

    await tester.tap(find.text('新建项目'));
    await tester.pumpAndSettle();

    expect(find.text('输入你的创作意图'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets(
    'advancing from intent to project name focuses the project name field',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectWizardPage(
            onFinish:
                (
                  unusedTitle,
                  unusedThemeStatement,
                  unusedCoverImagePath,
                ) async {},
            onPickCoverImage: () async => null,
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('projectIntentField')),
        '记录山体与工业边缘的呼吸感',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      final nameField = tester.widget<TextField>(
        find.byKey(const ValueKey('projectNameField')),
      );
      expect(nameField.focusNode?.hasFocus, isTrue);
    },
  );

  testWidgets(
    'sidebar shows textual empty states instead of mock project names when no projects exist',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu).first);
      await tester.pumpAndSettle();

      final sidebarFinder = find.byType(ProjectSidebar);

      expect(
        find.descendant(of: sidebarFinder, matching: find.text('赤水河沿岸寻访')),
        findsNothing,
      );
      expect(
        find.descendant(of: sidebarFinder, matching: find.text('建筑的沉默')),
        findsNothing,
      );
      expect(
        find.descendant(of: sidebarFinder, matching: find.text('无名系列 01')),
        findsNothing,
      );
      expect(
        find.descendant(of: sidebarFinder, matching: find.text('暂无项目')),
        findsNWidgets(2),
      );
    },
  );

  testWidgets(
    'finishing project wizard opens structure page for the created project',
    (tester) async {
      final repository = _InMemoryProjectRepository();

      await tester.pumpWidget(
        EchoApp(
          projectRepository: repository,
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('新建项目'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '记录河流与工业废墟之间的关系');
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '江岸计划');
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.tap(find.text('详 细 编 辑'));
      await tester.pumpAndSettle();

      expect(find.text('章节骨架'), findsOneWidget);
      expect(find.text('江岸计划'), findsOneWidget);
      expect((await repository.getCurrentProject())?.title, '江岸计划');
    },
  );

  testWidgets(
    'selected cover image path is passed when finishing project wizard',
    (tester) async {
      String? createdCoverImagePath;

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectWizardPage(
            onFinish:
                (unusedTitle, unusedThemeStatement, coverImagePath) async {
                  createdCoverImagePath = coverImagePath;
                },
            onPickCoverImage: () async => '/tmp/project-cover.jpg',
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('projectIntentField')),
        '追踪河流与厂房的关系',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('projectNameField')),
        '工业河岸',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('project-cover.jpg'), findsNothing);

      await tester.tap(find.text('详 细 编 辑'));
      await tester.pumpAndSettle();

      expect(createdCoverImagePath, '/tmp/project-cover.jpg');
    },
  );

  testWidgets(
    'project wizard recovers from onFinish failure without staying on white flash screen',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectWizardPage(
            onFinish:
                (
                  unusedTitle,
                  unusedThemeStatement,
                  unusedCoverImagePath,
                ) async {
                  throw StateError('mock create failure');
                },
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('projectIntentField')),
        '追踪河流与厂房的关系',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('projectNameField')),
        '工业河岸',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.tap(find.text('详 细 编 辑'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('详 细 编 辑'), findsOneWidget);
      expect(find.textContaining('创建项目失败：'), findsOneWidget);
    },
  );

  testWidgets(
    'echo app project creation flow surfaces create failure instead of leaving a white screen',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _FailingProjectRepository(),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('新 建 项 目'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('projectIntentField')),
        '记录河流与工业废墟之间的关系',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('projectNameField')),
        '江岸计划',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      await tester.tap(find.text('详 细 编 辑'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('详 细 编 辑'), findsOneWidget);
      expect(find.textContaining('创建项目失败：'), findsOneWidget);
      expect(find.text('章节骨架'), findsNothing);
    },
  );

  testWidgets(
    'structure page shows real chapters for the current project and add chapter opens placeholder page',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-structure',
            projectTitle: '结构测试项目',
            projectThemeStatement: '用于测试真实章节展示',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-structure',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-1',
            projectId: 'project-structure',
            chapterTitle: '第一章：河岸的回声',
            chapterDescription: '真实章节说明',
            chapterElementCount: 2,
            chapterSortOrder: 0,
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: _InMemoryNarrativeElementRepository(
            initialElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-1',
                projectId: 'project-structure',
                chapterId: 'chapter-1',
                elementTitle: '河岸石块',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
              NarrativeElement.create(
                id: 'element-2',
                projectId: 'project-structure',
                chapterId: 'chapter-1',
                elementTitle: '回声碎片',
                createdTimestamp: DateTime(2026, 1, 2),
                updatedTimestamp: DateTime(2026, 1, 2),
              ),
            ],
          ),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('第一章：河岸的回声'), findsOneWidget);
      expect(find.text('真实章节说明'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('添加章节'));
      await tester.pumpAndSettle();

      expect(find.text('添 加 章 节'), findsOneWidget);
    },
  );

  testWidgets(
    'structure page chapter cards keep blank description space without fallback copy',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-blank-chapter-desc',
                projectTitle: '空白章节说明测试',
                projectThemeStatement: '验证章节卡片空说明留白',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: 'project-blank-chapter-desc',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-blank-desc',
                projectId: 'project-blank-chapter-desc',
                chapterTitle: '无说明章节',
                chapterSortOrder: 0,
              ),
            ],
          ),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('无说明章节'), findsOneWidget);
      expect(find.text('暂无章节说明'), findsNothing);
    },
  );

  testWidgets(
    'chapter create page saves chapter and attached draft elements together',
    (tester) async {
      int? savedSortOrder;
      String? savedTitle;
      String? savedDescription;
      List<NarrativeElementDraft>? savedElements;

      await tester.pumpWidget(
        MaterialApp(
          home: ChapterCreatePage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-existing',
                projectId: 'project-a',
                chapterTitle: '晨曦之眼',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {
                  savedTitle = title;
                  savedDescription = description;
                  savedSortOrder = sortOrder;
                  savedElements = elements;
                },
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateTitleField')),
        '新的章节',
      );
      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateDescriptionField')),
        '新的章节说明',
      );
      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('chapterDraftElementNameField')),
        '章节内元素',
      );
      await tester.enterText(
        find.byKey(const ValueKey('chapterDraftElementDescriptionField')),
        '章节内元素说明',
      );
      await tester.tap(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      expect(savedTitle, '新的章节');
      expect(savedDescription, '新的章节说明');
      expect(savedSortOrder, 1);
      expect(savedElements?.length, 1);
      expect(savedElements?.first.title, '章节内元素');
    },
  );

  testWidgets(
    'chapter create page sequence list keeps blank description space without fallback copy',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChapterCreatePage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-sequence-blank-desc',
                projectId: 'project-sequence-blank-desc',
                chapterTitle: '空说明章节',
                chapterSortOrder: 0,
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('空说明章节'), findsOneWidget);
      expect(find.text('暂无章节说明'), findsNothing);
    },
  );

  testWidgets('tapping a chapter card opens edit page and save updates it', (
    tester,
  ) async {
    final projectRepository = _InMemoryProjectRepository(
      initialProjects: <Project>[
        Project.create(
          id: 'project-edit',
          projectTitle: '章节编辑测试',
          projectThemeStatement: '验证章节编辑流程',
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ],
      currentProjectId: 'project-edit',
    );
    final chapterRepository = _InMemoryStructureChapterRepository(
      initialChapters: <StructureChapter>[
        StructureChapter.create(
          id: 'chapter-edit',
          projectId: 'project-edit',
          chapterTitle: '待编辑章节',
          chapterDescription: '编辑前说明',
          chapterSortOrder: 0,
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ],
    );

    await tester.pumpWidget(
      EchoApp(
        projectRepository: projectRepository,
        structureChapterRepository: chapterRepository,
        narrativeElementRepository: _InMemoryNarrativeElementRepository(),
        projectRelationRepository: _InMemoryProjectRelationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('待编辑章节'));
    await tester.pumpAndSettle();

    expect(find.text('编 辑 章 节'), findsOneWidget);
    expect(find.byKey(const ValueKey('chapterCompleteButton')), findsOneWidget);
    expect(find.text('章节完成'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('chapterCreateTitleField')),
      '已更新章节',
    );
    await tester.enterText(
      find.byKey(const ValueKey('chapterCreateDescriptionField')),
      '更新后的章节说明',
    );
    await tester.tap(find.text('保 存'));
    await tester.pumpAndSettle();

    expect(find.text('已更新章节'), findsOneWidget);
    expect(find.text('更新后的章节说明'), findsOneWidget);
    expect(find.text('编 辑 章 节'), findsNothing);
  });

  testWidgets(
    'delete confirmation: chapter edit page shows delete action and removes chapter while unassigning elements',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-chapter-delete',
            projectTitle: '章节删除测试',
            projectThemeStatement: '验证章节删除流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-chapter-delete',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-delete',
            projectId: 'project-chapter-delete',
            chapterTitle: '待删除章节',
            chapterDescription: '即将删除',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-stays',
            projectId: 'project-chapter-delete',
            chapterId: 'chapter-delete',
            elementTitle: '保留元素',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('待删除章节'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('chapterDeleteButton')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('chapterDeleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确 认 删 除'), findsOneWidget);
      expect(
        find.text('删除后，仅当前章节会从结构中移除；章节内元素会保留并转入未分配；其他章节与关系内容不受影响。'),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删 除')),
      );
      await tester.pumpAndSettle();

      final chapters = await chapterRepository.listChaptersForProject(
        'project-chapter-delete',
      );
      final elements = await elementRepository.listElementsForProject(
        'project-chapter-delete',
      );

      expect(chapters, isEmpty);
      expect(elements.single.owningChapterId, isNull);
      expect(find.text('待删除章节'), findsNothing);

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();

      expect(find.text('保留元素'), findsOneWidget);
      expect(find.text('未 分 配 章 节'), findsOneWidget);
    },
  );

  testWidgets(
    'ongoing chapter completion button shows passive hints for invalid chapters',
    (tester) async {
      var completionCalls = 0;

      Future<void> pumpEditPage(List<NarrativeElement> existingElements) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChapterEditPage(
              existingChapters: <StructureChapter>[
                StructureChapter.create(
                  id: 'chapter-a',
                  projectId: 'project-a',
                  chapterTitle: '第一章',
                  chapterSortOrder: 0,
                  createdTimestamp: DateTime(2026),
                  updatedTimestamp: DateTime(2026),
                ),
              ],
              chapter: StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
              existingElements: existingElements,
              onSave:
                  ({
                    required String title,
                    required String description,
                    required int sortOrder,
                    required String statusLabel,
                    required List<NarrativeElementDraft> elements,
                  }) async {},
              onComplete:
                  ({
                    required String title,
                    required String description,
                    required int sortOrder,
                    required String statusLabel,
                    required List<NarrativeElementDraft> elements,
                  }) async {
                    completionCalls += 1;
                  },
              onDelete: () async {},
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpEditPage(const <NarrativeElement>[]);

      await tester.tap(find.byKey(const ValueKey('chapterCompleteButton')));
      await tester.pump();

      expect(find.text('章节缺少元素，无法完成。'), findsOneWidget);
      expect(completionCalls, 0);

      await pumpEditPage(<NarrativeElement>[
        NarrativeElement.create(
          id: 'element-a',
          projectId: 'project-a',
          chapterId: 'chapter-a',
          elementTitle: '河岸石块',
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ]);

      await tester.tap(find.byKey(const ValueKey('chapterCompleteButton')));
      await tester.pump();

      expect(completionCalls, 0);
    },
  );

  testWidgets(
    'ongoing chapter completion saves edits marks chapter complete and returns to structure tab',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-complete',
            projectTitle: '章节完成测试',
            projectThemeStatement: '验证章节完成流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-complete',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-complete',
            projectId: 'project-complete',
            chapterTitle: '可完成章节',
            chapterDescription: '完成前说明',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: _InMemoryNarrativeElementRepository(
            initialElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-ready',
                projectId: 'project-complete',
                chapterId: 'chapter-complete',
                elementTitle: '有码头的河岸',
                linkedPhotoPaths: <String>['/tmp/river-bank.png'],
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
          ),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('可完成章节'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateTitleField')),
        '已完成章节',
      );
      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateDescriptionField')),
        '完成后的章节说明',
      );
      await tester.tap(find.byKey(const ValueKey('chapterCompleteButton')));
      await tester.pumpAndSettle();

      final chapters = await chapterRepository.listChaptersForProject(
        'project-complete',
      );

      expect(find.text('已完成章节'), findsOneWidget);
      expect(find.text('完成'), findsOneWidget);
      expect(find.text('编 辑 章 节'), findsNothing);
      expect(chapters.single.description, '完成后的章节说明');
      expect(chapters.single.statusLabel, '完成');
    },
  );

  testWidgets(
    'complete/editing rules: completed chapter blocks save until continue editing is tapped',
    (tester) async {
      var saveCalls = 0;
      var completeCalls = 0;
      String? savedStatusLabel;

      await tester.pumpWidget(
        MaterialApp(
          home: ChapterEditPage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-completed',
                projectId: 'project-a',
                chapterTitle: '已完成章节',
                chapterStatus: '完成',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            chapter: StructureChapter.create(
              id: 'chapter-completed',
              projectId: 'project-a',
              chapterTitle: '已完成章节',
              chapterStatus: '完成',
              chapterSortOrder: 0,
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            existingElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-ready',
                projectId: 'project-a',
                chapterId: 'chapter-completed',
                elementTitle: '已完成元素',
                linkedPhotoPaths: <String>['/tmp/done.png'],
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {
                  saveCalls += 1;
                  savedStatusLabel = statusLabel;
                },
            onComplete:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {
                  completeCalls += 1;
                },
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('继续编辑'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('chapterLockedSaveButton')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('chapterLockedSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('章节已完成，请先点击右上角继续编辑'), findsOneWidget);
      expect(saveCalls, 0);

      await tester.tap(find.byKey(const ValueKey('chapterCompleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('章节现可继续编辑'), findsOneWidget);
      expect(find.text('章节完成'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('chapterLockedSaveButton')),
        findsNothing,
      );
      expect(completeCalls, 0);

      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      expect(saveCalls, 1);
      expect(savedStatusLabel, '进行');
    },
  );

  testWidgets(
    'complete/editing rules: completed chapter can unlock edit then save later changes as ongoing',
    (tester) async {
      var saveCalls = 0;
      String? savedStatusLabel;

      await tester.pumpWidget(
        MaterialApp(
          home: ChapterEditPage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-completed',
                projectId: 'project-a',
                chapterTitle: '已完成章节',
                chapterStatus: '完成',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            chapter: StructureChapter.create(
              id: 'chapter-completed',
              projectId: 'project-a',
              chapterTitle: '已完成章节',
              chapterStatus: '完成',
              chapterSortOrder: 0,
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            existingElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-ready',
                projectId: 'project-a',
                chapterId: 'chapter-completed',
                elementTitle: '已完成元素',
                linkedPhotoPaths: <String>['/tmp/done.png'],
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {
                  saveCalls += 1;
                  savedStatusLabel = statusLabel;
                },
            onComplete:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('chapterCompleteButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateDescriptionField')),
        '已完成章节的新说明',
      );
      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      expect(saveCalls, 1);
      expect(savedStatusLabel, '进行');
    },
  );

  testWidgets(
    'chapter edit page refreshes existing element snapshot after tag editing',
    (tester) async {
      var completeCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ChapterEditPage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            chapter: StructureChapter.create(
              id: 'chapter-a',
              projectId: 'project-a',
              chapterTitle: '第一章',
              chapterSortOrder: 0,
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            existingElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-a',
                projectId: 'project-a',
                chapterId: 'chapter-a',
                elementTitle: '缺图元素',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onOpenExistingElement: (element) async {
              return ChapterElementEditorResult.updated(
                NarrativeElement.create(
                  id: element.elementId,
                  projectId: element.owningProjectId,
                  chapterId: element.owningChapterId,
                  elementTitle: element.title,
                  linkedPhotoPaths: <String>['/tmp/fixed.png'],
                  createdTimestamp: element.createdAt,
                  updatedTimestamp: DateTime(2026, 1, 2),
                ),
              );
            },
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {},
            onComplete:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {
                  completeCalls += 1;
                },
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('缺图元素 · 待补照片'), findsOneWidget);

      await tester.tap(find.text('缺图元素 · 待补照片'));
      await tester.pumpAndSettle();

      expect(find.text('缺图元素 · 待补照片'), findsNothing);
      expect(find.text('缺图元素'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('chapterCompleteButton')));
      await tester.pumpAndSettle();

      expect(completeCalls, 1);
      expect(find.text('章节缺图元素元素缺少照片，无法完成。'), findsNothing);
    },
  );

  testWidgets(
    'chapter edit page removes existing element snapshot after nested delete result',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChapterEditPage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            chapter: StructureChapter.create(
              id: 'chapter-a',
              projectId: 'project-a',
              chapterTitle: '第一章',
              chapterSortOrder: 0,
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            existingElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-delete',
                projectId: 'project-a',
                chapterId: 'chapter-a',
                elementTitle: '会被删除的元素',
                linkedPhotoPaths: <String>['/tmp/fixed.png'],
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onOpenExistingElement: (element) async {
              return ChapterElementEditorResult.deleted(element.elementId);
            },
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {},
            onComplete:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('会被删除的元素'), findsOneWidget);

      await tester.tap(find.text('会被删除的元素'));
      await tester.pumpAndSettle();

      expect(find.text('会被删除的元素'), findsNothing);
    },
  );

  testWidgets(
    'structure page shows real narrative elements and add element opens real page',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-elements',
            projectTitle: '元素测试项目',
            projectThemeStatement: '用于测试真实叙事元素展示',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-elements',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-elements',
            projectId: 'project-elements',
            chapterTitle: '第一章：河岸的回声',
            chapterDescription: '真实章节说明',
            chapterElementCount: 1,
            chapterSortOrder: 0,
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-1',
            projectId: 'project-elements',
            chapterId: 'chapter-elements',
            elementTitle: '江边的空酒瓶',
            elementDescription: '真实叙事元素说明',
            linkedPhotoPaths: <String>[],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();

      expect(find.text('江边的空酒瓶'), findsOneWidget);
      expect(find.text('真实叙事元素说明'), findsOneWidget);

      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();

      expect(find.text('添 加 叙 事 元 素'), findsOneWidget);
    },
  );

  testWidgets(
    'narrative element tab filters list and hides empty chapter headers',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-element-counts',
            projectTitle: '元素计数测试',
            projectThemeStatement: '验证叙事元素状态计数',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-element-counts',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-finding',
            projectId: 'project-element-counts',
            chapterTitle: '第一章：寻找线索',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-ready',
            projectId: 'project-element-counts',
            chapterTitle: '第二章：完成确认',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-finding',
            projectId: 'project-element-counts',
            chapterId: 'chapter-finding',
            elementTitle: '寻找中的元素',
            elementStatus: 'finding',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-ready',
            projectId: 'project-element-counts',
            chapterId: 'chapter-ready',
            elementTitle: '已就绪的元素',
            elementStatus: 'ready',
            linkedPhotoPaths: <String>['/tmp/ready.png'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();

      expect(find.text('寻找中 (1)'), findsOneWidget);
      expect(find.text('已就绪 (1)'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.text('寻找中的元素'), findsOneWidget);
      expect(find.text('已就绪的元素'), findsOneWidget);
      expect(find.textContaining('第一章：寻找线索'), findsOneWidget);
      expect(find.textContaining('第二章：完成确认'), findsOneWidget);

      await tester.tap(find.text('已就绪 (1)'));
      await tester.pumpAndSettle();

      expect(find.text('寻找中的元素'), findsNothing);
      expect(find.text('已就绪的元素'), findsOneWidget);
      expect(find.textContaining('第一章：寻找线索'), findsNothing);
      expect(find.textContaining('第二章：完成确认'), findsOneWidget);

      await tester.tap(find.text('寻找中 (1)'));
      await tester.pumpAndSettle();

      expect(find.text('寻找中的元素'), findsOneWidget);
      expect(find.text('已就绪的元素'), findsNothing);
      expect(find.textContaining('第一章：寻找线索'), findsOneWidget);
      expect(find.textContaining('第二章：完成确认'), findsNothing);
    },
  );

  testWidgets('tapping a narrative element card opens edit page and saves it', (
    tester,
  ) async {
    final projectRepository = _InMemoryProjectRepository(
      initialProjects: <Project>[
        Project.create(
          id: 'project-element-edit',
          projectTitle: '元素编辑测试',
          projectThemeStatement: '验证元素编辑流程',
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ],
      currentProjectId: 'project-element-edit',
    );
    final chapterRepository = _InMemoryStructureChapterRepository(
      initialChapters: <StructureChapter>[
        StructureChapter.create(
          id: 'chapter-a',
          projectId: 'project-element-edit',
          chapterTitle: '第一章',
          chapterSortOrder: 0,
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ],
    );
    final elementRepository = _InMemoryNarrativeElementRepository(
      initialElements: <NarrativeElement>[
        NarrativeElement.create(
          id: 'element-edit',
          projectId: 'project-element-edit',
          chapterId: 'chapter-a',
          elementTitle: '待编辑元素',
          elementDescription: '编辑前说明',
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ],
    );

    await tester.pumpWidget(
      EchoApp(
        projectRepository: projectRepository,
        structureChapterRepository: chapterRepository,
        narrativeElementRepository: elementRepository,
        projectRelationRepository: _InMemoryProjectRelationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('叙事元素'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('待编辑元素'));
    await tester.pumpAndSettle();

    expect(find.text('元素完成'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('narrativeCompleteButton')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('narrativeElementNameField')),
      '已更新元素',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('narrativeSaveButton')),
    );
    await tester.tap(
      find.byKey(const ValueKey('narrativeSaveButton')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('已更新元素'), findsOneWidget);
    expect(find.text('待编辑元素'), findsNothing);
  });

  testWidgets(
    'delete confirmation: narrative element edit page shows delete action and removes linked relation groups',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-element-delete',
            projectTitle: '元素删除测试',
            projectThemeStatement: '验证元素删除流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-element-delete',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-a',
            projectId: 'project-element-delete',
            chapterTitle: '第一章',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-delete',
            projectId: 'project-element-delete',
            chapterId: 'chapter-a',
            elementTitle: '待删除元素',
            linkedPhotoPaths: <String>['/tmp/delete.png'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final captureRecordRepository = _InMemoryCaptureRecordRepository();
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationType =
          (await relationRepository.listRelationTypesForProject(
            'project-element-delete',
          )).firstWhere((type) => type.name == '对比');
      await relationRepository.createRelationGroup(
        projectId: 'project-element-delete',
        relationTypeId: relationType.relationTypeId,
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.element(elementId: 'element-delete'),
          ProjectRelationDraftMember.photo(
            photoPath: '/tmp/delete.png',
            sourceElementId: 'element-delete',
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: elementRepository,
          projectRelationRepository: relationRepository,
          captureRecordRepository: captureRecordRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('待删除元素'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('narrativeDeleteButton')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('narrativeDeleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确 认 删 除'), findsOneWidget);
      expect(
        find.text('删除后，仅当前元素及引用它的关联关系会移除；章节与关系类型会保留，当前页面将返回列表。'),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删 除')),
      );
      await tester.pumpAndSettle();

      final elements = await elementRepository.listElementsForProject(
        'project-element-delete',
      );
      final relationGroups = await relationRepository
          .listRelationGroupsForProject('project-element-delete');
      final captureRecords = await captureRecordRepository
          .listRecordsForProject('project-element-delete');

      expect(elements, isEmpty);
      expect(relationGroups, isEmpty);
      expect(captureRecords, hasLength(1));
      expect(captureRecords.single.unorganizedPhotoPaths, <String>[
        '/tmp/delete.png',
      ]);
      expect(find.text('待删除元素'), findsNothing);
    },
  );

  testWidgets(
    'ongoing narrative element completion button shows passive hint when no photo exists',
    (tester) async {
      var completeCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementEditPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            element: NarrativeElement.create(
              id: 'element-a',
              projectId: 'project-a',
              chapterId: 'chapter-a',
              elementTitle: '待完成元素',
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onComplete:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  completeCalls += 1;
                },
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('narrativeCompleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('元素缺少照片，无法完成。'), findsOneWidget);
      expect(completeCalls, 0);
    },
  );

  testWidgets(
    'unassigned narrative element stays explicit and offers a direct reassignment path',
    (tester) async {
      String? savedChapterId;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementEditPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            element: NarrativeElement.create(
              id: 'element-unassigned',
              projectId: 'project-a',
              elementTitle: '未归章元素',
              linkedPhotoPaths: <String>['/tmp/unassigned.jpg'],
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  savedChapterId = chapterId;
                },
            onComplete:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('narrativeElementUnassignedChapterChip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('narrativeElementUnassignedHint')),
        findsNothing,
      );

      await tester.tap(find.text('C H A P T E R   01'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(savedChapterId, 'chapter-a');
    },
  );

  testWidgets(
    'ongoing narrative element completion saves edits and marks ready',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-element-complete',
            projectTitle: '元素完成测试',
            projectThemeStatement: '验证元素完成流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-element-complete',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-a',
            projectId: 'project-element-complete',
            chapterTitle: '第一章',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-complete',
            projectId: 'project-element-complete',
            chapterId: 'chapter-a',
            elementTitle: '可完成元素',
            linkedPhotoPaths: <String>['/tmp/ready.png'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('可完成元素'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '已完成元素',
      );
      await tester.tap(find.byKey(const ValueKey('narrativeCompleteButton')));
      await tester.pumpAndSettle();

      final elements = await elementRepository.listElementsForProject(
        'project-element-complete',
      );
      expect(elements.single.title, '已完成元素');
      expect(elements.single.status, 'ready');
    },
  );

  testWidgets(
    'completed narrative element blocks save until continue editing is tapped',
    (tester) async {
      var saveCalls = 0;
      String? savedStatus;
      String? savedUnlockChapterId;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementEditPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterStatus: '完成',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            element: NarrativeElement.create(
              id: 'element-done',
              projectId: 'project-a',
              chapterId: 'chapter-a',
              elementTitle: '已完成元素',
              elementStatus: 'ready',
              linkedPhotoPaths: <String>['/tmp/done.png'],
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  saveCalls += 1;
                  savedStatus = status;
                  savedUnlockChapterId = unlockChapterId;
                },
            onComplete:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('继续编辑'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('narrativeLockedSaveButton')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('narrativeLockedSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('叙事元素已完成，请先点击右上角继续编辑'), findsOneWidget);
      expect(saveCalls, 0);

      await tester.tap(find.byKey(const ValueKey('narrativeCompleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认继续编辑'), findsOneWidget);
      expect(find.text('继续编辑该元素后，所属章节也会恢复为可编辑状态。'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('继续编辑')),
      );
      await tester.pumpAndSettle();

      expect(find.text('叙事元素及所属章节现可继续编辑'), findsOneWidget);
      expect(find.text('元素完成'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('narrativeLockedSaveButton')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(saveCalls, 1);
      expect(savedStatus, 'finding');
      expect(savedUnlockChapterId, 'chapter-a');
    },
  );

  testWidgets(
    'complete/editing rules: completed element inside completed chapter requires confirmation before continue editing',
    (tester) async {
      var saveCalls = 0;
      String? savedUnlockChapterId;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementEditPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterStatus: '完成',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            element: NarrativeElement.create(
              id: 'element-ready',
              projectId: 'project-a',
              chapterId: 'chapter-a',
              elementTitle: '完成元素',
              elementStatus: 'ready',
              linkedPhotoPaths: <String>['/tmp/done.png'],
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  saveCalls += 1;
                  savedUnlockChapterId = unlockChapterId;
                },
            onComplete:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('narrativeCompleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认继续编辑'), findsOneWidget);
      expect(find.text('继续编辑该元素后，所属章节也会恢复为可编辑状态。'), findsOneWidget);

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('继续编辑')),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('narrativeSaveButton')),
      );
      await tester.tap(
        find.byKey(const ValueKey('narrativeSaveButton')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(saveCalls, 1);
      expect(savedUnlockChapterId, 'chapter-a');
    },
  );

  testWidgets(
    'complete/editing rules: completed element inside ongoing chapter continues editing without confirmation',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementEditPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-ongoing',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterStatus: '进行',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            element: NarrativeElement.create(
              id: 'element-ready-ongoing',
              projectId: 'project-a',
              chapterId: 'chapter-ongoing',
              elementTitle: '完成元素',
              elementStatus: 'ready',
              linkedPhotoPaths: <String>['/tmp/done.png'],
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onComplete:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('narrativeCompleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认继续编辑'), findsNothing);
      expect(find.text('叙事元素现可继续编辑'), findsOneWidget);
      expect(find.text('元素完成'), findsOneWidget);
    },
  );

  testWidgets(
    'complete/editing rules: completed narrative element unlocks the newly selected completed chapter when reassigned',
    (tester) async {
      String? savedUnlockChapterId;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementEditPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterStatus: '进行',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
              StructureChapter.create(
                id: 'chapter-b',
                projectId: 'project-a',
                chapterTitle: '第二章',
                chapterStatus: '完成',
                chapterSortOrder: 1,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            element: NarrativeElement.create(
              id: 'element-ready',
              projectId: 'project-a',
              chapterId: 'chapter-a',
              elementTitle: '完成元素',
              elementStatus: 'ready',
              linkedPhotoPaths: <String>['/tmp/done.png'],
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  savedUnlockChapterId = unlockChapterId;
                },
            onComplete:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('C H A P T E R   02'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('narrativeCompleteButton')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('继续编辑')),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('narrativeSaveButton')),
      );
      await tester.tap(
        find.byKey(const ValueKey('narrativeSaveButton')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(savedUnlockChapterId, 'chapter-b');
    },
  );

  testWidgets(
    'editing an incomplete narrative element into a completed chapter requires confirmation before save',
    (tester) async {
      var saveCalls = 0;
      String? savedChapterId;
      String? savedUnlockChapterId;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementEditPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterStatus: '进行',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
              StructureChapter.create(
                id: 'chapter-b',
                projectId: 'project-a',
                chapterTitle: '第二章',
                chapterStatus: '完成',
                chapterSortOrder: 1,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            element: NarrativeElement.create(
              id: 'element-finding',
              projectId: 'project-a',
              chapterId: 'chapter-a',
              elementTitle: '未完成元素',
              elementStatus: 'finding',
              linkedPhotoPaths: const <String>[],
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  saveCalls += 1;
                  savedChapterId = chapterId;
                  savedUnlockChapterId = unlockChapterId;
                },
            onComplete:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onDelete: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('C H A P T E R   02'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认继续保存'), findsOneWidget);
      expect(find.text('继续保存该元素后，所属章节也会恢复为可编辑状态。'), findsOneWidget);
      expect(saveCalls, 0);

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('继续保存')),
      );
      await tester.pumpAndSettle();

      expect(saveCalls, 1);
      expect(savedChapterId, 'chapter-b');
      expect(savedUnlockChapterId, 'chapter-b');
    },
  );

  testWidgets(
    'chapter page draft element tag opens edit page without chapter selector',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChapterCreatePage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateTitleField')),
        '新的章节',
      );
      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('chapterDraftElementNameField')),
        '章节内元素',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
      );
      await tester.tap(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('章节内元素'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('chapterDraftElementNameField')),
        findsOneWidget,
      );
      expect(find.text('所 属 章 节'), findsNothing);
    },
  );

  testWidgets(
    'chapter page removes a draft element immediately on long press without extra confirmation',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChapterCreatePage(
            existingChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-remove-draft',
                projectId: 'project-remove-draft',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required int sortOrder,
                  required String statusLabel,
                  required List<NarrativeElementDraft> elements,
                }) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateTitleField')),
        '新的章节',
      );
      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();
      expect(find.text('添 加 叙 事 元 素'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('chapterDraftElementNameField')),
        '待移除草稿元素',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
      );
      await tester.tap(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('待移除草稿元素 · 待补照片'), findsOneWidget);

      await tester.longPress(find.text('待移除草稿元素 · 待补照片'));
      await tester.pump();

      expect(find.text('确 认 移 除'), findsNothing);
      expect(find.text('已从本章节移除「待移除草稿元素」'), findsOneWidget);
      expect(find.text('待移除草稿元素 · 待补照片'), findsNothing);
    },
  );

  testWidgets(
    'narrative list tile uses a local-file image provider for imported photo paths',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: NarrativeListTile(
              title: 'test-yuansu1',
              description: 'test-yuansu1',
              status: ElementStatus.finding,
              previewItems: <ContentPreviewItem>[
                ContentPreviewItem.photo(
                  stableId: '/tmp/echo/media/narrative/photo-1.jpg',
                  imageSource: '/tmp/echo/media/narrative/photo-1.jpg',
                ),
              ],
            ),
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image).first);

      expect(_baseImageProvider(imageWidget.image), isA<FileImage>());
    },
  );

  testWidgets(
    'narrative list tile keeps network image provider for remote photo urls',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: NarrativeListTile(
              title: 'test-yuansu1',
              description: 'test-yuansu1',
              status: ElementStatus.finding,
              previewItems: <ContentPreviewItem>[
                ContentPreviewItem.photo(
                  stableId: 'https://example.com/photo-1.jpg',
                  imageSource: 'https://example.com/photo-1.jpg',
                ),
              ],
            ),
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image).first);

      expect(_baseImageProvider(imageWidget.image), isA<NetworkImage>());
    },
  );

  testWidgets(
    'narrative list tile keeps blank description space without fallback copy',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Column(
              children: const [
                NarrativeListTile(
                  title: '有说明元素',
                  description: '这里有第一行说明\n这里有第二行说明',
                  status: ElementStatus.finding,
                  onTap: _noop,
                ),
                NarrativeListTile(
                  title: '空说明元素',
                  description: '',
                  status: ElementStatus.finding,
                  onTap: _noop,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('暂无叙事元素说明'), findsNothing);
      expect(
        tester.getSize(find.byType(InkWell).at(1)).height,
        closeTo(tester.getSize(find.byType(InkWell).at(0)).height, 0.5),
      );
    },
  );

  testWidgets('add element shows passive hint when no chapters exist', (
    tester,
  ) async {
    final projectRepository = _InMemoryProjectRepository(
      initialProjects: <Project>[
        Project.create(
          id: 'project-no-chapters',
          projectTitle: '无章节项目',
          projectThemeStatement: '用于测试无章节提示',
          createdTimestamp: DateTime(2026),
          updatedTimestamp: DateTime(2026),
        ),
      ],
      currentProjectId: 'project-no-chapters',
    );

    await tester.pumpWidget(
      EchoApp(
        projectRepository: projectRepository,
        structureChapterRepository: _InMemoryStructureChapterRepository(),
        narrativeElementRepository: _InMemoryNarrativeElementRepository(),
        projectRelationRepository: _InMemoryProjectRelationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('叙事元素'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加叙事元素'));
    await tester.pump();

    expect(find.text('请先添加章节'), findsOneWidget);
    expect(find.text('叙 事 元 素'), findsNothing);
  });

  testWidgets(
    'adding a narrative element returns to the source list and shows the new item',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-element-return',
            projectTitle: '元素返回落点测试',
            projectThemeStatement: '验证新增元素后返回来源列表',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-element-return',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-element-return',
            projectId: 'project-element-return',
            chapterTitle: '第一章：河岸',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final elementRepository = _InMemoryNarrativeElementRepository();

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('narrativeEditorTitle')),
        findsOneWidget,
      );
      expect(find.text('添 加 叙 事 元 素'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '新加入的河岸元素',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('章节骨架'), findsOneWidget);
      expect(find.text('叙事元素'), findsOneWidget);
      expect(find.text('新加入的河岸元素'), findsOneWidget);
    },
  );

  testWidgets(
    'adding a narrative element into a completed chapter unlocks the chapter after confirmation',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-add-completed-chapter',
            projectTitle: '完成章节挂载测试',
            projectThemeStatement: '验证新增元素时章节解锁',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-add-completed-chapter',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-completed',
            projectId: 'project-add-completed-chapter',
            chapterTitle: '已完成章节',
            chapterStatus: '完成',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final elementRepository = _InMemoryNarrativeElementRepository();

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '新增未完成元素',
      );
      await tester.tap(find.text('C H A P T E R   01'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认继续添加'), findsOneWidget);

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('继续添加')),
      );
      await tester.pumpAndSettle();

      final chapters = await chapterRepository.listChaptersForProject(
        'project-add-completed-chapter',
      );
      final elements = await elementRepository.listElementsForProject(
        'project-add-completed-chapter',
      );

      expect(chapters.single.statusLabel, '进行');
      expect(elements.single.owningChapterId, 'chapter-completed');
      expect(elements.single.status, 'finding');
    },
  );

  testWidgets(
    'moving an incomplete narrative element into a completed chapter unlocks that chapter after confirmation',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-move-completed-chapter',
            projectTitle: '元素移章测试',
            projectThemeStatement: '验证编辑元素移入完成章节时章节解锁',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-move-completed-chapter',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-a',
            projectId: 'project-move-completed-chapter',
            chapterTitle: '进行中的章节',
            chapterStatus: '进行',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-b',
            projectId: 'project-move-completed-chapter',
            chapterTitle: '已完成章节',
            chapterStatus: '完成',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-finding',
            projectId: 'project-move-completed-chapter',
            chapterId: 'chapter-a',
            elementTitle: '待整理元素',
            elementStatus: 'finding',
            linkedPhotoPaths: const <String>[],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('待整理元素'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('C H A P T E R   02'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认继续保存'), findsOneWidget);

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('继续保存')),
      );
      await tester.pumpAndSettle();

      final chapters = await chapterRepository.listChaptersForProject(
        'project-move-completed-chapter',
      );
      final elements = await elementRepository.listElementsForProject(
        'project-move-completed-chapter',
      );

      expect(
        chapters
            .singleWhere((chapter) => chapter.chapterId == 'chapter-b')
            .statusLabel,
        '进行',
      );
      expect(elements.single.owningChapterId, 'chapter-b');
      expect(elements.single.status, 'finding');
    },
  );

  testWidgets(
    'narrative element create page uses centered save button and returns entered data',
    (tester) async {
      String? savedTitle;
      String? savedDescription;
      String? savedChapterId;
      String? savedStatus;
      List<String>? savedPhotos;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章：河岸的回声',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  savedTitle = title;
                  savedDescription = description;
                  savedChapterId = chapterId;
                  savedStatus = status;
                  savedPhotos = photoPaths;
                },
            onPickPhoto: () async => <String>[],
          ),
        ),
      );

      final backIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(IconButton),
          matching: find.byIcon(Icons.arrow_back_ios_new),
        ),
      );
      expect(backIcon.size, 18);
      expect(find.text('添 加 叙 事 元 素'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('narrativeEditorTitle')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '新的叙事元素',
      );
      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementDescriptionField')),
        '新的叙事元素说明',
      );
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pump(const Duration(milliseconds: 200));

      expect(savedTitle, '新的叙事元素');
      expect(savedDescription, '新的叙事元素说明');
      expect(savedChapterId, 'chapter-a');
      expect(savedStatus, 'finding');
      expect(savedPhotos, isEmpty);
    },
  );

  testWidgets(
    'narrative element create page confirms before saving into a completed chapter',
    (tester) async {
      String? savedChapterId;
      String? savedUnlockChapterId;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章：河岸的回声',
                chapterStatus: '完成',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  savedChapterId = chapterId;
                  savedUnlockChapterId = unlockChapterId;
                },
            onPickPhoto: () async => <String>[],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '挂入完成章节的新元素',
      );
      await tester.tap(find.text('C H A P T E R   01'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认继续添加'), findsOneWidget);
      expect(find.text('继续添加该元素后，所属章节也会恢复为可编辑状态。'), findsOneWidget);

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('继续添加')),
      );
      await tester.pumpAndSettle();

      expect(savedChapterId, 'chapter-a');
      expect(savedUnlockChapterId, 'chapter-a');
    },
  );

  testWidgets(
    'narrative element create page persists imported app photo path instead of source path',
    (tester) async {
      List<String>? savedPhotos;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章：河岸的回声',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  savedPhotos = photoPaths;
                },
            onPickPhoto: () async => <String>[
              '/Users/demo/Pictures/source-photo.jpg',
            ],
            onImportPhoto: (sourcePath) async =>
                '/app/media/narrative/copied-photo.jpg',
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '新的叙事元素',
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(savedPhotos, <String>['/app/media/narrative/copied-photo.jpg']);
      expect(
        savedPhotos,
        isNot(contains('/Users/demo/Pictures/source-photo.jpg')),
      );
    },
  );

  testWidgets(
    'narrative element create page mounts multiple imported photos from one selection',
    (tester) async {
      List<String>? savedPhotos;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章：河岸的回声',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  savedPhotos = photoPaths;
                },
            onPickPhoto: () async => <String>[
              '/Users/demo/Pictures/source-photo-a.jpg',
              '/Users/demo/Pictures/source-photo-b.jpg',
            ],
            onImportPhoto: (sourcePath) async {
              if (sourcePath.endsWith('a.jpg')) {
                return '/app/media/narrative/copied-photo-a.jpg';
              }
              return '/app/media/narrative/copied-photo-b.jpg';
            },
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '新的叙事元素',
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(savedPhotos, <String>[
        '/app/media/narrative/copied-photo-a.jpg',
        '/app/media/narrative/copied-photo-b.jpg',
      ]);
    },
  );

  testWidgets(
    'narrative element create page shows mounted photo count and supports quick removal',
    (tester) async {
      List<String>? savedPhotos;

      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章：河岸的回声',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {
                  savedPhotos = photoPaths;
                },
            onPickPhoto: () async => <String>[
              '/Users/demo/Pictures/source-photo-a.jpg',
              '/Users/demo/Pictures/source-photo-b.jpg',
            ],
            onImportPhoto: (sourcePath) async {
              if (sourcePath.endsWith('a.jpg')) {
                return '/app/media/narrative/copied-photo-a.jpg';
              }
              return '/app/media/narrative/copied-photo-b.jpg';
            },
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '新的叙事元素',
      );
      await tester.tap(
        find.byKey(const ValueKey('narrativeMountedPhotoAddButton')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('narrativeMountedPhotoSummary')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('narrativeMountedPhotoTile-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('narrativeMountedPhotoTile-1')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Icon>(
              find.descendant(
                of: find.byKey(const ValueKey('narrativeMountedPhotoRemove-0')),
                matching: find.byIcon(Icons.close),
              ),
            )
            .size,
        11,
      );
      final narrativeTileRect = tester.getRect(
        find.byKey(const ValueKey('narrativeMountedPhotoTile-0')),
      );
      final narrativeRemoveRect = tester.getRect(
        find.byKey(const ValueKey('narrativeMountedPhotoRemove-0')),
      );
      expect(narrativeRemoveRect.top, lessThan(narrativeTileRect.top));
      expect(narrativeRemoveRect.right, greaterThan(narrativeTileRect.right));

      await tester.tap(
        find.byKey(const ValueKey('narrativeMountedPhotoRemove-0')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('narrativeMountedPhotoSummary')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('narrativeMountedPhotoTile-1')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('narrativeSaveButton')));
      await tester.pumpAndSettle();

      expect(savedPhotos, <String>['/app/media/narrative/copied-photo-b.jpg']);
    },
  );

  testWidgets(
    'narrative element create page shows hint and does not mount photo when import fails',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-a',
                projectId: 'project-a',
                chapterTitle: '第一章：河岸的回声',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onPickPhoto: () async => <String>['/tmp/fake-photo.jpg'],
            onImportPhoto: (sourcePath) async {
              throw Exception('import failed');
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('照片导入失败，请重试'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets(
    'narrative element create page shows compact hint when no chapters exist',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NarrativeElementCreatePage(
            chapters: const <StructureChapter>[],
            onSave:
                ({
                  required String title,
                  required String description,
                  required String? chapterId,
                  required String status,
                  required String? unlockChapterId,
                  required List<String> photoPaths,
                }) async {},
            onPickPhoto: () async => <String>[],
          ),
        ),
      );

      expect(find.text('请先添加章节'), findsOneWidget);
      expect(find.text('暂 无 可 选 章 节'), findsNothing);
    },
  );

  testWidgets(
    'chapter draft element create page mounts multiple imported photos from one selection',
    (tester) async {
      NarrativeElementDraft? savedDraft;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      savedDraft = await Navigator.of(context)
                          .push<NarrativeElementDraft>(
                            MaterialPageRoute(
                              builder: (_) => ChapterNarrativeElementCreatePage(
                                onPickPhoto: () async => <String>[
                                  '/tmp/chapter-draft-a.jpg',
                                  '/tmp/chapter-draft-b.jpg',
                                ],
                                onImportPhoto: (sourcePath) async {
                                  if (sourcePath.endsWith('a.jpg')) {
                                    return '/app/media/narrative/chapter-a.jpg';
                                  }
                                  return '/app/media/narrative/chapter-b.jpg';
                                },
                              ),
                            ),
                          );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('chapterDraftElementNameField')),
        '章节元素',
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
      );
      await tester.tap(
        find.byKey(const ValueKey('chapterDraftElementSaveButton')),
      );
      await tester.pumpAndSettle();

      expect(savedDraft?.photoPaths, <String>[
        '/app/media/narrative/chapter-a.jpg',
        '/app/media/narrative/chapter-b.jpg',
      ]);
    },
  );

  testWidgets(
    'project edit page saves updated project data and keeps wizard back icon style',
    (tester) async {
      String? savedTitle;
      String? savedIntent;
      String? savedCoverImagePath;

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectEditPage(
            project: Project.create(
              id: 'project-edit-page',
              projectTitle: '赤水河沿岸寻访',
              projectThemeStatement: '旧的创作意图',
              projectCoverImagePath:
                  'https://picsum.photos/seed/echo-cover/800/533',
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            onSave: (title, themeStatement, coverImagePath) async {
              savedTitle = title;
              savedIntent = themeStatement;
              savedCoverImagePath = coverImagePath;
            },
            onPickCoverImage: () async => '/tmp/updated-cover.jpg',
          ),
        ),
      );

      final backIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(IconButton),
          matching: find.byIcon(Icons.arrow_back_ios_new),
        ),
      );
      expect(backIcon.size, 18);

      await tester.enterText(
        find.byKey(const ValueKey('projectEditNameField')),
        '新的项目名称',
      );
      await tester.enterText(
        find.byKey(const ValueKey('projectEditIntentField')),
        '新的创作意图',
      );
      await tester.ensureVisible(find.byIcon(Icons.edit_outlined));
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      expect(savedTitle, '新的项目名称');
      expect(savedIntent, '新的创作意图');
      expect(savedCoverImagePath, '/tmp/updated-cover.jpg');
    },
  );

  testWidgets('structure page chapter preview fits narrow mobile widths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 800)),
          child: StructurePagePrototype(
            currentTabIndex: 0,
            chapterCards: const <StructureChapterCardData>[],
            elementGroups: const <Map<String, dynamic>>[],
            relationCards: const <StructureRelationCardData>[],
            onOpenSidebar: _noop,
            onAddChapter: _noop,
            onAddElement: _noop,
            onAddRelation: _noop,
            onOpenRelation: _noopTab,
            onTabChanged: _noopTab,
            onBottomTabChanged: _noopPrototypeTab,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('添加章节'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            (widget.axisDirection == AxisDirection.left ||
                widget.axisDirection == AxisDirection.right),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('structure page relation tab shows mock relation cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StructurePagePrototype(
          currentTabIndex: 2,
          chapterCards: const <StructureChapterCardData>[],
          elementGroups: const <Map<String, dynamic>>[],
          relationCards: const <StructureRelationCardData>[
            StructureRelationCardData(
              relationTypeId: 'type-a',
              name: '对比',
              description: '跨章节的色彩冷暖或几何构图冲突，强调环境的异质性。',
              setCount: 4,
            ),
            StructureRelationCardData(
              relationTypeId: 'type-b',
              name: '重复',
              description: '特定视觉符号的规律性再现，构建叙事韵律。',
              setCount: 2,
            ),
            StructureRelationCardData(
              relationTypeId: 'type-c',
              name: '呼应',
              description: '不同地理位置间的情感共鸣，将碎片化的河岸串联为整体。',
              setCount: 7,
            ),
            StructureRelationCardData(
              relationTypeId: 'type-d',
              name: '转折',
              description: '叙事节奏在工业遗迹与纯粹自然间的突然切换。',
              setCount: 1,
            ),
          ],
          onOpenSidebar: _noop,
          onAddChapter: _noop,
          onAddElement: _noop,
          onAddRelation: _noop,
          onOpenRelation: _noopTab,
          onTabChanged: _noopTab,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('关联关系'), findsOneWidget);
    expect(find.text('对比'), findsOneWidget);
    expect(find.text('重复'), findsOneWidget);
    expect(find.text('呼应'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('转折'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('转折'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('添加关系类型'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('添加关系类型'), findsOneWidget);
  });

  testWidgets('standalone relation page can add a new relation type card', (
    tester,
  ) async {
    final projectRepository = _InMemoryProjectRepository(
      initialProjects: <Project>[
        Project.create(
          id: 'project-seeded',
          projectTitle: '赤水河沿岸寻访',
          projectThemeStatement: '测试项目',
          createdTimestamp: DateTime(2026, 1, 1),
          updatedTimestamp: DateTime(2026, 1, 1),
        ),
      ],
      currentProjectId: 'project-seeded',
    );
    final relationRepository = _InMemoryProjectRelationRepository();

    await tester.pumpWidget(
      EchoApp(
        projectRepository: projectRepository,
        structureChapterRepository: _InMemoryStructureChapterRepository(),
        narrativeElementRepository: _InMemoryNarrativeElementRepository(),
        projectRelationRepository: relationRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('关联关系'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('添加关联关系'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('添加关联关系'));
    await tester.pumpAndSettle();

    expect(find.text('添 加 关 系 类 型'), findsOneWidget);
    expect(find.text('赤水河沿岸寻访'), findsNothing);
    expect(find.text('章节骨架'), findsNothing);
    expect(find.text('叙事元素'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('relationTypeNameField')),
      '时空并置',
    );
    await tester.enterText(
      find.byKey(const ValueKey('relationTypeDescriptionField')),
      '同一空间在不同时间中的互文关系',
    );
    await tester.tap(find.byKey(const ValueKey('relationTypeSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('时空并置'), findsOneWidget);
  });

  testWidgets(
    'relation card opens relation group page and edit button opens relation type editor',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-edit',
            projectTitle: '关联关系编辑测试',
            projectThemeStatement: '验证关联关系编辑流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-edit',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-relation-a',
            projectId: 'project-relation-edit',
            chapterTitle: '第一章：河岸',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-relation-b',
            projectId: 'project-relation-edit',
            chapterTitle: '第二章：旧厂',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-river',
            projectId: 'project-relation-edit',
            chapterId: 'chapter-relation-a',
            elementTitle: '江边水塔',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-factory',
            projectId: 'project-relation-edit',
            chapterId: 'chapter-relation-b',
            elementTitle: '旧厂烟囱',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationType =
          (await relationRepository.listRelationTypesForProject(
            'project-relation-edit',
          )).firstWhere((type) => type.name == '对比');
      await relationRepository.createRelationGroup(
        projectId: 'project-relation-edit',
        relationTypeId: relationType.relationTypeId,
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.element(elementId: 'element-river'),
          ProjectRelationDraftMember.element(elementId: 'element-factory'),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('对比'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationGroupPageTitle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('relationGroupPageScopeLabel')),
        findsOneWidget,
      );
      expect(find.text('关系类型'), findsWidgets);
      expect(find.text('编辑关系类型'), findsOneWidget);
      expect(find.text('关系组'), findsNothing);
      expect(find.text('江边水塔 / 旧厂烟囱'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('addRelationGroupButton')),
        findsOneWidget,
      );

      await tester.tap(find.text('编辑关系类型'));
      await tester.pumpAndSettle();

      expect(find.text('编 辑 关 系 类 型'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('relationTypeNameField')),
        '新的对比',
      );
      await tester.enterText(
        find.byKey(const ValueKey('relationTypeDescriptionField')),
        '更新后的对比说明',
      );
      await tester.tap(find.byKey(const ValueKey('relationTypeSaveButton')));
      await tester.pumpAndSettle();

      expect(find.text('新的对比'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new).first);
      await tester.pumpAndSettle();

      expect(find.text('新的对比'), findsOneWidget);
      expect(find.text('更新后的对比说明'), findsOneWidget);
    },
  );

  testWidgets(
    'relation group page shows only add group button when no groups exist',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-preview',
            projectTitle: '关系预览测试',
            projectThemeStatement: '验证关联关系详情预览',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-preview',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-preview',
            projectId: 'project-relation-preview',
            chapterTitle: '第一章：样例章节',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-preview-a',
            projectId: 'project-relation-preview',
            chapterId: 'chapter-preview',
            elementTitle: '河岸石阶',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-preview-b',
            projectId: 'project-relation-preview',
            chapterId: 'chapter-preview',
            elementTitle: '旧船缆绳',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('呼应'));
      await tester.pumpAndSettle();

      expect(find.text('当前还没有关联组，请点击下方按钮创建。'), findsNothing);
      expect(find.text('形态的往复映照'), findsNothing);
      expect(find.text('从局部裂隙到整体张力'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('addRelationGroupButton')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('addRelationGroupButton')),
        findsOneWidget,
      );
      expect(find.text('添加关系组'), findsOneWidget);
    },
  );

  testWidgets(
    'relation group add entry stays on detail page and shows a clear blocker when candidates are insufficient',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-blocked-group',
            projectTitle: '关系组依赖拦截测试',
            projectThemeStatement: '验证关系组添加前置依赖提示',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-blocked-group',
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('呼应'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('addRelationGroupButton')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('addRelationGroupButton')));
      await tester.pump();

      expect(find.text('请先准备至少 2 个可关联对象（元素或照片）'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('relationGroupPageTitle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('relationGroupEditorTitle')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'relation group selection requires at least two chosen members before completion',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectRelationGroupSelectionPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-selection-limit',
                projectId: 'project-selection-limit',
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            narrativeElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-selection-limit',
                projectId: 'project-selection-limit',
                chapterId: 'chapter-selection-limit',
                elementTitle: '单个元素',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            relationTypeName: '呼应',
            relationGroupTitle: '单成员限制',
            initialSelectionKeys: const <String>{},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('完 成'), findsOneWidget);

      await tester.tap(find.text('单个元素'));
      await tester.pumpAndSettle();

      expect(find.text('至少 2 个'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('completeRelationGroupSelectionButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('单成员限制'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('relationGroupSelectionTitle')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'relation group selection element title stays single-line and truncates long text',
    (tester) async {
      const longTitle =
          'asdfasdfjkfdsafjdasfjafjjdsjalkfsajkfsalflajsfjsajlfjsalfjsadljfasljfsafja';

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectRelationGroupSelectionPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-selection-long-title',
                projectId: 'project-selection-long-title',
                chapterTitle: 'heihei',
                chapterSortOrder: 1,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            narrativeElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-selection-long-title',
                projectId: 'project-selection-long-title',
                chapterId: 'chapter-selection-long-title',
                elementTitle: longTitle,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            relationTypeName: '呼应',
            relationGroupTitle: '长标题限制',
            initialSelectionKeys: const <String>{},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(
        find.byKey(
          const ValueKey(
            'relationSelectionElementTitle-element-selection-long-title',
          ),
        ),
      );
      expect(titleText.maxLines, 1);
      expect(titleText.overflow, TextOverflow.ellipsis);
    },
  );

  testWidgets(
    'add relation group page creates a real relation group from detail page',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-create-group',
            projectTitle: '关系组创建测试',
            projectThemeStatement: '验证新增关联组流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-create-group',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-create-group-a',
            projectId: 'project-relation-create-group',
            chapterTitle: '第一章：样本 A',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-create-group-b',
            projectId: 'project-relation-create-group',
            chapterTitle: '第二章：样本 B',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-create-group-a',
            projectId: 'project-relation-create-group',
            chapterId: 'chapter-create-group-a',
            elementTitle: '河岸台阶',
            linkedPhotoPaths: <String>['/tmp/create-group-a.jpg'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-create-group-b',
            projectId: 'project-relation-create-group',
            chapterId: 'chapter-create-group-b',
            elementTitle: '风化岩面',
            linkedPhotoPaths: <String>['/tmp/create-group-b.jpg'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final relationRepository = _InMemoryProjectRelationRepository();

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('呼应'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('addRelationGroupButton')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('添加关系组'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('addRelationGroupButton')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationGroupEditorScopeLabel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('relationGroupTitleField')),
        findsOneWidget,
      );
      final editorTitleBeforeInput = tester.widget<Text>(
        find.byKey(const ValueKey('relationGroupEditorTitle')),
      );
      expect(editorTitleBeforeInput.data, '新关系组');
      expect(
        find.byKey(const ValueKey('relationGroupAddNodePlaceholder')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('relationGroupAddNodePlaceholder')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationGroupSelectionContextLabel')),
        findsOneWidget,
      );
      expect(find.text('选择关联内容 · 呼应'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('relationGroupSelectionTitle')),
        findsOneWidget,
      );
      expect(find.text('新关系组'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('completeRelationGroupSelectionButton')),
        findsOneWidget,
      );
      await tester.tap(find.text('河岸台阶'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('风化岩面'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('completeRelationGroupSelectionButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('河岸台阶'), findsOneWidget);
      expect(find.text('风化岩面'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('relationGroupTitleField')),
        '河岸风化的结构呼应',
      );
      await tester.pumpAndSettle();
      final editorTitleAfterInput = tester.widget<Text>(
        find.byKey(const ValueKey('relationGroupEditorTitle')),
      );
      expect(editorTitleAfterInput.data, '河岸风化的结构呼应');
      await tester.tap(
        find.byKey(const ValueKey('relationGroupAddNodePlaceholder')),
      );
      await tester.pumpAndSettle();
      expect(find.text('河岸风化的结构呼应'), findsWidgets);
      expect(find.text('选择关联内容 · 呼应'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new).first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('relationGroupDescriptionField')),
        '真实创建后应在详情页出现这一组关系。',
      );
      await tester.tap(
        find.byKey(const ValueKey('completeRelationGroupButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('河岸风化的结构呼应'), findsOneWidget);
      expect(find.text('真实创建后应在详情页出现这一组关系。'), findsOneWidget);
      expect(find.text('当前还没有关联组，请点击下方按钮创建。'), findsNothing);
      expect(
        find.byKey(const ValueKey('relationGroupElementTile-河岸台阶')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('relationGroupElementTile-风化岩面')),
        findsOneWidget,
      );

      final relationGroups = await relationRepository
          .listRelationGroupsForProject('project-relation-create-group');
      final createdGroup = relationGroups.singleWhere(
        (group) => group.title == '河岸风化的结构呼应',
      );
      final relationMembers = await relationRepository
          .listRelationMembersForProject('project-relation-create-group');

      expect(createdGroup.description, '真实创建后应在详情页出现这一组关系。');
      expect(
        relationMembers.where(
          (member) => member.owningGroupId == createdGroup.relationGroupId,
        ),
        hasLength(greaterThanOrEqualTo(2)),
      );
    },
  );

  testWidgets(
    'tapping a relation group card opens edit page and saves updates',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-group-edit',
            projectTitle: '关系组编辑测试',
            projectThemeStatement: '验证关系组编辑流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-group-edit',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-group-edit-a',
            projectId: 'project-relation-group-edit',
            chapterTitle: '第一章：江岸',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-group-edit-b',
            projectId: 'project-relation-group-edit',
            chapterTitle: '第二章：山坳',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-group-edit-a',
            projectId: 'project-relation-group-edit',
            chapterId: 'chapter-group-edit-a',
            elementTitle: '岸边石阶',
            linkedPhotoPaths: <String>['/tmp/group-edit-a.jpg'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-group-edit-b',
            projectId: 'project-relation-group-edit',
            chapterId: 'chapter-group-edit-b',
            elementTitle: '被风吹弯的草',
            linkedPhotoPaths: <String>['/tmp/group-edit-b.jpg'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationType =
          (await relationRepository.listRelationTypesForProject(
            'project-relation-group-edit',
          )).firstWhere((type) => type.name == '呼应');
      final createdGroup = await relationRepository.createRelationGroup(
        projectId: 'project-relation-group-edit',
        relationTypeId: relationType.relationTypeId,
        title: '原始关系组标题',
        description: '原始关系组说明',
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.element(elementId: 'element-group-edit-a'),
          ProjectRelationDraftMember.element(elementId: 'element-group-edit-b'),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('呼应'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('原始关系组标题'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationGroupTitleField')),
        findsOneWidget,
      );
      final editorTitle = tester.widget<Text>(
        find.byKey(const ValueKey('relationGroupEditorTitle')),
      );
      expect(editorTitle.data, '原始关系组标题');

      await tester.enterText(
        find.byKey(const ValueKey('relationGroupTitleField')),
        '更新后的关系组标题',
      );
      await tester.enterText(
        find.byKey(const ValueKey('relationGroupDescriptionField')),
        '更新后的关系组说明',
      );
      await tester.tap(
        find.byKey(const ValueKey('completeRelationGroupButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('更新后的关系组标题'), findsOneWidget);
      expect(find.text('更新后的关系组说明'), findsOneWidget);

      final relationGroups = await relationRepository
          .listRelationGroupsForProject('project-relation-group-edit');
      final updatedGroup = relationGroups.singleWhere(
        (group) => group.relationGroupId == createdGroup.relationGroupId,
      );
      expect(updatedGroup.title, '更新后的关系组标题');
      expect(updatedGroup.description, '更新后的关系组说明');
    },
  );

  testWidgets(
    'relation group edit page supports removing a node locally and adding another through selection',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-group-local-edit',
            projectTitle: '关系组局部编辑测试',
            projectThemeStatement: '验证关系组编辑页局部增删',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-group-local-edit',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-local-a',
            projectId: 'project-relation-group-local-edit',
            chapterTitle: '第一章：江岸',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-local-b',
            projectId: 'project-relation-group-local-edit',
            chapterTitle: '第二章：山坳',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-local-a',
            projectId: 'project-relation-group-local-edit',
            chapterId: 'chapter-local-a',
            elementTitle: '岸边石阶',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-local-b',
            projectId: 'project-relation-group-local-edit',
            chapterId: 'chapter-local-b',
            elementTitle: '被风吹弯的草',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-local-c',
            projectId: 'project-relation-group-local-edit',
            chapterId: 'chapter-local-b',
            elementTitle: '山坳石纹',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationType =
          (await relationRepository.listRelationTypesForProject(
            'project-relation-group-local-edit',
          )).firstWhere((type) => type.name == '呼应');
      final createdGroup = await relationRepository.createRelationGroup(
        projectId: 'project-relation-group-local-edit',
        relationTypeId: relationType.relationTypeId,
        title: '局部编辑关系组',
        description: '先删再补。',
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.element(elementId: 'element-local-a'),
          ProjectRelationDraftMember.element(elementId: 'element-local-b'),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('呼应'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('局部编辑关系组'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Icon>(
              find.descendant(
                of: find.byKey(
                  const ValueKey(
                    'relationGroupRemoveNode-element:element-local-b',
                  ),
                ),
                matching: find.byIcon(Icons.close),
              ),
            )
            .size,
        11,
      );

      await tester.tap(
        find.byKey(
          const ValueKey('relationGroupRemoveNode-element:element-local-b'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('被风吹弯的草'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('relationGroupAddNodePlaceholder')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('山坳石纹'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('completeRelationGroupSelectionButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('山坳石纹'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('completeRelationGroupButton')),
      );
      await tester.pumpAndSettle();

      final relationMembers = await relationRepository
          .listRelationMembersForProject('project-relation-group-local-edit');
      final updatedMembers =
          relationMembers
              .where(
                (member) =>
                    member.owningGroupId == createdGroup.relationGroupId,
              )
              .toList()
            ..sort(
              (left, right) =>
                  left.memberSortOrder.compareTo(right.memberSortOrder),
            );

      expect(updatedMembers, hasLength(2));
      expect(updatedMembers.map((member) => member.linkedElementId), <String?>[
        'element-local-a',
        'element-local-c',
      ]);
    },
  );

  testWidgets(
    'delete confirmation: relation group edit page deletes relation group and refreshes detail page',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-group-delete',
            projectTitle: '关系组删除测试',
            projectThemeStatement: '验证关系组删除闭环',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-group-delete',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-group-delete-a',
            projectId: 'project-relation-group-delete',
            chapterTitle: '第一章：江岸',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-group-delete-b',
            projectId: 'project-relation-group-delete',
            chapterTitle: '第二章：山体',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-group-delete-a',
            projectId: 'project-relation-group-delete',
            chapterId: 'chapter-group-delete-a',
            elementTitle: '沿岸石壁',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-group-delete-b',
            projectId: 'project-relation-group-delete',
            chapterId: 'chapter-group-delete-b',
            elementTitle: '风化裂缝',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationType =
          (await relationRepository.listRelationTypesForProject(
            'project-relation-group-delete',
          )).firstWhere((type) => type.name == '呼应');
      final relationGroup = await relationRepository.createRelationGroup(
        projectId: 'project-relation-group-delete',
        relationTypeId: relationType.relationTypeId,
        title: '待删除关系组',
        description: '删除后详情页应立即刷新。',
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.element(
            elementId: 'element-group-delete-a',
          ),
          ProjectRelationDraftMember.element(
            elementId: 'element-group-delete-b',
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('呼应'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('待删除关系组'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationGroupDeleteButton')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('relationGroupDeleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确 认 删 除'), findsOneWidget);
      expect(
        find.text('删除后，仅当前关系组及其成员会移除；关系类型、元素与照片会保留，当前页面将返回详情。'),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删 除')),
      );
      await tester.pumpAndSettle();

      final relationGroups = await relationRepository
          .listRelationGroupsForProject('project-relation-group-delete');
      final relationMembers = await relationRepository
          .listRelationMembersForProject('project-relation-group-delete');

      expect(
        relationGroups.where(
          (group) => group.relationGroupId == relationGroup.relationGroupId,
        ),
        isEmpty,
      );
      expect(
        relationMembers.where(
          (member) => member.owningGroupId == relationGroup.relationGroupId,
        ),
        isEmpty,
      );
      expect(
        find.byKey(const ValueKey('relationGroupPageTitle')),
        findsOneWidget,
      );
      expect(find.text('待删除关系组'), findsNothing);
      expect(
        find.byKey(const ValueKey('addRelationGroupButton')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'unsaved changes: chapter edit page pops immediately when there are no unsaved changes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: const ValueKey('openChapterEditorButton'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChapterEditPage(
                            existingChapters: <StructureChapter>[
                              StructureChapter.create(
                                id: 'chapter-unsaved-clean',
                                projectId: 'project-unsaved-clean',
                                chapterTitle: '无改动章节',
                                chapterSortOrder: 0,
                                createdTimestamp: DateTime(2026),
                                updatedTimestamp: DateTime(2026),
                              ),
                            ],
                            chapter: StructureChapter.create(
                              id: 'chapter-unsaved-clean',
                              projectId: 'project-unsaved-clean',
                              chapterTitle: '无改动章节',
                              chapterSortOrder: 0,
                              createdTimestamp: DateTime(2026),
                              updatedTimestamp: DateTime(2026),
                            ),
                            existingElements: const <NarrativeElement>[],
                            onSave:
                                ({
                                  required title,
                                  required description,
                                  required sortOrder,
                                  required statusLabel,
                                  required elements,
                                }) async {},
                            onComplete:
                                ({
                                  required title,
                                  required description,
                                  required sortOrder,
                                  required statusLabel,
                                  required elements,
                                }) async {},
                            onDelete: () async {},
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('openChapterEditorButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('openChapterEditorButton')),
        findsOneWidget,
      );
      expect(find.text('放 弃 更 改'), findsNothing);
    },
  );

  testWidgets(
    'unsaved changes: chapter edit page confirms before leaving when there are unsaved changes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: const ValueKey('openChapterUnsavedEditorButton'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChapterEditPage(
                            existingChapters: <StructureChapter>[
                              StructureChapter.create(
                                id: 'chapter-unsaved-dirty',
                                projectId: 'project-unsaved-dirty',
                                chapterTitle: '原始章节',
                                chapterSortOrder: 0,
                                createdTimestamp: DateTime(2026),
                                updatedTimestamp: DateTime(2026),
                              ),
                            ],
                            chapter: StructureChapter.create(
                              id: 'chapter-unsaved-dirty',
                              projectId: 'project-unsaved-dirty',
                              chapterTitle: '原始章节',
                              chapterSortOrder: 0,
                              createdTimestamp: DateTime(2026),
                              updatedTimestamp: DateTime(2026),
                            ),
                            existingElements: const <NarrativeElement>[],
                            onSave:
                                ({
                                  required title,
                                  required description,
                                  required sortOrder,
                                  required statusLabel,
                                  required elements,
                                }) async {},
                            onComplete:
                                ({
                                  required title,
                                  required description,
                                  required sortOrder,
                                  required statusLabel,
                                  required elements,
                                }) async {},
                            onDelete: () async {},
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('openChapterUnsavedEditorButton')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateTitleField')),
        '已修改章节',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('放 弃 更 改'), findsOneWidget);
      expect(find.text('当前页面仍有未保存改动，返回后这些更改将丢失。'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('放 弃')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('openChapterUnsavedEditorButton')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'unsaved changes: narrative edit page confirms before leaving when there are unsaved changes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: const ValueKey('openNarrativeUnsavedEditorButton'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => NarrativeElementEditPage(
                            chapters: <StructureChapter>[
                              StructureChapter.create(
                                id: 'chapter-narrative-unsaved',
                                projectId: 'project-narrative-unsaved',
                                chapterTitle: '第一章',
                                chapterSortOrder: 0,
                                createdTimestamp: DateTime(2026),
                                updatedTimestamp: DateTime(2026),
                              ),
                            ],
                            element: NarrativeElement.create(
                              id: 'element-narrative-unsaved',
                              projectId: 'project-narrative-unsaved',
                              chapterId: 'chapter-narrative-unsaved',
                              elementTitle: '原始元素',
                              linkedPhotoPaths: <String>['/tmp/original.jpg'],
                              createdTimestamp: DateTime(2026),
                              updatedTimestamp: DateTime(2026),
                            ),
                            onSave:
                                ({
                                  required title,
                                  required description,
                                  required chapterId,
                                  required status,
                                  required unlockChapterId,
                                  required photoPaths,
                                }) async {},
                            onComplete:
                                ({
                                  required title,
                                  required description,
                                  required chapterId,
                                  required status,
                                  required unlockChapterId,
                                  required photoPaths,
                                }) async {},
                            onDelete: () async {},
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('openNarrativeUnsavedEditorButton')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '已修改元素',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('放 弃 更 改'), findsOneWidget);
      expect(find.text('当前页面仍有未保存改动，返回后这些更改将丢失。'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('放 弃')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('openNarrativeUnsavedEditorButton')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'unsaved changes: relation group edit page confirms before leaving when there are unsaved changes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: const ValueKey('openRelationGroupUnsavedEditorButton'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProjectRelationGroupCreatePage(
                            relationType: ProjectRelationType.create(
                              id: 'relation-type-unsaved',
                              projectId: 'project-relation-unsaved',
                              relationName: '呼应',
                              relationDescription: '测试关系',
                              relationSortOrder: 0,
                              createdTimestamp: DateTime(2026),
                              updatedTimestamp: DateTime(2026),
                            ),
                            narrativeElements: <NarrativeElement>[
                              NarrativeElement.create(
                                id: 'element-relation-unsaved-a',
                                projectId: 'project-relation-unsaved',
                                chapterId: 'chapter-relation-unsaved',
                                elementTitle: '元素 A',
                                createdTimestamp: DateTime(2026),
                                updatedTimestamp: DateTime(2026),
                              ),
                              NarrativeElement.create(
                                id: 'element-relation-unsaved-b',
                                projectId: 'project-relation-unsaved',
                                chapterId: 'chapter-relation-unsaved',
                                elementTitle: '元素 B',
                                createdTimestamp: DateTime(2026),
                                updatedTimestamp: DateTime(2026),
                              ),
                            ],
                            chapters: <StructureChapter>[
                              StructureChapter.create(
                                id: 'chapter-relation-unsaved',
                                projectId: 'project-relation-unsaved',
                                chapterTitle: '第一章',
                                chapterSortOrder: 0,
                                createdTimestamp: DateTime(2026),
                                updatedTimestamp: DateTime(2026),
                              ),
                            ],
                            initialTitle: '原始关系组',
                            initialDescription: '原始说明',
                            initialMembers: const <ProjectRelationDraftMember>[
                              ProjectRelationDraftMember.element(
                                elementId: 'element-relation-unsaved-a',
                              ),
                              ProjectRelationDraftMember.element(
                                elementId: 'element-relation-unsaved-b',
                              ),
                            ],
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
                                }) async {},
                            onDeleteRelationGroup: () async {},
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('openRelationGroupUnsavedEditorButton')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('relationGroupTitleField')),
        '已修改关系组',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('放 弃 更 改'), findsOneWidget);
      expect(find.text('当前页面仍有未保存改动，返回后这些更改将丢失。'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('放 弃')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('openRelationGroupUnsavedEditorButton')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'unsaved changes: relation type edit page confirms before leaving when there are unsaved changes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: const ValueKey('openRelationTypeUnsavedEditorButton'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProjectRelationCreatePage.edit(
                            relationType: ProjectRelationType.create(
                              id: 'relation-type-editor-unsaved',
                              projectId: 'project-relation-type-unsaved',
                              relationName: '原始关系',
                              relationDescription: '原始描述',
                              relationSortOrder: 0,
                              createdTimestamp: DateTime(2026),
                              updatedTimestamp: DateTime(2026),
                            ),
                            onUpdateRelationType:
                                ({required name, required description}) async {
                                  return ProjectRelationType.create(
                                    id: 'relation-type-editor-unsaved',
                                    projectId: 'project-relation-type-unsaved',
                                    relationName: name,
                                    relationDescription: description,
                                    relationSortOrder: 0,
                                    createdTimestamp: DateTime(2026),
                                    updatedTimestamp: DateTime(2026),
                                  );
                                },
                            onDeleteRelationType: () async {},
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('openRelationTypeUnsavedEditorButton')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('relationTypeNameField')),
        '已修改关系类型',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('放 弃 更 改'), findsOneWidget);
      expect(find.text('当前页面仍有未保存改动，返回后这些更改将丢失。'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('放 弃')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('openRelationTypeUnsavedEditorButton')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'relation group photo thumbnail opens full screen viewer and supports horizontal paging',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-fullscreen',
            projectTitle: '关系全屏查看测试',
            projectThemeStatement: '验证关系组照片全屏查看',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-fullscreen',
      );
      final chapterRepository = _InMemoryStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-fullscreen-a',
            projectId: 'project-relation-fullscreen',
            chapterTitle: '第一章：河岸线',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-fullscreen-b',
            projectId: 'project-relation-fullscreen',
            chapterTitle: '第二章：风化带',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final narrativeElementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-fullscreen-a',
            projectId: 'project-relation-fullscreen',
            chapterId: 'chapter-fullscreen-a',
            elementTitle: '沿岸石壁',
            linkedPhotoPaths: <String>['/tmp/relation-fullscreen-a.jpg'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-fullscreen-b',
            projectId: 'project-relation-fullscreen',
            chapterId: 'chapter-fullscreen-b',
            elementTitle: '风化裂缝',
            linkedPhotoPaths: <String>['/tmp/relation-fullscreen-b.jpg'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationType =
          (await relationRepository.listRelationTypesForProject(
            'project-relation-fullscreen',
          )).firstWhere((type) => type.name == '呼应');
      await relationRepository.createRelationGroup(
        projectId: 'project-relation-fullscreen',
        relationTypeId: relationType.relationTypeId,
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.photo(
            photoPath: '/tmp/relation-fullscreen-a.jpg',
            sourceElementId: 'element-fullscreen-a',
          ),
          ProjectRelationDraftMember.photo(
            photoPath: '/tmp/relation-fullscreen-b.jpg',
            sourceElementId: 'element-fullscreen-b',
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: chapterRepository,
          narrativeElementRepository: narrativeElementRepository,
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('呼应'));
      await tester.pumpAndSettle();

      expect(find.text('CH 01'), findsNothing);
      expect(find.text('CH 02'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('relationGroupThumbnail-group-1-0')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationFullscreenPageView')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('relationFullscreenTypeLabel')),
        findsOneWidget,
      );
      final typeLabel = tester.widget<Text>(
        find.byKey(const ValueKey('relationFullscreenTypeLabel')),
      );
      expect(typeLabel.data, '呼应');
      expect(
        find.byKey(const ValueKey('relationFullscreenNodeTitle')),
        findsOneWidget,
      );
      expect(find.text('沿岸石壁'), findsOneWidget);
      expect(find.text('CH.01'), findsOneWidget);
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('relationFullscreenCounter')),
            )
            .data,
        '1 / 2',
      );

      await tester.fling(
        find.byKey(const ValueKey('relationFullscreenPageView')),
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('风化裂缝'), findsOneWidget);
      expect(find.text('CH.02'), findsOneWidget);
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('relationFullscreenCounter')),
            )
            .data,
        '2 / 2',
      );

      await tester.tap(
        find.byKey(const ValueKey('relationFullscreenCloseButton')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationGroupPageTitle')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'delete confirmation: relation edit page shows delete action and removes relation type with linked groups',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-relation-delete',
            projectTitle: '关系删除测试',
            projectThemeStatement: '验证关系删除流程',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-relation-delete',
      );
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationType =
          (await relationRepository.listRelationTypesForProject(
            'project-relation-delete',
          )).firstWhere((type) => type.name == '对比');
      await relationRepository.createRelationGroup(
        projectId: 'project-relation-delete',
        relationTypeId: relationType.relationTypeId,
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.element(elementId: 'element-a'),
          ProjectRelationDraftMember.element(elementId: 'element-b'),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('对比'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('编辑关系类型'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationTypeDeleteButton')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('relationTypeDeleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确 认 删 除'), findsOneWidget);
      expect(
        find.text('删除后，仅当前关系类型及其下属关联组会移除；元素、照片与章节内容会保留，当前页面将返回列表。'),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删 除')),
      );
      await tester.pumpAndSettle();

      final relationTypes = await relationRepository
          .listRelationTypesForProject('project-relation-delete');
      final relationGroups = await relationRepository
          .listRelationGroupsForProject('project-relation-delete');

      expect(
        relationTypes.where(
          (type) => type.relationTypeId == relationType.relationTypeId,
        ),
        isEmpty,
      );
      expect(relationGroups, isEmpty);
      expect(find.text('对比'), findsNothing);
    },
  );

  testWidgets(
    'deleting the last visible relation type keeps the relation list empty after refresh',
    (tester) async {
      final projectRepository = _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-last-relation-delete',
            projectTitle: '最后关系删除测试',
            projectThemeStatement: '验证最后一个关系类型删除后不会回填默认值',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-last-relation-delete',
      );
      final relationRepository = _InMemoryProjectRelationRepository();
      final allRelationTypes = await relationRepository
          .listRelationTypesForProject('project-last-relation-delete');
      final targetRelationType = allRelationTypes.firstWhere(
        (type) => type.name == '对比',
      );
      for (final relationType in allRelationTypes) {
        if (relationType.relationTypeId == targetRelationType.relationTypeId) {
          continue;
        }
        await relationRepository.deleteRelationType(
          relationType.relationTypeId,
        );
      }

      await tester.pumpWidget(
        EchoApp(
          projectRepository: projectRepository,
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('对比'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('编辑关系类型'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('relationTypeDeleteButton')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删 除')),
      );
      await tester.pumpAndSettle();

      final visibleRelationTypes = await relationRepository
          .listRelationTypesForProject('project-last-relation-delete');

      expect(visibleRelationTypes, isEmpty);
      expect(find.text('对比'), findsNothing);
      expect(find.text('添加关系类型'), findsOneWidget);
    },
  );

  testWidgets(
    'curation tab opens real pending organize page with independent nav and pending-only photos',
    (tester) async {
      const projectId = 'project-curation';
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationTypes = await relationRepository
          .listRelationTypesForProject(projectId);
      final echoType = relationTypes.firstWhere((type) => type.name == '呼应');
      await relationRepository.createRelationGroup(
        projectId: projectId,
        relationTypeId: echoType.relationTypeId,
        title: '呼应组',
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.photo(
            photoPath: '/tmp/pending-a.jpg',
            sourceElementId: 'element-pending-a',
          ),
          ProjectRelationDraftMember.element(elementId: 'element-chapter-1'),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '江岸计划',
                projectThemeStatement: '用于整理页接线验证',
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-1',
                projectId: projectId,
                chapterTitle: '第一章',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
          ),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(
            initialElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-pending-a',
                projectId: projectId,
                elementTitle: '待整理 A',
                linkedPhotoPaths: <String>['/tmp/pending-a.jpg'],
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
              NarrativeElement.create(
                id: 'element-pending-b',
                projectId: projectId,
                elementTitle: '待整理 B',
                linkedPhotoPaths: <String>['/tmp/pending-b.jpg'],
                createdTimestamp: DateTime(2026, 1, 2),
                updatedTimestamp: DateTime(2026, 1, 2),
              ),
              NarrativeElement.create(
                id: 'element-chapter-1',
                projectId: projectId,
                chapterId: 'chapter-1',
                elementTitle: '章节元素',
                linkedPhotoPaths: <String>['/tmp/chapter-photo.jpg'],
                createdTimestamp: DateTime(2026, 1, 3),
                updatedTimestamp: DateTime(2026, 1, 3),
              ),
            ],
          ),
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangePendingButton')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('globalArrangeGenerateSamplesButton')),
        findsNothing,
      );
      expect(find.textContaining('CH 01 / 第一章'), findsOneWidget);
      expect(find.text('章节元素'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('globalArrangePendingButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PendingOrganizePage), findsOneWidget);
      expect(find.byType(CustomBottomNavBar), findsNothing);
      expect(find.text('待整理'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('pendingOrganizeSaveButton')),
            )
            .onPressed,
        isNull,
      );
      expect(find.byIcon(Icons.search), findsNothing);
      expect(
        find.byKey(const ValueKey('pendingOrganizePhotoCounter')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(
                const ValueKey('pendingOrganizePhotoCounter'),
                skipOffstage: false,
              ),
            )
            .data,
        '1 / 2',
      );
    },
  );

  testWidgets(
    'pending organize page changes chapter element relation state with current photo',
    (tester) async {
      const projectId = 'project-pending-switch';
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationTypes = await relationRepository
          .listRelationTypesForProject(projectId);
      final echoType = relationTypes.firstWhere((type) => type.name == '呼应');
      await relationRepository.createRelationGroup(
        projectId: projectId,
        relationTypeId: echoType.relationTypeId,
        title: '呼应组',
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.photo(
            photoPath: '/tmp/pending-a.jpg',
            sourceElementId: 'element-pending-a',
          ),
          ProjectRelationDraftMember.element(elementId: 'element-chapter-1'),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '待整理联动',
                projectThemeStatement: '验证按照片切换',
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-1',
                projectId: projectId,
                chapterTitle: '第一章',
                chapterSortOrder: 0,
              ),
            ],
          ),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(
            initialElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-pending-a',
                projectId: projectId,
                elementTitle: '待整理 A',
                linkedPhotoPaths: <String>['/tmp/pending-a.jpg'],
              ),
              NarrativeElement.create(
                id: 'element-pending-b',
                projectId: projectId,
                elementTitle: '待整理 B',
                linkedPhotoPaths: <String>['/tmp/pending-b.jpg'],
              ),
              NarrativeElement.create(
                id: 'element-chapter-1',
                projectId: projectId,
                chapterId: 'chapter-1',
                elementTitle: '章节元素',
                linkedPhotoPaths: <String>['/tmp/chapter-photo.jpg'],
              ),
            ],
          ),
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('globalArrangePendingButton')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          ValueKey('pendingRelationTypeCount-${echoType.relationTypeId}'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(
                ValueKey('pendingRelationTypeCount-${echoType.relationTypeId}'),
                skipOffstage: false,
              ),
            )
            .data,
        anyOf('已选 1 组', '可选 1 组'),
      );

      await tester.dragFrom(const Offset(400, 180), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Text>(
              find.byKey(
                const ValueKey('pendingOrganizePhotoCounter'),
                skipOffstage: false,
              ),
            )
            .data,
        '2 / 2',
      );
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('pendingOrganizeSaveButton')),
            )
            .onPressed,
        isNull,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('pendingChapterCard-chapter-1')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('pendingOrganizeSaveButton')),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('pendingOrganizeSaveButton')),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets(
    'pending organize relation selection saves photo into chapter element and removes it from pending list',
    (tester) async {
      const projectId = 'project-pending-save';
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationTypes = await relationRepository
          .listRelationTypesForProject(projectId);
      final echoType = relationTypes.firstWhere((type) => type.name == '呼应');
      await relationRepository.createRelationGroup(
        projectId: projectId,
        relationTypeId: echoType.relationTypeId,
        title: '原始呼应组',
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.photo(
            photoPath: '/tmp/pending-a.jpg',
            sourceElementId: 'element-pending-a',
          ),
          ProjectRelationDraftMember.element(elementId: 'element-chapter-1'),
        ],
      );
      final extraGroup = await relationRepository.createRelationGroup(
        projectId: projectId,
        relationTypeId: echoType.relationTypeId,
        title: '补充呼应组',
        members: const <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.element(elementId: 'element-pending-b'),
          ProjectRelationDraftMember.element(elementId: 'element-chapter-1'),
        ],
      );

      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-pending-a',
            projectId: projectId,
            elementTitle: '待整理 A',
            linkedPhotoPaths: <String>['/tmp/pending-a.jpg'],
          ),
          NarrativeElement.create(
            id: 'element-pending-b',
            projectId: projectId,
            elementTitle: '待整理 B',
            linkedPhotoPaths: <String>['/tmp/pending-b.jpg'],
          ),
          NarrativeElement.create(
            id: 'element-chapter-1',
            projectId: projectId,
            chapterId: 'chapter-1',
            elementTitle: '章节元素',
            linkedPhotoPaths: <String>['/tmp/chapter-photo.jpg'],
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '待整理保存',
                projectThemeStatement: '验证真实保存',
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-1',
                projectId: projectId,
                chapterTitle: '第一章',
                chapterSortOrder: 0,
              ),
            ],
          ),
          narrativeElementRepository: elementRepository,
          projectRelationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('globalArrangePendingButton')),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(
          ValueKey('pendingRelationTypeCard-${echoType.relationTypeId}'),
        ),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          ValueKey('pendingRelationTypeCard-${echoType.relationTypeId}'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(echoType.name), findsOneWidget);
      expect(
        find.byKey(const ValueKey('pendingRelationSelectionCompleteButton')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          ValueKey('pendingRelationGroupCard-${extraGroup.relationGroupId}'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingRelationSelectionCompleteButton')),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Text>(
              find.byKey(
                ValueKey('pendingRelationTypeCount-${echoType.relationTypeId}'),
                skipOffstage: false,
              ),
            )
            .data,
        anyOf('已选 1 组', '已选 2 组'),
      );
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('pendingOrganizeSaveButton')),
            )
            .onPressed,
        isNotNull,
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('pendingOrganizePhotoCounter')),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('pendingChapterCard-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pendingOrganizeSaveButton')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Text>(
              find.byKey(
                const ValueKey('pendingOrganizePhotoCounter'),
                skipOffstage: false,
              ),
            )
            .data,
        '1 / 1',
      );

      final updatedElements = await elementRepository.listElementsForProject(
        projectId,
      );
      final pendingSource = updatedElements.firstWhere(
        (element) => element.elementId == 'element-pending-a',
      );
      final chapterElement = updatedElements.firstWhere(
        (element) => element.elementId == 'element-chapter-1',
      );
      final remainingPendingPhotos = <String>[
        ...pendingSource.photoPaths,
        ...updatedElements
            .firstWhere((element) => element.elementId == 'element-pending-b')
            .photoPaths,
      ];
      expect(remainingPendingPhotos.length, 1);
      expect(chapterElement.photoPaths.length, 2);
      expect(
        chapterElement.photoPaths.contains('/tmp/pending-a.jpg') ||
            chapterElement.photoPaths.contains('/tmp/pending-b.jpg'),
        isTrue,
      );

      final updatedMembers = await relationRepository
          .listRelationMembersForProject(projectId);
      expect(
        updatedMembers.where(
          (member) =>
              member.owningGroupId == extraGroup.relationGroupId &&
              member.linkedSourceElementId == 'element-chapter-1' &&
              (member.linkedPhotoPath == '/tmp/pending-a.jpg' ||
                  member.linkedPhotoPath == '/tmp/pending-b.jpg'),
        ),
        isNotEmpty,
      );
    },
  );

  testWidgets(
    'pending organize back dialog close keeps page and discard exits without saving',
    (tester) async {
      const projectId = 'project-pending-discard';
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-pending-a',
            projectId: projectId,
            elementTitle: '待整理 A',
            linkedPhotoPaths: <String>['/tmp/pending-a.jpg'],
          ),
          NarrativeElement.create(
            id: 'element-chapter-1',
            projectId: projectId,
            chapterId: 'chapter-1',
            elementTitle: '章节元素',
            linkedPhotoPaths: <String>['/tmp/chapter-photo.jpg'],
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '待整理返回确认',
                projectThemeStatement: '验证关闭与放弃',
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-1',
                projectId: projectId,
                chapterTitle: '第一章',
                chapterSortOrder: 0,
              ),
            ],
          ),
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('globalArrangePendingButton')),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingChapterCard-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('pendingUnsavedDialogTitle')),
        findsOneWidget,
      );
      expect(find.text('全部保存'), findsOneWidget);
      expect(find.text('仍然返回'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('pendingUnsavedDialogCloseButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PendingOrganizePage), findsOneWidget);
      expect(
        find.byKey(const ValueKey('pendingUnsavedDialogTitle')),
        findsNothing,
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingUnsavedDialogDiscardButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PendingOrganizePage), findsNothing);

      final updatedElements = await elementRepository.listElementsForProject(
        projectId,
      );
      final pendingSource = updatedElements.firstWhere(
        (element) => element.elementId == 'element-pending-a',
      );
      final chapterElement = updatedElements.firstWhere(
        (element) => element.elementId == 'element-chapter-1',
      );
      expect(pendingSource.photoPaths, contains('/tmp/pending-a.jpg'));
      expect(chapterElement.photoPaths, isNot(contains('/tmp/pending-a.jpg')));
    },
  );

  testWidgets(
    'pending organize back dialog save all persists dirty photos before leaving',
    (tester) async {
      const projectId = 'project-pending-save-all';
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-pending-a',
            projectId: projectId,
            elementTitle: '待整理 A',
            linkedPhotoPaths: <String>['/tmp/pending-a.jpg'],
          ),
          NarrativeElement.create(
            id: 'element-chapter-1',
            projectId: projectId,
            chapterId: 'chapter-1',
            elementTitle: '章节元素',
            linkedPhotoPaths: <String>['/tmp/chapter-photo.jpg'],
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '待整理全部保存',
                projectThemeStatement: '验证返回时全部保存',
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-1',
                projectId: projectId,
                chapterTitle: '第一章',
                chapterSortOrder: 0,
              ),
            ],
          ),
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('globalArrangePendingButton')),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingChapterCard-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingUnsavedDialogSaveAllButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PendingOrganizePage), findsNothing);

      final updatedElements = await elementRepository.listElementsForProject(
        projectId,
      );
      final pendingSource = updatedElements.firstWhere(
        (element) => element.elementId == 'element-pending-a',
      );
      final chapterElement = updatedElements.firstWhere(
        (element) => element.elementId == 'element-chapter-1',
      );
      expect(pendingSource.photoPaths, isEmpty);
      expect(chapterElement.photoPaths, contains('/tmp/pending-a.jpg'));
    },
  );

  testWidgets(
    'pending organize save all skips dirty photos without target element and still exits',
    (tester) async {
      const projectId = 'project-pending-save-all-skip-invalid';
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-pending-a',
            projectId: projectId,
            elementTitle: '待整理 A',
            linkedPhotoPaths: <String>['/tmp/pending-a.jpg'],
          ),
          NarrativeElement.create(
            id: 'element-pending-b',
            projectId: projectId,
            elementTitle: '待整理 B',
            linkedPhotoPaths: <String>['/tmp/pending-b.jpg'],
          ),
          NarrativeElement.create(
            id: 'element-chapter-1',
            projectId: projectId,
            chapterId: 'chapter-1',
            elementTitle: '章节元素',
            linkedPhotoPaths: <String>['/tmp/chapter-photo.jpg'],
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '待整理全部保存跳过不可保存',
                projectThemeStatement: '验证全部保存只保存可保存项',
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-1',
                projectId: projectId,
                chapterTitle: '第一章',
                chapterSortOrder: 0,
              ),
            ],
          ),
          narrativeElementRepository: elementRepository,
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('globalArrangePendingButton')),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingChapterCard-chapter-1')),
      );
      await tester.pumpAndSettle();

      await tester.dragFrom(const Offset(400, 180), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingChapterCard-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingElementCard-element-chapter-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('pendingUnsavedDialogSaveAllButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PendingOrganizePage), findsNothing);

      final updatedElements = await elementRepository.listElementsForProject(
        projectId,
      );
      final pendingA = updatedElements.firstWhere(
        (element) => element.elementId == 'element-pending-a',
      );
      final pendingB = updatedElements.firstWhere(
        (element) => element.elementId == 'element-pending-b',
      );
      final chapterElement = updatedElements.firstWhere(
        (element) => element.elementId == 'element-chapter-1',
      );

      final remainingPendingPhotos = <String>[
        ...pendingA.photoPaths,
        ...pendingB.photoPaths,
      ];
      expect(remainingPendingPhotos.length, 1);
      expect(
        remainingPendingPhotos.single == '/tmp/pending-a.jpg' ||
            remainingPendingPhotos.single == '/tmp/pending-b.jpg',
        isTrue,
      );
      expect(chapterElement.photoPaths.length, 2);
      expect(
        chapterElement.photoPaths.contains('/tmp/pending-a.jpg') ||
            chapterElement.photoPaths.contains('/tmp/pending-b.jpg'),
        isTrue,
      );
    },
  );

  testWidgets(
    'curation tab keeps a newly created project empty instead of offering mock content',
    (tester) async {
      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-empty-curation',
                projectTitle: '空白项目',
                projectThemeStatement: '验证整理页新状态',
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
            ],
            currentProjectId: 'project-empty-curation',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('整理'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('globalArrangePendingButton')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('globalArrangeGenerateSamplesButton')),
        findsNothing,
      );
      expect(find.textContaining('拖拽示例｜'), findsNothing);
      expect(find.text('生成示例内容'), findsNothing);
    },
  );

  testWidgets(
    'global arrange photo safe area does not open fullscreen but image area does',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GlobalArrangePage(
            projectTitle: '测试项目',
            boardData: const GlobalArrangeBoardData(
              chapters: <GlobalArrangeChapterData>[
                GlobalArrangeChapterData(
                  chapterId: 'chapter-1',
                  title: '第一章',
                  elements: <GlobalArrangeElementData>[
                    GlobalArrangeElementData(
                      elementId: 'element-1',
                      title: '测试元素',
                      relationTags: <String>['呼应'],
                      photos: <GlobalArrangePhotoData>[
                        GlobalArrangePhotoData(
                          photoId: 'photo-1',
                          imageSource: '/tmp/test-photo.jpg',
                          relationTags: <String>['呼应'],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            onOpenSidebar: _noop,
            onBottomTabChanged: _noopPrototypeTab,
            onOpenPendingOrganize: _noopAsync,
            onMoveChapter: _noopMoveChapter,
            onMoveElement: _noopMoveElement,
            onMovePhoto: _noopMovePhoto,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);

      await tester.tapAt(
        tester.getCenter(
          find.byKey(const ValueKey('globalArrangePhotoSafeArea-photo-1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('globalArrangePhotoOpenArea-photo-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('1 / 1'), findsOneWidget);
    },
  );

  testWidgets('timeline page keeps core markers after extraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelinePagePrototype(
          items: [
            TimelineItem(
              id: 'photo-1',
              recordId: 'record-photo',
              createdAt: DateTime(2026, 1, 12, 10, 30),
              type: TimelineItemType.photo,
              content: '照片条目',
              images: const <String>['https://example.com/photo-a.jpg'],
              photoTarget: const TimelinePhotoTarget(
                recordId: 'record-photo',
                photoPath: '/tmp/photo-a.jpg',
              ),
            ),
            TimelineItem(
              id: 'note-1',
              recordId: 'record-note',
              createdAt: DateTime(2026, 1, 11, 8, 20),
              type: TimelineItemType.note,
              content: '带照片的手记',
              images: const <String>[
                'https://example.com/note-a.jpg',
                'https://example.com/note-b.jpg',
              ],
            ),
          ],
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('照片'), findsOneWidget);
    expect(find.text('手记'), findsOneWidget);
    expect(find.text('整理'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CustomBottomNavBar),
        matching: find.text('整理'),
      ),
      findsOneWidget,
    );
    expect(find.text('节点'), findsNothing);
    expect(find.byIcon(Icons.search), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('timelineItem-photo-1')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('timelineItem-note-1')),
        matching: find.byType(Image),
      ),
      findsNWidgets(2),
    );
    expect(
      tester.widget<Text>(find.text('带照片的手记')).style?.fontStyle,
      FontStyle.italic,
    );
    expect(find.text('作品'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('timelineImageStrip-photo-1')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('timelineImageStrip-note-1')),
        matching: find.byType(Image),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets(
    'timeline classifies capture records by capture mode and ignores synthetic repair records',
    (tester) async {
      final project = Project.create(
        id: 'project-timeline',
        projectTitle: '历程项目',
        projectThemeStatement: '验证历程接入真实数据',
        createdTimestamp: DateTime(2026, 1, 1),
        updatedTimestamp: DateTime(2026, 1, 1),
      );
      final captureRecordRepository = _InMemoryCaptureRecordRepository(
        initialRecords: <CaptureRecord>[
          CaptureRecord.create(
            id: 'record-portfolio',
            projectId: project.projectId,
            captureMode: CaptureMode.portfolio.storageValue,
            captureText: '作品照片',
            capturedPhotoPaths: <String>['/tmp/portfolio-a.jpg'],
            pendingPhotoPaths: <String>['/tmp/portfolio-a.jpg'],
            createdTimestamp: DateTime(2026, 2, 2, 10),
            updatedTimestamp: DateTime(2026, 2, 2, 10),
          ),
          CaptureRecord.create(
            id: 'record-note',
            projectId: project.projectId,
            captureMode: CaptureMode.record.storageValue,
            captureText: '纯文本手记',
            createdTimestamp: DateTime(2026, 2, 1, 9),
            updatedTimestamp: DateTime(2026, 2, 1, 9),
          ),
          CaptureRecord.create(
            id: 'record-note-photo',
            projectId: project.projectId,
            captureMode: CaptureMode.record.storageValue,
            captureText: '带图记录',
            capturedPhotoPaths: <String>['/tmp/note-a.jpg'],
            pendingPhotoPaths: <String>['/tmp/note-a.jpg'],
            createdTimestamp: DateTime(2026, 1, 31, 8),
            updatedTimestamp: DateTime(2026, 2, 9, 8),
          ),
          CaptureRecord.create(
            id: 'record-synthetic',
            projectId: project.projectId,
            captureMode: CaptureMode.record.storageValue,
            captureText: '整理页未归属照片',
            capturedPhotoPaths: <String>['/tmp/synthetic-a.jpg'],
            pendingPhotoPaths: <String>['/tmp/synthetic-a.jpg'],
            createdTimestamp: DateTime(2026, 2, 3, 7),
            updatedTimestamp: DateTime(2026, 2, 3, 7),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[project],
            currentProjectId: project.projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          captureRecordRepository: captureRecordRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('历程'));
      await tester.pumpAndSettle();

      expect(find.textContaining('作品照片', findRichText: true), findsOneWidget);
      expect(find.textContaining('纯文本手记', findRichText: true), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('带图记录', findRichText: true),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('带图记录', findRichText: true), findsOneWidget);
      expect(find.textContaining('整理页未归属照片', findRichText: true), findsNothing);

      await tester.tap(find.text('照片'));
      await tester.pumpAndSettle();

      expect(find.textContaining('作品照片', findRichText: true), findsOneWidget);
      expect(find.text('作品'), findsOneWidget);
      expect(find.textContaining('纯文本手记', findRichText: true), findsNothing);
      expect(find.textContaining('带图记录', findRichText: true), findsNothing);

      await tester.tap(find.text('手记'));
      await tester.pumpAndSettle();

      expect(find.text('作品'), findsNothing);
      expect(find.textContaining('作品照片', findRichText: true), findsNothing);
      expect(find.textContaining('纯文本手记', findRichText: true), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('带图记录', findRichText: true),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('带图记录', findRichText: true), findsOneWidget);
    },
  );

  testWidgets(
    'timeline image strips show all attached images in a horizontal list',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TimelinePagePrototype(
            items: [
              TimelineItem(
                id: 'note-gallery',
                recordId: 'record-note-gallery',
                createdAt: DateTime(2026, 2, 1, 10),
                type: TimelineItemType.note,
                content: '多图手记',
                images: const <String>[
                  'https://example.com/a.jpg',
                  'https://example.com/b.jpg',
                  'https://example.com/c.jpg',
                ],
              ),
            ],
            onOpenSidebar: _noop,
            onBottomTabChanged: _noopPrototypeTab,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('timelineImageStrip-note-gallery')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('timelineImageStrip-note-gallery')),
          matching: find.byType(Image),
        ),
        findsNWidgets(3),
      );
    },
  );

  testWidgets(
    'portfolio records with multiple photos create a single timeline entry',
    (tester) async {
      final project = Project.create(
        id: 'project-timeline-portfolio-single-entry',
        projectTitle: '作品聚合',
        projectThemeStatement: '验证作品多图只生成一条历程',
        createdTimestamp: DateTime(2026, 1, 1),
        updatedTimestamp: DateTime(2026, 1, 1),
      );
      final captureRecordRepository = _InMemoryCaptureRecordRepository(
        initialRecords: <CaptureRecord>[
          CaptureRecord.create(
            id: 'record-portfolio-multi',
            projectId: project.projectId,
            captureMode: CaptureMode.portfolio.storageValue,
            captureText: '多图作品',
            capturedPhotoPaths: <String>[
              '/tmp/portfolio-a.jpg',
              '/tmp/portfolio-b.jpg',
              '/tmp/portfolio-c.jpg',
            ],
            pendingPhotoPaths: <String>[
              '/tmp/portfolio-a.jpg',
              '/tmp/portfolio-b.jpg',
              '/tmp/portfolio-c.jpg',
            ],
            createdTimestamp: DateTime(2026, 2, 2, 10),
            updatedTimestamp: DateTime(2026, 2, 2, 10),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[project],
            currentProjectId: project.projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          captureRecordRepository: captureRecordRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('历程'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey('timelineItem-timeline-photo-record-portfolio-multi'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const ValueKey(
              'timelineImageStrip-timeline-photo-record-portfolio-multi',
            ),
          ),
          matching: find.byType(Image),
        ),
        findsNWidgets(3),
      );
    },
  );

  testWidgets(
    'timeline photo item opens curation and lands on visible loose photo card once',
    (tester) async {
      final project = Project.create(
        id: 'project-timeline-jump',
        projectTitle: '历程跳转',
        projectThemeStatement: '验证历程照片跳转',
        createdTimestamp: DateTime(2026, 1, 1),
        updatedTimestamp: DateTime(2026, 1, 1),
      );
      final captureRecordRepository = _InMemoryCaptureRecordRepository(
        initialRecords: <CaptureRecord>[
          CaptureRecord.create(
            id: 'record-portfolio',
            projectId: project.projectId,
            captureMode: CaptureMode.portfolio.storageValue,
            captureText: '待整理作品',
            capturedPhotoPaths: <String>['/tmp/portfolio-a.jpg'],
            pendingPhotoPaths: <String>['/tmp/portfolio-a.jpg'],
            createdTimestamp: DateTime(2026, 2, 2, 10),
            updatedTimestamp: DateTime(2026, 2, 2, 10),
          ),
          CaptureRecord.create(
            id: 'record-note',
            projectId: project.projectId,
            captureMode: CaptureMode.record.storageValue,
            captureText: '旁白手记',
            createdTimestamp: DateTime(2026, 2, 1, 9),
            updatedTimestamp: DateTime(2026, 2, 1, 9),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[project],
            currentProjectId: project.projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          captureRecordRepository: captureRecordRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('历程'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          const ValueKey('timelineItem-timeline-photo-record-portfolio'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey(
            'globalArrangePhotoCard-record-portfolio::0::/tmp/portfolio-a.jpg',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('未 关 联 照 片'), findsOneWidget);

      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey(
            'globalArrangePhotoCard-record-portfolio::0::/tmp/portfolio-a.jpg',
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'global arrange landing request auto-expands a collapsed element to reveal the target photo',
    (tester) async {
      final landingRequest = ValueNotifier<GlobalArrangePhotoLandingRequest?>(
        null,
      );
      var consumedCount = 0;
      final chapter = GlobalArrangeChapterData(
        chapterId: 'chapter-1',
        title: '第一章',
        elements: <GlobalArrangeElementData>[
          const GlobalArrangeElementData(
            elementId: 'element-1',
            title: '元素一',
            relationTags: <String>[],
            photos: <GlobalArrangePhotoData>[
              GlobalArrangePhotoData(
                photoId: 'element-1::0::/tmp/nested-photo.jpg',
                imageSource: '/tmp/nested-photo.jpg',
                relationTags: <String>[],
                sourceRecordId: 'record-portfolio',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<GlobalArrangePhotoLandingRequest?>(
            valueListenable: landingRequest,
            builder: (context, request, _) {
              return GlobalArrangePage(
                projectTitle: '历程跳转',
                boardData: GlobalArrangeBoardData(
                  chapters: <GlobalArrangeChapterData>[chapter],
                ),
                onOpenSidebar: _noop,
                onBottomTabChanged: _noopPrototypeTab,
                onOpenPendingOrganize: _noopAsync,
                onMoveChapter: _noopMoveChapter,
                onMoveElement: _noopMoveElement,
                onMovePhoto: _noopMovePhoto,
                landingRequest: request,
                onLandingRequestConsumed: (_) {
                  consumedCount += 1;
                  landingRequest.value = null;
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('元素一'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey(
            'globalArrangePhotoCard-element-1::0::/tmp/nested-photo.jpg',
          ),
        ),
        findsNothing,
      );

      landingRequest.value = const GlobalArrangePhotoLandingRequest(
        requestId: 'landing-1',
        sourceRecordId: 'record-portfolio',
        photoPath: '/tmp/nested-photo.jpg',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey(
            'globalArrangePhotoCard-element-1::0::/tmp/nested-photo.jpg',
          ),
        ),
        findsOneWidget,
      );
      expect(consumedCount, 1);

      await tester.pump();
      await tester.pump();
      expect(consumedCount, 1);
    },
  );

  testWidgets(
    'fullscreen curation photo delete removes app references and physical file',
    (tester) async {
      final tempDir = Directory.systemTemp.createTempSync('echo-photo-delete-');
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final photoFile = File('${tempDir.path}/delete-me.jpg');
      photoFile.writeAsBytesSync(<int>[1, 2, 3]);
      final photoPath = photoFile.path;
      const projectId = 'project-photo-delete';
      final relationRepository = _InMemoryProjectRelationRepository();
      final relationTypes = await relationRepository
          .listRelationTypesForProject(projectId);
      await relationRepository.createRelationGroup(
        projectId: projectId,
        relationTypeId: relationTypes.first.relationTypeId,
        title: '照片关系',
        members: <ProjectRelationDraftMember>[
          ProjectRelationDraftMember.photo(
            photoPath: photoPath,
            sourceElementId: 'element-delete',
          ),
          const ProjectRelationDraftMember.element(elementId: 'element-keep'),
        ],
      );
      final elementRepository = _InMemoryNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-delete',
            projectId: projectId,
            chapterId: 'chapter-delete',
            elementTitle: '待删照片元素',
            linkedPhotoPaths: <String>[photoPath],
          ),
          NarrativeElement.create(
            id: 'element-keep',
            projectId: projectId,
            chapterId: 'chapter-delete',
            elementTitle: '保留元素',
          ),
        ],
      );
      final captureRecordRepository = _InMemoryCaptureRecordRepository(
        initialRecords: <CaptureRecord>[
          CaptureRecord.create(
            id: 'record-delete-photo',
            projectId: projectId,
            captureMode: CaptureMode.portfolio.storageValue,
            captureText: '会随最后照片消失的作品',
            capturedPhotoPaths: <String>[photoPath],
            pendingPhotoPaths: <String>[photoPath],
            createdTimestamp: DateTime(2026, 2, 2, 10),
            updatedTimestamp: DateTime(2026, 2, 2, 10),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '删除照片',
                projectThemeStatement: '验证照片删除',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-delete',
                projectId: projectId,
                chapterTitle: '第一章',
                chapterSortOrder: 0,
              ),
            ],
          ),
          narrativeElementRepository: elementRepository,
          projectRelationRepository: relationRepository,
          captureRecordRepository: captureRecordRepository,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('整理'));
      await tester.pump(const Duration(milliseconds: 500));
      final photoOpenAreaFinder = find.byKey(
        ValueKey('globalArrangePhotoOpenArea-element-delete::0::$photoPath'),
      );
      await tester.ensureVisible(photoOpenAreaFinder);
      await tester.pump(const Duration(milliseconds: 300));
      expect(photoOpenAreaFinder.hitTestable(), findsOneWidget);
      await tester.tap(photoOpenAreaFinder);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('globalArrangePhotoDeleteButton')),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.descendant(of: find.byType(Dialog), matching: find.text('删除照片')),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删除')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.byKey(const ValueKey('globalArrangePhotoDeleteButton')),
        findsNothing,
      );
      expect(photoFile.existsSync(), isFalse);
      final updatedElements = await elementRepository.listElementsForProject(
        projectId,
      );
      expect(
        updatedElements
            .singleWhere((element) => element.elementId == 'element-delete')
            .photoPaths,
        isEmpty,
      );
      final updatedRecords = await captureRecordRepository
          .listRecordsForProject(projectId);
      expect(updatedRecords.single.photoPaths, isEmpty);
      expect(updatedRecords.single.unorganizedPhotoPaths, isEmpty);
      final updatedMembers = await relationRepository
          .listRelationMembersForProject(projectId);
      expect(
        updatedMembers.where((member) => member.linkedPhotoPath == photoPath),
        isEmpty,
      );

      await tester.tap(find.text('历程'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('会随最后照片消失', findRichText: true), findsNothing);
    },
  );

  testWidgets(
    'timeline long press delete removes capture record and orphan file',
    (tester) async {
      final tempDir = Directory.systemTemp.createTempSync(
        'echo-timeline-delete-',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final photoFile = File('${tempDir.path}/timeline-delete.jpg');
      photoFile.writeAsBytesSync(<int>[1, 2, 3]);
      const projectId = 'project-timeline-delete';
      final captureRecordRepository = _InMemoryCaptureRecordRepository(
        initialRecords: <CaptureRecord>[
          CaptureRecord.create(
            id: 'record-timeline-delete',
            projectId: projectId,
            captureMode: CaptureMode.portfolio.storageValue,
            captureText: '待删除历程',
            capturedPhotoPaths: <String>[photoFile.path],
            pendingPhotoPaths: <String>[photoFile.path],
            createdTimestamp: DateTime(2026, 2, 2, 10),
            updatedTimestamp: DateTime(2026, 2, 2, 10),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: projectId,
                projectTitle: '删除历程',
                projectThemeStatement: '验证历程删除',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: projectId,
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          captureRecordRepository: captureRecordRepository,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('历程'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.longPress(
        find.byKey(
          const ValueKey('timelineItem-timeline-photo-record-timeline-delete'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.descendant(of: find.byType(Dialog), matching: find.text('删除历程')),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删除')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        await captureRecordRepository.listRecordsForProject(projectId),
        isEmpty,
      );
      expect(photoFile.existsSync(), isFalse);
      expect(find.textContaining('待删除历程', findRichText: true), findsNothing);
    },
  );

  testWidgets(
    'echo app overview uses injected beacon tasks with derived chapter and element lines',
    (tester) async {
      final beaconTaskRepository = _InMemoryBeaconTaskRepository(
        initialTasks: <BeaconTask>[
          BeaconTask.create(
            id: 'task-1',
            projectId: 'project-beacon',
            taskTitle: '县城剧院废弃放映厅',
            taskDescription: '极低照度拍摄，捕捉放映机投射孔透出的微光。',
            linkedElementIds: <String>['element-1'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.pumpWidget(
        EchoApp(
          projectRepository: _InMemoryProjectRepository(
            initialProjects: <Project>[
              Project.create(
                id: 'project-beacon',
                projectTitle: '赤水河沿岸寻访',
                projectThemeStatement: '用于验证信标页接线',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            currentProjectId: 'project-beacon',
          ),
          structureChapterRepository: _InMemoryStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-1',
                projectId: 'project-beacon',
                chapterTitle: '晨曦之眼',
                chapterDescription: '章节说明',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
          ),
          narrativeElementRepository: _InMemoryNarrativeElementRepository(
            initialElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-1',
                projectId: 'project-beacon',
                chapterId: 'chapter-1',
                elementTitle: '某种醉态',
                elementDescription: '元素说明',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
          ),
          projectRelationRepository: _InMemoryProjectRelationRepository(),
          beaconTaskRepository: beaconTaskRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('信标'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('beaconNormalModeRoot')),
        findsOneWidget,
      );
      expect(find.text('县城剧院废弃放映厅'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('beaconTaskChapterLine-task-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('beaconTaskElementLine-task-1')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('beaconAddTaskButton')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('beaconExecutionEntryButton')),
        findsOneWidget,
      );
      final searchToggleRect = tester.getRect(
        find.byKey(const ValueKey('beaconSearchToggleButton')),
      );
      expect(searchToggleRect.width, greaterThanOrEqualTo(48));
      expect(searchToggleRect.height, greaterThanOrEqualTo(48));
      expect(
        find.byKey(const ValueKey('beaconPendingSectionHeader')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('beaconArchivedSectionHeader')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('beaconTaskCard-task-1')),
          matching: find.byType(Image),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'echo app beacon page derives chapter and element summary lines from linked elements only',
    (tester) async {
      final beaconTaskRepository = _InMemoryBeaconTaskRepository(
        initialTasks: <BeaconTask>[
          BeaconTask.create(
            id: 'task-both',
            projectId: 'project-beacon',
            taskTitle: '跨章线索',
            taskDescription: '同时命中多个元素与章节。',
            linkedElementIds: <String>[
              'element-a',
              'element-b',
              'element-c',
              'element-missing',
            ],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 5),
          ),
          BeaconTask.create(
            id: 'task-element-only',
            projectId: 'project-beacon',
            taskTitle: '只关联元素',
            taskDescription: '没有章节归属的元素。',
            linkedElementIds: <String>['element-no-chapter'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 4),
          ),
          BeaconTask.create(
            id: 'task-none',
            projectId: 'project-beacon',
            taskTitle: '纯文字任务',
            taskDescription: '不关联任何元素。',
            linkedElementIds: const <String>[],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 3),
          ),
          BeaconTask.create(
            id: 'task-unresolved-chapter',
            projectId: 'project-beacon',
            taskTitle: '缺失章节映射',
            taskDescription: '元素带 chapterId 但 lookup 缺失。',
            linkedElementIds: <String>['element-unresolved'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
        ],
      );

      await _pumpBeaconApp(
        tester,
        beaconTaskRepository: beaconTaskRepository,
        chapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-1',
            projectId: 'project-beacon',
            chapterTitle: '晨曦之眼',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          StructureChapter.create(
            id: 'chapter-2',
            projectId: 'project-beacon',
            chapterTitle: '潮湿而冗长的第二章标题用于验证章节摘要在超长文案下保持单行省略而不是撑高卡片',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        elements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-a',
            projectId: 'project-beacon',
            chapterId: 'chapter-1',
            elementTitle: '同章元素一',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-b',
            projectId: 'project-beacon',
            chapterId: 'chapter-1',
            elementTitle: '同章元素二',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-c',
            projectId: 'project-beacon',
            chapterId: 'chapter-2',
            elementTitle: '潮湿而冗长的元素标题用于验证元素摘要在超长文案下保持单行省略而不是换行',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-no-chapter',
            projectId: 'project-beacon',
            elementTitle: '游离元素',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-unresolved',
            projectId: 'project-beacon',
            chapterId: 'chapter-missing',
            elementTitle: '找不到章节标题的元素',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      final chapterLine = tester.widget<Text>(
        find.byKey(const ValueKey('beaconTaskChapterLine-task-both')),
      );
      final elementLine = tester.widget<Text>(
        find.byKey(const ValueKey('beaconTaskElementLine-task-both')),
      );

      expect(
        chapterLine.data,
        '[章节]  晨曦之眼，潮湿而冗长的第二章标题用于验证章节摘要在超长文案下保持单行省略而不是撑高卡片',
      );
      expect(chapterLine.maxLines, 1);
      expect(chapterLine.overflow, TextOverflow.ellipsis);
      expect(
        elementLine.data,
        '[元素]  同章元素一，同章元素二，潮湿而冗长的元素标题用于验证元素摘要在超长文案下保持单行省略而不是换行',
      );
      expect(elementLine.maxLines, 1);
      expect(elementLine.overflow, TextOverflow.ellipsis);
      expect(chapterLine.data?.split('晨曦之眼').length, 2);

      expect(
        find.byKey(const ValueKey('beaconTaskChapterLine-task-element-only')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('beaconTaskElementLine-task-element-only')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('beaconTaskChapterLine-task-none')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('beaconTaskElementLine-task-none')),
        findsNothing,
      );

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -420));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey('beaconTaskChapterLine-task-unresolved-chapter'),
        ),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey('beaconTaskElementLine-task-unresolved-chapter'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'echo app beacon page supports search and add or edit task flow through the repository',
    (tester) async {
      final beaconTaskRepository = _InMemoryBeaconTaskRepository(
        initialTasks: <BeaconTask>[
          BeaconTask.create(
            id: 'task-1',
            projectId: 'project-beacon',
            taskTitle: '盐道码头',
            taskDescription: '关注铁锈与水面的反光对比。',
            linkedElementIds: <String>['element-1'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
          BeaconTask.create(
            id: 'task-2',
            projectId: 'project-beacon',
            taskTitle: '空仓入口',
            taskDescription: '从介绍文本里搜索剧院关键词。',
            linkedElementIds: <String>['element-2'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 1),
          ),
        ],
      );

      await _pumpBeaconApp(
        tester,
        beaconTaskRepository: beaconTaskRepository,
        chapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-1',
            projectId: 'project-beacon',
            chapterTitle: '晨曦之眼',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        elements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-1',
            projectId: 'project-beacon',
            chapterId: 'chapter-1',
            elementTitle: '斑驳的树影',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-2',
            projectId: 'project-beacon',
            elementTitle: '某种醉态',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.tap(find.byKey(const ValueKey('beaconSearchToggleButton')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('beaconSearchField')),
        '剧院',
      );
      await tester.pumpAndSettle();
      expect(find.text('空仓入口'), findsOneWidget);
      expect(find.text('盐道码头'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('beaconSearchField')),
        '',
      );
      await tester.pumpAndSettle();
      expect(find.text('盐道码头'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('beaconSearchToggleButton')));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -520));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('beaconAddTaskButton')));
      await tester.pumpAndSettle();
      expect(find.byType(BeaconTaskEditorPage), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('beaconTaskEditorTitleField')),
        '林道伐木痕迹',
      );
      await tester.enterText(
        find.byKey(const ValueKey('beaconTaskEditorDescriptionField')),
        '记录树桩年轮与青苔细节。',
      );
      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorElement-element-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorSaveButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('林道伐木痕迹'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('beaconTaskElementLine-task-3')),
        findsOneWidget,
      );
      expect(
        beaconTaskRepository.tasks.map((task) => task.taskId),
        contains('task-3'),
      );

      await tester.tap(find.byKey(const ValueKey('beaconTaskCard-task-3')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('beaconTaskEditorTitleField')),
        '林道伐木痕迹更新',
      );
      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorSaveButton')),
      );
      await tester.pumpAndSettle();

      expect(
        beaconTaskRepository.tasks
            .singleWhere((task) => task.taskId == 'task-3')
            .title,
        '林道伐木痕迹更新',
      );
      await tester.fling(
        find.byType(ListView).last,
        const Offset(0, 600),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('林道伐木痕迹更新'), findsOneWidget);
      expect(find.text('林道伐木痕迹'), findsNothing);
    },
  );

  testWidgets(
    'echo app beacon page keeps search inside tab filters and supports archive or delete',
    (tester) async {
      final beaconTaskRepository = _InMemoryBeaconTaskRepository(
        initialTasks: <BeaconTask>[
          BeaconTask.create(
            id: 'task-1',
            projectId: 'project-beacon',
            taskTitle: '放映厅微光',
            taskDescription: '极低照度拍摄。',
            linkedElementIds: <String>['element-1'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 3),
          ),
          BeaconTask.create(
            id: 'task-2',
            projectId: 'project-beacon',
            taskTitle: '河滩残骸',
            taskDescription: '观察河床切割线。',
            linkedElementIds: const <String>[],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
          BeaconTask.create(
            id: 'task-3',
            projectId: 'project-beacon',
            taskTitle: '已归档剧院记录',
            taskDescription: '用于搜索和 tab 边界验证。',
            linkedElementIds: const <String>[],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 1),
          )..statusValue = BeaconTaskStatus.archived,
        ],
      );

      await _pumpBeaconApp(
        tester,
        beaconTaskRepository: beaconTaskRepository,
        elements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-1',
            projectId: 'project-beacon',
            elementTitle: '某种醉态',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      await tester.tap(find.text('待执行'));
      await tester.pumpAndSettle();
      expect(find.text('放映厅微光'), findsOneWidget);
      expect(find.text('已归档剧院记录'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('beaconSearchToggleButton')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('beaconSearchField')),
        '剧院',
      );
      await tester.pumpAndSettle();
      expect(find.text('放映厅微光'), findsNothing);
      expect(find.text('已归档剧院记录'), findsNothing);

      await tester.tap(find.text('已归档'));
      await tester.pumpAndSettle();
      expect(find.text('已归档剧院记录'), findsOneWidget);
      expect(find.text('放映厅微光'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('beaconSearchToggleButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('全部'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('beaconTaskCard-task-1')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorArchiveButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('归档').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('待执行'));
      await tester.pumpAndSettle();
      expect(find.text('放映厅微光'), findsNothing);

      await tester.tap(find.text('已归档'));
      await tester.pumpAndSettle();
      expect(find.text('放映厅微光'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('beaconTaskCard-task-1')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('beaconTaskEditorArchiveButton')),
        findsOneWidget,
      );
      expect(find.text('恢复'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorArchiveButton')),
      );
      await tester.pumpAndSettle();
      expect(find.text('恢复任务'), findsOneWidget);
      await tester.tap(find.text('恢复').last);
      await tester.pumpAndSettle();

      expect(
        beaconTaskRepository.tasks
            .singleWhere((task) => task.taskId == 'task-1')
            .isArchived,
        isFalse,
      );
      await tester.tap(find.text('待执行'));
      await tester.pumpAndSettle();
      expect(find.text('放映厅微光'), findsOneWidget);

      await tester.tap(find.text('全部'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('beaconTaskCard-task-2')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorDeleteButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除').last);
      await tester.pumpAndSettle();

      expect(find.text('河滩残骸'), findsNothing);
      expect(
        beaconTaskRepository.tasks.map((task) => task.taskId),
        isNot(contains('task-2')),
      );
    },
  );

  testWidgets(
    'echo app beacon all tab groups pending tasks above archived tasks',
    (tester) async {
      final beaconTaskRepository = _InMemoryBeaconTaskRepository(
        initialTasks: <BeaconTask>[
          BeaconTask.create(
            id: 'task-pending',
            projectId: 'project-beacon',
            taskTitle: '进行中任务',
            taskDescription: '仍在进行。',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
          BeaconTask.create(
            id: 'task-archived',
            projectId: 'project-beacon',
            taskTitle: '已归档任务',
            taskDescription: '已经完成。',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 1),
          )..statusValue = BeaconTaskStatus.archived,
        ],
      );

      await _pumpBeaconApp(tester, beaconTaskRepository: beaconTaskRepository);

      final pendingHeaderY = tester
          .getTopLeft(find.byKey(const ValueKey('beaconPendingSectionHeader')))
          .dy;
      final pendingCardY = tester
          .getTopLeft(find.byKey(const ValueKey('beaconTaskCard-task-pending')))
          .dy;
      final archivedHeaderY = tester
          .getTopLeft(find.byKey(const ValueKey('beaconArchivedSectionHeader')))
          .dy;
      final archivedCardY = tester
          .getTopLeft(
            find.byKey(const ValueKey('beaconTaskCard-task-archived')),
          )
          .dy;

      expect(pendingHeaderY, lessThan(pendingCardY));
      expect(pendingCardY, lessThan(archivedHeaderY));
      expect(archivedHeaderY, lessThan(archivedCardY));
    },
  );

  testWidgets(
    'echo app beacon execution mode replaces the normal view, supports multi-select, and resets temporary selections',
    (tester) async {
      final beaconTaskRepository = _InMemoryBeaconTaskRepository(
        initialTasks: <BeaconTask>[
          BeaconTask.create(
            id: 'task-1',
            projectId: 'project-beacon',
            taskTitle: '放映厅微光',
            taskDescription: '极低照度拍摄。',
            linkedElementIds: <String>['element-1', 'element-2'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 3),
          ),
          BeaconTask.create(
            id: 'task-2',
            projectId: 'project-beacon',
            taskTitle: '河滩残骸',
            taskDescription: '观察河床切割线。',
            linkedElementIds: <String>['element-2'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
          BeaconTask.create(
            id: 'task-4',
            projectId: 'project-beacon',
            taskTitle: '未选中的进行中任务',
            taskDescription: '它的元素不应该出现在探索。',
            linkedElementIds: <String>['element-3'],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 2, 1),
          ),
          BeaconTask.create(
            id: 'task-3',
            projectId: 'project-beacon',
            taskTitle: '不会出现在探索',
            taskDescription: '因为已归档。',
            linkedElementIds: const <String>[],
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026, 1, 1),
          )..statusValue = BeaconTaskStatus.archived,
        ],
      );

      await _pumpBeaconApp(
        tester,
        beaconTaskRepository: beaconTaskRepository,
        elements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-1',
            projectId: 'project-beacon',
            elementTitle: '某种醉态',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-2',
            projectId: 'project-beacon',
            elementTitle: '河岸石块',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
          NarrativeElement.create(
            id: 'element-3',
            projectId: 'project-beacon',
            elementTitle: '不应出现的独有元素',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
      );

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      final entryButtonFinder = find.byKey(
        const ValueKey('beaconExecutionEntryButton'),
      );
      expect(navigator.canPop(), isFalse);
      expect(
        find.descendant(
          of: entryButtonFinder,
          matching: find.byIcon(Icons.playlist_add_check_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: entryButtonFinder, matching: find.text('探索')),
        findsOneWidget,
      );

      final normalRootRect = tester.getRect(
        find.byKey(const ValueKey('beaconNormalModeRoot')),
      );
      final entryRect = tester.getRect(entryButtonFinder);
      expect(entryRect.center.dx, greaterThan(normalRootRect.center.dx));
      expect(entryRect.center.dy, greaterThan(normalRootRect.center.dy));

      await tester.tap(entryButtonFinder);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('beaconExecutionTaskPickerDialog')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('beaconExecutionTaskPickerDialog')),
          matching: find.text('放映厅微光'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('beaconExecutionTaskPickerDialog')),
          matching: find.text('河滩残骸'),
        ),
        findsOneWidget,
      );
      expect(find.byType(Checkbox), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('beaconExecutionTaskPickerDialog')),
          matching: find.text('极低照度拍摄。'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('beaconExecutionTaskPickerDialog')),
          matching: find.text('观察河床切割线。'),
        ),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('beaconExecutionModeRoot')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('beaconExecutionTaskPickerRow-task-3')),
        findsNothing,
      );
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(
                of: find.byKey(
                  const ValueKey('beaconExecutionTaskPickerConfirmButton'),
                ),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        0.35,
      );
      final pickerTitle = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('beaconExecutionTaskPickerRow-task-1')),
          matching: find.text('放映厅微光'),
        ),
      );
      expect(pickerTitle.maxLines, 1);
      expect(pickerTitle.overflow, TextOverflow.ellipsis);
      await tester.tap(
        find.byKey(const ValueKey('beaconExecutionTaskPickerRow-task-1')),
      );
      await tester.tap(
        find.byKey(const ValueKey('beaconExecutionTaskPickerRow-task-2')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('beaconExecutionTaskPickerConfirmButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('beaconNormalModeRoot')), findsNothing);
      expect(
        find.byKey(const ValueKey('beaconExecutionModeRoot')),
        findsOneWidget,
      );
      expect(find.byType(CustomBottomNavBar), findsNothing);
      expect(find.byKey(const ValueKey('beaconSearchField')), findsNothing);
      expect(find.byKey(const ValueKey('beaconAddTaskButton')), findsNothing);
      expect(
        find.byKey(const ValueKey('beaconExecutionExitButton')),
        findsOneWidget,
      );
      expect(find.byType(Image), findsNothing);
      expect(find.text('不会出现在探索'), findsNothing);
      expect(find.text('选择任务后，这里只保留当前外拍需要记住的提示。'), findsNothing);
      expect(navigator.canPop(), isFalse);

      final elementSectionFinder = find.byKey(
        const ValueKey('beaconExecutionElementSection'),
      );
      final taskSectionFinder = find.byKey(
        const ValueKey('beaconExecutionTaskSection'),
      );
      expect(elementSectionFinder, findsOneWidget);
      expect(taskSectionFinder, findsOneWidget);
      expect(
        tester.getTopLeft(elementSectionFinder).dy,
        lessThan(tester.getTopLeft(taskSectionFinder).dy),
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(const ValueKey('beaconExecutionModeRoot')),
                matching: find.text('寻 找 中'),
              ),
            )
            .style
            ?.fontSize,
        greaterThanOrEqualTo(
          tester
                  .widget<Text>(
                    find.descendant(
                      of: taskSectionFinder,
                      matching: find.text('任务介绍'),
                    ),
                  )
                  .style
                  ?.fontSize ??
              0,
        ),
      );

      final elementRowOne = find.byKey(
        const ValueKey('beaconExecutionElementRow-element-1'),
      );
      final elementRowTwo = find.byKey(
        const ValueKey('beaconExecutionElementRow-element-2'),
      );

      expect(elementRowOne, findsOneWidget);
      expect(elementRowTwo, findsOneWidget);
      expect(find.text('某种醉态'), findsOneWidget);
      expect(find.text('河岸石块'), findsOneWidget);
      expect(find.text('不应出现的独有元素'), findsNothing);
      expect(
        find.byKey(const ValueKey('beaconExecutionElementRow-element-2')),
        findsOneWidget,
      );
      expect(find.text('极低照度拍摄。'), findsOneWidget);
      expect(find.text('观察河床切割线。'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('beaconExecutionExitButton')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('beaconNormalModeRoot')),
        findsOneWidget,
      );

      await tester.tap(entryButtonFinder);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('beaconExecutionTaskPickerDialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('beaconExecutionTaskPickerRow-task-3')),
        findsNothing,
      );
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(
                of: find.byKey(
                  const ValueKey('beaconExecutionTaskPickerConfirmButton'),
                ),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        0.35,
      );
      await tester.tap(
        find.byKey(const ValueKey('beaconExecutionTaskPickerConfirmButton')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('beaconExecutionTaskPickerDialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('beaconExecutionModeRoot')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'beacon task editor groups elements by chapter order and leaves unassigned elements last',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BeaconTaskEditorPage(
            chapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-2',
                projectId: 'project-beacon',
                chapterTitle: '后出现章节',
                chapterSortOrder: 1,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
              StructureChapter.create(
                id: 'chapter-1',
                projectId: 'project-beacon',
                chapterTitle: '先出现章节',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            elements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-b',
                projectId: 'project-beacon',
                chapterId: 'chapter-2',
                elementTitle: '第二章元素',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
              NarrativeElement.create(
                id: 'element-a',
                projectId: 'project-beacon',
                chapterId: 'chapter-1',
                elementTitle: '第一章元素',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
              NarrativeElement.create(
                id: 'element-c',
                projectId: 'project-beacon',
                elementTitle: '未归章节元素',
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
            onSave:
                ({
                  required String title,
                  required String description,
                  required List<String> linkedElementIds,
                }) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('任务名'), findsNothing);
      expect(find.text('任务介绍'), findsNothing);
      expect(find.text('C H A P T E R  01  /  先出现章节'), findsOneWidget);
      expect(find.text('C H A P T E R  02  /  后出现章节'), findsOneWidget);
      expect(find.text('未 归 章 节'), findsOneWidget);

      expect(
        find.text('C H A P T E R  01  /  先出现章节').evaluate().single,
        isNotNull,
      );
      final chapterOneY = tester
          .getTopLeft(find.text('C H A P T E R  01  /  先出现章节'))
          .dy;
      final chapterTwoY = tester
          .getTopLeft(find.text('C H A P T E R  02  /  后出现章节'))
          .dy;
      final unassignedY = tester.getTopLeft(find.text('未 归 章 节')).dy;

      expect(chapterOneY, lessThan(chapterTwoY));
      expect(chapterTwoY, lessThan(unassignedY));
      expect(find.text('第一章元素'), findsOneWidget);
      expect(find.text('第二章元素'), findsOneWidget);
      expect(find.text('未归章节元素'), findsOneWidget);
    },
  );

  testWidgets(
    'beacon task editor archive and delete confirmation reuse shared dialog style',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BeaconTaskEditorPage(
            task: BeaconTask.create(
              id: 'task-confirm',
              projectId: 'project-beacon',
              taskTitle: '放映厅微光',
              taskDescription: '极低照度拍摄。',
              createdTimestamp: DateTime(2026),
              updatedTimestamp: DateTime(2026),
            ),
            chapters: const <StructureChapter>[],
            elements: const <NarrativeElement>[],
            onSave:
                ({
                  required String title,
                  required String description,
                  required List<String> linkedElementIds,
                }) async {},
            onDelete: () async {},
            onArchive: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('任务名'), findsOneWidget);
      expect(find.text('任务介绍'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorArchiveButton')),
      );
      await tester.pumpAndSettle();
      expect(find.text('归档任务'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('取 消'), findsOneWidget);
      expect(find.text('归档').last, findsOneWidget);

      await tester.tap(find.text('取 消'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('beaconTaskEditorDeleteButton')),
      );
      await tester.pumpAndSettle();
      expect(find.text('删除任务'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.descendant(of: find.byType(Dialog), matching: find.text('删除')),
        findsOneWidget,
      );
    },
  );
}

void _noop() {}

void _noopTab(int _) {}

void _noopPrototypeTab(PrototypeTab _) {}

Future<void> _noopAsync() async {}

Future<void> _noopMoveChapter({
  required String chapterId,
  required int targetIndex,
}) async {}

Future<void> _noopMoveElement({
  required String elementId,
  required String? targetChapterId,
  required int targetIndex,
}) async {}

Future<void> _noopMovePhoto({
  required String sourceElementId,
  required int sourcePhotoIndex,
  required String targetElementId,
  required int targetPhotoIndex,
}) async {}

Future<void> _pumpBeaconApp(
  WidgetTester tester, {
  required _InMemoryBeaconTaskRepository beaconTaskRepository,
  List<StructureChapter>? chapters,
  List<NarrativeElement>? elements,
}) async {
  await tester.pumpWidget(
    EchoApp(
      projectRepository: _InMemoryProjectRepository(
        initialProjects: <Project>[
          Project.create(
            id: 'project-beacon',
            projectTitle: '赤水河沿岸寻访',
            projectThemeStatement: '用于验证信标页接线',
            createdTimestamp: DateTime(2026),
            updatedTimestamp: DateTime(2026),
          ),
        ],
        currentProjectId: 'project-beacon',
      ),
      structureChapterRepository: _InMemoryStructureChapterRepository(
        initialChapters: chapters,
      ),
      narrativeElementRepository: _InMemoryNarrativeElementRepository(
        initialElements: elements,
      ),
      projectRelationRepository: _InMemoryProjectRelationRepository(),
      beaconTaskRepository: beaconTaskRepository,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('信标'));
  await tester.pumpAndSettle();
}

Future<String> _resolveIsarLibraryPath() async {
  final packageConfigFile = File('.dart_tool/package_config.json');
  final packageConfig =
      jsonDecode(await packageConfigFile.readAsString())
          as Map<String, dynamic>;
  final packages = packageConfig['packages'] as List<dynamic>;

  final isarFlutterLibsPackage = packages
      .cast<Map<String, dynamic>>()
      .firstWhere((package) => package['name'] == 'isar_flutter_libs');
  final packageRoot = Uri.parse(isarFlutterLibsPackage['rootUri'] as String);
  final packageDirectory = packageRoot.isAbsolute
      ? Directory.fromUri(packageRoot)
      : Directory.fromUri(packageConfigFile.parent.uri.resolveUri(packageRoot));

  if (Platform.isMacOS) {
    return '${packageDirectory.path}/macos/libisar.dylib';
  }
  if (Platform.isLinux) {
    return '${packageDirectory.path}/linux/libisar.so';
  }
  if (Platform.isWindows) {
    return '${packageDirectory.path}/windows/isar.dll';
  }

  throw UnsupportedError(
    'Isar core path resolution is not configured for this platform.',
  );
}

Finder _findSelectedCompressionOption(String label) {
  return find.byWidgetPredicate((widget) {
    if (widget is! RadioListTile<Object?>) {
      return false;
    }
    final title = widget.title;
    if (title is! Text || title.data != label) {
      return false;
    }
    return widget.groupValue == widget.value;
  });
}

class _InMemoryProjectRepository implements ProjectRepository {
  Project? _currentProject;
  final List<Project> _projects;
  int _counter = 0;

  _InMemoryProjectRepository({
    List<Project>? initialProjects,
    String? currentProjectId,
  }) : _projects = List<Project>.from(initialProjects ?? <Project>[]) {
    if (currentProjectId != null) {
      for (final project in _projects) {
        if (project.projectId == currentProjectId) {
          _currentProject = project;
          break;
        }
      }
    }
  }

  List<Project> get projects => List<Project>.unmodifiable(_projects);

  @override
  Future<Project> createProject({
    required String title,
    required String themeStatement,
    String? description,
    String? coverImagePath,
  }) async {
    _counter++;
    final createdProject = Project.create(
      id: 'project-$_counter',
      projectTitle: title,
      projectThemeStatement: themeStatement,
      projectDescription: description,
      projectCoverImagePath: coverImagePath,
      createdTimestamp: DateTime(2026),
      updatedTimestamp: DateTime(2026),
    );
    _projects.insert(0, createdProject);
    _currentProject = createdProject;
    return createdProject;
  }

  @override
  Future<Project?> getCurrentProject() async => _currentProject;

  @override
  Future<List<Project>> listProjects() async =>
      List<Project>.unmodifiable(_projects);

  @override
  Future<void> setCurrentProject(String projectId) async {
    for (final project in _projects) {
      if (project.projectId == projectId) {
        _currentProject = project;
        return;
      }
    }
  }

  @override
  Future<Project?> archiveProject(String projectId) async {
    for (final project in _projects) {
      if (project.projectId == projectId) {
        project.stage = project.stage == 'completed' ? 'draft' : 'completed';
        project.updatedAt = DateTime(2026, 1, 2);
        return project;
      }
    }
    return null;
  }

  @override
  Future<Project?> updateProject({
    required String projectId,
    required String title,
    required String themeStatement,
    String? coverImagePath,
  }) async {
    for (final project in _projects) {
      if (project.projectId == projectId) {
        project.title = title;
        project.themeStatement = themeStatement;
        project.coverImagePath = coverImagePath;
        project.updatedAt = DateTime(2026, 1, 3);
        if (_currentProject?.projectId == projectId) {
          _currentProject = project;
        }
        return project;
      }
    }
    return null;
  }

  @override
  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((project) => project.projectId == projectId);
    if (_currentProject?.projectId == projectId) {
      _currentProject = _projects.isEmpty ? null : _projects.first;
    }
  }
}

class _FailingProjectRepository implements ProjectRepository {
  @override
  Future<Project> createProject({
    required String title,
    required String themeStatement,
    String? description,
    String? coverImagePath,
  }) async {
    throw StateError('mock create failure');
  }

  @override
  Future<Project?> getCurrentProject() async => null;

  @override
  Future<List<Project>> listProjects() async => const <Project>[];

  @override
  Future<void> setCurrentProject(String projectId) async {}

  @override
  Future<Project?> updateProject({
    required String projectId,
    required String title,
    required String themeStatement,
    String? coverImagePath,
  }) async {
    return null;
  }

  @override
  Future<Project?> archiveProject(String projectId) async {
    return null;
  }

  @override
  Future<void> deleteProject(String projectId) async {}
}

class _InMemoryStructureChapterRepository
    implements StructureChapterRepository {
  _InMemoryStructureChapterRepository({List<StructureChapter>? initialChapters})
    : _chapters = List<StructureChapter>.from(
        initialChapters ?? <StructureChapter>[],
      );

  final List<StructureChapter> _chapters;

  @override
  Future<List<StructureChapter>> listChaptersForProject(
    String projectId,
  ) async {
    final chapters = _chapters
        .where((chapter) => chapter.owningProjectId == projectId)
        .toList();
    chapters.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return chapters;
  }

  @override
  Future<StructureChapter> createChapter({
    required String projectId,
    required String title,
    String? description,
    required int sortOrder,
  }) async {
    for (final chapter in _chapters) {
      if (chapter.owningProjectId == projectId &&
          chapter.sortOrder >= sortOrder) {
        chapter.sortOrder += 1;
      }
    }

    final chapter = StructureChapter.create(
      id: 'chapter-${_chapters.length + 1}',
      projectId: projectId,
      chapterTitle: title,
      chapterDescription: description,
      chapterSortOrder: sortOrder,
      createdTimestamp: DateTime(2026),
      updatedTimestamp: DateTime(2026),
    );
    _chapters.add(chapter);
    return chapter;
  }

  @override
  Future<StructureChapter?> updateChapter({
    required String chapterId,
    required String title,
    String? description,
    required int sortOrder,
    required String statusLabel,
  }) async {
    StructureChapter? targetChapter;
    for (final chapter in _chapters) {
      if (chapter.chapterId == chapterId) {
        targetChapter = chapter;
        break;
      }
    }
    if (targetChapter == null) {
      return null;
    }

    final projectChapters = _chapters
        .where(
          (chapter) =>
              chapter.owningProjectId == targetChapter!.owningProjectId,
        )
        .toList();
    projectChapters.sort(
      (left, right) => left.sortOrder.compareTo(right.sortOrder),
    );

    final reorderedChapters = projectChapters
        .where((chapter) => chapter.chapterId != chapterId)
        .toList();
    final normalizedSortOrder = sortOrder.clamp(0, reorderedChapters.length);
    reorderedChapters.insert(normalizedSortOrder, targetChapter);

    final trimmedDescription = description?.trim();
    for (var index = 0; index < reorderedChapters.length; index++) {
      final chapter = reorderedChapters[index];
      chapter.sortOrder = index;
      if (chapter.chapterId == chapterId) {
        chapter.title = title.trim();
        chapter.description = trimmedDescription?.isNotEmpty == true
            ? trimmedDescription
            : null;
        chapter.statusLabel = statusLabel;
        chapter.updatedAt = DateTime(2026, 1, 4, index + 1);
      }
    }

    return targetChapter;
  }

  @override
  Future<bool> deleteChapter(String chapterId) async {
    final targetIndex = _chapters.indexWhere(
      (chapter) => chapter.chapterId == chapterId,
    );
    if (targetIndex < 0) {
      return false;
    }

    final deletedChapter = _chapters.removeAt(targetIndex);
    final remainingChapters =
        _chapters
            .where(
              (chapter) =>
                  chapter.owningProjectId == deletedChapter.owningProjectId,
            )
            .toList()
          ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));

    for (var index = 0; index < remainingChapters.length; index++) {
      remainingChapters[index].sortOrder = index;
      remainingChapters[index].updatedAt = DateTime(2026, 1, 7, index + 1);
    }

    return true;
  }
}

class _InMemoryNarrativeElementRepository
    implements NarrativeElementRepository {
  _InMemoryNarrativeElementRepository({List<NarrativeElement>? initialElements})
    : _elements = List<NarrativeElement>.from(
        initialElements ?? <NarrativeElement>[],
      );

  final List<NarrativeElement> _elements;

  List<NarrativeElement> _bucket(String projectId, String? chapterId) {
    final bucket = _elements
        .where(
          (element) =>
              element.owningProjectId == projectId &&
              element.owningChapterId == chapterId,
        )
        .toList();
    bucket.sort((left, right) {
      final sortCompare = left.sortOrder.compareTo(right.sortOrder);
      if (sortCompare != 0) {
        return sortCompare;
      }
      return left.createdAt.compareTo(right.createdAt);
    });
    return bucket;
  }

  void _normalizeBucket(List<NarrativeElement> bucket) {
    for (var index = 0; index < bucket.length; index++) {
      bucket[index].sortOrder = index;
    }
  }

  @override
  Future<NarrativeElement> createElement({
    required String projectId,
    String? chapterId,
    required String title,
    String? description,
    String status = 'finding',
    int? sortOrder,
    List<String>? photoPaths,
  }) async {
    final bucket = _bucket(projectId, chapterId);
    final resolvedSortOrder = (sortOrder ?? bucket.length).clamp(
      0,
      bucket.length,
    );
    for (var index = resolvedSortOrder; index < bucket.length; index++) {
      bucket[index].sortOrder += 1;
    }
    final element = NarrativeElement.create(
      id: 'element-${_elements.length + 1}',
      projectId: projectId,
      chapterId: chapterId,
      elementTitle: title,
      elementDescription: description,
      elementStatus: status,
      elementSortOrder: resolvedSortOrder,
      linkedPhotoPaths: photoPaths,
      createdTimestamp: DateTime(2026),
      updatedTimestamp: DateTime(2026),
    );
    _elements.add(element);
    return element;
  }

  @override
  Future<List<NarrativeElement>> listElementsForProject(
    String projectId,
  ) async {
    final elements = _elements
        .where((element) => element.owningProjectId == projectId)
        .toList();
    elements.sort((left, right) {
      final leftChapter = left.owningChapterId;
      final rightChapter = right.owningChapterId;
      if (leftChapter == null && rightChapter != null) {
        return 1;
      }
      if (leftChapter != null && rightChapter == null) {
        return -1;
      }
      if (leftChapter != null && rightChapter != null) {
        final chapterCompare = leftChapter.compareTo(rightChapter);
        if (chapterCompare != 0) {
          return chapterCompare;
        }
      }
      final sortCompare = left.sortOrder.compareTo(right.sortOrder);
      if (sortCompare != 0) {
        return sortCompare;
      }
      return left.createdAt.compareTo(right.createdAt);
    });
    return elements;
  }

  @override
  Future<NarrativeElement> updateElement({
    required String elementId,
    required String title,
    String? description,
    String? chapterId,
    required String status,
    int? sortOrder,
    required List<String> photoPaths,
  }) async {
    NarrativeElement? targetElement;
    for (final element in _elements) {
      if (element.elementId == elementId) {
        targetElement = element;
        break;
      }
    }
    if (targetElement == null) {
      throw StateError('Narrative element not found: $elementId');
    }

    final projectId = targetElement.owningProjectId;
    final sourceChapterId = targetElement.owningChapterId;
    final targetChapterId = chapterId;
    final movingAcrossBuckets = sourceChapterId != targetChapterId;
    final retainedElements = _elements
        .where((element) => element.elementId != elementId)
        .toList();
    final sourceBucket =
        retainedElements
            .where(
              (element) =>
                  element.owningProjectId == projectId &&
                  element.owningChapterId == sourceChapterId,
            )
            .toList()
          ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final targetBucket = movingAcrossBuckets
        ? (retainedElements
              .where(
                (element) =>
                    element.owningProjectId == projectId &&
                    element.owningChapterId == targetChapterId,
              )
              .toList()
            ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder)))
        : sourceBucket;
    final resolvedSortOrder =
        (sortOrder ??
                (movingAcrossBuckets
                    ? targetBucket.length
                    : targetElement.sortOrder))
            .clamp(0, targetBucket.length);
    if (movingAcrossBuckets) {
      _normalizeBucket(sourceBucket);
    }

    targetElement.title = title.trim();
    final trimmedDescription = description?.trim();
    targetElement.description = trimmedDescription?.isNotEmpty == true
        ? trimmedDescription
        : null;
    targetElement.owningChapterId = targetChapterId;
    targetElement.status = status;
    targetElement.photoPaths = List<String>.from(photoPaths);
    targetElement.updatedAt = DateTime(2026, 1, 5);
    targetBucket.insert(resolvedSortOrder, targetElement);
    _normalizeBucket(targetBucket);
    return targetElement;
  }

  @override
  Future<bool> deleteElement(String elementId) async {
    final targetIndex = _elements.indexWhere(
      (element) => element.elementId == elementId,
    );
    if (targetIndex < 0) {
      return false;
    }

    final deletedElement = _elements.removeAt(targetIndex);
    final remainingBucket = _bucket(
      deletedElement.owningProjectId,
      deletedElement.owningChapterId,
    );
    _normalizeBucket(remainingBucket);
    return true;
  }
}

class _InMemoryBeaconTaskRepository implements BeaconTaskRepository {
  _InMemoryBeaconTaskRepository({List<BeaconTask>? initialTasks})
    : _tasks = List<BeaconTask>.from(initialTasks ?? <BeaconTask>[]);

  final List<BeaconTask> _tasks;

  List<BeaconTask> get tasks => List<BeaconTask>.unmodifiable(_tasks);

  @override
  Future<List<BeaconTask>> listTasksForProject(String projectId) async {
    final tasks = _tasks
        .where((task) => task.owningProjectId == projectId)
        .toList();
    tasks.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return tasks;
  }

  @override
  Future<BeaconTask> createTask({
    required String projectId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  }) async {
    final task = BeaconTask.create(
      id: 'task-${_tasks.length + 1}',
      projectId: projectId,
      taskTitle: title,
      taskDescription: description,
      linkedElementIds: linkedElementIds,
      createdTimestamp: DateTime(2026),
      updatedTimestamp: DateTime(2026),
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<BeaconTask?> updateTask({
    required String taskId,
    required String title,
    required String description,
    required List<String> linkedElementIds,
  }) async {
    for (final task in _tasks) {
      if (task.taskId == taskId) {
        task.title = title.trim();
        task.description = description.trim();
        task.linkedElementIds = List<String>.from(linkedElementIds);
        task.updatedAt = DateTime(2026, 1, 10);
        return task;
      }
    }
    return null;
  }

  @override
  Future<BeaconTask?> archiveTask(String taskId) async {
    for (final task in _tasks) {
      if (task.taskId == taskId) {
        task.statusValue = BeaconTaskStatus.archived;
        task.updatedAt = DateTime(2026, 1, 11);
        return task;
      }
    }
    return null;
  }

  @override
  Future<BeaconTask?> restoreTask(String taskId) async {
    for (final task in _tasks) {
      if (task.taskId == taskId) {
        task.statusValue = BeaconTaskStatus.pending;
        task.updatedAt = DateTime(2026, 1, 12);
        return task;
      }
    }
    return null;
  }

  @override
  Future<bool> deleteTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.taskId == taskId);
    if (index < 0) {
      return false;
    }
    _tasks.removeAt(index);
    return true;
  }
}

class _InMemoryCaptureRecordRepository implements CaptureRecordRepository {
  _InMemoryCaptureRecordRepository({List<CaptureRecord>? initialRecords})
    : _records = List<CaptureRecord>.from(initialRecords ?? <CaptureRecord>[]);

  final List<CaptureRecord> _records;

  @override
  Future<CaptureRecord> createRecord({
    required String projectId,
    required String mode,
    String? rawText,
    required List<String> photoPaths,
  }) async {
    final record = CaptureRecord.create(
      id: 'record-${_records.length + 1}',
      projectId: projectId,
      captureMode: mode,
      captureText: rawText,
      capturedPhotoPaths: photoPaths,
      pendingPhotoPaths: photoPaths,
      createdTimestamp: DateTime(2026),
      updatedTimestamp: DateTime(2026),
    );
    _records.add(record);
    return record;
  }

  @override
  Future<CaptureRecord?> getRecordById(String recordId) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<List<CaptureRecord>> listRecordsForProject(String projectId) async {
    final records = _records
        .where((record) => record.owningProjectId == projectId)
        .toList();
    records.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return records;
  }

  @override
  Future<CaptureRecord?> updatePendingPhotoPaths({
    required String recordId,
    required List<String> pendingPhotoPaths,
  }) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        record.unorganizedPhotoPaths = List<String>.from(pendingPhotoPaths);
        record.updatedAt = DateTime(2026, 1, 9);
        return record;
      }
    }
    return null;
  }

  @override
  Future<CaptureRecord?> updateRecordPhotos({
    required String recordId,
    required List<String> photoPaths,
    required List<String> pendingPhotoPaths,
  }) async {
    for (final record in _records) {
      if (record.recordId == recordId) {
        record.photoPaths = List<String>.from(photoPaths);
        record.unorganizedPhotoPaths = List<String>.from(pendingPhotoPaths);
        record.updatedAt = DateTime(2026, 1, 10);
        return record;
      }
    }
    return null;
  }

  @override
  Future<bool> deleteRecord(String recordId) async {
    final index = _records.indexWhere((record) => record.recordId == recordId);
    if (index < 0) {
      return false;
    }
    _records.removeAt(index);
    return true;
  }
}

class _InMemoryProjectRelationRepository implements ProjectRelationRepository {
  static const String _hiddenRelationTypeName = '__echo_hidden_relation_type__';
  static const String _hiddenRelationTypeDescription =
      '__echo_hidden_relation_type__';

  final Map<String, List<ProjectRelationType>> _typesByProject =
      <String, List<ProjectRelationType>>{};
  final Map<String, List<ProjectRelationGroup>> _groupsByProject =
      <String, List<ProjectRelationGroup>>{};
  final Map<String, List<ProjectRelationMember>> _membersByProject =
      <String, List<ProjectRelationMember>>{};

  Future<void> _ensureDefaults(String projectId) async {
    if ((_typesByProject[projectId] ?? const <ProjectRelationType>[])
        .isNotEmpty) {
      return;
    }

    final now = DateTime(2026, 1, 1);
    _typesByProject[projectId] = defaultProjectRelationDefinitions
        .map(
          (definition) => ProjectRelationType.create(
            id: 'type-$projectId-${definition.sortOrder}',
            projectId: projectId,
            relationName: definition.name,
            relationDescription: definition.description,
            relationSortOrder: definition.sortOrder,
            createdTimestamp: now,
            updatedTimestamp: now,
          ),
        )
        .toList();
  }

  bool _isHiddenRelationType(ProjectRelationType relationType) {
    return relationType.name == _hiddenRelationTypeName &&
        relationType.description == _hiddenRelationTypeDescription;
  }

  ProjectRelationType _buildHiddenRelationType(String projectId) {
    final now = DateTime(2026, 1, 8);
    return ProjectRelationType.create(
      id: 'type-$projectId-hidden',
      projectId: projectId,
      relationName: _hiddenRelationTypeName,
      relationDescription: _hiddenRelationTypeDescription,
      relationSortOrder: -1,
      createdTimestamp: now,
      updatedTimestamp: now,
    );
  }

  @override
  Future<ProjectRelationType> createRelationType({
    required String projectId,
    required String name,
    required String description,
  }) async {
    await _ensureDefaults(projectId);
    final existingTypes = _typesByProject[projectId] ?? <ProjectRelationType>[];
    for (final relationType in existingTypes) {
      if (!_isHiddenRelationType(relationType)) {
        relationType.sortOrder += 1;
      }
    }
    final now = DateTime(2026, 1, 3, existingTypes.length + 1);
    final relationType = ProjectRelationType.create(
      id: 'type-$projectId-${existingTypes.length + 1}',
      projectId: projectId,
      relationName: name,
      relationDescription: description,
      relationSortOrder: 0,
      createdTimestamp: now,
      updatedTimestamp: now,
    );
    existingTypes.add(relationType);
    _typesByProject[projectId] = existingTypes;
    return relationType;
  }

  @override
  Future<ProjectRelationType> updateRelationType({
    required String relationTypeId,
    required String name,
    required String description,
  }) async {
    for (final entry in _typesByProject.entries) {
      for (final relationType in entry.value) {
        if (relationType.relationTypeId == relationTypeId) {
          relationType.name = name.trim();
          relationType.description = description.trim();
          relationType.updatedAt = DateTime(2026, 1, 6);
          return relationType;
        }
      }
    }
    throw StateError('Relation type not found: $relationTypeId');
  }

  @override
  Future<bool> deleteRelationType(String relationTypeId) async {
    String? projectId;
    ProjectRelationType? targetType;
    for (final entry in _typesByProject.entries) {
      for (final relationType in entry.value) {
        if (relationType.relationTypeId == relationTypeId) {
          projectId = entry.key;
          targetType = relationType;
          break;
        }
      }
      if (targetType != null) {
        break;
      }
    }
    if (projectId == null || targetType == null) {
      return false;
    }

    _typesByProject[projectId]!.remove(targetType);
    final hasVisibleTypes = _typesByProject[projectId]!.any(
      (relationType) => !_isHiddenRelationType(relationType),
    );
    final hasHiddenPlaceholder = _typesByProject[projectId]!.any(
      _isHiddenRelationType,
    );
    if (!hasVisibleTypes && !hasHiddenPlaceholder) {
      _typesByProject[projectId]!.add(_buildHiddenRelationType(projectId));
    }
    final relationGroups =
        (_groupsByProject[projectId] ?? <ProjectRelationGroup>[])
            .where((group) => group.linkedRelationTypeId == relationTypeId)
            .toList();
    final groupIds = relationGroups
        .map((group) => group.relationGroupId)
        .toSet();
    _groupsByProject[projectId]?.removeWhere(
      (group) => groupIds.contains(group.relationGroupId),
    );
    _membersByProject[projectId]?.removeWhere(
      (member) => groupIds.contains(member.owningGroupId),
    );
    return true;
  }

  @override
  Future<ProjectRelationGroup> createRelationGroup({
    required String projectId,
    required String relationTypeId,
    String? title,
    String? description,
    required List<ProjectRelationDraftMember> members,
  }) async {
    if (members.length < 2) {
      throw ArgumentError(
        'A relation group must contain at least two selections.',
      );
    }

    await _ensureDefaults(projectId);
    final now = DateTime(2026, 1, 2);
    final relationGroup = ProjectRelationGroup.create(
      id: 'group-${(_groupsByProject[projectId]?.length ?? 0) + 1}',
      projectId: projectId,
      relationTypeId: relationTypeId,
      relationGroupTitle: title?.trim().isNotEmpty == true
          ? title!.trim()
          : null,
      relationGroupDescription: description?.trim().isNotEmpty == true
          ? description!.trim()
          : null,
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    final relationMembers = <ProjectRelationMember>[
      for (var index = 0; index < members.length; index++)
        ProjectRelationMember.create(
          id: 'member-$projectId-${(_membersByProject[projectId]?.length ?? 0) + index + 1}',
          projectId: projectId,
          groupId: relationGroup.relationGroupId,
          targetKind: members[index].kind.name,
          elementId: members[index].elementId,
          photoPath: members[index].photoPath,
          sourceElementId: members[index].sourceElementId,
          sortOrder: index,
          createdTimestamp: now,
        ),
    ];

    _groupsByProject.putIfAbsent(projectId, () => <ProjectRelationGroup>[]);
    _groupsByProject[projectId]!.add(relationGroup);
    _membersByProject.putIfAbsent(projectId, () => <ProjectRelationMember>[]);
    _membersByProject[projectId]!.addAll(relationMembers);
    return relationGroup;
  }

  @override
  Future<ProjectRelationGroup> updateRelationGroup({
    required String relationGroupId,
    String? title,
    String? description,
    required List<ProjectRelationDraftMember> members,
  }) async {
    if (members.length < 2) {
      throw ArgumentError(
        'A relation group must contain at least two selections.',
      );
    }

    for (final entry in _groupsByProject.entries) {
      for (final group in entry.value) {
        if (group.relationGroupId != relationGroupId) {
          continue;
        }

        final now = DateTime(2026, 1, 9);
        group.title = title?.trim().isNotEmpty == true ? title!.trim() : null;
        group.description = description?.trim().isNotEmpty == true
            ? description!.trim()
            : null;
        group.updatedAt = now;

        final rebuiltMembers = <ProjectRelationMember>[
          for (var index = 0; index < members.length; index++)
            ProjectRelationMember.create(
              id: 'member-${entry.key}-$relationGroupId-${index + 1}',
              projectId: entry.key,
              groupId: relationGroupId,
              targetKind: members[index].kind.name,
              elementId: members[index].elementId,
              photoPath: members[index].photoPath,
              sourceElementId: members[index].sourceElementId,
              sortOrder: index,
              createdTimestamp: now,
            ),
        ];
        _membersByProject[entry.key] ??= <ProjectRelationMember>[];
        _membersByProject[entry.key]!.removeWhere(
          (member) => member.owningGroupId == relationGroupId,
        );
        _membersByProject[entry.key]!.addAll(rebuiltMembers);
        return group;
      }
    }

    throw StateError('Relation group not found: $relationGroupId');
  }

  @override
  Future<bool> deleteRelationGroup(String relationGroupId) async {
    for (final entry in _groupsByProject.entries) {
      final targetIndex = entry.value.indexWhere(
        (group) => group.relationGroupId == relationGroupId,
      );
      if (targetIndex < 0) {
        continue;
      }

      entry.value.removeAt(targetIndex);
      _membersByProject[entry.key]?.removeWhere(
        (member) => member.owningGroupId == relationGroupId,
      );
      return true;
    }
    return false;
  }

  @override
  Future<List<ProjectRelationGroup>> listRelationGroupsForProject(
    String projectId,
  ) async {
    await _ensureDefaults(projectId);
    return List<ProjectRelationGroup>.from(
      _groupsByProject[projectId] ?? const [],
    );
  }

  @override
  Future<List<ProjectRelationMember>> listRelationMembersForProject(
    String projectId,
  ) async {
    await _ensureDefaults(projectId);
    return List<ProjectRelationMember>.from(
      _membersByProject[projectId] ?? const [],
    );
  }

  @override
  Future<List<ProjectRelationType>> listRelationTypesForProject(
    String projectId,
  ) async {
    await _ensureDefaults(projectId);
    final relationTypes = List<ProjectRelationType>.from(
      (_typesByProject[projectId] ?? const <ProjectRelationType>[]).where(
        (relationType) => !_isHiddenRelationType(relationType),
      ),
    );
    relationTypes.sort(
      (left, right) => left.sortOrder.compareTo(right.sortOrder),
    );
    return relationTypes;
  }
}

class _CurationInteractionHarness extends StatelessWidget {
  _CurationInteractionHarness()
    : boardData = _curationBoardData(chapterCount: 1);

  _CurationInteractionHarness.large()
    : boardData = _curationBoardData(chapterCount: 18);

  final GlobalArrangeBoardData boardData;

  @override
  Widget build(BuildContext context) {
    return GlobalArrangePage(
      projectTitle: '交互测试项目',
      boardData: boardData,
      onOpenSidebar: () {},
      onBottomTabChanged: (_) {},
      onOpenPendingOrganize: () async {},
      onMoveChapter: ({required chapterId, required targetIndex}) async {},
      onMoveElement:
          ({
            required elementId,
            required targetChapterId,
            required targetIndex,
          }) async {},
      onMovePhoto:
          ({
            required sourceElementId,
            required sourcePhotoIndex,
            required targetElementId,
            required targetPhotoIndex,
          }) async {},
    );
  }
}

GlobalArrangeBoardData _curationBoardData({required int chapterCount}) {
  return GlobalArrangeBoardData(
    chapters: List<GlobalArrangeChapterData>.generate(chapterCount, (
      chapterIndex,
    ) {
      final chapterNumber = chapterIndex + 1;
      return GlobalArrangeChapterData(
        chapterId: 'chapter-$chapterNumber',
        title: '章节 $chapterNumber',
        elements: <GlobalArrangeElementData>[
          GlobalArrangeElementData(
            elementId: 'element-$chapterNumber',
            title: '元素 $chapterNumber',
            relationTags: chapterIndex == 0 ? const <String>['呼应'] : const [],
            photos: <GlobalArrangePhotoData>[
              GlobalArrangePhotoData(
                photoId: chapterIndex == 0
                    ? 'photo-1'
                    : 'chapter-$chapterNumber-photo-1',
                imageSource: '/tmp/photo-$chapterNumber-a.jpg',
                relationTags: chapterIndex == 0
                    ? const <String>['呼应']
                    : const [],
              ),
              if (chapterIndex == 0)
                const GlobalArrangePhotoData(
                  photoId: 'photo-2',
                  imageSource: '/tmp/photo-2.jpg',
                  relationTags: <String>['旁支'],
                ),
            ],
          ),
        ],
      );
    }),
  );
}

ImageProvider<Object> _baseImageProvider(ImageProvider<Object> provider) {
  if (provider is ResizeImage) {
    return provider.imageProvider;
  }
  return provider;
}
