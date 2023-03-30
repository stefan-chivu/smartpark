// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_car.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetIsarCarCollection on Isar {
  IsarCollection<IsarCar> get isarCars => this.collection();
}

const IsarCarSchema = CollectionSchema(
  name: r'IsarCar',
  id: -497810588100247232,
  properties: {
    r'isElectric': PropertySchema(
      id: 0,
      name: r'isElectric',
      type: IsarType.bool,
    ),
    r'licensePlate': PropertySchema(
      id: 1,
      name: r'licensePlate',
      type: IsarType.string,
    ),
    r'ownerUid': PropertySchema(
      id: 2,
      name: r'ownerUid',
      type: IsarType.string,
    )
  },
  estimateSize: _isarCarEstimateSize,
  serialize: _isarCarSerialize,
  deserialize: _isarCarDeserialize,
  deserializeProp: _isarCarDeserializeProp,
  idName: r'id',
  indexes: {
    r'ownerUid': IndexSchema(
      id: -8016718989707307851,
      name: r'ownerUid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ownerUid',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'licensePlate': IndexSchema(
      id: -2810072559435191233,
      name: r'licensePlate',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'licensePlate',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarCarGetId,
  getLinks: _isarCarGetLinks,
  attach: _isarCarAttach,
  version: '3.0.5',
);

int _isarCarEstimateSize(
  IsarCar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.licensePlate.length * 3;
  bytesCount += 3 + object.ownerUid.length * 3;
  return bytesCount;
}

void _isarCarSerialize(
  IsarCar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isElectric);
  writer.writeString(offsets[1], object.licensePlate);
  writer.writeString(offsets[2], object.ownerUid);
}

IsarCar _isarCarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarCar(
    isElectric: reader.readBool(offsets[0]),
    licensePlate: reader.readString(offsets[1]),
    ownerUid: reader.readString(offsets[2]),
  );
  return object;
}

P _isarCarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarCarGetId(IsarCar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarCarGetLinks(IsarCar object) {
  return [];
}

void _isarCarAttach(IsarCollection<dynamic> col, Id id, IsarCar object) {}

extension IsarCarByIndex on IsarCollection<IsarCar> {
  Future<IsarCar?> getByLicensePlate(String licensePlate) {
    return getByIndex(r'licensePlate', [licensePlate]);
  }

  IsarCar? getByLicensePlateSync(String licensePlate) {
    return getByIndexSync(r'licensePlate', [licensePlate]);
  }

  Future<bool> deleteByLicensePlate(String licensePlate) {
    return deleteByIndex(r'licensePlate', [licensePlate]);
  }

  bool deleteByLicensePlateSync(String licensePlate) {
    return deleteByIndexSync(r'licensePlate', [licensePlate]);
  }

  Future<List<IsarCar?>> getAllByLicensePlate(List<String> licensePlateValues) {
    final values = licensePlateValues.map((e) => [e]).toList();
    return getAllByIndex(r'licensePlate', values);
  }

  List<IsarCar?> getAllByLicensePlateSync(List<String> licensePlateValues) {
    final values = licensePlateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'licensePlate', values);
  }

  Future<int> deleteAllByLicensePlate(List<String> licensePlateValues) {
    final values = licensePlateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'licensePlate', values);
  }

  int deleteAllByLicensePlateSync(List<String> licensePlateValues) {
    final values = licensePlateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'licensePlate', values);
  }

  Future<Id> putByLicensePlate(IsarCar object) {
    return putByIndex(r'licensePlate', object);
  }

  Id putByLicensePlateSync(IsarCar object, {bool saveLinks = true}) {
    return putByIndexSync(r'licensePlate', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLicensePlate(List<IsarCar> objects) {
    return putAllByIndex(r'licensePlate', objects);
  }

  List<Id> putAllByLicensePlateSync(List<IsarCar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'licensePlate', objects, saveLinks: saveLinks);
  }
}

extension IsarCarQueryWhereSort on QueryBuilder<IsarCar, IsarCar, QWhere> {
  QueryBuilder<IsarCar, IsarCar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhere> anyOwnerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ownerUid'),
      );
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhere> anyLicensePlate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'licensePlate'),
      );
    });
  }
}

extension IsarCarQueryWhere on QueryBuilder<IsarCar, IsarCar, QWhereClause> {
  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidEqualTo(
      String ownerUid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ownerUid',
        value: [ownerUid],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidNotEqualTo(
      String ownerUid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerUid',
              lower: [],
              upper: [ownerUid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerUid',
              lower: [ownerUid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerUid',
              lower: [ownerUid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerUid',
              lower: [],
              upper: [ownerUid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidGreaterThan(
    String ownerUid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ownerUid',
        lower: [ownerUid],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidLessThan(
    String ownerUid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ownerUid',
        lower: [],
        upper: [ownerUid],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidBetween(
    String lowerOwnerUid,
    String upperOwnerUid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ownerUid',
        lower: [lowerOwnerUid],
        includeLower: includeLower,
        upper: [upperOwnerUid],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidStartsWith(
      String OwnerUidPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ownerUid',
        lower: [OwnerUidPrefix],
        upper: ['$OwnerUidPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ownerUid',
        value: [''],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> ownerUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'ownerUid',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'ownerUid',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'ownerUid',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'ownerUid',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateEqualTo(
      String licensePlate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'licensePlate',
        value: [licensePlate],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateNotEqualTo(
      String licensePlate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licensePlate',
              lower: [],
              upper: [licensePlate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licensePlate',
              lower: [licensePlate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licensePlate',
              lower: [licensePlate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licensePlate',
              lower: [],
              upper: [licensePlate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateGreaterThan(
    String licensePlate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'licensePlate',
        lower: [licensePlate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateLessThan(
    String licensePlate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'licensePlate',
        lower: [],
        upper: [licensePlate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateBetween(
    String lowerLicensePlate,
    String upperLicensePlate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'licensePlate',
        lower: [lowerLicensePlate],
        includeLower: includeLower,
        upper: [upperLicensePlate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateStartsWith(
      String LicensePlatePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'licensePlate',
        lower: [LicensePlatePrefix],
        upper: ['$LicensePlatePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'licensePlate',
        value: [''],
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterWhereClause> licensePlateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'licensePlate',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'licensePlate',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'licensePlate',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'licensePlate',
              upper: [''],
            ));
      }
    });
  }
}

extension IsarCarQueryFilter
    on QueryBuilder<IsarCar, IsarCar, QFilterCondition> {
  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> isElectricEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isElectric',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licensePlate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'licensePlate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'licensePlate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'licensePlate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'licensePlate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'licensePlate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'licensePlate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'licensePlate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> licensePlateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licensePlate',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition>
      licensePlateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'licensePlate',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ownerUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownerUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerUid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterFilterCondition> ownerUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownerUid',
        value: '',
      ));
    });
  }
}

extension IsarCarQueryObject
    on QueryBuilder<IsarCar, IsarCar, QFilterCondition> {}

extension IsarCarQueryLinks
    on QueryBuilder<IsarCar, IsarCar, QFilterCondition> {}

extension IsarCarQuerySortBy on QueryBuilder<IsarCar, IsarCar, QSortBy> {
  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> sortByIsElectric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isElectric', Sort.asc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> sortByIsElectricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isElectric', Sort.desc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> sortByLicensePlate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.asc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> sortByLicensePlateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.desc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> sortByOwnerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.asc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> sortByOwnerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.desc);
    });
  }
}

extension IsarCarQuerySortThenBy
    on QueryBuilder<IsarCar, IsarCar, QSortThenBy> {
  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenByIsElectric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isElectric', Sort.asc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenByIsElectricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isElectric', Sort.desc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenByLicensePlate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.asc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenByLicensePlateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.desc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenByOwnerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.asc);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QAfterSortBy> thenByOwnerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.desc);
    });
  }
}

extension IsarCarQueryWhereDistinct
    on QueryBuilder<IsarCar, IsarCar, QDistinct> {
  QueryBuilder<IsarCar, IsarCar, QDistinct> distinctByIsElectric() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isElectric');
    });
  }

  QueryBuilder<IsarCar, IsarCar, QDistinct> distinctByLicensePlate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licensePlate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCar, IsarCar, QDistinct> distinctByOwnerUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUid', caseSensitive: caseSensitive);
    });
  }
}

extension IsarCarQueryProperty
    on QueryBuilder<IsarCar, IsarCar, QQueryProperty> {
  QueryBuilder<IsarCar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarCar, bool, QQueryOperations> isElectricProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isElectric');
    });
  }

  QueryBuilder<IsarCar, String, QQueryOperations> licensePlateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licensePlate');
    });
  }

  QueryBuilder<IsarCar, String, QQueryOperations> ownerUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUid');
    });
  }
}
