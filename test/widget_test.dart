import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:echo/app/app.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/project/infrastructure/repositories/local_project_repository.dart';
import 'package:echo/features/project/presentation/pages/project_edit_page.dart';
import 'package:echo/features/project/presentation/pages/project_wizard_page.dart';
import 'package:echo/features/project/presentation/widgets/project_sidebar.dart';
import 'package:echo/features/beacon/presentation/pages/beacon_page_prototype.dart';
import 'package:echo/features/curation/presentation/pages/organize_page_prototype.dart';
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
import 'package:echo/features/structure_elements_relations/presentation/widgets/narrative_list_tile.dart';
import 'package:echo/features/timeline/presentation/pages/timeline_page_prototype.dart';
import 'package:echo/shared/models/prototype_tab.dart';
import 'package:echo/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
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
      ),
    );

    expect(find.text('新 建 项 目'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byType(CustomBottomNavBar), findsNothing);
    expect(find.text('章节骨架'), findsNothing);
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

  testWidgets('add button opens overlay and close button dismisses it', (
    tester,
  ) async {
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
    expect(find.text('在此输入文字速记...'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('保 存 记 录'), findsNothing);
  });

  testWidgets('sidebar opens and new project entry launches wizard', (
    tester,
  ) async {
    await tester.pumpWidget(
      EchoApp(
        projectRepository: _InMemoryProjectRepository(),
        structureChapterRepository: _InMemoryStructureChapterRepository(),
        narrativeElementRepository: _InMemoryNarrativeElementRepository(),
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
      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      expect(find.text('章节内元素'), findsOneWidget);

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
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();

      expect(find.text('江边的空酒瓶'), findsOneWidget);
      expect(find.text('真实叙事元素说明'), findsOneWidget);

      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();

      expect(find.text('叙 事 元 素'), findsOneWidget);
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
              images: <String>['/tmp/echo/media/narrative/photo-1.jpg'],
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
              images: <String>['https://example.com/photo-1.jpg'],
            ),
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image).first);

      expect(_baseImageProvider(imageWidget.image), isA<NetworkImage>());
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
    'narrative element create page uses centered save button and returns entered data',
    (tester) async {
      String? savedTitle;
      String? savedDescription;
      String? savedChapterId;
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
                  required List<String> photoPaths,
                }) async {
                  savedTitle = title;
                  savedDescription = description;
                  savedChapterId = chapterId;
                  savedPhotos = photoPaths;
                },
            onPickPhoto: () async => null,
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
        find.byKey(const ValueKey('narrativeElementNameField')),
        '新的叙事元素',
      );
      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementDescriptionField')),
        '新的叙事元素说明',
      );
      await tester.tap(find.text('保 存'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(savedTitle, '新的叙事元素');
      expect(savedDescription, '新的叙事元素说明');
      expect(savedChapterId, 'chapter-a');
      expect(savedPhotos, isEmpty);
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
                  required List<String> photoPaths,
                }) async {
                  savedPhotos = photoPaths;
                },
            onPickPhoto: () async => '/Users/demo/Pictures/source-photo.jpg',
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
      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      expect(savedPhotos, <String>['/app/media/narrative/copied-photo.jpg']);
      expect(
        savedPhotos,
        isNot(contains('/Users/demo/Pictures/source-photo.jpg')),
      );
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
                  required List<String> photoPaths,
                }) async {},
            onPickPhoto: () async => '/tmp/fake-photo.jpg',
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
                  required List<String> photoPaths,
                }) async {},
            onPickPhoto: () async => null,
          ),
        ),
      );

      expect(find.text('请先添加章节'), findsOneWidget);
      expect(find.text('暂 无 可 选 章 节'), findsNothing);
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
            onOpenSidebar: _noop,
            onAddChapter: _noop,
            onAddElement: _noop,
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

  testWidgets('organize page keeps core curation markers after extraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OrganizePagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('关联关系'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('关联章节'), findsOneWidget);
    expect(find.textContaining('关联元素'), findsOneWidget);
    expect(find.textContaining('关联关系'), findsOneWidget);
  });

  testWidgets('timeline page keeps core markers after extraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelinePagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('照片'), findsOneWidget);
    expect(find.text('手记'), findsOneWidget);
  });

  testWidgets('beacon page keeps core markers after extraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BeaconPagePrototype(
          onOpenSidebar: _noop,
          onBottomTabChanged: _noopPrototypeTab,
        ),
      ),
    );

    expect(find.text('待执行'), findsOneWidget);
    expect(find.text('已归档'), findsOneWidget);
    expect(find.text('执 行 模 式'), findsOneWidget);
  });
}

void _noop() {}

void _noopTab(int _) {}

void _noopPrototypeTab(PrototypeTab _) {}

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
}

class _InMemoryNarrativeElementRepository
    implements NarrativeElementRepository {
  _InMemoryNarrativeElementRepository({List<NarrativeElement>? initialElements})
    : _elements = List<NarrativeElement>.from(
        initialElements ?? <NarrativeElement>[],
      );

  final List<NarrativeElement> _elements;

  @override
  Future<NarrativeElement> createElement({
    required String projectId,
    String? chapterId,
    required String title,
    String? description,
    List<String>? photoPaths,
  }) async {
    final element = NarrativeElement.create(
      id: 'element-${_elements.length + 1}',
      projectId: projectId,
      chapterId: chapterId,
      elementTitle: title,
      elementDescription: description,
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
    return _elements
        .where((element) => element.owningProjectId == projectId)
        .toList();
  }
}

ImageProvider<Object> _baseImageProvider(ImageProvider<Object> provider) {
  if (provider is ResizeImage) {
    return provider.imageProvider;
  }
  return provider;
}
