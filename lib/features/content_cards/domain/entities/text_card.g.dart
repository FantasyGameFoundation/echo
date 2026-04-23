// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_card.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTextCardCollection on Isar {
  IsarCollection<TextCard> get textCards => this.collection();
}

const TextCardSchema = CollectionSchema(
  name: r'TextCard',
  id: 3148929390008386118,
  properties: {
    r'body': PropertySchema(id: 0, name: r'body', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'owningChapterId': PropertySchema(
      id: 2,
      name: r'owningChapterId',
      type: IsarType.string,
    ),
    r'owningProjectId': PropertySchema(
      id: 3,
      name: r'owningProjectId',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 4,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'sourceRecordId': PropertySchema(
      id: 5,
      name: r'sourceRecordId',
      type: IsarType.string,
    ),
    r'textCardId': PropertySchema(
      id: 6,
      name: r'textCardId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 7, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _textCardEstimateSize,
  serialize: _textCardSerialize,
  deserialize: _textCardDeserialize,
  deserializeProp: _textCardDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'textCardId': IndexSchema(
      id: 6655308093478825315,
      name: r'textCardId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'textCardId',
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
    r'sourceRecordId': IndexSchema(
      id: 7553221645504061090,
      name: r'sourceRecordId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceRecordId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _textCardGetId,
  getLinks: _textCardGetLinks,
  attach: _textCardAttach,
  version: '3.1.0+1',
);

int _textCardEstimateSize(
  TextCard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.body.length * 3;
  {
    final value = object.owningChapterId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.owningProjectId.length * 3;
  {
    final value = object.sourceRecordId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.textCardId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _textCardSerialize(
  TextCard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.body);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.owningChapterId);
  writer.writeString(offsets[3], object.owningProjectId);
  writer.writeLong(offsets[4], object.sortOrder);
  writer.writeString(offsets[5], object.sourceRecordId);
  writer.writeString(offsets[6], object.textCardId);
  writer.writeString(offsets[7], object.title);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

TextCard _textCardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TextCard();
  object.body = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.isarId = id;
  object.owningChapterId = reader.readStringOrNull(offsets[2]);
  object.owningProjectId = reader.readString(offsets[3]);
  object.sortOrder = reader.readLong(offsets[4]);
  object.sourceRecordId = reader.readStringOrNull(offsets[5]);
  object.textCardId = reader.readString(offsets[6]);
  object.title = reader.readString(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _textCardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _textCardGetId(TextCard object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _textCardGetLinks(TextCard object) {
  return [];
}

void _textCardAttach(IsarCollection<dynamic> col, Id id, TextCard object) {
  object.isarId = id;
}

extension TextCardByIndex on IsarCollection<TextCard> {
  Future<TextCard?> getByTextCardId(String textCardId) {
    return getByIndex(r'textCardId', [textCardId]);
  }

  TextCard? getByTextCardIdSync(String textCardId) {
    return getByIndexSync(r'textCardId', [textCardId]);
  }

  Future<bool> deleteByTextCardId(String textCardId) {
    return deleteByIndex(r'textCardId', [textCardId]);
  }

  bool deleteByTextCardIdSync(String textCardId) {
    return deleteByIndexSync(r'textCardId', [textCardId]);
  }

  Future<List<TextCard?>> getAllByTextCardId(List<String> textCardIdValues) {
    final values = textCardIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'textCardId', values);
  }

  List<TextCard?> getAllByTextCardIdSync(List<String> textCardIdValues) {
    final values = textCardIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'textCardId', values);
  }

  Future<int> deleteAllByTextCardId(List<String> textCardIdValues) {
    final values = textCardIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'textCardId', values);
  }

  int deleteAllByTextCardIdSync(List<String> textCardIdValues) {
    final values = textCardIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'textCardId', values);
  }

  Future<Id> putByTextCardId(TextCard object) {
    return putByIndex(r'textCardId', object);
  }

  Id putByTextCardIdSync(TextCard object, {bool saveLinks = true}) {
    return putByIndexSync(r'textCardId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTextCardId(List<TextCard> objects) {
    return putAllByIndex(r'textCardId', objects);
  }

  List<Id> putAllByTextCardIdSync(
    List<TextCard> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'textCardId', objects, saveLinks: saveLinks);
  }
}

extension TextCardQueryWhereSort on QueryBuilder<TextCard, TextCard, QWhere> {
  QueryBuilder<TextCard, TextCard, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TextCardQueryWhere on QueryBuilder<TextCard, TextCard, QWhereClause> {
  QueryBuilder<TextCard, TextCard, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> isarIdNotEqualTo(
    Id isarId,
  ) {
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

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> isarIdGreaterThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> isarIdLessThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> textCardIdEqualTo(
    String textCardId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'textCardId', value: [textCardId]),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> textCardIdNotEqualTo(
    String textCardId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'textCardId',
                lower: [],
                upper: [textCardId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'textCardId',
                lower: [textCardId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'textCardId',
                lower: [textCardId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'textCardId',
                lower: [],
                upper: [textCardId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> owningProjectIdEqualTo(
    String owningProjectId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'owningProjectId',
          value: [owningProjectId],
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> owningProjectIdNotEqualTo(
    String owningProjectId,
  ) {
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

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> owningChapterIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'owningChapterId', value: [null]),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause>
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

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> owningChapterIdEqualTo(
    String? owningChapterId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'owningChapterId',
          value: [owningChapterId],
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> owningChapterIdNotEqualTo(
    String? owningChapterId,
  ) {
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

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> sourceRecordIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sourceRecordId', value: [null]),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause>
  sourceRecordIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'sourceRecordId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> sourceRecordIdEqualTo(
    String? sourceRecordId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'sourceRecordId',
          value: [sourceRecordId],
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterWhereClause> sourceRecordIdNotEqualTo(
    String? sourceRecordId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceRecordId',
                lower: [],
                upper: [sourceRecordId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceRecordId',
                lower: [sourceRecordId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceRecordId',
                lower: [sourceRecordId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceRecordId',
                lower: [],
                upper: [sourceRecordId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension TextCardQueryFilter
    on QueryBuilder<TextCard, TextCard, QFilterCondition> {
  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'body',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'body',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'body', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'body', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> isarIdEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  owningChapterIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'owningChapterId'),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  owningChapterIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'owningChapterId'),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  owningChapterIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'owningChapterId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  owningChapterIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'owningChapterId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  owningProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'owningProjectId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  owningProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'owningProjectId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> sortOrderEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> sortOrderBetween(
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceRecordId'),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceRecordId'),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> sourceRecordIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> sourceRecordIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceRecordId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> sourceRecordIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceRecordId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceRecordId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  sourceRecordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceRecordId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'textCardId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'textCardId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'textCardId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'textCardId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'textCardId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'textCardId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'textCardId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'textCardId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> textCardIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'textCardId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition>
  textCardIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'textCardId', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<TextCard, TextCard, QAfterFilterCondition> updatedAtBetween(
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

extension TextCardQueryObject
    on QueryBuilder<TextCard, TextCard, QFilterCondition> {}

extension TextCardQueryLinks
    on QueryBuilder<TextCard, TextCard, QFilterCondition> {}

extension TextCardQuerySortBy on QueryBuilder<TextCard, TextCard, QSortBy> {
  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByOwningChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByOwningChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortBySourceRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRecordId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortBySourceRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRecordId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByTextCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textCardId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByTextCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textCardId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TextCardQuerySortThenBy
    on QueryBuilder<TextCard, TextCard, QSortThenBy> {
  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByOwningChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByOwningChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningChapterId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByOwningProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByOwningProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owningProjectId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenBySourceRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRecordId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenBySourceRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRecordId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByTextCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textCardId', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByTextCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textCardId', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TextCard, TextCard, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TextCardQueryWhereDistinct
    on QueryBuilder<TextCard, TextCard, QDistinct> {
  QueryBuilder<TextCard, TextCard, QDistinct> distinctByBody({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctByOwningChapterId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'owningChapterId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctByOwningProjectId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'owningProjectId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctBySourceRecordId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'sourceRecordId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctByTextCardId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textCardId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TextCard, TextCard, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TextCardQueryProperty
    on QueryBuilder<TextCard, TextCard, QQueryProperty> {
  QueryBuilder<TextCard, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<TextCard, String, QQueryOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<TextCard, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TextCard, String?, QQueryOperations> owningChapterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningChapterId');
    });
  }

  QueryBuilder<TextCard, String, QQueryOperations> owningProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owningProjectId');
    });
  }

  QueryBuilder<TextCard, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<TextCard, String?, QQueryOperations> sourceRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceRecordId');
    });
  }

  QueryBuilder<TextCard, String, QQueryOperations> textCardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textCardId');
    });
  }

  QueryBuilder<TextCard, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<TextCard, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
