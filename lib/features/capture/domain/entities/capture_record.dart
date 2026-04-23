import 'package:echo/features/capture/domain/models/capture_mode.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'capture_record.g.dart';

@collection
class CaptureRecord {
  CaptureRecord();

  CaptureRecord.create({
    String? id,
    required String projectId,
    required String captureMode,
    String? captureText,
    List<String>? capturedPhotoPaths,
    List<String>? pendingPhotoPaths,
    DateTime? createdTimestamp,
    DateTime? updatedTimestamp,
  }) : recordId = id ?? const Uuid().v4(),
       owningProjectId = projectId,
       mode = captureMode,
       rawText = captureText ?? '',
       photoPaths = capturedPhotoPaths ?? <String>[],
       unorganizedPhotoPaths =
           pendingPhotoPaths ?? capturedPhotoPaths ?? <String>[],
       createdAt = createdTimestamp ?? DateTime.now(),
       updatedAt = updatedTimestamp ?? DateTime.now();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String recordId;

  @Index()
  late String owningProjectId;

  @Index()
  late String mode;

  String rawText = '';
  List<String> photoPaths = <String>[];
  List<String> unorganizedPhotoPaths = <String>[];
  late DateTime createdAt;
  late DateTime updatedAt;

  @ignore
  CaptureMode get captureModeValue => CaptureModeX.fromStorageValue(mode);

  set captureModeValue(CaptureMode value) {
    mode = value.storageValue;
  }
}
