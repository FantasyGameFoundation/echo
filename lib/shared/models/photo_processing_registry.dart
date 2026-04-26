import 'package:echo/shared/models/processing_photo_ref.dart';
import 'package:flutter/foundation.dart';

class PhotoProcessingRegistry extends ChangeNotifier {
  final Map<String, ProcessingPhotoRef> _refs = <String, ProcessingPhotoRef>{};

  List<ProcessingPhotoRef> get refs =>
      List<ProcessingPhotoRef>.unmodifiable(_refs.values);

  void upsert(ProcessingPhotoRef ref) {
    _refs[ref.id] = ref;
    notifyListeners();
  }

  void remove(String refId) {
    if (_refs.remove(refId) != null) {
      notifyListeners();
    }
  }

  void removeContext(String contextId) {
    final before = _refs.length;
    _refs.removeWhere((_, ref) => ref.contextId == contextId);
    if (_refs.length != before) {
      notifyListeners();
    }
  }

  bool hasBlockingWorkForContext(String contextId) {
    return _refs.values.any(
      (ref) => ref.contextId == contextId && ref.isProcessing,
    );
  }
}
