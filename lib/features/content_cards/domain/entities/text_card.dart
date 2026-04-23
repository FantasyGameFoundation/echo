import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'text_card.g.dart';

@collection
class TextCard {
  TextCard();

  TextCard.create({
    String? id,
    required String projectId,
    String? chapterId,
    String? elementId,
    this.sourceRecordId,
    required this.title,
    required this.body,
    required int cardSortOrder,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : textCardId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       owningChapterId = chapterId,
       owningElementId = elementId,
       sortOrder = cardSortOrder,
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  factory TextCard.fromRawText({
    String? id,
    required String projectId,
    String? chapterId,
    String? elementId,
    String? sourceRecordId,
    required String rawText,
    int? sortOrder,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
    int titleMaxLength = defaultTitleMaxLength,
  }) {
    final normalizedBody = normalizeBody(rawText);
    if (normalizedBody.isEmpty) {
      throw ArgumentError.value(
        rawText,
        'rawText',
        'Text cards require non-empty text after trimming.',
      );
    }

    return TextCard.create(
      id: id,
      projectId: projectId,
      chapterId: chapterId,
      elementId: elementId,
      sourceRecordId: sourceRecordId,
      title: deriveTitle(normalizedBody, maxLength: titleMaxLength),
      body: normalizedBody,
      cardSortOrder: sortOrder ?? 0,
      createdTimestamp: createdTimestamp,
      updatedTimestamp: updatedTimestamp,
    );
  }

  static const int defaultTitleMaxLength = 80;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String textCardId;

  @Index()
  late String owningProjectId;

  @Index()
  String? owningChapterId;

  @Index()
  String? owningElementId;

  @Index()
  String? sourceRecordId;

  late String title;
  late String body;
  late int sortOrder;
  late DateTime createdAt;
  late DateTime updatedAt;

  @ignore
  String? get sourceCaptureRecordId => sourceRecordId;

  set sourceCaptureRecordId(String? value) {
    sourceRecordId = value;
  }

  static bool hasMeaningfulBody(String rawText) {
    return normalizeBody(rawText).isNotEmpty;
  }

  static String normalizeBody(String rawText) {
    return rawText.trim();
  }

  static String deriveTitle(
    String rawText, {
    int maxLength = defaultTitleMaxLength,
  }) {
    final normalizedBody = normalizeBody(rawText);
    if (normalizedBody.isEmpty) {
      return '';
    }

    final firstNonEmptyLine = normalizedBody
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    final collapsedTitle = firstNonEmptyLine.replaceAll(RegExp(r'\s+'), ' ');
    if (collapsedTitle.length <= maxLength) {
      return collapsedTitle;
    }
    if (maxLength <= 3) {
      return collapsedTitle.substring(0, maxLength);
    }

    final truncatedTitle = collapsedTitle
        .substring(0, maxLength - 3)
        .trimRight();
    return '$truncatedTitle...';
  }
}
