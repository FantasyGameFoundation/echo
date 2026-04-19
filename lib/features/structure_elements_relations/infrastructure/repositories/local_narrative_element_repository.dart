import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:echo/features/structure_elements_relations/domain/entities/narrative_element.dart';
import 'package:echo/features/structure_elements_relations/domain/repositories/narrative_element_repository.dart';
import 'package:isar/isar.dart';

class LocalNarrativeElementRepository implements NarrativeElementRepository {
  LocalNarrativeElementRepository({Future<Isar> Function()? openIsar})
    : _openIsar = openIsar ?? openProjectIsar;

  final Future<Isar> Function() _openIsar;
  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar();
  }

  @override
  Future<List<NarrativeElement>> listElementsForProject(
    String projectId,
  ) async {
    final database = await _database();
    final elements = await database.narrativeElements
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    elements.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return elements;
  }

  @override
  Future<NarrativeElement> createElement({
    required String projectId,
    String? chapterId,
    required String title,
    String? description,
    String status = 'finding',
    List<String>? photoPaths,
  }) async {
    final database = await _database();
    final now = DateTime.now();
    final element = NarrativeElement.create(
      projectId: projectId,
      chapterId: chapterId,
      elementTitle: title.trim(),
      elementDescription: description?.trim(),
      elementStatus: status,
      linkedPhotoPaths: photoPaths,
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      await database.narrativeElements.put(element);
    });

    return element;
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
    final database = await _database();
    final element = await database.narrativeElements
        .filter()
        .elementIdEqualTo(elementId)
        .findFirst();
    if (element == null) {
      throw StateError('Narrative element not found: $elementId');
    }

    element.title = title.trim();
    final trimmedDescription = description?.trim();
    element.description = trimmedDescription?.isNotEmpty == true
        ? trimmedDescription
        : null;
    element.owningChapterId = chapterId;
    element.status = status;
    element.photoPaths = List<String>.from(photoPaths);
    element.updatedAt = DateTime.now();

    await database.writeTxn(() async {
      await database.narrativeElements.put(element);
    });

    return element;
  }
}
