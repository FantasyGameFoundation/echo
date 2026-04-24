// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beacon_task.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBeaconTaskCollection on Isar {
  IsarCollection<BeaconTask> get beaconTasks => this.collection();
}

const BeaconTaskSchema = CollectionSchema(
  name: r'BeaconTask',
  id: -5558700412993255369,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'linkedElementIds': PropertySchema(
      id: 2,
      name: r'linkedElementIds',
      type: IsarType.stringList,
    ),
    r'owningProjectId': PropertySchema(
      id: 3,
      name: r'owningProjectId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 4,
      name: r'status',
      type: IsarType.string,
    ),
    r'taskId': PropertySchema(
      id: 5,
      name: r'taskId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 6,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _beaconTaskEstimateSize,
  serialize: _beaconTaskSerialize,
  deserialize: _beaconTaskDeserialize,
  deserializeProp: _beaconTaskDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'taskId': IndexSchema(
      id: -6391211041487498726,
      name: r'taskId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'owningProjectId': IndexSchema(
      id: 8853439974620037944,
      name: r'owningProjectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'owningProjectId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _beaconTaskGetId,
  getLinks: _beaconTaskGetLinks,
  attach: _beaconTaskAttach,
  version: '3.1.0+1',
);

int _beaconTaskEstimateSize(
  BeaconTask object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  final description = object.description;
  if (description != null) {
    bytesCount += 3 + description.length * 3;
  }
  bytesCount += 3 + object.linkedElementIds.length * 3;
  for (var index = 0; index < object.linkedElementIds.length; index++) {
    final value = object.linkedElementIds[index];
    bytesCount += value.length * 3;
  }
  bytesCount += 3 + object.owningProjectId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.taskId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _beaconTaskSerialize(
  BeaconTask object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.description);
  writer.writeStringList(offsets[2], object.linkedElementIds);
  writer.writeString(offsets[3], object.owningProjectId);
  writer.writeString(offsets[4], object.status);
  writer.writeString(offsets[5], object.taskId);
  writer.writeString(offsets[6], object.title);
  writer.writeDateTime(offsets[7], object.updatedAt);
}

BeaconTask _beaconTaskDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BeaconTask();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.description = reader.readStringOrNull(offsets[1]);
  object.isarId = id;
  object.linkedElementIds = reader.readStringList(offsets[2]) ?? <String>[];
  object.owningProjectId = reader.readString(offsets[3]);
  object.status = reader.readString(offsets[4]);
  object.taskId = reader.readString(offsets[5]);
  object.title = reader.readString(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  return object;
}

P _beaconTaskDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return reader.readDateTime(offset) as P;
    case 1:
      return reader.readStringOrNull(offset) as P;
    case 2:
      return (reader.readStringList(offset) ?? <String>[]) as P;
    case 3:
      return reader.readString(offset) as P;
    case 4:
      return reader.readString(offset) as P;
    case 5:
      return reader.readString(offset) as P;
    case 6:
      return reader.readString(offset) as P;
    case 7:
      return reader.readDateTime(offset) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _beaconTaskGetId(BeaconTask object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _beaconTaskGetLinks(BeaconTask object) {
  return <IsarLinkBase<dynamic>>[];
}

void _beaconTaskAttach(IsarCollection<dynamic> col, Id id, BeaconTask object) {
  object.isarId = id;
}

extension BeaconTaskQueryFilter
    on QueryBuilder<BeaconTask, BeaconTask, QFilterCondition> {
  QueryBuilder<BeaconTask, BeaconTask, QAfterFilterCondition>
      owningProjectIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'owningProjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeaconTask, BeaconTask, QAfterFilterCondition> taskIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'taskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeaconTask, BeaconTask, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }
}
