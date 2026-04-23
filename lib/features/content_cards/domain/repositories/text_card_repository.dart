import 'package:echo/features/content_cards/domain/entities/text_card.dart';

abstract class TextCardRepository {
  Future<TextCard> createTextCard({
    required String projectId,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    required String title,
    required String body,
    int? sortOrder,
  });

  Future<TextCard> createCard({
    required String projectId,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    required String rawText,
    int? sortOrder,
  });

  Future<TextCard?> getTextCardById(String textCardId);

  Future<TextCard?> getCardById(String textCardId);

  Future<List<TextCard>> listTextCardsForProject(String projectId);

  Future<List<TextCard>> listCardsForProject(String projectId);

  Future<List<TextCard>> listTextCardsForSourceRecord(String sourceRecordId);

  Future<List<TextCard>> listCardsForSourceRecord(String sourceRecordId);

  Future<TextCard?> updateTextCard({
    required String textCardId,
    required String title,
    required String body,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    int? sortOrder,
  });
}
