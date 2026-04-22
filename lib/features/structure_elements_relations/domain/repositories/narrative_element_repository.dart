import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';

abstract class NarrativeElementRepository {
  Future<List<NarrativeElement>> listElementsForProject(String projectId);

  Future<NarrativeElement> createElement({
    required String projectId,
    String? chapterId,
    required String title,
    String? description,
    String status = 'finding',
    int? sortOrder,
    List<String>? photoPaths,
  });

  Future<NarrativeElement> updateElement({
    required String elementId,
    required String title,
    String? description,
    String? chapterId,
    required String status,
    int? sortOrder,
    required List<String> photoPaths,
  });

  Future<bool> deleteElement(String elementId);
}
