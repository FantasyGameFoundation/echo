import 'dart:io';

import 'package:echo/app/app.dart';
import 'package:echo/features/project/domain/entities/project.dart';
import 'package:echo/features/project/domain/repositories/project_repository.dart';
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
import 'package:echo/features/structure_elements_relations/presentation/widgets/chapter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'restart app, add narrative element photo, and keep thumbnail after source deletion',
    (tester) async {
      await _setPhoneSurface(binding);
      final photoFixture = await _PhotoFixture.create();
      addTearDown(photoFixture.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          chapterRepository: _MutableStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-seeded',
                projectId: 'project-seeded',
                chapterTitle: 'test1',
                chapterDescription: '测试章节',
                chapterStatus: '进行',
                chapterElementCount: 0,
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026),
                updatedTimestamp: DateTime(2026),
              ),
            ],
          ),
          narrativeRepository: _MutableNarrativeElementRepository(),
          relationRepository: _MutableProjectRelationRepository(),
          photoPicker: () async => <String>[photoFixture.sourceFile.path],
          photoImporter: photoFixture.importIntoAppMedia,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '集成测试叙事元素',
      );
      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementDescriptionField')),
        '验证照片复制后仍可显示',
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(photoFixture.copiedFile?.existsSync(), isTrue);
      expect(photoFixture.sourceFile.existsSync(), isFalse);

      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      expect(find.text('集成测试叙事元素'), findsOneWidget);
      expect(find.text('验证照片复制后仍可显示'), findsOneWidget);

      final imageWidget = tester.widget<Image>(find.byType(Image).first);
      expect(_baseImageProvider(imageWidget.image), isA<FileImage>());

      await _captureScreenshot(
        binding: binding,
        name: 'narrative-element-photo-flow',
      );
    },
  );

  testWidgets(
    'creating a chapter from the chapter page defaults its status to ongoing',
    (tester) async {
      await _setPhoneSurface(binding);

      final chapterRepository = _MutableStructureChapterRepository();

      await tester.pumpWidget(
        _buildTestApp(
          chapterRepository: chapterRepository,
          narrativeRepository: _MutableNarrativeElementRepository(),
          relationRepository: _MutableProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('添加章节'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateTitleField')),
        '新章节状态测试',
      );
      await tester.enterText(
        find.byKey(const ValueKey('chapterCreateDescriptionField')),
        '验证章节默认状态',
      );
      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      final createdChapterCard = find.ancestor(
        of: find.text('新章节状态测试'),
        matching: find.byType(ChapterCard),
      );

      expect(createdChapterCard, findsOneWidget);
      expect(
        find.descendant(of: createdChapterCard, matching: find.text('进行')),
        findsOneWidget,
      );
      expect(find.text('草稿'), findsNothing);
    },
  );

  testWidgets(
    'adding an element from the narrative page associates it to the selected chapter, keeps chapter order, and shows chapter preview photo',
    (tester) async {
      await _setPhoneSurface(binding);
      final photoFixture = await _PhotoFixture.create(
        fileName: 'chapter-link.png',
      );
      addTearDown(photoFixture.dispose);

      final chapterRepository = _MutableStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-a',
            projectId: 'project-seeded',
            chapterTitle: '第一章',
            chapterDescription: '第一章说明',
            chapterStatus: '进行',
            chapterElementCount: 1,
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026, 1, 1),
            updatedTimestamp: DateTime(2026, 1, 1),
          ),
          StructureChapter.create(
            id: 'chapter-b',
            projectId: 'project-seeded',
            chapterTitle: '第二章',
            chapterDescription: '第二章说明',
            chapterStatus: '进行',
            chapterElementCount: 1,
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026, 1, 2),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
        ],
      );
      final narrativeRepository = _MutableNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-b-old',
            projectId: 'project-seeded',
            chapterId: 'chapter-b',
            elementTitle: '第二章旧元素',
            elementDescription: '较早创建',
            linkedPhotoPaths: <String>[],
            createdTimestamp: DateTime(2026, 1, 1),
            updatedTimestamp: DateTime(2026, 1, 1),
          ),
          NarrativeElement.create(
            id: 'element-a-old',
            projectId: 'project-seeded',
            chapterId: 'chapter-a',
            elementTitle: '第一章旧元素',
            elementDescription: '较晚创建',
            linkedPhotoPaths: <String>[],
            createdTimestamp: DateTime(2026, 1, 2),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
        ],
      );

      await tester.pumpWidget(
        _buildTestApp(
          chapterRepository: chapterRepository,
          narrativeRepository: narrativeRepository,
          relationRepository: _MutableProjectRelationRepository(),
          photoPicker: () async => <String>[photoFixture.sourceFile.path],
          photoImporter: photoFixture.importIntoAppMedia,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('叙事元素'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('添加叙事元素'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('C H A P T E R   02'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementNameField')),
        '第二章新增元素',
      );
      await tester.enterText(
        find.byKey(const ValueKey('narrativeElementDescriptionField')),
        '需要回写章节摘要',
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保 存'));
      await tester.pumpAndSettle();

      final firstHeader = tester.getTopLeft(
        find.text('C H A P T E R  01  /  第一章'),
      );
      final secondHeader = tester.getTopLeft(
        find.text('C H A P T E R  02  /  第二章'),
      );
      expect(firstHeader.dy, lessThan(secondHeader.dy));

      await tester.tap(find.text('章节骨架'));
      await tester.pumpAndSettle();

      final secondChapterCard = find.ancestor(
        of: find.text('第二章'),
        matching: find.byType(ChapterCard),
      );
      expect(secondChapterCard, findsOneWidget);
      expect(
        find.descendant(of: secondChapterCard, matching: find.text('2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: secondChapterCard, matching: find.byType(Image)),
        findsOneWidget,
      );

      await _captureScreenshot(
        binding: binding,
        name: 'chapter-element-association-flow',
      );
    },
  );

  testWidgets(
    'chapter cards use description-only for no-photo chapters and reference-style strips for 1, 2, and 3+ latest photos',
    (tester) async {
      await _setPhoneSurface(binding);

      await tester.pumpWidget(
        _buildTestApp(
          chapterRepository: _MutableStructureChapterRepository(
            initialChapters: <StructureChapter>[
              StructureChapter.create(
                id: 'chapter-none',
                projectId: 'project-seeded',
                chapterTitle: '无图章节',
                chapterDescription: '没有任何照片时显示这段说明',
                chapterStatus: '进行',
                chapterSortOrder: 0,
                createdTimestamp: DateTime(2026, 1, 1),
                updatedTimestamp: DateTime(2026, 1, 1),
              ),
              StructureChapter.create(
                id: 'chapter-one',
                projectId: 'project-seeded',
                chapterTitle: '单图章节',
                chapterDescription: '有图时不应显示这段说明',
                chapterStatus: '进行',
                chapterSortOrder: 1,
                createdTimestamp: DateTime(2026, 1, 2),
                updatedTimestamp: DateTime(2026, 1, 2),
              ),
              StructureChapter.create(
                id: 'chapter-two',
                projectId: 'project-seeded',
                chapterTitle: '双图章节',
                chapterDescription: '有图时不应显示这段说明',
                chapterStatus: '进行',
                chapterSortOrder: 2,
                createdTimestamp: DateTime(2026, 1, 3),
                updatedTimestamp: DateTime(2026, 1, 3),
              ),
              StructureChapter.create(
                id: 'chapter-overflow',
                projectId: 'project-seeded',
                chapterTitle: '溢出章节',
                chapterDescription: '有图时不应显示这段说明',
                chapterStatus: '进行',
                chapterSortOrder: 3,
                createdTimestamp: DateTime(2026, 1, 4),
                updatedTimestamp: DateTime(2026, 1, 4),
              ),
            ],
          ),
          narrativeRepository: _MutableNarrativeElementRepository(
            initialElements: <NarrativeElement>[
              NarrativeElement.create(
                id: 'element-one',
                projectId: 'project-seeded',
                chapterId: 'chapter-one',
                elementTitle: '单图元素',
                linkedPhotoPaths: <String>['/tmp/photo-one.png'],
                createdTimestamp: DateTime(2026, 2, 1),
                updatedTimestamp: DateTime(2026, 2, 1),
              ),
              NarrativeElement.create(
                id: 'element-two',
                projectId: 'project-seeded',
                chapterId: 'chapter-two',
                elementTitle: '双图元素',
                linkedPhotoPaths: <String>[
                  '/tmp/photo-two-a.png',
                  '/tmp/photo-two-b.png',
                ],
                createdTimestamp: DateTime(2026, 2, 2),
                updatedTimestamp: DateTime(2026, 2, 2),
              ),
              NarrativeElement.create(
                id: 'element-overflow-old',
                projectId: 'project-seeded',
                chapterId: 'chapter-overflow',
                elementTitle: '旧照片元素',
                linkedPhotoPaths: <String>['/tmp/photo-old.png'],
                createdTimestamp: DateTime(2026, 2, 3),
                updatedTimestamp: DateTime(2026, 2, 3),
              ),
              NarrativeElement.create(
                id: 'element-overflow-new',
                projectId: 'project-seeded',
                chapterId: 'chapter-overflow',
                elementTitle: '新照片元素',
                linkedPhotoPaths: <String>[
                  '/tmp/photo-new-a.png',
                  '/tmp/photo-new-b.png',
                ],
                createdTimestamp: DateTime(2026, 2, 4),
                updatedTimestamp: DateTime(2026, 2, 4),
              ),
            ],
          ),
          relationRepository: _MutableProjectRelationRepository(),
        ),
      );
      await tester.pumpAndSettle();

      final noPhotoCard = find.ancestor(
        of: find.text('无图章节'),
        matching: find.byType(ChapterCard),
      );
      expect(
        find.descendant(of: noPhotoCard, matching: find.text('没有任何照片时显示这段说明')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: noPhotoCard, matching: find.byType(Image)),
        findsNothing,
      );

      final onePhotoCard = find.ancestor(
        of: find.text('单图章节'),
        matching: find.byType(ChapterCard),
      );
      expect(
        find.descendant(
          of: onePhotoCard,
          matching: find.byKey(
            const ValueKey('chapterPreviewImage-/tmp/photo-one.png'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: onePhotoCard, matching: find.text('有图时不应显示这段说明')),
        findsNothing,
      );
      expect(
        find.descendant(of: onePhotoCard, matching: find.byType(Image)),
        findsOneWidget,
      );

      final twoPhotoCard = find.ancestor(
        of: find.text('双图章节'),
        matching: find.byType(ChapterCard),
      );
      expect(
        find.descendant(
          of: twoPhotoCard,
          matching: find.byKey(
            const ValueKey('chapterPreviewImage-/tmp/photo-two-b.png'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: twoPhotoCard,
          matching: find.byKey(
            const ValueKey('chapterPreviewImage-/tmp/photo-two-a.png'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: twoPhotoCard,
          matching: find.byKey(const ValueKey('chapterPreviewOverflow-+1')),
        ),
        findsNothing,
      );

      await tester.scrollUntilVisible(
        find.text('溢出章节'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final overflowCard = find.ancestor(
        of: find.text('溢出章节'),
        matching: find.byType(ChapterCard),
      );
      expect(
        find.descendant(
          of: overflowCard,
          matching: find.byKey(
            const ValueKey('chapterPreviewImage-/tmp/photo-new-b.png'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: overflowCard,
          matching: find.byKey(
            const ValueKey('chapterPreviewImage-/tmp/photo-new-a.png'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: overflowCard,
          matching: find.byKey(
            const ValueKey('chapterPreviewImage-/tmp/photo-old.png'),
          ),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: overflowCard,
          matching: find.byKey(const ValueKey('chapterPreviewOverflow-+1')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: overflowCard, matching: find.text('有图时不应显示这段说明')),
        findsNothing,
      );

      await _captureScreenshot(
        binding: binding,
        name: 'chapter-card-photo-style-flow',
      );
    },
  );

  testWidgets(
    'new projects show real relation types and add page saves a new relation type',
    (tester) async {
      await _setPhoneSurface(binding);

      final relationRepository = _MutableProjectRelationRepository();
      final chapterRepository = _MutableStructureChapterRepository(
        initialChapters: <StructureChapter>[
          StructureChapter.create(
            id: 'chapter-a',
            projectId: 'project-seeded',
            chapterTitle: '第一章',
            chapterDescription: '第一章说明',
            chapterStatus: '进行',
            chapterSortOrder: 0,
            createdTimestamp: DateTime(2026, 1, 1),
            updatedTimestamp: DateTime(2026, 1, 1),
          ),
          StructureChapter.create(
            id: 'chapter-b',
            projectId: 'project-seeded',
            chapterTitle: '第二章',
            chapterDescription: '第二章说明',
            chapterStatus: '进行',
            chapterSortOrder: 1,
            createdTimestamp: DateTime(2026, 1, 2),
            updatedTimestamp: DateTime(2026, 1, 2),
          ),
        ],
      );
      final narrativeRepository = _MutableNarrativeElementRepository(
        initialElements: <NarrativeElement>[
          NarrativeElement.create(
            id: 'element-a',
            projectId: 'project-seeded',
            chapterId: 'chapter-a',
            elementTitle: '第一章元素',
            linkedPhotoPaths: <String>[
              '/tmp/relation-photo-a1.png',
              '/tmp/relation-photo-a2.png',
            ],
            createdTimestamp: DateTime(2026, 3, 1),
            updatedTimestamp: DateTime(2026, 3, 1),
          ),
          NarrativeElement.create(
            id: 'element-b',
            projectId: 'project-seeded',
            chapterId: 'chapter-b',
            elementTitle: '第二章元素',
            linkedPhotoPaths: <String>[
              '/tmp/relation-photo-b1.png',
              '/tmp/relation-photo-b2.png',
            ],
            createdTimestamp: DateTime(2026, 3, 2),
            updatedTimestamp: DateTime(2026, 3, 2),
          ),
        ],
      );

      await tester.pumpWidget(
        _buildTestApp(
          chapterRepository: chapterRepository,
          narrativeRepository: narrativeRepository,
          relationRepository: relationRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('关联关系'));
      await tester.pumpAndSettle();

      expect(find.text('对比'), findsOneWidget);
      expect(find.text('重复'), findsOneWidget);
      expect(find.text('呼应'), findsOneWidget);
      expect(find.text('转折'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('添加关联关系'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('添加关联关系'));
      await tester.pumpAndSettle();

      expect(find.text('添 加 关 联 关 系'), findsOneWidget);

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

      expect(relationRepository.groupsForProject('project-seeded'), isEmpty);
      expect(
        (await relationRepository.listRelationTypesForProject(
          'project-seeded',
        )).length,
        5,
      );
      expect(find.text('时空并置'), findsOneWidget);
      expect(find.text('对比'), findsOneWidget);
      expect(find.text('重复'), findsOneWidget);
      expect(find.text('呼应'), findsOneWidget);

      await _captureScreenshot(
        binding: binding,
        name: 'project-relation-real-flow',
      );
    },
  );
}

EchoApp _buildTestApp({
  required _MutableStructureChapterRepository chapterRepository,
  required _MutableNarrativeElementRepository narrativeRepository,
  required _MutableProjectRelationRepository relationRepository,
  Future<List<String>> Function()? photoPicker,
  Future<String> Function(String sourcePath)? photoImporter,
}) {
  return EchoApp(
    projectRepository: _SeededProjectRepository(),
    structureChapterRepository: chapterRepository,
    narrativeElementRepository: narrativeRepository,
    projectRelationRepository: relationRepository,
    narrativeElementPhotoPicker: photoPicker,
    narrativeElementPhotoImporter: photoImporter,
  );
}

Future<void> _setPhoneSurface(
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  await binding.setSurfaceSize(const Size(393, 852));
}

Future<void> _captureScreenshot({
  required IntegrationTestWidgetsFlutterBinding binding,
  required String name,
}) async {
  final screenshotBytes = await binding.takeScreenshot(name);
  final screenshotFile = File('${Directory.systemTemp.path}/$name.png');
  await screenshotFile.writeAsBytes(screenshotBytes, flush: true);
  debugPrint('SCREENSHOT_PATH=${screenshotFile.path}');
}

class _PhotoFixture {
  _PhotoFixture._({
    required this.rootDirectory,
    required this.sourceFile,
    required this.appMediaDirectory,
  });

  final Directory rootDirectory;
  final File sourceFile;
  final Directory appMediaDirectory;
  File? copiedFile;

  static Future<_PhotoFixture> create({
    String fileName = 'source-photo.png',
  }) async {
    final rootDirectory = await Directory.systemTemp.createTemp(
      'echo-photo-flow-',
    );
    final sourceFile = File('${rootDirectory.path}/$fileName');
    await sourceFile.writeAsBytes(_tinyPngBytes, flush: true);

    final appMediaDirectory = Directory(
      '${rootDirectory.path}/app-media/narrative_elements',
    );
    await appMediaDirectory.create(recursive: true);

    return _PhotoFixture._(
      rootDirectory: rootDirectory,
      sourceFile: sourceFile,
      appMediaDirectory: appMediaDirectory,
    );
  }

  Future<String> importIntoAppMedia(String sourcePath) async {
    final copiedFile = await File(
      sourcePath,
    ).copy('${appMediaDirectory.path}/copied-photo.png');
    this.copiedFile = copiedFile;
    await sourceFile.delete();
    return copiedFile.path;
  }

  Future<void> dispose() async {
    if (rootDirectory.existsSync()) {
      await rootDirectory.delete(recursive: true);
    }
  }
}

class _SeededProjectRepository implements ProjectRepository {
  final Project _project = Project.create(
    id: 'project-seeded',
    projectTitle: 'test',
    projectThemeStatement: '集成测试项目',
    createdTimestamp: DateTime(2026),
    updatedTimestamp: DateTime(2026),
  );

  @override
  Future<Project> createProject({
    required String title,
    required String themeStatement,
    String? description,
    String? coverImagePath,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProject(String projectId) async {
    throw UnimplementedError();
  }

  @override
  Future<Project?> getCurrentProject() async => _project;

  @override
  Future<List<Project>> listProjects() async => <Project>[_project];

  @override
  Future<Project?> archiveProject(String projectId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setCurrentProject(String projectId) async {}

  @override
  Future<Project?> updateProject({
    required String projectId,
    required String title,
    required String themeStatement,
    String? coverImagePath,
  }) async {
    throw UnimplementedError();
  }
}

class _MutableStructureChapterRepository implements StructureChapterRepository {
  _MutableStructureChapterRepository({List<StructureChapter>? initialChapters})
    : _chapters = List<StructureChapter>.from(
        initialChapters ?? <StructureChapter>[],
      );

  final List<StructureChapter> _chapters;

  @override
  Future<StructureChapter> createChapter({
    required String projectId,
    required String title,
    String? description,
    required int sortOrder,
  }) async {
    final chapter = StructureChapter.create(
      id: 'chapter-${_chapters.length + 1}',
      projectId: projectId,
      chapterTitle: title,
      chapterDescription: description,
      chapterSortOrder: sortOrder,
      createdTimestamp: DateTime(2026, 2, 1),
      updatedTimestamp: DateTime(2026, 2, 1),
    );
    _chapters.add(chapter);
    return chapter;
  }

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
        chapter.updatedAt = DateTime(2026, 2, 2, index + 1);
      }
    }

    return targetChapter;
  }

  @override
  Future<bool> deleteChapter(String chapterId) async {
    final beforeCount = _chapters.length;
    _chapters.removeWhere((chapter) => chapter.chapterId == chapterId);
    return _chapters.length != beforeCount;
  }
}

class _MutableNarrativeElementRepository implements NarrativeElementRepository {
  _MutableNarrativeElementRepository({List<NarrativeElement>? initialElements})
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
      createdTimestamp: DateTime(2026, 3, 1, 12),
      updatedTimestamp: DateTime(2026, 3, 1, 12),
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
    elements.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return elements;
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
    targetElement.updatedAt = DateTime(2026, 3, 2, 12);
    return targetElement;
  }

  @override
  Future<bool> deleteElement(String elementId) async {
    final beforeCount = _elements.length;
    _elements.removeWhere((element) => element.elementId == elementId);
    return _elements.length != beforeCount;
  }
}

class _MutableProjectRelationRepository implements ProjectRelationRepository {
  final Map<String, List<ProjectRelationType>> _typesByProject =
      <String, List<ProjectRelationType>>{};
  final Map<String, List<ProjectRelationGroup>> _groupsByProject =
      <String, List<ProjectRelationGroup>>{};
  final Map<String, List<ProjectRelationMember>> _membersByProject =
      <String, List<ProjectRelationMember>>{};

  List<ProjectRelationGroup> groupsForProject(String projectId) {
    return List<ProjectRelationGroup>.from(
      _groupsByProject[projectId] ?? const [],
    );
  }

  Future<void> _ensureDefaults(String projectId) async {
    if ((_typesByProject[projectId] ?? const <ProjectRelationType>[])
        .isNotEmpty) {
      return;
    }

    final now = DateTime(2026, 4, 1);
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
    final now = DateTime(2026, 4, 3, existingTypes.length + 1);
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
          relationType.updatedAt = DateTime(2026, 4, 4);
          return relationType;
        }
      }
    }
    throw StateError('Relation type not found: $relationTypeId');
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

    final now = DateTime(
      2026,
      4,
      2,
      (_groupsByProject[projectId]?.length ?? 0) + 1,
    );
    final relationGroup = ProjectRelationGroup.create(
      id: 'group-${(_groupsByProject[projectId]?.length ?? 0) + 1}',
      projectId: projectId,
      relationTypeId: relationTypeId,
      relationGroupTitle: title,
      relationGroupDescription: description,
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
    for (final entry in _groupsByProject.entries) {
      for (final group in entry.value) {
        if (group.relationGroupId != relationGroupId) {
          continue;
        }
        final now = DateTime(2026, 4, 5);
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
  Future<bool> deleteRelationType(String relationTypeId) async {
    for (final entry in _typesByProject.entries) {
      final beforeCount = entry.value.length;
      entry.value.removeWhere(
        (relationType) => relationType.relationTypeId == relationTypeId,
      );
      if (entry.value.length == beforeCount) {
        continue;
      }

      final groups = _groupsByProject[entry.key] ?? <ProjectRelationGroup>[];
      final removedGroupIds = groups
          .where((group) => group.linkedRelationTypeId == relationTypeId)
          .map((group) => group.relationGroupId)
          .toSet();
      groups.removeWhere(
        (group) => removedGroupIds.contains(group.relationGroupId),
      );
      _membersByProject[entry.key]?.removeWhere(
        (member) => removedGroupIds.contains(member.owningGroupId),
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteRelationGroup(String relationGroupId) async {
    for (final entry in _groupsByProject.entries) {
      final beforeCount = entry.value.length;
      entry.value.removeWhere(
        (group) => group.relationGroupId == relationGroupId,
      );
      if (entry.value.length == beforeCount) {
        continue;
      }
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
      _typesByProject[projectId] ?? const [],
    );
  }
}

ImageProvider<Object> _baseImageProvider(ImageProvider<Object> provider) {
  if (provider is ResizeImage) {
    return provider.imageProvider;
  }
  return provider;
}

const List<int> _tinyPngBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0xF0,
  0x1F,
  0x00,
  0x05,
  0x00,
  0x01,
  0xFF,
  0x89,
  0x99,
  0x3D,
  0x1D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
