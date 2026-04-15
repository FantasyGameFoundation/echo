import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/structure_chapter_repository.dart';
import 'package:isar/isar.dart';

class LocalStructureChapterRepository implements StructureChapterRepository {
  LocalStructureChapterRepository({Future<Isar> Function()? openIsar})
    : _openIsar = openIsar ?? openProjectIsar;

  final Future<Isar> Function() _openIsar;
  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar();
  }

  @override
  Future<List<StructureChapter>> listChaptersForProject(
    String projectId,
  ) async {
    final database = await _database();
    final chapters = await database.structureChapters
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
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
    final database = await _database();
    final existingChapters = await database.structureChapters
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();

    existingChapters.sort(
      (left, right) => left.sortOrder.compareTo(right.sortOrder),
    );
    for (final chapter in existingChapters) {
      if (chapter.sortOrder >= sortOrder) {
        chapter.sortOrder += 1;
      }
    }

    final now = DateTime.now();
    final chapter = StructureChapter.create(
      projectId: projectId,
      chapterTitle: title.trim(),
      chapterDescription: description?.trim(),
      chapterSortOrder: sortOrder,
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      await database.structureChapters.putAll(existingChapters);
      await database.structureChapters.put(chapter);
    });

    return chapter;
  }
}
