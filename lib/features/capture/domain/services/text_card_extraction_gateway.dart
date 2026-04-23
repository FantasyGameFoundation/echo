import 'package:echo/features/content_cards/domain/entities/text_card.dart';

abstract class TextCardExtractionGateway {
  Future<TextCard> extractTextCard({
    required String recordId,
    String? titleOverride,
    String? bodyOverride,
  });
}
