// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narrative_element.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNarrativeElementCollection on Isar {
  IsarCollection<NarrativeElement> get narrativeElements => this.collection();
}

const NarrativeElementSchema = CollectionSchema(
  name: r'NarrativeElement',
  id: 1819911946439001999,
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
    r'elementId': PropertySchema(
      id: 2,
      name: r'elementId',
      type: IsarType.string,
    ),
    r'owningChapterId': PropertySchema(
      id: 3,
      name: r'owningChapterId',
      type: IsarType.string,
    ),
    r'owningProjectId': PropertySchema(
      id: 4,
      name: r'owningProjectId',
      type: IsarType.string,
    ),
    r'photoPaths': PropertySchema(
      id: 5,
      name: r'photoPaths',
      type: IsarType.stringList,
    ),
    r'sortOrder': PropertySchema(
      id: 6,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'status': PropertySchema(id: 7, name: r'status', type: IsarType.string),
    r'title': PropertySchema(id: 8, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _narrativeElementEstimateSize,
  serialize: _narrativeElementSerialize,
  deserialize: _narrativeElementDeserialize,
  deserializeProp: _narrativeElementDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'elementId': IndexSchema(
      id: 4987470561970176603,
      name: r'elementId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'elementId',
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
    r'owningChapterId': IndexSchema(
      id: 7259123930917318183,
      name: r'owningChapterId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'owningChapterId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _narrativeElementGetId,
  getLinks: _narrativeElementGetLinks,
  attach: _narrativeElementAttach,
  version: '3.1.0+1',
);

int _narrativeElementEstimateSize(
  NarrativeElement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.elementId.length * 3;
  {
    final value = object.owningChapterId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.owningProjectId.length * 3;
  bytesCount += 3 + object.photoPaths.length * 3;
  {
    for (var i = 0; i < object.photoPaths.length; i++) {
      final value = object.photoPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _narrativeElementSerialize(
  NarrativeElement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.elementId);
  writer.writeString(offsets[3], object.owningChapterId);
  writer.writeString(offsets[4], object.owningProjectId);
  writer.writeStringList(offsets[5], object.photoPaths);
  writer.writeLong(offsets[6], object.sortOrder);
  writer.writeString(offsets[7], object.status);
  writer.writeString(offsets[8], object.title);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

NarrativeElement _narrativeElementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NarrativeElement();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.description = reader.readStringOrNull(offsets[1]);
  object.elementId = reader.readString(offsets[2]);
  object.isarId = id;
  object.owningChapterId = reader.readStringOrNull(offsets[3]);
  object.owningProjectId = reader.readString(offsets[4]);
  object.photoPaths = reader.readStringList(offsets[5]) ?? [];
  object.sortOrder = reader.readLong(offsets[6]);
  object.status = reader.readString(offsets[7]);
  object.title = reader.readString(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _narrativeElementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _narrativeElementGetId(NarrativeElement object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _narrativeElementGetLinks(NarrativeElement object) {
  return [];
}

void _narrativeElementAttach(
  IsarCollection<dynamic> col,
  Id id,
  NarrativeElement object,
) {
  object.isarId = id;
}

extension NarrativeElementByIndex on IsarCollection<NarrativeElement> {
  Future<NarrativeElement?> getByElementId(String elementId) {
    return getByIndex(r'elementId', [elementId]);
  }

  NarrativeElement? getByElementIdSync(String elementId) {
    return getByIndexSync(r'elementId', [elementId]);
  }

  Future<bool> deleteByElementId(String elementId) {
    return deleteByIndex(r'elementId', [elementId]);
  }

  bool deleteByElementIdSync(String elementId) {
    return deleteByIndexSync(r'elementId', [elementId]);
  }

  Future<List<NarrativeElement?>> getAllByElementId(
    List<String> elementIdValues,
  ) {
    final values = elementIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'elementId', values);
  }

  List<NarrativeElement?> getAllByElementIdSync(List<String> elementIdValues) {
    final values = elementIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'elementId', values);
  }

  Future<int> deleteAllByElementId(List<String> elementIdValues) {
    final values = elementIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'elementId', values);
  }

  int deleteAllByElementIdSync(List<String> elementIdValues) {
    final values = elementIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'elementId', values);
  }

  Future<Id> putByElementId(NarrativeElement object) {
    return putByIndex(r'elementId', object);
  }

  Id putByElementIdSync(NarrativeElement object, {bool saveLinks = true}) {
    return putByIndexSync(r'elementId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByElementId(List<NarrativeElement> objects) {
    return putAllByIndex(r'elementId', objects);
  }

  List<Id> putAllByElementIdSync(
    List<NarrativeElement> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'elementId', objects, saveLinks: saveLinks);
  }
}

extension NarrativeElementQueryWhereSort
    on QueryBuilder<NarrativeElement, NarrativeElement, QWhere> {
  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NarrativeElementQueryWhere
    on QueryBuilder<NarrativeElement, NarrativeElement, QWhereClause> {
  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
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

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  elementIdEqualTo(String elementId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'elementId', value: [elementId]),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  elementIdNotEqualTo(String elementId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'elementId',
                lower: [],
                upper: [elementId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'elementId',
                lower: [elementId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'elementId',
                lower: [elementId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'elementId',
                lower: [],
                upper: [elementId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  owningProjectIdEqualTo(String owningProjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'owningProjectId',
          value: [owningProjectId],
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  owningProjectIdNotEqualTo(String owningProjectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningProjectId',
                lower: [],
                upper: [owningProjectId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningProjectId',
                lower: [owningProjectId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningProjectId',
                lower: [owningProjectId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningProjectId',
                lower: [],
                upper: [owningProjectId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  owningChapterIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'owningChapterId', value: [null]),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  owningChapterIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'owningChapterId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  owningChapterIdEqualTo(String? owningChapterId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'owningChapterId',
          value: [owningChapterId],
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterWhereClause>
  owningChapterIdNotEqualTo(String? owningChapterId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningChapterId',
                lower: [],
                upper: [owningChapterId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningChapterId',
                lower: [owningChapterId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningChapterId',
                lower: [owningChapterId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'owningChapterId',
                lower: [],
                upper: [owningChapterId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension NarrativeElementQueryFilter
    on QueryBuilder<NarrativeElement, NarrativeElement, QFilterCondition> {
  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'elementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'elementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'elementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'elementId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'elementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'elementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'elementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'elementId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'elementId', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  elementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'elementId', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'owningChapterId'),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'owningChapterId'),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'owningChapterId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'owningChapterId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'owningChapterId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'owningChapterId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'owningChapterId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'owningChapterId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'owningChapterId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'owningChapterId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'owningChapterId', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningChapterIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'owningChapterId', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'owningProjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'owningProjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'owningProjectId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'owningProjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'owningProjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'owningProjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'owningProjectId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'owningProjectId', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  owningProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'owningProjectId', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'photoPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'photoPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'photoPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'photoPaths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'photoPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'photoPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'photoPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'photoPaths',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoPaths', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoPaths', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoPaths', length, true, length, true);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoPaths', 0, true, 0, true);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoPaths', 0, false, 999999, true);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoPaths', 0, true, length, include);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoPaths', length, include, 999999, true);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  photoPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  sortOrderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  sortOrderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NarrativeElementQueryObject
    on QueryBuilder<NarrativeElement, NarrativeElement, QFilterCondition> {}

extension NarrativeElementQueryLinks
    on QueryBuilder<NarrativeElement, NarrativeElement, QFilterCondition> {}

extension NarrativeElementQuerySortBy
    on QueryBuilder<NarrativeElement, NarrativeElement, QSortBy> {
  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elementId', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elementId', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByOwningChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByOwningChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NarrativeElementQuerySortThenBy
    on QueryBuilder<NarrativeElement, NarrativeElement, QSortThenBy> {
  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elementId', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elementId', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByOwningChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByOwningChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NarrativeElementQueryWhereDistinct
    on QueryBuilder<NarrativeElement, NarrativeElement, QDistinct> {
  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctByElementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elementId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctByOwningChapterId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'owningChapterId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctByOwningProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'owningProjectId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctByPhotoPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPaths');
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NarrativeElement, NarrativeElement, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension NarrativeElementQueryProperty
    on QueryBuilder<NarrativeElement, NarrativeElement, QQueryProperty> {
  QueryBuilder<NarrativeElement, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<NarrativeElement, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<NarrativeElement, String?, QQueryOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<NarrativeElement, String, QQueryOperations> elementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elementId');
    });
  }

  QueryBuilder<NarrativeElement, String?, QQueryOperations>
  owningChapterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningChapterId');
    });
  }

  QueryBuilder<NarrativeElement, String, QQueryOperations>
  owningProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningProjectId');
    });
  }

  QueryBuilder<NarrativeElement, List<String>, QQueryOperations>
  photoPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPaths');
    });
  }

  QueryBuilder<NarrativeElement, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<NarrativeElement, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<NarrativeElement, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<NarrativeElement, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
