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
    'chapter edit page shows delete action and removes chapter while unassigning elements',
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
      expect(find.text('删除后，本章节会从结构中移除，章节内元素将保留并转入未分配章节。'), findsOneWidget);

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
    'completed chapter blocks save until continue editing is tapped',
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

      expect(find.text('章节已完成无法保存，如需编辑请点击右上角继续编辑'), findsOneWidget);
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
    'completed chapter can unlock edit then save later changes as ongoing',
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

      expect(find.text('叙 事 元 素'), findsOneWidget);
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
    'narrative element edit page shows delete action and removes linked relation groups',
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
      expect(find.text('删除后，该元素及其关联关系引用会一并移除，当前页面将返回列表。'), findsOneWidget);

      await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('删 除')),
      );
      await tester.pumpAndSettle();

      final elements = await elementRepository.listElementsForProject(
        'project-element-delete',
      );
      final relationGroups = await relationRepository
          .listRelationGroupsForProject('project-element-delete');

      expect(elements, isEmpty);
      expect(relationGroups, isEmpty);
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

      expect(find.text('叙事元素已完成无法编辑，请点击右上角继续编辑'), findsOneWidget);
      expect(saveCalls, 0);

      await tester.tap(find.byKey(const ValueKey('narrativeCompleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确认更改'), findsOneWidget);
      expect(find.text('元素所属章节已完成，需更改为可编辑'), findsOneWidget);
      await tester.tap(find.text('修改'));
      await tester.pumpAndSettle();

      expect(find.text('叙事元素现可继续编辑'), findsOneWidget);
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
    'completed element inside completed chapter requires confirmation before continue editing',
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

      expect(find.text('确认更改'), findsOneWidget);
      expect(find.text('元素所属章节已完成，需更改为可编辑'), findsOneWidget);

      await tester.tap(find.text('修改'));
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
    'completed narrative element unlocks the newly selected completed chapter when reassigned',
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
      await tester.tap(find.text('修改'));
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
                  required String status,
                  required String? unlockChapterId,
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
    expect(find.text('转折'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('添加关联关系'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('添加关联关系'), findsOneWidget);
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

    expect(find.text('添 加 关 联 关 系'), findsOneWidget);
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
    'relation card opens relation group page and edit button opens relation editor',
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
      expect(find.text('编辑关系'), findsOneWidget);
      expect(find.text('江边水塔 / 旧厂烟囱'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('addRelationGroupButton')),
        findsOneWidget,
      );

      await tester.tap(find.text('编辑关系'));
      await tester.pumpAndSettle();

      expect(find.text('编 辑 关 联 关 系'), findsOneWidget);
      expect(find.text('编辑时不可修改关联类型'), findsOneWidget);

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
        find.text('添 加 关 系 组'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('addRelationGroupButton')),
        findsOneWidget,
      );
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
        find.text('添 加 关 系 组'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('addRelationGroupButton')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationGroupTitleField')),
        findsOneWidget,
      );
      final editorTitleBeforeInput = tester.widget<Text>(
        find.byKey(const ValueKey('relationGroupEditorTitle')),
      );
      expect(editorTitleBeforeInput.data, isEmpty);
      expect(
        find.byKey(const ValueKey('relationGroupAddNodePlaceholder')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('relationGroupAddNodePlaceholder')),
      );
      await tester.pumpAndSettle();

      expect(find.text('选 择 关 联 内 容'), findsOneWidget);
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
          ProjectRelationDraftMember.element(elementId: 'element-fullscreen-a'),
          ProjectRelationDraftMember.element(elementId: 'element-fullscreen-b'),
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
      expect(find.text('1 / 2'), findsOneWidget);

      await tester.fling(
        find.byKey(const ValueKey('relationFullscreenPageView')),
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('风化裂缝'), findsOneWidget);
      expect(find.text('CH.02'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);

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
    'relation edit page shows delete action and removes relation type with linked groups',
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

      await tester.tap(find.text('编辑关系'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('relationTypeDeleteButton')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('relationTypeDeleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('确 认 删 除'), findsOneWidget);
      expect(find.text('删除后，该关系类型及其关联关系集合会一并移除，当前页面将返回列表。'), findsOneWidget);

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
      await tester.tap(find.text('编辑关系'));
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
      expect(find.text('添加关联关系'), findsOneWidget);
    },
  );

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

  @override
  Future<NarrativeElement> createElement({
    required String projectId,
    String? chapterId,
    required String title,
    String? description,
    String status = 'finding',
    List<String>? photoPaths,
  }) async {
    final element = NarrativeElement.create(
      id: 'element-${_elements.length + 1}',
      projectId: projectId,
      chapterId: chapterId,
      elementTitle: title,
      elementDescription: description,
      elementStatus: status,
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

  @override
  Future<NarrativeElement> updateElement({
    required String elementId,
    required String title,
    String? description,
    String? chapterId,
    required String status,
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

    targetElement.title = title.trim();
    final trimmedDescription = description?.trim();
    targetElement.description = trimmedDescription?.isNotEmpty == true
        ? trimmedDescription
        : null;
    targetElement.owningChapterId = chapterId;
    targetElement.status = status;
    targetElement.photoPaths = List<String>.from(photoPaths);
    targetElement.updatedAt = DateTime(2026, 1, 5);
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

    _elements.removeAt(targetIndex);
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
    final nextSortOrder = existingTypes.isEmpty
        ? 0
        : existingTypes
                  .map((relationType) => relationType.sortOrder)
                  .reduce((left, right) => left > right ? left : right) +
              1;
    final now = DateTime(2026, 1, 3, existingTypes.length + 1);
    final relationType = ProjectRelationType.create(
      id: 'type-$projectId-$nextSortOrder',
      projectId: projectId,
      relationName: name,
      relationDescription: description,
      relationSortOrder: nextSortOrder,
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
    return List<ProjectRelationType>.from(
      (_typesByProject[projectId] ?? const <ProjectRelationType>[]).where(
        (relationType) => !_isHiddenRelationType(relationType),
      ),
    );
  }
}

ImageProvider<Object> _baseImageProvider(ImageProvider<Object> provider) {
  if (provider is ResizeImage) {
    return provider.imageProvider;
  }
  return provider;
}
