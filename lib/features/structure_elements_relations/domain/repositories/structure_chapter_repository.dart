import 'package:echo/features/structure_elements_relations/domain/entities/structure_chapter.dart';

abstract class StructureChapterRepository {
  Future<List<StructureChapter>> listChaptersForProject(String projectId);

  Future<StructureChapter> createChapter({
    required String projectId,
    required String title,
    String? description,
    required int sortOrder,
  });

  Future<StructureChapter?> updateChapter({
    required String chapterId,
    required String title,
    String? description,
    required int sortOrder,
    required String statusLabel,
  });

  Future<bool> deleteChapter(String chapterId);
}
