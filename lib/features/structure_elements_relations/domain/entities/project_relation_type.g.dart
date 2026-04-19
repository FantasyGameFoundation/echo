// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_relation_type.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectRelationTypeCollection on Isar {
  IsarCollection<ProjectRelationType> get projectRelationTypes =>
      this.collection();
}

const ProjectRelationTypeSchema = CollectionSchema(
  name: r'ProjectRelationType',
  id: -5901830523203264637,
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
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'owningProjectId': PropertySchema(
      id: 3,
      name: r'owningProjectId',
      type: IsarType.string,
    ),
    r'relationTypeId': PropertySchema(
      id: 4,
      name: r'relationTypeId',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 5,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _projectRelationTypeEstimateSize,
  serialize: _projectRelationTypeSerialize,
  deserialize: _projectRelationTypeDeserialize,
  deserializeProp: _projectRelationTypeDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'relationTypeId': IndexSchema(
      id: -4939906505146300982,
      name: r'relationTypeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'relationTypeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _projectRelationTypeGetId,
  getLinks: _projectRelationTypeGetLinks,
  attach: _projectRelationTypeAttach,
  version: '3.1.0+1',
);

int _projectRelationTypeEstimateSize(
  ProjectRelationType object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.owningProjectId.length * 3;
  bytesCount += 3 + object.relationTypeId.length * 3;
  return bytesCount;
}

void _projectRelationTypeSerialize(
  ProjectRelationType object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.owningProjectId);
  writer.writeString(offsets[4], object.relationTypeId);
  writer.writeLong(offsets[5], object.sortOrder);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

ProjectRelationType _projectRelationTypeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectRelationType();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.isarId = id;
  object.name = reader.readString(offsets[2]);
  object.owningProjectId = reader.readString(offsets[3]);
  object.relationTypeId = reader.readString(offsets[4]);
  object.sortOrder = reader.readLong(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _projectRelationTypeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectRelationTypeGetId(ProjectRelationType object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _projectRelationTypeGetLinks(
    ProjectRelationType object) {
  return [];
}

void _projectRelationTypeAttach(
    IsarCollection<dynamic> col, Id id, ProjectRelationType object) {
  object.isarId = id;
}

extension ProjectRelationTypeByIndex on IsarCollection<ProjectRelationType> {
  Future<ProjectRelationType?> getByRelationTypeId(String relationTypeId) {
    return getByIndex(r'relationTypeId', [relationTypeId]);
  }

  ProjectRelationType? getByRelationTypeIdSync(String relationTypeId) {
    return getByIndexSync(r'relationTypeId', [relationTypeId]);
  }

  Future<bool> deleteByRelationTypeId(String relationTypeId) {
    return deleteByIndex(r'relationTypeId', [relationTypeId]);
  }

  bool deleteByRelationTypeIdSync(String relationTypeId) {
    return deleteByIndexSync(r'relationTypeId', [relationTypeId]);
  }

  Future<List<ProjectRelationType?>> getAllByRelationTypeId(
      List<String> relationTypeIdValues) {
    final values = relationTypeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'relationTypeId', values);
  }

  List<ProjectRelationType?> getAllByRelationTypeIdSync(
      List<String> relationTypeIdValues) {
    final values = relationTypeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'relationTypeId', values);
  }

  Future<int> deleteAllByRelationTypeId(List<String> relationTypeIdValues) {
    final values = relationTypeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'relationTypeId', values);
  }

  int deleteAllByRelationTypeIdSync(List<String> relationTypeIdValues) {
    final values = relationTypeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'relationTypeId', values);
  }

  Future<Id> putByRelationTypeId(ProjectRelationType object) {
    return putByIndex(r'relationTypeId', object);
  }

  Id putByRelationTypeIdSync(ProjectRelationType object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'relationTypeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRelationTypeId(List<ProjectRelationType> objects) {
    return putAllByIndex(r'relationTypeId', objects);
  }

  List<Id> putAllByRelationTypeIdSync(List<ProjectRelationType> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'relationTypeId', objects, saveLinks: saveLinks);
  }
}

extension ProjectRelationTypeQueryWhereSort
    on QueryBuilder<ProjectRelationType, ProjectRelationType, QWhere> {
  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectRelationTypeQueryWhere
    on QueryBuilder<ProjectRelationType, ProjectRelationType, QWhereClause> {
  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      relationTypeIdEqualTo(String relationTypeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'relationTypeId',
        value: [relationTypeId],
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      relationTypeIdNotEqualTo(String relationTypeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationTypeId',
              lower: [],
              upper: [relationTypeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationTypeId',
              lower: [relationTypeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationTypeId',
              lower: [relationTypeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'relationTypeId',
              lower: [],
              upper: [relationTypeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      owningProjectIdEqualTo(String owningProjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'owningProjectId',
        value: [owningProjectId],
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterWhereClause>
      owningProjectIdNotEqualTo(String owningProjectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [],
              upper: [owningProjectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [owningProjectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [owningProjectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'owningProjectId',
              lower: [],
              upper: [owningProjectId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProjectRelationTypeQueryFilter on QueryBuilder<ProjectRelationType,
    ProjectRelationType, QFilterCondition> {
  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'owningProjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'owningProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'owningProjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owningProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      owningProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'owningProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationTypeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationTypeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationTypeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationTypeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      relationTypeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationTypeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProjectRelationTypeQueryObject on QueryBuilder<ProjectRelationType,
    ProjectRelationType, QFilterCondition> {}

extension ProjectRelationTypeQueryLinks on QueryBuilder<ProjectRelationType,
    ProjectRelationType, QFilterCondition> {}

extension ProjectRelationTypeQuerySortBy
    on QueryBuilder<ProjectRelationType, ProjectRelationType, QSortBy> {
  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByRelationTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationTypeId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByRelationTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationTypeId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProjectRelationTypeQuerySortThenBy
    on QueryBuilder<ProjectRelationType, ProjectRelationType, QSortThenBy> {
  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByRelationTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationTypeId', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByRelationTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationTypeId', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProjectRelationTypeQueryWhereDistinct
    on QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct> {
  QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct>
      distinctByOwningProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'owningProjectId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct>
      distinctByRelationTypeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationTypeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct>
      distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<ProjectRelationType, ProjectRelationType, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ProjectRelationTypeQueryProperty
    on QueryBuilder<ProjectRelationType, ProjectRelationType, QQueryProperty> {
  QueryBuilder<ProjectRelationType, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ProjectRelationType, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProjectRelationType, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<ProjectRelationType, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ProjectRelationType, String, QQueryOperations>
      owningProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningProjectId');
    });
  }

  QueryBuilder<ProjectRelationType, String, QQueryOperations>
      relationTypeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationTypeId');
    });
  }

  QueryBuilder<ProjectRelationType, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<ProjectRelationType, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
