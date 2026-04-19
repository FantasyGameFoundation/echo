import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';

abstract class NarrativeElementRepository {
  Future<List<NarrativeElement>> listElementsForProject(String projectId);

  Future<NarrativeElement> createElement({
    required String projectId,
    String? chapterId,
    required String title,
    String? description,
    String status = 'finding',
    List<String>? photoPaths,
  });

  Future<NarrativeElement> updateElement({
    required String elementId,
    required String title,
    String? description,
    String? chapterId,
    required String status,
    required List<String> photoPaths,
  });

  Future<bool> deleteElement(String elementId);
}
