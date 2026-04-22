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

  int _compareElements(NarrativeElement left, NarrativeElement right) {
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
  }

  List<NarrativeElement> _bucketElements(
    Iterable<NarrativeElement> elements,
    String? chapterId,
  ) {
    final bucket = elements
        .where((element) => element.owningChapterId == chapterId)
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

  void _normalizeBucket(List<NarrativeElement> elements) {
    for (var index = 0; index < elements.length; index++) {
      elements[index].sortOrder = index;
    }
  }

  Future<void> _ensureElementSortOrders(String projectId) async {
    final database = await _database();
    final elements = await database.narrativeElements
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    if (elements.length < 2) {
      if (elements.length == 1 && elements.single.sortOrder != 0) {
        elements.single.sortOrder = 0;
        await database.writeTxn(() async {
          await database.narrativeElements.put(elements.single);
        });
      }
      return;
    }

    final groupedElements = <String?, List<NarrativeElement>>{};
    for (final element in elements) {
      groupedElements.putIfAbsent(
        element.owningChapterId,
        () => <NarrativeElement>[],
      );
      groupedElements[element.owningChapterId]!.add(element);
    }

    var changed = false;
    for (final bucket in groupedElements.values) {
      final orders = bucket.map((element) => element.sortOrder).toList();
      final uniqueSequential =
          orders.toSet().length == orders.length &&
          (orders.toList()..sort()).asMap().entries.every(
            (entry) => entry.value == entry.key,
          );
      if (uniqueSequential) {
        continue;
      }

      bucket.sort((left, right) => left.createdAt.compareTo(right.createdAt));
      for (var index = 0; index < bucket.length; index++) {
        if (bucket[index].sortOrder != index) {
          bucket[index].sortOrder = index;
          changed = true;
        }
      }
    }

    if (!changed) {
      return;
    }

    await database.writeTxn(() async {
      await database.narrativeElements.putAll(elements);
    });
  }

  @override
  Future<List<NarrativeElement>> listElementsForProject(
    String projectId,
  ) async {
    await _ensureElementSortOrders(projectId);
    final database = await _database();
    final elements = await database.narrativeElements
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    elements.sort(_compareElements);
    return elements;
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
    final database = await _database();
    await _ensureElementSortOrders(projectId);
    final projectElements = await database.narrativeElements
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    final targetBucket = _bucketElements(projectElements, chapterId);
    final resolvedSortOrder = (sortOrder ?? targetBucket.length).clamp(
      0,
      targetBucket.length,
    );
    for (var index = resolvedSortOrder; index < targetBucket.length; index++) {
      targetBucket[index].sortOrder += 1;
    }
    final now = DateTime.now();
    final element = NarrativeElement.create(
      projectId: projectId,
      chapterId: chapterId,
      elementTitle: title.trim(),
      elementDescription: description?.trim(),
      elementStatus: status,
      elementSortOrder: resolvedSortOrder,
      linkedPhotoPaths: photoPaths,
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      if (targetBucket.isNotEmpty) {
        await database.narrativeElements.putAll(targetBucket);
      }
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
    int? sortOrder,
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

    await _ensureElementSortOrders(element.owningProjectId);
    final projectElements = await database.narrativeElements
        .filter()
        .owningProjectIdEqualTo(element.owningProjectId)
        .findAll();
    final previousChapterId = element.owningChapterId;
    final targetChapterId = chapterId;
    final movingAcrossBuckets = previousChapterId != targetChapterId;
    final retainedElements = projectElements
        .where((currentElement) => currentElement.elementId != elementId)
        .toList();
    final sourceBucket = _bucketElements(retainedElements, previousChapterId);
    final targetBucket = movingAcrossBuckets
        ? _bucketElements(retainedElements, targetChapterId)
        : sourceBucket;
    final insertionIndex =
        (sortOrder ??
                (movingAcrossBuckets ? targetBucket.length : element.sortOrder))
            .clamp(0, targetBucket.length);

    if (movingAcrossBuckets) {
      _normalizeBucket(sourceBucket);
    }

    element.title = title.trim();
    final trimmedDescription = description?.trim();
    element.description = trimmedDescription?.isNotEmpty == true
        ? trimmedDescription
        : null;
    element.owningChapterId = targetChapterId;
    element.status = status;
    element.photoPaths = List<String>.from(photoPaths);
    element.updatedAt = DateTime.now();

    targetBucket.insert(insertionIndex, element);
    _normalizeBucket(targetBucket);
    final affectedElements = <NarrativeElement>{
      ...sourceBucket,
      ...targetBucket,
    }.toList();

    await database.writeTxn(() async {
      await database.narrativeElements.putAll(affectedElements);
    });

    return element;
  }

  @override
  Future<bool> deleteElement(String elementId) async {
    final database = await _database();
    final element = await database.narrativeElements
        .filter()
        .elementIdEqualTo(elementId)
        .findFirst();
    if (element == null) {
      return false;
    }

    await database.writeTxn(() async {
      await database.narrativeElements.delete(element.isarId);
    });

    return true;
  }
}
