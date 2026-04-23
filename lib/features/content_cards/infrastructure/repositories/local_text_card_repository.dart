import 'package:echo/features/content_cards/domain/entities/text_card.dart';
import 'package:echo/features/content_cards/domain/repositories/text_card_repository.dart';
import 'package:echo/features/project/infrastructure/database/project_isar.dart';
import 'package:isar/isar.dart';

class LocalTextCardRepository implements TextCardRepository {
  LocalTextCardRepository({Future<Isar> Function()? openIsar})
    : _openIsar = openIsar ?? openProjectIsar;

  final Future<Isar> Function() _openIsar;
  Future<Isar>? _isarFuture;

  Future<Isar> _database() {
    return _isarFuture ??= _openIsar();
  }

  Future<int> _nextSortOrder(String projectId, String? chapterId) async {
    final database = await _database();
    final cards = await database.textCards
        .filter()
        .owningProjectIdEqualTo(projectId)
        .findAll();
    final matching = cards
        .where((card) => card.owningChapterId == chapterId)
        .toList(growable: false);
    if (matching.isEmpty) {
      return 0;
    }
    final maxSort = matching
        .map((card) => card.sortOrder)
        .reduce((left, right) => left > right ? left : right);
    return maxSort + 1;
  }

  @override
  Future<TextCard> createTextCard({
    required String projectId,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    required String title,
    required String body,
    int? sortOrder,
  }) async {
    final database = await _database();
    final now = DateTime.now();
    final normalizedBody = TextCard.normalizeBody(body);
    if (normalizedBody.isEmpty) {
      throw ArgumentError.value(
        body,
        'body',
        'Text cards require non-empty text after trimming.',
      );
    }
    final card = TextCard.create(
      projectId: projectId.trim(),
      chapterId: chapterId,
      elementId: elementId,
      sourceRecordId: sourceRecordId,
      title: title.trim(),
      body: normalizedBody,
      cardSortOrder:
          sortOrder ?? await _nextSortOrder(projectId.trim(), chapterId),
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      await database.textCards.put(card);
    });
    return card;
  }

  @override
  Future<TextCard?> getTextCardById(String textCardId) async {
    final database = await _database();
    return database.textCards
        .filter()
        .textCardIdEqualTo(textCardId)
        .findFirst();
  }

  @override
  Future<List<TextCard>> listTextCardsForProject(String projectId) async {
    final database = await _database();
    final cards = await database.textCards
        .filter()
        .owningProjectIdEqualTo(projectId.trim())
        .findAll();
    cards.sort((left, right) {
      final chapterCompare = (left.owningChapterId ?? '').compareTo(
        right.owningChapterId ?? '',
      );
      if (chapterCompare != 0) {
        return chapterCompare;
      }
      final sortCompare = left.sortOrder.compareTo(right.sortOrder);
      if (sortCompare != 0) {
        return sortCompare;
      }
      return left.createdAt.compareTo(right.createdAt);
    });
    return cards;
  }

  @override
  Future<TextCard> createCard({
    required String projectId,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    required String rawText,
    int? sortOrder,
  }) async {
    final database = await _database();
    final now = DateTime.now();
    final trimmedProjectId = projectId.trim();
    final card = TextCard.fromRawText(
      projectId: trimmedProjectId,
      chapterId: chapterId,
      elementId: elementId,
      sourceRecordId: sourceRecordId,
      rawText: rawText,
      sortOrder: sortOrder ?? await _nextSortOrder(trimmedProjectId, chapterId),
      createdTimestamp: now,
      updatedTimestamp: now,
    );

    await database.writeTxn(() async {
      await database.textCards.put(card);
    });

    return card;
  }

  @override
  Future<TextCard?> getCardById(String textCardId) {
    return getTextCardById(textCardId);
  }

  @override
  Future<List<TextCard>> listCardsForProject(String projectId) {
    return listTextCardsForProject(projectId);
  }

  @override
  Future<List<TextCard>> listTextCardsForSourceRecord(
    String sourceRecordId,
  ) async {
    final database = await _database();
    final cards = await database.textCards
        .filter()
        .sourceRecordIdEqualTo(sourceRecordId)
        .findAll();
    cards.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return cards;
  }

  @override
  Future<List<TextCard>> listCardsForSourceRecord(String sourceRecordId) {
    return listTextCardsForSourceRecord(sourceRecordId);
  }

  @override
  Future<TextCard?> updateTextCard({
    required String textCardId,
    required String title,
    required String body,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    int? sortOrder,
  }) async {
    final database = await _database();
    final card = await database.textCards
        .filter()
        .textCardIdEqualTo(textCardId)
        .findFirst();
    if (card == null) {
      return null;
    }
    final normalizedBody = TextCard.normalizeBody(body);
    if (normalizedBody.isEmpty) {
      throw ArgumentError.value(
        body,
        'body',
        'Text cards require non-empty text after trimming.',
      );
    }

    card.title = title.trim();
    card.body = normalizedBody;
    card.owningChapterId = chapterId;
    card.owningElementId = elementId;
    card.sourceRecordId = sourceRecordId;
    if (sortOrder != null) {
      card.sortOrder = sortOrder;
    }
    card.updatedAt = DateTime.now();

    await database.writeTxn(() async {
      await database.textCards.put(card);
    });
    return card;
  }
}
