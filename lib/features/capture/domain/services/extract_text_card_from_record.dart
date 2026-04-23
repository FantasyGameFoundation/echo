import 'package:echo/features/capture/domain/repositories/capture_record_repository.dart';
import 'package:echo/features/capture/domain/services/text_card_extraction_gateway.dart';
import 'package:echo/features/content_cards/domain/entities/text_card.dart';
import 'package:echo/features/content_cards/domain/repositories/text_card_repository.dart';

class ExtractTextCardFromRecord implements TextCardExtractionGateway {
  const ExtractTextCardFromRecord({
    required this.captureRecordRepository,
    required this.textCardRepository,
  });

  final CaptureRecordRepository captureRecordRepository;
  final TextCardRepository textCardRepository;

  @override
  Future<TextCard> extractTextCard({
    required String recordId,
    String? titleOverride,
    String? bodyOverride,
  }) async {
    final record = await captureRecordRepository.getRecordById(recordId);
    if (record == null) {
      throw StateError('Capture record not found: $recordId');
    }

    final candidateBody = (bodyOverride ?? record.rawText).trim();
    if (candidateBody.isEmpty) {
      throw StateError('Cannot extract a text card from an empty record.');
    }

    final resolvedTitle =
        (titleOverride?.trim().isNotEmpty == true
                ? titleOverride!.trim()
                : TextCard.deriveTitle(candidateBody))
            .replaceAll(RegExp(r'\s+'), ' ');

    return textCardRepository.createTextCard(
      projectId: record.owningProjectId,
      chapterId: null,
      elementId: null,
      sourceRecordId: record.recordId,
      title: resolvedTitle,
      body: candidateBody,
    );
  }
}
