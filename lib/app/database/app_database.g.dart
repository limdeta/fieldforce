// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashedPasswordMeta = const VerificationMeta(
    'hashedPassword',
  );
  @override
  late final GeneratedColumn<String> hashedPassword = GeneratedColumn<String>(
    'hashed_password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    externalId,
    role,
    phoneNumber,
    hashedPassword,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('hashed_password')) {
      context.handle(
        _hashedPasswordMeta,
        hashedPassword.isAcceptableOrUnknown(
          data['hashed_password']!,
          _hashedPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hashedPasswordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      hashedPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hashed_password'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserData extends DataClass implements Insertable<UserData> {
  final int id;
  final String externalId;
  final String role;
  final String phoneNumber;
  final String hashedPassword;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserData({
    required this.id,
    required this.externalId,
    required this.role,
    required this.phoneNumber,
    required this.hashedPassword,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['external_id'] = Variable<String>(externalId);
    map['role'] = Variable<String>(role);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['hashed_password'] = Variable<String>(hashedPassword);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      externalId: Value(externalId),
      role: Value(role),
      phoneNumber: Value(phoneNumber),
      hashedPassword: Value(hashedPassword),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserData(
      id: serializer.fromJson<int>(json['id']),
      externalId: serializer.fromJson<String>(json['externalId']),
      role: serializer.fromJson<String>(json['role']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      hashedPassword: serializer.fromJson<String>(json['hashedPassword']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'externalId': serializer.toJson<String>(externalId),
      'role': serializer.toJson<String>(role),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'hashedPassword': serializer.toJson<String>(hashedPassword),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserData copyWith({
    int? id,
    String? externalId,
    String? role,
    String? phoneNumber,
    String? hashedPassword,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserData(
    id: id ?? this.id,
    externalId: externalId ?? this.externalId,
    role: role ?? this.role,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    hashedPassword: hashedPassword ?? this.hashedPassword,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserData copyWithCompanion(UsersCompanion data) {
    return UserData(
      id: data.id.present ? data.id.value : this.id,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      role: data.role.present ? data.role.value : this.role,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      hashedPassword: data.hashedPassword.present
          ? data.hashedPassword.value
          : this.hashedPassword,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserData(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('role: $role, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('hashedPassword: $hashedPassword, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    externalId,
    role,
    phoneNumber,
    hashedPassword,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserData &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.role == this.role &&
          other.phoneNumber == this.phoneNumber &&
          other.hashedPassword == this.hashedPassword &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<UserData> {
  final Value<int> id;
  final Value<String> externalId;
  final Value<String> role;
  final Value<String> phoneNumber;
  final Value<String> hashedPassword;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.role = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.hashedPassword = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String externalId,
    required String role,
    required String phoneNumber,
    required String hashedPassword,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : externalId = Value(externalId),
       role = Value(role),
       phoneNumber = Value(phoneNumber),
       hashedPassword = Value(hashedPassword);
  static Insertable<UserData> custom({
    Expression<int>? id,
    Expression<String>? externalId,
    Expression<String>? role,
    Expression<String>? phoneNumber,
    Expression<String>? hashedPassword,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (role != null) 'role': role,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (hashedPassword != null) 'hashed_password': hashedPassword,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? externalId,
    Value<String>? role,
    Value<String>? phoneNumber,
    Value<String>? hashedPassword,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (hashedPassword.present) {
      map['hashed_password'] = Variable<String>(hashedPassword.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('role: $role, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('hashedPassword: $hashedPassword, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, EmployeeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastName,
    firstName,
    middleName,
    role,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmployeeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmployeeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class EmployeeData extends DataClass implements Insertable<EmployeeData> {
  final int id;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EmployeeData({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['last_name'] = Variable<String>(lastName);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      lastName: Value(lastName),
      firstName: Value(firstName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EmployeeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeData(
      id: serializer.fromJson<int>(json['id']),
      lastName: serializer.fromJson<String>(json['lastName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastName': serializer.toJson<String>(lastName),
      'firstName': serializer.toJson<String>(firstName),
      'middleName': serializer.toJson<String?>(middleName),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EmployeeData copyWith({
    int? id,
    String? lastName,
    String? firstName,
    Value<String?> middleName = const Value.absent(),
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EmployeeData(
    id: id ?? this.id,
    lastName: lastName ?? this.lastName,
    firstName: firstName ?? this.firstName,
    middleName: middleName.present ? middleName.value : this.middleName,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EmployeeData copyWithCompanion(EmployeesCompanion data) {
    return EmployeeData(
      id: data.id.present ? data.id.value : this.id,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeData(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastName,
    firstName,
    middleName,
    role,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeData &&
          other.id == this.id &&
          other.lastName == this.lastName &&
          other.firstName == this.firstName &&
          other.middleName == this.middleName &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EmployeesCompanion extends UpdateCompanion<EmployeeData> {
  final Value<int> id;
  final Value<String> lastName;
  final Value<String> firstName;
  final Value<String?> middleName;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.id = const Value.absent(),
    required String lastName,
    required String firstName,
    this.middleName = const Value.absent(),
    required String role,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : lastName = Value(lastName),
       firstName = Value(firstName),
       role = Value(role);
  static Insertable<EmployeeData> custom({
    Expression<int>? id,
    Expression<String>? lastName,
    Expression<String>? firstName,
    Expression<String>? middleName,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastName != null) 'last_name': lastName,
      if (firstName != null) 'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EmployeesCompanion copyWith({
    Value<int>? id,
    Value<String>? lastName,
    Value<String>? firstName,
    Value<String?>? middleName,
    Value<String>? role,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EmployeesCompanion(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RoutesTable extends Routes with TableInfo<$RoutesTable, RouteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
    'employee_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
    startTime,
    endTime,
    status,
    employeeId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_id'],
      ),
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }
}

class RouteData extends DataClass implements Insertable<RouteData> {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status;
  final int? employeeId;
  const RouteData({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.startTime,
    this.endTime,
    required this.status,
    this.employeeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || employeeId != null) {
      map['employee_id'] = Variable<int>(employeeId);
    }
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      status: Value(status),
      employeeId: employeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeId),
    );
  }

  factory RouteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      status: serializer.fromJson<String>(json['status']),
      employeeId: serializer.fromJson<int?>(json['employeeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'status': serializer.toJson<String>(status),
      'employeeId': serializer.toJson<int?>(employeeId),
    };
  }

  RouteData copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    String? status,
    Value<int?> employeeId = const Value.absent(),
  }) => RouteData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    status: status ?? this.status,
    employeeId: employeeId.present ? employeeId.value : this.employeeId,
  );
  RouteData copyWithCompanion(RoutesCompanion data) {
    return RouteData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      status: data.status.present ? data.status.value : this.status,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('employeeId: $employeeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    updatedAt,
    startTime,
    endTime,
    status,
    employeeId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.status == this.status &&
          other.employeeId == this.employeeId);
}

class RoutesCompanion extends UpdateCompanion<RouteData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<String> status;
  final Value<int?> employeeId;
  const RoutesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.employeeId = const Value.absent(),
  });
  RoutesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    required String status,
    this.employeeId = const Value.absent(),
  }) : name = Value(name),
       status = Value(status);
  static Insertable<RouteData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? status,
    Expression<int>? employeeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (status != null) 'status': status,
      if (employeeId != null) 'employee_id': employeeId,
    });
  }

  RoutesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<String>? status,
    Value<int?>? employeeId,
  }) {
    return RoutesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      employeeId: employeeId ?? this.employeeId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<int>(employeeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('employeeId: $employeeId')
          ..write(')'))
        .toString();
  }
}

class $PointsOfInterestTable extends PointsOfInterest
    with TableInfo<$PointsOfInterestTable, PointOfInterestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointsOfInterestTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _visitedAtMeta = const VerificationMeta(
    'visitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
    'visited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    name,
    description,
    latitude,
    longitude,
    status,
    createdAt,
    visitedAt,
    notes,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'points_of_interest';
  @override
  VerificationContext validateIntegrity(
    Insertable<PointOfInterestData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointOfInterestData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointOfInterestData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      visitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $PointsOfInterestTable createAlias(String alias) {
    return $PointsOfInterestTable(attachedDatabase, alias);
  }
}

class PointOfInterestData extends DataClass
    implements Insertable<PointOfInterestData> {
  final int id;
  final int routeId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;
  final DateTime? visitedAt;
  final String? notes;
  final String type;
  const PointOfInterestData({
    required this.id,
    required this.routeId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.visitedAt,
    this.notes,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || visitedAt != null) {
      map['visited_at'] = Variable<DateTime>(visitedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  PointsOfInterestCompanion toCompanion(bool nullToAbsent) {
    return PointsOfInterestCompanion(
      id: Value(id),
      routeId: Value(routeId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      latitude: Value(latitude),
      longitude: Value(longitude),
      status: Value(status),
      createdAt: Value(createdAt),
      visitedAt: visitedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(visitedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      type: Value(type),
    );
  }

  factory PointOfInterestData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointOfInterestData(
      id: serializer.fromJson<int>(json['id']),
      routeId: serializer.fromJson<int>(json['routeId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      visitedAt: serializer.fromJson<DateTime?>(json['visitedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeId': serializer.toJson<int>(routeId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'visitedAt': serializer.toJson<DateTime?>(visitedAt),
      'notes': serializer.toJson<String?>(notes),
      'type': serializer.toJson<String>(type),
    };
  }

  PointOfInterestData copyWith({
    int? id,
    int? routeId,
    String? name,
    Value<String?> description = const Value.absent(),
    double? latitude,
    double? longitude,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> visitedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? type,
  }) => PointOfInterestData(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    visitedAt: visitedAt.present ? visitedAt.value : this.visitedAt,
    notes: notes.present ? notes.value : this.notes,
    type: type ?? this.type,
  );
  PointOfInterestData copyWithCompanion(PointsOfInterestCompanion data) {
    return PointOfInterestData(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointOfInterestData(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('notes: $notes, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routeId,
    name,
    description,
    latitude,
    longitude,
    status,
    createdAt,
    visitedAt,
    notes,
    type,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointOfInterestData &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.name == this.name &&
          other.description == this.description &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.visitedAt == this.visitedAt &&
          other.notes == this.notes &&
          other.type == this.type);
}

class PointsOfInterestCompanion extends UpdateCompanion<PointOfInterestData> {
  final Value<int> id;
  final Value<int> routeId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> visitedAt;
  final Value<String?> notes;
  final Value<String> type;
  const PointsOfInterestCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.type = const Value.absent(),
  });
  PointsOfInterestCompanion.insert({
    this.id = const Value.absent(),
    required int routeId,
    required String name,
    this.description = const Value.absent(),
    required double latitude,
    required double longitude,
    required String status,
    this.createdAt = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required String type,
  }) : routeId = Value(routeId),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       status = Value(status),
       type = Value(type);
  static Insertable<PointOfInterestData> custom({
    Expression<int>? id,
    Expression<int>? routeId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? visitedAt,
    Expression<String>? notes,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (notes != null) 'notes': notes,
      if (type != null) 'type': type,
    });
  }

  PointsOfInterestCompanion copyWith({
    Value<int>? id,
    Value<int>? routeId,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? visitedAt,
    Value<String?>? notes,
    Value<String>? type,
  }) {
    return PointsOfInterestCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      visitedAt: visitedAt ?? this.visitedAt,
      notes: notes ?? this.notes,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointsOfInterestCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('notes: $notes, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $TradingPointsTable extends TradingPoints
    with TableInfo<$TradingPointsTable, TradingPointData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradingPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pointOfInterestIdMeta = const VerificationMeta(
    'pointOfInterestId',
  );
  @override
  late final GeneratedColumn<int> pointOfInterestId = GeneratedColumn<int>(
    'point_of_interest_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES points_of_interest (id)',
    ),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workingHoursMeta = const VerificationMeta(
    'workingHours',
  );
  @override
  late final GeneratedColumn<String> workingHours = GeneratedColumn<String>(
    'working_hours',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pointOfInterestId,
    address,
    contactPerson,
    phone,
    email,
    workingHours,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trading_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradingPointData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('point_of_interest_id')) {
      context.handle(
        _pointOfInterestIdMeta,
        pointOfInterestId.isAcceptableOrUnknown(
          data['point_of_interest_id']!,
          _pointOfInterestIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointOfInterestIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('working_hours')) {
      context.handle(
        _workingHoursMeta,
        workingHours.isAcceptableOrUnknown(
          data['working_hours']!,
          _workingHoursMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradingPointData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradingPointData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pointOfInterestId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_of_interest_id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      workingHours: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}working_hours'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TradingPointsTable createAlias(String alias) {
    return $TradingPointsTable(attachedDatabase, alias);
  }
}

class TradingPointData extends DataClass
    implements Insertable<TradingPointData> {
  final int id;
  final int pointOfInterestId;
  final String? address;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? workingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const TradingPointData({
    required this.id,
    required this.pointOfInterestId,
    this.address,
    this.contactPerson,
    this.phone,
    this.email,
    this.workingHours,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['point_of_interest_id'] = Variable<int>(pointOfInterestId);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || workingHours != null) {
      map['working_hours'] = Variable<String>(workingHours);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TradingPointsCompanion toCompanion(bool nullToAbsent) {
    return TradingPointsCompanion(
      id: Value(id),
      pointOfInterestId: Value(pointOfInterestId),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      workingHours: workingHours == null && nullToAbsent
          ? const Value.absent()
          : Value(workingHours),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TradingPointData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradingPointData(
      id: serializer.fromJson<int>(json['id']),
      pointOfInterestId: serializer.fromJson<int>(json['pointOfInterestId']),
      address: serializer.fromJson<String?>(json['address']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      workingHours: serializer.fromJson<String?>(json['workingHours']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pointOfInterestId': serializer.toJson<int>(pointOfInterestId),
      'address': serializer.toJson<String?>(address),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'workingHours': serializer.toJson<String?>(workingHours),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  TradingPointData copyWith({
    int? id,
    int? pointOfInterestId,
    Value<String?> address = const Value.absent(),
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> workingHours = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => TradingPointData(
    id: id ?? this.id,
    pointOfInterestId: pointOfInterestId ?? this.pointOfInterestId,
    address: address.present ? address.value : this.address,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    workingHours: workingHours.present ? workingHours.value : this.workingHours,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TradingPointData copyWithCompanion(TradingPointsCompanion data) {
    return TradingPointData(
      id: data.id.present ? data.id.value : this.id,
      pointOfInterestId: data.pointOfInterestId.present
          ? data.pointOfInterestId.value
          : this.pointOfInterestId,
      address: data.address.present ? data.address.value : this.address,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      workingHours: data.workingHours.present
          ? data.workingHours.value
          : this.workingHours,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradingPointData(')
          ..write('id: $id, ')
          ..write('pointOfInterestId: $pointOfInterestId, ')
          ..write('address: $address, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('workingHours: $workingHours, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pointOfInterestId,
    address,
    contactPerson,
    phone,
    email,
    workingHours,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradingPointData &&
          other.id == this.id &&
          other.pointOfInterestId == this.pointOfInterestId &&
          other.address == this.address &&
          other.contactPerson == this.contactPerson &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.workingHours == this.workingHours &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TradingPointsCompanion extends UpdateCompanion<TradingPointData> {
  final Value<int> id;
  final Value<int> pointOfInterestId;
  final Value<String?> address;
  final Value<String?> contactPerson;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> workingHours;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const TradingPointsCompanion({
    this.id = const Value.absent(),
    this.pointOfInterestId = const Value.absent(),
    this.address = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.workingHours = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TradingPointsCompanion.insert({
    this.id = const Value.absent(),
    required int pointOfInterestId,
    this.address = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.workingHours = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : pointOfInterestId = Value(pointOfInterestId);
  static Insertable<TradingPointData> custom({
    Expression<int>? id,
    Expression<int>? pointOfInterestId,
    Expression<String>? address,
    Expression<String>? contactPerson,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? workingHours,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pointOfInterestId != null) 'point_of_interest_id': pointOfInterestId,
      if (address != null) 'address': address,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (workingHours != null) 'working_hours': workingHours,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TradingPointsCompanion copyWith({
    Value<int>? id,
    Value<int>? pointOfInterestId,
    Value<String?>? address,
    Value<String?>? contactPerson,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? workingHours,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return TradingPointsCompanion(
      id: id ?? this.id,
      pointOfInterestId: pointOfInterestId ?? this.pointOfInterestId,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pointOfInterestId.present) {
      map['point_of_interest_id'] = Variable<int>(pointOfInterestId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (workingHours.present) {
      map['working_hours'] = Variable<String>(workingHours.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradingPointsCompanion(')
          ..write('id: $id, ')
          ..write('pointOfInterestId: $pointOfInterestId, ')
          ..write('address: $address, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('workingHours: $workingHours, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TradingPointEntitiesTable extends TradingPointEntities
    with TableInfo<$TradingPointEntitiesTable, TradingPointEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradingPointEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _innMeta = const VerificationMeta('inn');
  @override
  late final GeneratedColumn<String> inn = GeneratedColumn<String>(
    'inn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('P3V'),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    externalId,
    name,
    inn,
    region,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trading_point_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradingPointEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('inn')) {
      context.handle(
        _innMeta,
        inn.isAcceptableOrUnknown(data['inn']!, _innMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradingPointEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradingPointEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      inn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inn'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TradingPointEntitiesTable createAlias(String alias) {
    return $TradingPointEntitiesTable(attachedDatabase, alias);
  }
}

class TradingPointEntity extends DataClass
    implements Insertable<TradingPointEntity> {
  final int id;
  final String externalId;
  final String name;
  final String? inn;
  final String region;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const TradingPointEntity({
    required this.id,
    required this.externalId,
    required this.name,
    this.inn,
    required this.region,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['external_id'] = Variable<String>(externalId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || inn != null) {
      map['inn'] = Variable<String>(inn);
    }
    map['region'] = Variable<String>(region);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TradingPointEntitiesCompanion toCompanion(bool nullToAbsent) {
    return TradingPointEntitiesCompanion(
      id: Value(id),
      externalId: Value(externalId),
      name: Value(name),
      inn: inn == null && nullToAbsent ? const Value.absent() : Value(inn),
      region: Value(region),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TradingPointEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradingPointEntity(
      id: serializer.fromJson<int>(json['id']),
      externalId: serializer.fromJson<String>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      inn: serializer.fromJson<String?>(json['inn']),
      region: serializer.fromJson<String>(json['region']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'externalId': serializer.toJson<String>(externalId),
      'name': serializer.toJson<String>(name),
      'inn': serializer.toJson<String?>(inn),
      'region': serializer.toJson<String>(region),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  TradingPointEntity copyWith({
    int? id,
    String? externalId,
    String? name,
    Value<String?> inn = const Value.absent(),
    String? region,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => TradingPointEntity(
    id: id ?? this.id,
    externalId: externalId ?? this.externalId,
    name: name ?? this.name,
    inn: inn.present ? inn.value : this.inn,
    region: region ?? this.region,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TradingPointEntity copyWithCompanion(TradingPointEntitiesCompanion data) {
    return TradingPointEntity(
      id: data.id.present ? data.id.value : this.id,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      inn: data.inn.present ? data.inn.value : this.inn,
      region: data.region.present ? data.region.value : this.region,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradingPointEntity(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('inn: $inn, ')
          ..write('region: $region, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    externalId,
    name,
    inn,
    region,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradingPointEntity &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.inn == this.inn &&
          other.region == this.region &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TradingPointEntitiesCompanion
    extends UpdateCompanion<TradingPointEntity> {
  final Value<int> id;
  final Value<String> externalId;
  final Value<String> name;
  final Value<String?> inn;
  final Value<String> region;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const TradingPointEntitiesCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.inn = const Value.absent(),
    this.region = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TradingPointEntitiesCompanion.insert({
    this.id = const Value.absent(),
    required String externalId,
    required String name,
    this.inn = const Value.absent(),
    this.region = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : externalId = Value(externalId),
       name = Value(name);
  static Insertable<TradingPointEntity> custom({
    Expression<int>? id,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? inn,
    Expression<String>? region,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (inn != null) 'inn': inn,
      if (region != null) 'region': region,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TradingPointEntitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? externalId,
    Value<String>? name,
    Value<String?>? inn,
    Value<String>? region,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return TradingPointEntitiesCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      inn: inn ?? this.inn,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (inn.present) {
      map['inn'] = Variable<String>(inn.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradingPointEntitiesCompanion(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('inn: $inn, ')
          ..write('region: $region, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EmployeeTradingPointAssignmentsTable
    extends EmployeeTradingPointAssignments
    with
        TableInfo<
          $EmployeeTradingPointAssignmentsTable,
          EmployeeTradingPointAssignment
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeeTradingPointAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (id)',
    ),
  );
  static const VerificationMeta _tradingPointExternalIdMeta =
      const VerificationMeta('tradingPointExternalId');
  @override
  late final GeneratedColumn<String> tradingPointExternalId =
      GeneratedColumn<String>(
        'trading_point_external_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _assignedAtMeta = const VerificationMeta(
    'assignedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
    'assigned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    employeeId,
    tradingPointExternalId,
    assignedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employee_trading_point_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmployeeTradingPointAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('trading_point_external_id')) {
      context.handle(
        _tradingPointExternalIdMeta,
        tradingPointExternalId.isAcceptableOrUnknown(
          data['trading_point_external_id']!,
          _tradingPointExternalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tradingPointExternalIdMeta);
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
        _assignedAtMeta,
        assignedAt.isAcceptableOrUnknown(data['assigned_at']!, _assignedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {employeeId, tradingPointExternalId};
  @override
  EmployeeTradingPointAssignment map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeTradingPointAssignment(
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_id'],
      )!,
      tradingPointExternalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trading_point_external_id'],
      )!,
      assignedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assigned_at'],
      )!,
    );
  }

  @override
  $EmployeeTradingPointAssignmentsTable createAlias(String alias) {
    return $EmployeeTradingPointAssignmentsTable(attachedDatabase, alias);
  }
}

class EmployeeTradingPointAssignment extends DataClass
    implements Insertable<EmployeeTradingPointAssignment> {
  final int employeeId;
  final String tradingPointExternalId;
  final DateTime assignedAt;
  const EmployeeTradingPointAssignment({
    required this.employeeId,
    required this.tradingPointExternalId,
    required this.assignedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['employee_id'] = Variable<int>(employeeId);
    map['trading_point_external_id'] = Variable<String>(tradingPointExternalId);
    map['assigned_at'] = Variable<DateTime>(assignedAt);
    return map;
  }

  EmployeeTradingPointAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return EmployeeTradingPointAssignmentsCompanion(
      employeeId: Value(employeeId),
      tradingPointExternalId: Value(tradingPointExternalId),
      assignedAt: Value(assignedAt),
    );
  }

  factory EmployeeTradingPointAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeTradingPointAssignment(
      employeeId: serializer.fromJson<int>(json['employeeId']),
      tradingPointExternalId: serializer.fromJson<String>(
        json['tradingPointExternalId'],
      ),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'employeeId': serializer.toJson<int>(employeeId),
      'tradingPointExternalId': serializer.toJson<String>(
        tradingPointExternalId,
      ),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
    };
  }

  EmployeeTradingPointAssignment copyWith({
    int? employeeId,
    String? tradingPointExternalId,
    DateTime? assignedAt,
  }) => EmployeeTradingPointAssignment(
    employeeId: employeeId ?? this.employeeId,
    tradingPointExternalId:
        tradingPointExternalId ?? this.tradingPointExternalId,
    assignedAt: assignedAt ?? this.assignedAt,
  );
  EmployeeTradingPointAssignment copyWithCompanion(
    EmployeeTradingPointAssignmentsCompanion data,
  ) {
    return EmployeeTradingPointAssignment(
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      tradingPointExternalId: data.tradingPointExternalId.present
          ? data.tradingPointExternalId.value
          : this.tradingPointExternalId,
      assignedAt: data.assignedAt.present
          ? data.assignedAt.value
          : this.assignedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeTradingPointAssignment(')
          ..write('employeeId: $employeeId, ')
          ..write('tradingPointExternalId: $tradingPointExternalId, ')
          ..write('assignedAt: $assignedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(employeeId, tradingPointExternalId, assignedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeTradingPointAssignment &&
          other.employeeId == this.employeeId &&
          other.tradingPointExternalId == this.tradingPointExternalId &&
          other.assignedAt == this.assignedAt);
}

class EmployeeTradingPointAssignmentsCompanion
    extends UpdateCompanion<EmployeeTradingPointAssignment> {
  final Value<int> employeeId;
  final Value<String> tradingPointExternalId;
  final Value<DateTime> assignedAt;
  final Value<int> rowid;
  const EmployeeTradingPointAssignmentsCompanion({
    this.employeeId = const Value.absent(),
    this.tradingPointExternalId = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeeTradingPointAssignmentsCompanion.insert({
    required int employeeId,
    required String tradingPointExternalId,
    this.assignedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : employeeId = Value(employeeId),
       tradingPointExternalId = Value(tradingPointExternalId);
  static Insertable<EmployeeTradingPointAssignment> custom({
    Expression<int>? employeeId,
    Expression<String>? tradingPointExternalId,
    Expression<DateTime>? assignedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (employeeId != null) 'employee_id': employeeId,
      if (tradingPointExternalId != null)
        'trading_point_external_id': tradingPointExternalId,
      if (assignedAt != null) 'assigned_at': assignedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeeTradingPointAssignmentsCompanion copyWith({
    Value<int>? employeeId,
    Value<String>? tradingPointExternalId,
    Value<DateTime>? assignedAt,
    Value<int>? rowid,
  }) {
    return EmployeeTradingPointAssignmentsCompanion(
      employeeId: employeeId ?? this.employeeId,
      tradingPointExternalId:
          tradingPointExternalId ?? this.tradingPointExternalId,
      assignedAt: assignedAt ?? this.assignedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (employeeId.present) {
      map['employee_id'] = Variable<int>(employeeId.value);
    }
    if (tradingPointExternalId.present) {
      map['trading_point_external_id'] = Variable<String>(
        tradingPointExternalId.value,
      );
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<DateTime>(assignedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeTradingPointAssignmentsCompanion(')
          ..write('employeeId: $employeeId, ')
          ..write('tradingPointExternalId: $tradingPointExternalId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserTracksTable extends UserTracks
    with TableInfo<$UserTracksTable, UserTrackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id)',
    ),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPointsMeta = const VerificationMeta(
    'totalPoints',
  );
  @override
  late final GeneratedColumn<int> totalPoints = GeneratedColumn<int>(
    'total_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDistanceKmMeta = const VerificationMeta(
    'totalDistanceKm',
  );
  @override
  late final GeneratedColumn<double> totalDistanceKm = GeneratedColumn<double>(
    'total_distance_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalDurationSecondsMeta =
      const VerificationMeta('totalDurationSeconds');
  @override
  late final GeneratedColumn<int> totalDurationSeconds = GeneratedColumn<int>(
    'total_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    routeId,
    startTime,
    endTime,
    status,
    totalPoints,
    totalDistanceKm,
    totalDurationSeconds,
    metadata,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserTrackData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_points')) {
      context.handle(
        _totalPointsMeta,
        totalPoints.isAcceptableOrUnknown(
          data['total_points']!,
          _totalPointsMeta,
        ),
      );
    }
    if (data.containsKey('total_distance_km')) {
      context.handle(
        _totalDistanceKmMeta,
        totalDistanceKm.isAcceptableOrUnknown(
          data['total_distance_km']!,
          _totalDistanceKmMeta,
        ),
      );
    }
    if (data.containsKey('total_duration_seconds')) {
      context.handle(
        _totalDurationSecondsMeta,
        totalDurationSeconds.isAcceptableOrUnknown(
          data['total_duration_seconds']!,
          _totalDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTrackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTrackData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_points'],
      )!,
      totalDistanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance_km'],
      )!,
      totalDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_seconds'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserTracksTable createAlias(String alias) {
    return $UserTracksTable(attachedDatabase, alias);
  }
}

class UserTrackData extends DataClass implements Insertable<UserTrackData> {
  final int id;

  /// Ссылка на пользователя в таблице Users
  final int userId;

  /// Ссылка на маршрут (может быть null для свободного трекинга)
  final int? routeId;

  /// Время начала трека
  final DateTime startTime;

  /// Время завершения трека (null для активных треков)
  final DateTime? endTime;

  /// Статус трека (active, paused, completed, cancelled)
  final String status;

  /// Общее количество точек во всех сегментах
  final int totalPoints;

  /// Общее расстояние в километрах
  final double totalDistanceKm;

  /// Общая продолжительность в секундах
  final int totalDurationSeconds;

  /// Дополнительные метаданные (JSON)
  final String? metadata;

  /// Время создания
  final DateTime createdAt;

  /// Время последнего обновления
  final DateTime updatedAt;
  const UserTrackData({
    required this.id,
    required this.userId,
    this.routeId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.totalPoints,
    required this.totalDistanceKm,
    required this.totalDurationSeconds,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || routeId != null) {
      map['route_id'] = Variable<int>(routeId);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['status'] = Variable<String>(status);
    map['total_points'] = Variable<int>(totalPoints);
    map['total_distance_km'] = Variable<double>(totalDistanceKm);
    map['total_duration_seconds'] = Variable<int>(totalDurationSeconds);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserTracksCompanion toCompanion(bool nullToAbsent) {
    return UserTracksCompanion(
      id: Value(id),
      userId: Value(userId),
      routeId: routeId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      status: Value(status),
      totalPoints: Value(totalPoints),
      totalDistanceKm: Value(totalDistanceKm),
      totalDurationSeconds: Value(totalDurationSeconds),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserTrackData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTrackData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      routeId: serializer.fromJson<int?>(json['routeId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      status: serializer.fromJson<String>(json['status']),
      totalPoints: serializer.fromJson<int>(json['totalPoints']),
      totalDistanceKm: serializer.fromJson<double>(json['totalDistanceKm']),
      totalDurationSeconds: serializer.fromJson<int>(
        json['totalDurationSeconds'],
      ),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'routeId': serializer.toJson<int?>(routeId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'status': serializer.toJson<String>(status),
      'totalPoints': serializer.toJson<int>(totalPoints),
      'totalDistanceKm': serializer.toJson<double>(totalDistanceKm),
      'totalDurationSeconds': serializer.toJson<int>(totalDurationSeconds),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserTrackData copyWith({
    int? id,
    int? userId,
    Value<int?> routeId = const Value.absent(),
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    String? status,
    int? totalPoints,
    double? totalDistanceKm,
    int? totalDurationSeconds,
    Value<String?> metadata = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserTrackData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    routeId: routeId.present ? routeId.value : this.routeId,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    status: status ?? this.status,
    totalPoints: totalPoints ?? this.totalPoints,
    totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
    totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserTrackData copyWithCompanion(UserTracksCompanion data) {
    return UserTrackData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      status: data.status.present ? data.status.value : this.status,
      totalPoints: data.totalPoints.present
          ? data.totalPoints.value
          : this.totalPoints,
      totalDistanceKm: data.totalDistanceKm.present
          ? data.totalDistanceKm.value
          : this.totalDistanceKm,
      totalDurationSeconds: data.totalDurationSeconds.present
          ? data.totalDurationSeconds.value
          : this.totalDurationSeconds,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTrackData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('routeId: $routeId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    routeId,
    startTime,
    endTime,
    status,
    totalPoints,
    totalDistanceKm,
    totalDurationSeconds,
    metadata,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTrackData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.routeId == this.routeId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.status == this.status &&
          other.totalPoints == this.totalPoints &&
          other.totalDistanceKm == this.totalDistanceKm &&
          other.totalDurationSeconds == this.totalDurationSeconds &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserTracksCompanion extends UpdateCompanion<UserTrackData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int?> routeId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<String> status;
  final Value<int> totalPoints;
  final Value<double> totalDistanceKm;
  final Value<int> totalDurationSeconds;
  final Value<String?> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserTracksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.routeId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.totalPoints = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserTracksCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.routeId = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required String status,
    this.totalPoints = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : userId = Value(userId),
       startTime = Value(startTime),
       status = Value(status);
  static Insertable<UserTrackData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? routeId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? status,
    Expression<int>? totalPoints,
    Expression<double>? totalDistanceKm,
    Expression<int>? totalDurationSeconds,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (routeId != null) 'route_id': routeId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (status != null) 'status': status,
      if (totalPoints != null) 'total_points': totalPoints,
      if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
      if (totalDurationSeconds != null)
        'total_duration_seconds': totalDurationSeconds,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserTracksCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int?>? routeId,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<String>? status,
    Value<int>? totalPoints,
    Value<double>? totalDistanceKm,
    Value<int>? totalDurationSeconds,
    Value<String?>? metadata,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserTracksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routeId: routeId ?? this.routeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalPoints: totalPoints ?? this.totalPoints,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalPoints.present) {
      map['total_points'] = Variable<int>(totalPoints.value);
    }
    if (totalDistanceKm.present) {
      map['total_distance_km'] = Variable<double>(totalDistanceKm.value);
    }
    if (totalDurationSeconds.present) {
      map['total_duration_seconds'] = Variable<int>(totalDurationSeconds.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTracksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('routeId: $routeId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CompactTracksTable extends CompactTracks
    with TableInfo<$CompactTracksTable, CompactTrackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompactTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userTrackIdMeta = const VerificationMeta(
    'userTrackId',
  );
  @override
  late final GeneratedColumn<int> userTrackId = GeneratedColumn<int>(
    'user_track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _segmentOrderMeta = const VerificationMeta(
    'segmentOrder',
  );
  @override
  late final GeneratedColumn<int> segmentOrder = GeneratedColumn<int>(
    'segment_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coordinatesBlobMeta = const VerificationMeta(
    'coordinatesBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> coordinatesBlob =
      GeneratedColumn<Uint8List>(
        'coordinates_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timestampsBlobMeta = const VerificationMeta(
    'timestampsBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> timestampsBlob =
      GeneratedColumn<Uint8List>(
        'timestamps_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _speedsBlobMeta = const VerificationMeta(
    'speedsBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> speedsBlob = GeneratedColumn<Uint8List>(
    'speeds_blob',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuraciesBlobMeta = const VerificationMeta(
    'accuraciesBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> accuraciesBlob =
      GeneratedColumn<Uint8List>(
        'accuracies_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _bearingsBlobMeta = const VerificationMeta(
    'bearingsBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> bearingsBlob =
      GeneratedColumn<Uint8List>(
        'bearings_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userTrackId,
    segmentOrder,
    coordinatesBlob,
    timestampsBlob,
    speedsBlob,
    accuraciesBlob,
    bearingsBlob,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compact_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompactTrackData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_track_id')) {
      context.handle(
        _userTrackIdMeta,
        userTrackId.isAcceptableOrUnknown(
          data['user_track_id']!,
          _userTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userTrackIdMeta);
    }
    if (data.containsKey('segment_order')) {
      context.handle(
        _segmentOrderMeta,
        segmentOrder.isAcceptableOrUnknown(
          data['segment_order']!,
          _segmentOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentOrderMeta);
    }
    if (data.containsKey('coordinates_blob')) {
      context.handle(
        _coordinatesBlobMeta,
        coordinatesBlob.isAcceptableOrUnknown(
          data['coordinates_blob']!,
          _coordinatesBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coordinatesBlobMeta);
    }
    if (data.containsKey('timestamps_blob')) {
      context.handle(
        _timestampsBlobMeta,
        timestampsBlob.isAcceptableOrUnknown(
          data['timestamps_blob']!,
          _timestampsBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampsBlobMeta);
    }
    if (data.containsKey('speeds_blob')) {
      context.handle(
        _speedsBlobMeta,
        speedsBlob.isAcceptableOrUnknown(data['speeds_blob']!, _speedsBlobMeta),
      );
    } else if (isInserting) {
      context.missing(_speedsBlobMeta);
    }
    if (data.containsKey('accuracies_blob')) {
      context.handle(
        _accuraciesBlobMeta,
        accuraciesBlob.isAcceptableOrUnknown(
          data['accuracies_blob']!,
          _accuraciesBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accuraciesBlobMeta);
    }
    if (data.containsKey('bearings_blob')) {
      context.handle(
        _bearingsBlobMeta,
        bearingsBlob.isAcceptableOrUnknown(
          data['bearings_blob']!,
          _bearingsBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bearingsBlobMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompactTrackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompactTrackData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_track_id'],
      )!,
      segmentOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_order'],
      )!,
      coordinatesBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}coordinates_blob'],
      )!,
      timestampsBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}timestamps_blob'],
      )!,
      speedsBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}speeds_blob'],
      )!,
      accuraciesBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}accuracies_blob'],
      )!,
      bearingsBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bearings_blob'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CompactTracksTable createAlias(String alias) {
    return $CompactTracksTable(attachedDatabase, alias);
  }
}

class CompactTrackData extends DataClass
    implements Insertable<CompactTrackData> {
  final int id;
  final int userTrackId;
  final int segmentOrder;
  final Uint8List coordinatesBlob;

  /// Временные метки (timestamps в binary)
  final Uint8List timestampsBlob;

  /// Скорости (speeds в binary)
  final Uint8List speedsBlob;

  /// Точности GPS (accuracies в binary)
  final Uint8List accuraciesBlob;

  /// Направления движения (bearings в binary)
  final Uint8List bearingsBlob;

  /// Время создания
  final DateTime createdAt;
  const CompactTrackData({
    required this.id,
    required this.userTrackId,
    required this.segmentOrder,
    required this.coordinatesBlob,
    required this.timestampsBlob,
    required this.speedsBlob,
    required this.accuraciesBlob,
    required this.bearingsBlob,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_track_id'] = Variable<int>(userTrackId);
    map['segment_order'] = Variable<int>(segmentOrder);
    map['coordinates_blob'] = Variable<Uint8List>(coordinatesBlob);
    map['timestamps_blob'] = Variable<Uint8List>(timestampsBlob);
    map['speeds_blob'] = Variable<Uint8List>(speedsBlob);
    map['accuracies_blob'] = Variable<Uint8List>(accuraciesBlob);
    map['bearings_blob'] = Variable<Uint8List>(bearingsBlob);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CompactTracksCompanion toCompanion(bool nullToAbsent) {
    return CompactTracksCompanion(
      id: Value(id),
      userTrackId: Value(userTrackId),
      segmentOrder: Value(segmentOrder),
      coordinatesBlob: Value(coordinatesBlob),
      timestampsBlob: Value(timestampsBlob),
      speedsBlob: Value(speedsBlob),
      accuraciesBlob: Value(accuraciesBlob),
      bearingsBlob: Value(bearingsBlob),
      createdAt: Value(createdAt),
    );
  }

  factory CompactTrackData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompactTrackData(
      id: serializer.fromJson<int>(json['id']),
      userTrackId: serializer.fromJson<int>(json['userTrackId']),
      segmentOrder: serializer.fromJson<int>(json['segmentOrder']),
      coordinatesBlob: serializer.fromJson<Uint8List>(json['coordinatesBlob']),
      timestampsBlob: serializer.fromJson<Uint8List>(json['timestampsBlob']),
      speedsBlob: serializer.fromJson<Uint8List>(json['speedsBlob']),
      accuraciesBlob: serializer.fromJson<Uint8List>(json['accuraciesBlob']),
      bearingsBlob: serializer.fromJson<Uint8List>(json['bearingsBlob']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userTrackId': serializer.toJson<int>(userTrackId),
      'segmentOrder': serializer.toJson<int>(segmentOrder),
      'coordinatesBlob': serializer.toJson<Uint8List>(coordinatesBlob),
      'timestampsBlob': serializer.toJson<Uint8List>(timestampsBlob),
      'speedsBlob': serializer.toJson<Uint8List>(speedsBlob),
      'accuraciesBlob': serializer.toJson<Uint8List>(accuraciesBlob),
      'bearingsBlob': serializer.toJson<Uint8List>(bearingsBlob),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CompactTrackData copyWith({
    int? id,
    int? userTrackId,
    int? segmentOrder,
    Uint8List? coordinatesBlob,
    Uint8List? timestampsBlob,
    Uint8List? speedsBlob,
    Uint8List? accuraciesBlob,
    Uint8List? bearingsBlob,
    DateTime? createdAt,
  }) => CompactTrackData(
    id: id ?? this.id,
    userTrackId: userTrackId ?? this.userTrackId,
    segmentOrder: segmentOrder ?? this.segmentOrder,
    coordinatesBlob: coordinatesBlob ?? this.coordinatesBlob,
    timestampsBlob: timestampsBlob ?? this.timestampsBlob,
    speedsBlob: speedsBlob ?? this.speedsBlob,
    accuraciesBlob: accuraciesBlob ?? this.accuraciesBlob,
    bearingsBlob: bearingsBlob ?? this.bearingsBlob,
    createdAt: createdAt ?? this.createdAt,
  );
  CompactTrackData copyWithCompanion(CompactTracksCompanion data) {
    return CompactTrackData(
      id: data.id.present ? data.id.value : this.id,
      userTrackId: data.userTrackId.present
          ? data.userTrackId.value
          : this.userTrackId,
      segmentOrder: data.segmentOrder.present
          ? data.segmentOrder.value
          : this.segmentOrder,
      coordinatesBlob: data.coordinatesBlob.present
          ? data.coordinatesBlob.value
          : this.coordinatesBlob,
      timestampsBlob: data.timestampsBlob.present
          ? data.timestampsBlob.value
          : this.timestampsBlob,
      speedsBlob: data.speedsBlob.present
          ? data.speedsBlob.value
          : this.speedsBlob,
      accuraciesBlob: data.accuraciesBlob.present
          ? data.accuraciesBlob.value
          : this.accuraciesBlob,
      bearingsBlob: data.bearingsBlob.present
          ? data.bearingsBlob.value
          : this.bearingsBlob,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompactTrackData(')
          ..write('id: $id, ')
          ..write('userTrackId: $userTrackId, ')
          ..write('segmentOrder: $segmentOrder, ')
          ..write('coordinatesBlob: $coordinatesBlob, ')
          ..write('timestampsBlob: $timestampsBlob, ')
          ..write('speedsBlob: $speedsBlob, ')
          ..write('accuraciesBlob: $accuraciesBlob, ')
          ..write('bearingsBlob: $bearingsBlob, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userTrackId,
    segmentOrder,
    $driftBlobEquality.hash(coordinatesBlob),
    $driftBlobEquality.hash(timestampsBlob),
    $driftBlobEquality.hash(speedsBlob),
    $driftBlobEquality.hash(accuraciesBlob),
    $driftBlobEquality.hash(bearingsBlob),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompactTrackData &&
          other.id == this.id &&
          other.userTrackId == this.userTrackId &&
          other.segmentOrder == this.segmentOrder &&
          $driftBlobEquality.equals(
            other.coordinatesBlob,
            this.coordinatesBlob,
          ) &&
          $driftBlobEquality.equals(
            other.timestampsBlob,
            this.timestampsBlob,
          ) &&
          $driftBlobEquality.equals(other.speedsBlob, this.speedsBlob) &&
          $driftBlobEquality.equals(
            other.accuraciesBlob,
            this.accuraciesBlob,
          ) &&
          $driftBlobEquality.equals(other.bearingsBlob, this.bearingsBlob) &&
          other.createdAt == this.createdAt);
}

class CompactTracksCompanion extends UpdateCompanion<CompactTrackData> {
  final Value<int> id;
  final Value<int> userTrackId;
  final Value<int> segmentOrder;
  final Value<Uint8List> coordinatesBlob;
  final Value<Uint8List> timestampsBlob;
  final Value<Uint8List> speedsBlob;
  final Value<Uint8List> accuraciesBlob;
  final Value<Uint8List> bearingsBlob;
  final Value<DateTime> createdAt;
  const CompactTracksCompanion({
    this.id = const Value.absent(),
    this.userTrackId = const Value.absent(),
    this.segmentOrder = const Value.absent(),
    this.coordinatesBlob = const Value.absent(),
    this.timestampsBlob = const Value.absent(),
    this.speedsBlob = const Value.absent(),
    this.accuraciesBlob = const Value.absent(),
    this.bearingsBlob = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CompactTracksCompanion.insert({
    this.id = const Value.absent(),
    required int userTrackId,
    required int segmentOrder,
    required Uint8List coordinatesBlob,
    required Uint8List timestampsBlob,
    required Uint8List speedsBlob,
    required Uint8List accuraciesBlob,
    required Uint8List bearingsBlob,
    this.createdAt = const Value.absent(),
  }) : userTrackId = Value(userTrackId),
       segmentOrder = Value(segmentOrder),
       coordinatesBlob = Value(coordinatesBlob),
       timestampsBlob = Value(timestampsBlob),
       speedsBlob = Value(speedsBlob),
       accuraciesBlob = Value(accuraciesBlob),
       bearingsBlob = Value(bearingsBlob);
  static Insertable<CompactTrackData> custom({
    Expression<int>? id,
    Expression<int>? userTrackId,
    Expression<int>? segmentOrder,
    Expression<Uint8List>? coordinatesBlob,
    Expression<Uint8List>? timestampsBlob,
    Expression<Uint8List>? speedsBlob,
    Expression<Uint8List>? accuraciesBlob,
    Expression<Uint8List>? bearingsBlob,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userTrackId != null) 'user_track_id': userTrackId,
      if (segmentOrder != null) 'segment_order': segmentOrder,
      if (coordinatesBlob != null) 'coordinates_blob': coordinatesBlob,
      if (timestampsBlob != null) 'timestamps_blob': timestampsBlob,
      if (speedsBlob != null) 'speeds_blob': speedsBlob,
      if (accuraciesBlob != null) 'accuracies_blob': accuraciesBlob,
      if (bearingsBlob != null) 'bearings_blob': bearingsBlob,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CompactTracksCompanion copyWith({
    Value<int>? id,
    Value<int>? userTrackId,
    Value<int>? segmentOrder,
    Value<Uint8List>? coordinatesBlob,
    Value<Uint8List>? timestampsBlob,
    Value<Uint8List>? speedsBlob,
    Value<Uint8List>? accuraciesBlob,
    Value<Uint8List>? bearingsBlob,
    Value<DateTime>? createdAt,
  }) {
    return CompactTracksCompanion(
      id: id ?? this.id,
      userTrackId: userTrackId ?? this.userTrackId,
      segmentOrder: segmentOrder ?? this.segmentOrder,
      coordinatesBlob: coordinatesBlob ?? this.coordinatesBlob,
      timestampsBlob: timestampsBlob ?? this.timestampsBlob,
      speedsBlob: speedsBlob ?? this.speedsBlob,
      accuraciesBlob: accuraciesBlob ?? this.accuraciesBlob,
      bearingsBlob: bearingsBlob ?? this.bearingsBlob,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userTrackId.present) {
      map['user_track_id'] = Variable<int>(userTrackId.value);
    }
    if (segmentOrder.present) {
      map['segment_order'] = Variable<int>(segmentOrder.value);
    }
    if (coordinatesBlob.present) {
      map['coordinates_blob'] = Variable<Uint8List>(coordinatesBlob.value);
    }
    if (timestampsBlob.present) {
      map['timestamps_blob'] = Variable<Uint8List>(timestampsBlob.value);
    }
    if (speedsBlob.present) {
      map['speeds_blob'] = Variable<Uint8List>(speedsBlob.value);
    }
    if (accuraciesBlob.present) {
      map['accuracies_blob'] = Variable<Uint8List>(accuraciesBlob.value);
    }
    if (bearingsBlob.present) {
      map['bearings_blob'] = Variable<Uint8List>(bearingsBlob.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompactTracksCompanion(')
          ..write('id: $id, ')
          ..write('userTrackId: $userTrackId, ')
          ..write('segmentOrder: $segmentOrder, ')
          ..write('coordinatesBlob: $coordinatesBlob, ')
          ..write('timestampsBlob: $timestampsBlob, ')
          ..write('speedsBlob: $speedsBlob, ')
          ..write('accuraciesBlob: $accuraciesBlob, ')
          ..write('bearingsBlob: $bearingsBlob, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppUsersTable extends AppUsers
    with TableInfo<$AppUsersTable, AppUserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _selectedTradingPointIdMeta =
      const VerificationMeta('selectedTradingPointId');
  @override
  late final GeneratedColumn<int> selectedTradingPointId = GeneratedColumn<int>(
    'selected_trading_point_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    employeeId,
    userId,
    selectedTradingPointId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUserData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('selected_trading_point_id')) {
      context.handle(
        _selectedTradingPointIdMeta,
        selectedTradingPointId.isAcceptableOrUnknown(
          data['selected_trading_point_id']!,
          _selectedTradingPointIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {employeeId};
  @override
  AppUserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserData(
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      selectedTradingPointId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_trading_point_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUserData extends DataClass implements Insertable<AppUserData> {
  final int employeeId;
  final int userId;
  final int? selectedTradingPointId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AppUserData({
    required this.employeeId,
    required this.userId,
    this.selectedTradingPointId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['employee_id'] = Variable<int>(employeeId);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || selectedTradingPointId != null) {
      map['selected_trading_point_id'] = Variable<int>(selectedTradingPointId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      employeeId: Value(employeeId),
      userId: Value(userId),
      selectedTradingPointId: selectedTradingPointId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedTradingPointId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppUserData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserData(
      employeeId: serializer.fromJson<int>(json['employeeId']),
      userId: serializer.fromJson<int>(json['userId']),
      selectedTradingPointId: serializer.fromJson<int?>(
        json['selectedTradingPointId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'employeeId': serializer.toJson<int>(employeeId),
      'userId': serializer.toJson<int>(userId),
      'selectedTradingPointId': serializer.toJson<int?>(selectedTradingPointId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppUserData copyWith({
    int? employeeId,
    int? userId,
    Value<int?> selectedTradingPointId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AppUserData(
    employeeId: employeeId ?? this.employeeId,
    userId: userId ?? this.userId,
    selectedTradingPointId: selectedTradingPointId.present
        ? selectedTradingPointId.value
        : this.selectedTradingPointId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppUserData copyWithCompanion(AppUsersCompanion data) {
    return AppUserData(
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      userId: data.userId.present ? data.userId.value : this.userId,
      selectedTradingPointId: data.selectedTradingPointId.present
          ? data.selectedTradingPointId.value
          : this.selectedTradingPointId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserData(')
          ..write('employeeId: $employeeId, ')
          ..write('userId: $userId, ')
          ..write('selectedTradingPointId: $selectedTradingPointId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    employeeId,
    userId,
    selectedTradingPointId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserData &&
          other.employeeId == this.employeeId &&
          other.userId == this.userId &&
          other.selectedTradingPointId == this.selectedTradingPointId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUserData> {
  final Value<int> employeeId;
  final Value<int> userId;
  final Value<int?> selectedTradingPointId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AppUsersCompanion({
    this.employeeId = const Value.absent(),
    this.userId = const Value.absent(),
    this.selectedTradingPointId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.employeeId = const Value.absent(),
    required int userId,
    this.selectedTradingPointId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<AppUserData> custom({
    Expression<int>? employeeId,
    Expression<int>? userId,
    Expression<int>? selectedTradingPointId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (employeeId != null) 'employee_id': employeeId,
      if (userId != null) 'user_id': userId,
      if (selectedTradingPointId != null)
        'selected_trading_point_id': selectedTradingPointId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppUsersCompanion copyWith({
    Value<int>? employeeId,
    Value<int>? userId,
    Value<int?>? selectedTradingPointId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AppUsersCompanion(
      employeeId: employeeId ?? this.employeeId,
      userId: userId ?? this.userId,
      selectedTradingPointId:
          selectedTradingPointId ?? this.selectedTradingPointId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (employeeId.present) {
      map['employee_id'] = Variable<int>(employeeId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (selectedTradingPointId.present) {
      map['selected_trading_point_id'] = Variable<int>(
        selectedTradingPointId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('employeeId: $employeeId, ')
          ..write('userId: $userId, ')
          ..write('selectedTradingPointId: $selectedTradingPointId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WorkDaysTable extends WorkDays
    with TableInfo<$WorkDaysTable, WorkDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<int> user = GeneratedColumn<int>(
    'user',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    user,
    date,
    routeId,
    trackId,
    status,
    startTime,
    endTime,
    metadata,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkDayData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user')) {
      context.handle(
        _userMeta,
        user.isAcceptableOrUnknown(data['user']!, _userMeta),
      );
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {user, date},
  ];
  @override
  WorkDayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkDayData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      user: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      ),
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkDaysTable createAlias(String alias) {
    return $WorkDaysTable(attachedDatabase, alias);
  }
}

class WorkDayData extends DataClass implements Insertable<WorkDayData> {
  final int id;
  final int user;
  final DateTime date;
  final int? routeId;
  final int? trackId;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkDayData({
    required this.id,
    required this.user,
    required this.date,
    this.routeId,
    this.trackId,
    required this.status,
    this.startTime,
    this.endTime,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user'] = Variable<int>(user);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || routeId != null) {
      map['route_id'] = Variable<int>(routeId);
    }
    if (!nullToAbsent || trackId != null) {
      map['track_id'] = Variable<int>(trackId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkDaysCompanion toCompanion(bool nullToAbsent) {
    return WorkDaysCompanion(
      id: Value(id),
      user: Value(user),
      date: Value(date),
      routeId: routeId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeId),
      trackId: trackId == null && nullToAbsent
          ? const Value.absent()
          : Value(trackId),
      status: Value(status),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkDayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkDayData(
      id: serializer.fromJson<int>(json['id']),
      user: serializer.fromJson<int>(json['user']),
      date: serializer.fromJson<DateTime>(json['date']),
      routeId: serializer.fromJson<int?>(json['routeId']),
      trackId: serializer.fromJson<int?>(json['trackId']),
      status: serializer.fromJson<String>(json['status']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'user': serializer.toJson<int>(user),
      'date': serializer.toJson<DateTime>(date),
      'routeId': serializer.toJson<int?>(routeId),
      'trackId': serializer.toJson<int?>(trackId),
      'status': serializer.toJson<String>(status),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkDayData copyWith({
    int? id,
    int? user,
    DateTime? date,
    Value<int?> routeId = const Value.absent(),
    Value<int?> trackId = const Value.absent(),
    String? status,
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkDayData(
    id: id ?? this.id,
    user: user ?? this.user,
    date: date ?? this.date,
    routeId: routeId.present ? routeId.value : this.routeId,
    trackId: trackId.present ? trackId.value : this.trackId,
    status: status ?? this.status,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkDayData copyWithCompanion(WorkDaysCompanion data) {
    return WorkDayData(
      id: data.id.present ? data.id.value : this.id,
      user: data.user.present ? data.user.value : this.user,
      date: data.date.present ? data.date.value : this.date,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      status: data.status.present ? data.status.value : this.status,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkDayData(')
          ..write('id: $id, ')
          ..write('user: $user, ')
          ..write('date: $date, ')
          ..write('routeId: $routeId, ')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    user,
    date,
    routeId,
    trackId,
    status,
    startTime,
    endTime,
    metadata,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkDayData &&
          other.id == this.id &&
          other.user == this.user &&
          other.date == this.date &&
          other.routeId == this.routeId &&
          other.trackId == this.trackId &&
          other.status == this.status &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkDaysCompanion extends UpdateCompanion<WorkDayData> {
  final Value<int> id;
  final Value<int> user;
  final Value<DateTime> date;
  final Value<int?> routeId;
  final Value<int?> trackId;
  final Value<String> status;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<String?> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WorkDaysCompanion({
    this.id = const Value.absent(),
    this.user = const Value.absent(),
    this.date = const Value.absent(),
    this.routeId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WorkDaysCompanion.insert({
    this.id = const Value.absent(),
    required int user,
    required DateTime date,
    this.routeId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.status = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : user = Value(user),
       date = Value(date);
  static Insertable<WorkDayData> custom({
    Expression<int>? id,
    Expression<int>? user,
    Expression<DateTime>? date,
    Expression<int>? routeId,
    Expression<int>? trackId,
    Expression<String>? status,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (user != null) 'user': user,
      if (date != null) 'date': date,
      if (routeId != null) 'route_id': routeId,
      if (trackId != null) 'track_id': trackId,
      if (status != null) 'status': status,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WorkDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? user,
    Value<DateTime>? date,
    Value<int?>? routeId,
    Value<int?>? trackId,
    Value<String>? status,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<String?>? metadata,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WorkDaysCompanion(
      id: id ?? this.id,
      user: user ?? this.user,
      date: date ?? this.date,
      routeId: routeId ?? this.routeId,
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (user.present) {
      map['user'] = Variable<int>(user.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkDaysCompanion(')
          ..write('id: $id, ')
          ..write('user: $user, ')
          ..write('date: $date, ')
          ..write('routeId: $routeId, ')
          ..write('trackId: $trackId, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _lftMeta = const VerificationMeta('lft');
  @override
  late final GeneratedColumn<int> lft = GeneratedColumn<int>(
    'lft',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lvlMeta = const VerificationMeta('lvl');
  @override
  late final GeneratedColumn<int> lvl = GeneratedColumn<int>(
    'lvl',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rgtMeta = const VerificationMeta('rgt');
  @override
  late final GeneratedColumn<int> rgt = GeneratedColumn<int>(
    'rgt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    categoryId,
    lft,
    lvl,
    rgt,
    description,
    query,
    count,
    parentId,
    rawJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('lft')) {
      context.handle(
        _lftMeta,
        lft.isAcceptableOrUnknown(data['lft']!, _lftMeta),
      );
    } else if (isInserting) {
      context.missing(_lftMeta);
    }
    if (data.containsKey('lvl')) {
      context.handle(
        _lvlMeta,
        lvl.isAcceptableOrUnknown(data['lvl']!, _lvlMeta),
      );
    } else if (isInserting) {
      context.missing(_lvlMeta);
    }
    if (data.containsKey('rgt')) {
      context.handle(
        _rgtMeta,
        rgt.isAcceptableOrUnknown(data['rgt']!, _rgtMeta),
      );
    } else if (isInserting) {
      context.missing(_rgtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      lft: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lft'],
      )!,
      lvl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lvl'],
      )!,
      rgt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rgt'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String name;
  final int categoryId;
  final int lft;
  final int lvl;
  final int rgt;
  final String? description;
  final String? query;
  final int count;
  final int? parentId;
  final String rawJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CategoryData({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.lft,
    required this.lvl,
    required this.rgt,
    this.description,
    this.query,
    required this.count,
    this.parentId,
    required this.rawJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<int>(categoryId);
    map['lft'] = Variable<int>(lft);
    map['lvl'] = Variable<int>(lvl);
    map['rgt'] = Variable<int>(rgt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || query != null) {
      map['query'] = Variable<String>(query);
    }
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['raw_json'] = Variable<String>(rawJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: Value(categoryId),
      lft: Value(lft),
      lvl: Value(lvl),
      rgt: Value(rgt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      query: query == null && nullToAbsent
          ? const Value.absent()
          : Value(query),
      count: Value(count),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      rawJson: Value(rawJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      lft: serializer.fromJson<int>(json['lft']),
      lvl: serializer.fromJson<int>(json['lvl']),
      rgt: serializer.fromJson<int>(json['rgt']),
      description: serializer.fromJson<String?>(json['description']),
      query: serializer.fromJson<String?>(json['query']),
      count: serializer.fromJson<int>(json['count']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int>(categoryId),
      'lft': serializer.toJson<int>(lft),
      'lvl': serializer.toJson<int>(lvl),
      'rgt': serializer.toJson<int>(rgt),
      'description': serializer.toJson<String?>(description),
      'query': serializer.toJson<String?>(query),
      'count': serializer.toJson<int>(count),
      'parentId': serializer.toJson<int?>(parentId),
      'rawJson': serializer.toJson<String>(rawJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CategoryData copyWith({
    int? id,
    String? name,
    int? categoryId,
    int? lft,
    int? lvl,
    int? rgt,
    Value<String?> description = const Value.absent(),
    Value<String?> query = const Value.absent(),
    int? count,
    Value<int?> parentId = const Value.absent(),
    String? rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CategoryData(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    lft: lft ?? this.lft,
    lvl: lvl ?? this.lvl,
    rgt: rgt ?? this.rgt,
    description: description.present ? description.value : this.description,
    query: query.present ? query.value : this.query,
    count: count ?? this.count,
    parentId: parentId.present ? parentId.value : this.parentId,
    rawJson: rawJson ?? this.rawJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CategoryData copyWithCompanion(CategoriesCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      lft: data.lft.present ? data.lft.value : this.lft,
      lvl: data.lvl.present ? data.lvl.value : this.lvl,
      rgt: data.rgt.present ? data.rgt.value : this.rgt,
      description: data.description.present
          ? data.description.value
          : this.description,
      query: data.query.present ? data.query.value : this.query,
      count: data.count.present ? data.count.value : this.count,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('lft: $lft, ')
          ..write('lvl: $lvl, ')
          ..write('rgt: $rgt, ')
          ..write('description: $description, ')
          ..write('query: $query, ')
          ..write('count: $count, ')
          ..write('parentId: $parentId, ')
          ..write('rawJson: $rawJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    categoryId,
    lft,
    lvl,
    rgt,
    description,
    query,
    count,
    parentId,
    rawJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.lft == this.lft &&
          other.lvl == this.lvl &&
          other.rgt == this.rgt &&
          other.description == this.description &&
          other.query == this.query &&
          other.count == this.count &&
          other.parentId == this.parentId &&
          other.rawJson == this.rawJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> categoryId;
  final Value<int> lft;
  final Value<int> lvl;
  final Value<int> rgt;
  final Value<String?> description;
  final Value<String?> query;
  final Value<int> count;
  final Value<int?> parentId;
  final Value<String> rawJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lft = const Value.absent(),
    this.lvl = const Value.absent(),
    this.rgt = const Value.absent(),
    this.description = const Value.absent(),
    this.query = const Value.absent(),
    this.count = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int categoryId,
    required int lft,
    required int lvl,
    required int rgt,
    this.description = const Value.absent(),
    this.query = const Value.absent(),
    required int count,
    this.parentId = const Value.absent(),
    required String rawJson,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       categoryId = Value(categoryId),
       lft = Value(lft),
       lvl = Value(lvl),
       rgt = Value(rgt),
       count = Value(count),
       rawJson = Value(rawJson);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? lft,
    Expression<int>? lvl,
    Expression<int>? rgt,
    Expression<String>? description,
    Expression<String>? query,
    Expression<int>? count,
    Expression<int>? parentId,
    Expression<String>? rawJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (lft != null) 'lft': lft,
      if (lvl != null) 'lvl': lvl,
      if (rgt != null) 'rgt': rgt,
      if (description != null) 'description': description,
      if (query != null) 'query': query,
      if (count != null) 'count': count,
      if (parentId != null) 'parent_id': parentId,
      if (rawJson != null) 'raw_json': rawJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? categoryId,
    Value<int>? lft,
    Value<int>? lvl,
    Value<int>? rgt,
    Value<String?>? description,
    Value<String?>? query,
    Value<int>? count,
    Value<int?>? parentId,
    Value<String>? rawJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      lft: lft ?? this.lft,
      lvl: lvl ?? this.lvl,
      rgt: rgt ?? this.rgt,
      description: description ?? this.description,
      query: query ?? this.query,
      count: count ?? this.count,
      parentId: parentId ?? this.parentId,
      rawJson: rawJson ?? this.rawJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (lft.present) {
      map['lft'] = Variable<int>(lft.value);
    }
    if (lvl.present) {
      map['lvl'] = Variable<int>(lvl.value);
    }
    if (rgt.present) {
      map['rgt'] = Variable<int>(rgt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('lft: $lft, ')
          ..write('lvl: $lvl, ')
          ..write('rgt: $rgt, ')
          ..write('description: $description, ')
          ..write('query: $query, ')
          ..write('count: $count, ')
          ..write('parentId: $parentId, ')
          ..write('rawJson: $rawJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<int> catalogId = GeneratedColumn<int>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<int> code = GeneratedColumn<int>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bcodeMeta = const VerificationMeta('bcode');
  @override
  late final GeneratedColumn<int> bcode = GeneratedColumn<int>(
    'bcode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vendorCodeMeta = const VerificationMeta(
    'vendorCode',
  );
  @override
  late final GeneratedColumn<String> vendorCode = GeneratedColumn<String>(
    'vendor_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountInPackageMeta = const VerificationMeta(
    'amountInPackage',
  );
  @override
  late final GeneratedColumn<int> amountInPackage = GeneratedColumn<int>(
    'amount_in_package',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noveltyMeta = const VerificationMeta(
    'novelty',
  );
  @override
  late final GeneratedColumn<bool> novelty = GeneratedColumn<bool>(
    'novelty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("novelty" IN (0, 1))',
    ),
  );
  static const VerificationMeta _popularMeta = const VerificationMeta(
    'popular',
  );
  @override
  late final GeneratedColumn<bool> popular = GeneratedColumn<bool>(
    'popular',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("popular" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isMarkedMeta = const VerificationMeta(
    'isMarked',
  );
  @override
  late final GeneratedColumn<bool> isMarked = GeneratedColumn<bool>(
    'is_marked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_marked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _canBuyMeta = const VerificationMeta('canBuy');
  @override
  late final GeneratedColumn<bool> canBuy = GeneratedColumn<bool>(
    'can_buy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_buy" IN (0, 1))',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
    'type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceListCategoryIdMeta =
      const VerificationMeta('priceListCategoryId');
  @override
  late final GeneratedColumn<int> priceListCategoryId = GeneratedColumn<int>(
    'price_list_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultImageJsonMeta = const VerificationMeta(
    'defaultImageJson',
  );
  @override
  late final GeneratedColumn<String> defaultImageJson = GeneratedColumn<String>(
    'default_image_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagesJsonMeta = const VerificationMeta(
    'imagesJson',
  );
  @override
  late final GeneratedColumn<String> imagesJson = GeneratedColumn<String>(
    'images_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodesJsonMeta = const VerificationMeta(
    'barcodesJson',
  );
  @override
  late final GeneratedColumn<String> barcodesJson = GeneratedColumn<String>(
    'barcodes_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _howToUseMeta = const VerificationMeta(
    'howToUse',
  );
  @override
  late final GeneratedColumn<String> howToUse = GeneratedColumn<String>(
    'how_to_use',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientsMeta = const VerificationMeta(
    'ingredients',
  );
  @override
  late final GeneratedColumn<String> ingredients = GeneratedColumn<String>(
    'ingredients',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catalogId,
    code,
    bcode,
    title,
    description,
    vendorCode,
    amountInPackage,
    novelty,
    popular,
    isMarked,
    canBuy,
    categoryId,
    typeId,
    priceListCategoryId,
    defaultImageJson,
    imagesJson,
    barcodesJson,
    howToUse,
    ingredients,
    rawJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('bcode')) {
      context.handle(
        _bcodeMeta,
        bcode.isAcceptableOrUnknown(data['bcode']!, _bcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bcodeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('vendor_code')) {
      context.handle(
        _vendorCodeMeta,
        vendorCode.isAcceptableOrUnknown(data['vendor_code']!, _vendorCodeMeta),
      );
    }
    if (data.containsKey('amount_in_package')) {
      context.handle(
        _amountInPackageMeta,
        amountInPackage.isAcceptableOrUnknown(
          data['amount_in_package']!,
          _amountInPackageMeta,
        ),
      );
    }
    if (data.containsKey('novelty')) {
      context.handle(
        _noveltyMeta,
        novelty.isAcceptableOrUnknown(data['novelty']!, _noveltyMeta),
      );
    } else if (isInserting) {
      context.missing(_noveltyMeta);
    }
    if (data.containsKey('popular')) {
      context.handle(
        _popularMeta,
        popular.isAcceptableOrUnknown(data['popular']!, _popularMeta),
      );
    } else if (isInserting) {
      context.missing(_popularMeta);
    }
    if (data.containsKey('is_marked')) {
      context.handle(
        _isMarkedMeta,
        isMarked.isAcceptableOrUnknown(data['is_marked']!, _isMarkedMeta),
      );
    } else if (isInserting) {
      context.missing(_isMarkedMeta);
    }
    if (data.containsKey('can_buy')) {
      context.handle(
        _canBuyMeta,
        canBuy.isAcceptableOrUnknown(data['can_buy']!, _canBuyMeta),
      );
    } else if (isInserting) {
      context.missing(_canBuyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    }
    if (data.containsKey('price_list_category_id')) {
      context.handle(
        _priceListCategoryIdMeta,
        priceListCategoryId.isAcceptableOrUnknown(
          data['price_list_category_id']!,
          _priceListCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('default_image_json')) {
      context.handle(
        _defaultImageJsonMeta,
        defaultImageJson.isAcceptableOrUnknown(
          data['default_image_json']!,
          _defaultImageJsonMeta,
        ),
      );
    }
    if (data.containsKey('images_json')) {
      context.handle(
        _imagesJsonMeta,
        imagesJson.isAcceptableOrUnknown(data['images_json']!, _imagesJsonMeta),
      );
    }
    if (data.containsKey('barcodes_json')) {
      context.handle(
        _barcodesJsonMeta,
        barcodesJson.isAcceptableOrUnknown(
          data['barcodes_json']!,
          _barcodesJsonMeta,
        ),
      );
    }
    if (data.containsKey('how_to_use')) {
      context.handle(
        _howToUseMeta,
        howToUse.isAcceptableOrUnknown(data['how_to_use']!, _howToUseMeta),
      );
    }
    if (data.containsKey('ingredients')) {
      context.handle(
        _ingredientsMeta,
        ingredients.isAcceptableOrUnknown(
          data['ingredients']!,
          _ingredientsMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}catalog_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}code'],
      )!,
      bcode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bcode'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      vendorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_code'],
      ),
      amountInPackage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_in_package'],
      ),
      novelty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}novelty'],
      )!,
      popular: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}popular'],
      )!,
      isMarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_marked'],
      )!,
      canBuy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_buy'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type_id'],
      ),
      priceListCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_list_category_id'],
      ),
      defaultImageJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_image_json'],
      ),
      imagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images_json'],
      ),
      barcodesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcodes_json'],
      ),
      howToUse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}how_to_use'],
      ),
      ingredients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductData extends DataClass implements Insertable<ProductData> {
  final int id;
  final int catalogId;
  final int code;
  final int bcode;
  final String title;
  final String? description;
  final String? vendorCode;
  final int? amountInPackage;
  final bool novelty;
  final bool popular;
  final bool isMarked;
  final bool canBuy;
  final int? categoryId;
  final int? typeId;
  final int? priceListCategoryId;
  final String? defaultImageJson;
  final String? imagesJson;
  final String? barcodesJson;
  final String? howToUse;
  final String? ingredients;
  final String rawJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProductData({
    required this.id,
    required this.catalogId,
    required this.code,
    required this.bcode,
    required this.title,
    this.description,
    this.vendorCode,
    this.amountInPackage,
    required this.novelty,
    required this.popular,
    required this.isMarked,
    required this.canBuy,
    this.categoryId,
    this.typeId,
    this.priceListCategoryId,
    this.defaultImageJson,
    this.imagesJson,
    this.barcodesJson,
    this.howToUse,
    this.ingredients,
    required this.rawJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['catalog_id'] = Variable<int>(catalogId);
    map['code'] = Variable<int>(code);
    map['bcode'] = Variable<int>(bcode);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || vendorCode != null) {
      map['vendor_code'] = Variable<String>(vendorCode);
    }
    if (!nullToAbsent || amountInPackage != null) {
      map['amount_in_package'] = Variable<int>(amountInPackage);
    }
    map['novelty'] = Variable<bool>(novelty);
    map['popular'] = Variable<bool>(popular);
    map['is_marked'] = Variable<bool>(isMarked);
    map['can_buy'] = Variable<bool>(canBuy);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || typeId != null) {
      map['type_id'] = Variable<int>(typeId);
    }
    if (!nullToAbsent || priceListCategoryId != null) {
      map['price_list_category_id'] = Variable<int>(priceListCategoryId);
    }
    if (!nullToAbsent || defaultImageJson != null) {
      map['default_image_json'] = Variable<String>(defaultImageJson);
    }
    if (!nullToAbsent || imagesJson != null) {
      map['images_json'] = Variable<String>(imagesJson);
    }
    if (!nullToAbsent || barcodesJson != null) {
      map['barcodes_json'] = Variable<String>(barcodesJson);
    }
    if (!nullToAbsent || howToUse != null) {
      map['how_to_use'] = Variable<String>(howToUse);
    }
    if (!nullToAbsent || ingredients != null) {
      map['ingredients'] = Variable<String>(ingredients);
    }
    map['raw_json'] = Variable<String>(rawJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      catalogId: Value(catalogId),
      code: Value(code),
      bcode: Value(bcode),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      vendorCode: vendorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorCode),
      amountInPackage: amountInPackage == null && nullToAbsent
          ? const Value.absent()
          : Value(amountInPackage),
      novelty: Value(novelty),
      popular: Value(popular),
      isMarked: Value(isMarked),
      canBuy: Value(canBuy),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      typeId: typeId == null && nullToAbsent
          ? const Value.absent()
          : Value(typeId),
      priceListCategoryId: priceListCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(priceListCategoryId),
      defaultImageJson: defaultImageJson == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultImageJson),
      imagesJson: imagesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(imagesJson),
      barcodesJson: barcodesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(barcodesJson),
      howToUse: howToUse == null && nullToAbsent
          ? const Value.absent()
          : Value(howToUse),
      ingredients: ingredients == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredients),
      rawJson: Value(rawJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductData(
      id: serializer.fromJson<int>(json['id']),
      catalogId: serializer.fromJson<int>(json['catalogId']),
      code: serializer.fromJson<int>(json['code']),
      bcode: serializer.fromJson<int>(json['bcode']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      vendorCode: serializer.fromJson<String?>(json['vendorCode']),
      amountInPackage: serializer.fromJson<int?>(json['amountInPackage']),
      novelty: serializer.fromJson<bool>(json['novelty']),
      popular: serializer.fromJson<bool>(json['popular']),
      isMarked: serializer.fromJson<bool>(json['isMarked']),
      canBuy: serializer.fromJson<bool>(json['canBuy']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      typeId: serializer.fromJson<int?>(json['typeId']),
      priceListCategoryId: serializer.fromJson<int?>(
        json['priceListCategoryId'],
      ),
      defaultImageJson: serializer.fromJson<String?>(json['defaultImageJson']),
      imagesJson: serializer.fromJson<String?>(json['imagesJson']),
      barcodesJson: serializer.fromJson<String?>(json['barcodesJson']),
      howToUse: serializer.fromJson<String?>(json['howToUse']),
      ingredients: serializer.fromJson<String?>(json['ingredients']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catalogId': serializer.toJson<int>(catalogId),
      'code': serializer.toJson<int>(code),
      'bcode': serializer.toJson<int>(bcode),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'vendorCode': serializer.toJson<String?>(vendorCode),
      'amountInPackage': serializer.toJson<int?>(amountInPackage),
      'novelty': serializer.toJson<bool>(novelty),
      'popular': serializer.toJson<bool>(popular),
      'isMarked': serializer.toJson<bool>(isMarked),
      'canBuy': serializer.toJson<bool>(canBuy),
      'categoryId': serializer.toJson<int?>(categoryId),
      'typeId': serializer.toJson<int?>(typeId),
      'priceListCategoryId': serializer.toJson<int?>(priceListCategoryId),
      'defaultImageJson': serializer.toJson<String?>(defaultImageJson),
      'imagesJson': serializer.toJson<String?>(imagesJson),
      'barcodesJson': serializer.toJson<String?>(barcodesJson),
      'howToUse': serializer.toJson<String?>(howToUse),
      'ingredients': serializer.toJson<String?>(ingredients),
      'rawJson': serializer.toJson<String>(rawJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductData copyWith({
    int? id,
    int? catalogId,
    int? code,
    int? bcode,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> vendorCode = const Value.absent(),
    Value<int?> amountInPackage = const Value.absent(),
    bool? novelty,
    bool? popular,
    bool? isMarked,
    bool? canBuy,
    Value<int?> categoryId = const Value.absent(),
    Value<int?> typeId = const Value.absent(),
    Value<int?> priceListCategoryId = const Value.absent(),
    Value<String?> defaultImageJson = const Value.absent(),
    Value<String?> imagesJson = const Value.absent(),
    Value<String?> barcodesJson = const Value.absent(),
    Value<String?> howToUse = const Value.absent(),
    Value<String?> ingredients = const Value.absent(),
    String? rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProductData(
    id: id ?? this.id,
    catalogId: catalogId ?? this.catalogId,
    code: code ?? this.code,
    bcode: bcode ?? this.bcode,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    vendorCode: vendorCode.present ? vendorCode.value : this.vendorCode,
    amountInPackage: amountInPackage.present
        ? amountInPackage.value
        : this.amountInPackage,
    novelty: novelty ?? this.novelty,
    popular: popular ?? this.popular,
    isMarked: isMarked ?? this.isMarked,
    canBuy: canBuy ?? this.canBuy,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    typeId: typeId.present ? typeId.value : this.typeId,
    priceListCategoryId: priceListCategoryId.present
        ? priceListCategoryId.value
        : this.priceListCategoryId,
    defaultImageJson: defaultImageJson.present
        ? defaultImageJson.value
        : this.defaultImageJson,
    imagesJson: imagesJson.present ? imagesJson.value : this.imagesJson,
    barcodesJson: barcodesJson.present ? barcodesJson.value : this.barcodesJson,
    howToUse: howToUse.present ? howToUse.value : this.howToUse,
    ingredients: ingredients.present ? ingredients.value : this.ingredients,
    rawJson: rawJson ?? this.rawJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProductData copyWithCompanion(ProductsCompanion data) {
    return ProductData(
      id: data.id.present ? data.id.value : this.id,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      code: data.code.present ? data.code.value : this.code,
      bcode: data.bcode.present ? data.bcode.value : this.bcode,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      vendorCode: data.vendorCode.present
          ? data.vendorCode.value
          : this.vendorCode,
      amountInPackage: data.amountInPackage.present
          ? data.amountInPackage.value
          : this.amountInPackage,
      novelty: data.novelty.present ? data.novelty.value : this.novelty,
      popular: data.popular.present ? data.popular.value : this.popular,
      isMarked: data.isMarked.present ? data.isMarked.value : this.isMarked,
      canBuy: data.canBuy.present ? data.canBuy.value : this.canBuy,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      priceListCategoryId: data.priceListCategoryId.present
          ? data.priceListCategoryId.value
          : this.priceListCategoryId,
      defaultImageJson: data.defaultImageJson.present
          ? data.defaultImageJson.value
          : this.defaultImageJson,
      imagesJson: data.imagesJson.present
          ? data.imagesJson.value
          : this.imagesJson,
      barcodesJson: data.barcodesJson.present
          ? data.barcodesJson.value
          : this.barcodesJson,
      howToUse: data.howToUse.present ? data.howToUse.value : this.howToUse,
      ingredients: data.ingredients.present
          ? data.ingredients.value
          : this.ingredients,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductData(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('code: $code, ')
          ..write('bcode: $bcode, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('vendorCode: $vendorCode, ')
          ..write('amountInPackage: $amountInPackage, ')
          ..write('novelty: $novelty, ')
          ..write('popular: $popular, ')
          ..write('isMarked: $isMarked, ')
          ..write('canBuy: $canBuy, ')
          ..write('categoryId: $categoryId, ')
          ..write('typeId: $typeId, ')
          ..write('priceListCategoryId: $priceListCategoryId, ')
          ..write('defaultImageJson: $defaultImageJson, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('barcodesJson: $barcodesJson, ')
          ..write('howToUse: $howToUse, ')
          ..write('ingredients: $ingredients, ')
          ..write('rawJson: $rawJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    catalogId,
    code,
    bcode,
    title,
    description,
    vendorCode,
    amountInPackage,
    novelty,
    popular,
    isMarked,
    canBuy,
    categoryId,
    typeId,
    priceListCategoryId,
    defaultImageJson,
    imagesJson,
    barcodesJson,
    howToUse,
    ingredients,
    rawJson,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductData &&
          other.id == this.id &&
          other.catalogId == this.catalogId &&
          other.code == this.code &&
          other.bcode == this.bcode &&
          other.title == this.title &&
          other.description == this.description &&
          other.vendorCode == this.vendorCode &&
          other.amountInPackage == this.amountInPackage &&
          other.novelty == this.novelty &&
          other.popular == this.popular &&
          other.isMarked == this.isMarked &&
          other.canBuy == this.canBuy &&
          other.categoryId == this.categoryId &&
          other.typeId == this.typeId &&
          other.priceListCategoryId == this.priceListCategoryId &&
          other.defaultImageJson == this.defaultImageJson &&
          other.imagesJson == this.imagesJson &&
          other.barcodesJson == this.barcodesJson &&
          other.howToUse == this.howToUse &&
          other.ingredients == this.ingredients &&
          other.rawJson == this.rawJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<ProductData> {
  final Value<int> id;
  final Value<int> catalogId;
  final Value<int> code;
  final Value<int> bcode;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> vendorCode;
  final Value<int?> amountInPackage;
  final Value<bool> novelty;
  final Value<bool> popular;
  final Value<bool> isMarked;
  final Value<bool> canBuy;
  final Value<int?> categoryId;
  final Value<int?> typeId;
  final Value<int?> priceListCategoryId;
  final Value<String?> defaultImageJson;
  final Value<String?> imagesJson;
  final Value<String?> barcodesJson;
  final Value<String?> howToUse;
  final Value<String?> ingredients;
  final Value<String> rawJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.code = const Value.absent(),
    this.bcode = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.vendorCode = const Value.absent(),
    this.amountInPackage = const Value.absent(),
    this.novelty = const Value.absent(),
    this.popular = const Value.absent(),
    this.isMarked = const Value.absent(),
    this.canBuy = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.typeId = const Value.absent(),
    this.priceListCategoryId = const Value.absent(),
    this.defaultImageJson = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.barcodesJson = const Value.absent(),
    this.howToUse = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required int catalogId,
    required int code,
    required int bcode,
    required String title,
    this.description = const Value.absent(),
    this.vendorCode = const Value.absent(),
    this.amountInPackage = const Value.absent(),
    required bool novelty,
    required bool popular,
    required bool isMarked,
    required bool canBuy,
    this.categoryId = const Value.absent(),
    this.typeId = const Value.absent(),
    this.priceListCategoryId = const Value.absent(),
    this.defaultImageJson = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.barcodesJson = const Value.absent(),
    this.howToUse = const Value.absent(),
    this.ingredients = const Value.absent(),
    required String rawJson,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : catalogId = Value(catalogId),
       code = Value(code),
       bcode = Value(bcode),
       title = Value(title),
       novelty = Value(novelty),
       popular = Value(popular),
       isMarked = Value(isMarked),
       canBuy = Value(canBuy),
       rawJson = Value(rawJson);
  static Insertable<ProductData> custom({
    Expression<int>? id,
    Expression<int>? catalogId,
    Expression<int>? code,
    Expression<int>? bcode,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? vendorCode,
    Expression<int>? amountInPackage,
    Expression<bool>? novelty,
    Expression<bool>? popular,
    Expression<bool>? isMarked,
    Expression<bool>? canBuy,
    Expression<int>? categoryId,
    Expression<int>? typeId,
    Expression<int>? priceListCategoryId,
    Expression<String>? defaultImageJson,
    Expression<String>? imagesJson,
    Expression<String>? barcodesJson,
    Expression<String>? howToUse,
    Expression<String>? ingredients,
    Expression<String>? rawJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catalogId != null) 'catalog_id': catalogId,
      if (code != null) 'code': code,
      if (bcode != null) 'bcode': bcode,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (vendorCode != null) 'vendor_code': vendorCode,
      if (amountInPackage != null) 'amount_in_package': amountInPackage,
      if (novelty != null) 'novelty': novelty,
      if (popular != null) 'popular': popular,
      if (isMarked != null) 'is_marked': isMarked,
      if (canBuy != null) 'can_buy': canBuy,
      if (categoryId != null) 'category_id': categoryId,
      if (typeId != null) 'type_id': typeId,
      if (priceListCategoryId != null)
        'price_list_category_id': priceListCategoryId,
      if (defaultImageJson != null) 'default_image_json': defaultImageJson,
      if (imagesJson != null) 'images_json': imagesJson,
      if (barcodesJson != null) 'barcodes_json': barcodesJson,
      if (howToUse != null) 'how_to_use': howToUse,
      if (ingredients != null) 'ingredients': ingredients,
      if (rawJson != null) 'raw_json': rawJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<int>? catalogId,
    Value<int>? code,
    Value<int>? bcode,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? vendorCode,
    Value<int?>? amountInPackage,
    Value<bool>? novelty,
    Value<bool>? popular,
    Value<bool>? isMarked,
    Value<bool>? canBuy,
    Value<int?>? categoryId,
    Value<int?>? typeId,
    Value<int?>? priceListCategoryId,
    Value<String?>? defaultImageJson,
    Value<String?>? imagesJson,
    Value<String?>? barcodesJson,
    Value<String?>? howToUse,
    Value<String?>? ingredients,
    Value<String>? rawJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      catalogId: catalogId ?? this.catalogId,
      code: code ?? this.code,
      bcode: bcode ?? this.bcode,
      title: title ?? this.title,
      description: description ?? this.description,
      vendorCode: vendorCode ?? this.vendorCode,
      amountInPackage: amountInPackage ?? this.amountInPackage,
      novelty: novelty ?? this.novelty,
      popular: popular ?? this.popular,
      isMarked: isMarked ?? this.isMarked,
      canBuy: canBuy ?? this.canBuy,
      categoryId: categoryId ?? this.categoryId,
      typeId: typeId ?? this.typeId,
      priceListCategoryId: priceListCategoryId ?? this.priceListCategoryId,
      defaultImageJson: defaultImageJson ?? this.defaultImageJson,
      imagesJson: imagesJson ?? this.imagesJson,
      barcodesJson: barcodesJson ?? this.barcodesJson,
      howToUse: howToUse ?? this.howToUse,
      ingredients: ingredients ?? this.ingredients,
      rawJson: rawJson ?? this.rawJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<int>(catalogId.value);
    }
    if (code.present) {
      map['code'] = Variable<int>(code.value);
    }
    if (bcode.present) {
      map['bcode'] = Variable<int>(bcode.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (vendorCode.present) {
      map['vendor_code'] = Variable<String>(vendorCode.value);
    }
    if (amountInPackage.present) {
      map['amount_in_package'] = Variable<int>(amountInPackage.value);
    }
    if (novelty.present) {
      map['novelty'] = Variable<bool>(novelty.value);
    }
    if (popular.present) {
      map['popular'] = Variable<bool>(popular.value);
    }
    if (isMarked.present) {
      map['is_marked'] = Variable<bool>(isMarked.value);
    }
    if (canBuy.present) {
      map['can_buy'] = Variable<bool>(canBuy.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<int>(typeId.value);
    }
    if (priceListCategoryId.present) {
      map['price_list_category_id'] = Variable<int>(priceListCategoryId.value);
    }
    if (defaultImageJson.present) {
      map['default_image_json'] = Variable<String>(defaultImageJson.value);
    }
    if (imagesJson.present) {
      map['images_json'] = Variable<String>(imagesJson.value);
    }
    if (barcodesJson.present) {
      map['barcodes_json'] = Variable<String>(barcodesJson.value);
    }
    if (howToUse.present) {
      map['how_to_use'] = Variable<String>(howToUse.value);
    }
    if (ingredients.present) {
      map['ingredients'] = Variable<String>(ingredients.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('code: $code, ')
          ..write('bcode: $bcode, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('vendorCode: $vendorCode, ')
          ..write('amountInPackage: $amountInPackage, ')
          ..write('novelty: $novelty, ')
          ..write('popular: $popular, ')
          ..write('isMarked: $isMarked, ')
          ..write('canBuy: $canBuy, ')
          ..write('categoryId: $categoryId, ')
          ..write('typeId: $typeId, ')
          ..write('priceListCategoryId: $priceListCategoryId, ')
          ..write('defaultImageJson: $defaultImageJson, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('barcodesJson: $barcodesJson, ')
          ..write('howToUse: $howToUse, ')
          ..write('ingredients: $ingredients, ')
          ..write('rawJson: $rawJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, OrderEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (id)',
    ),
  );
  static const VerificationMeta _outletIdMeta = const VerificationMeta(
    'outletId',
  );
  @override
  late final GeneratedColumn<int> outletId = GeneratedColumn<int>(
    'outlet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trading_point_entities (id)',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentDetailsMeta = const VerificationMeta(
    'paymentDetails',
  );
  @override
  late final GeneratedColumn<String> paymentDetails = GeneratedColumn<String>(
    'payment_details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentIsCashMeta = const VerificationMeta(
    'paymentIsCash',
  );
  @override
  late final GeneratedColumn<bool> paymentIsCash = GeneratedColumn<bool>(
    'payment_is_cash',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("payment_is_cash" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paymentIsCardMeta = const VerificationMeta(
    'paymentIsCard',
  );
  @override
  late final GeneratedColumn<bool> paymentIsCard = GeneratedColumn<bool>(
    'payment_is_card',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("payment_is_card" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paymentIsCreditMeta = const VerificationMeta(
    'paymentIsCredit',
  );
  @override
  late final GeneratedColumn<bool> paymentIsCredit = GeneratedColumn<bool>(
    'payment_is_credit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("payment_is_credit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPickupMeta = const VerificationMeta(
    'isPickup',
  );
  @override
  late final GeneratedColumn<bool> isPickup = GeneratedColumn<bool>(
    'is_pickup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pickup" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _approvedDeliveryDayMeta =
      const VerificationMeta('approvedDeliveryDay');
  @override
  late final GeneratedColumn<DateTime> approvedDeliveryDay =
      GeneratedColumn<DateTime>(
        'approved_delivery_day',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _approvedAssemblyDayMeta =
      const VerificationMeta('approvedAssemblyDay');
  @override
  late final GeneratedColumn<DateTime> approvedAssemblyDay =
      GeneratedColumn<DateTime>(
        'approved_assembly_day',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _withRealizationMeta = const VerificationMeta(
    'withRealization',
  );
  @override
  late final GeneratedColumn<bool> withRealization = GeneratedColumn<bool>(
    'with_realization',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("with_realization" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    creatorId,
    outletId,
    state,
    paymentType,
    paymentDetails,
    paymentIsCash,
    paymentIsCard,
    paymentIsCredit,
    comment,
    name,
    isPickup,
    approvedDeliveryDay,
    approvedAssemblyDay,
    withRealization,
    failureReason,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('outlet_id')) {
      context.handle(
        _outletIdMeta,
        outletId.isAcceptableOrUnknown(data['outlet_id']!, _outletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outletIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    }
    if (data.containsKey('payment_details')) {
      context.handle(
        _paymentDetailsMeta,
        paymentDetails.isAcceptableOrUnknown(
          data['payment_details']!,
          _paymentDetailsMeta,
        ),
      );
    }
    if (data.containsKey('payment_is_cash')) {
      context.handle(
        _paymentIsCashMeta,
        paymentIsCash.isAcceptableOrUnknown(
          data['payment_is_cash']!,
          _paymentIsCashMeta,
        ),
      );
    }
    if (data.containsKey('payment_is_card')) {
      context.handle(
        _paymentIsCardMeta,
        paymentIsCard.isAcceptableOrUnknown(
          data['payment_is_card']!,
          _paymentIsCardMeta,
        ),
      );
    }
    if (data.containsKey('payment_is_credit')) {
      context.handle(
        _paymentIsCreditMeta,
        paymentIsCredit.isAcceptableOrUnknown(
          data['payment_is_credit']!,
          _paymentIsCreditMeta,
        ),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('is_pickup')) {
      context.handle(
        _isPickupMeta,
        isPickup.isAcceptableOrUnknown(data['is_pickup']!, _isPickupMeta),
      );
    }
    if (data.containsKey('approved_delivery_day')) {
      context.handle(
        _approvedDeliveryDayMeta,
        approvedDeliveryDay.isAcceptableOrUnknown(
          data['approved_delivery_day']!,
          _approvedDeliveryDayMeta,
        ),
      );
    }
    if (data.containsKey('approved_assembly_day')) {
      context.handle(
        _approvedAssemblyDayMeta,
        approvedAssemblyDay.isAcceptableOrUnknown(
          data['approved_assembly_day']!,
          _approvedAssemblyDayMeta,
        ),
      );
    }
    if (data.containsKey('with_realization')) {
      context.handle(
        _withRealizationMeta,
        withRealization.isAcceptableOrUnknown(
          data['with_realization']!,
          _withRealizationMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      )!,
      outletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outlet_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      ),
      paymentDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_details'],
      ),
      paymentIsCash: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}payment_is_cash'],
      )!,
      paymentIsCard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}payment_is_card'],
      )!,
      paymentIsCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}payment_is_credit'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      isPickup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pickup'],
      )!,
      approvedDeliveryDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}approved_delivery_day'],
      ),
      approvedAssemblyDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}approved_assembly_day'],
      ),
      withRealization: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}with_realization'],
      )!,
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class OrderEntity extends DataClass implements Insertable<OrderEntity> {
  final int id;
  final int creatorId;
  final int outletId;
  final String state;
  final String? paymentType;
  final String? paymentDetails;
  final bool paymentIsCash;
  final bool paymentIsCard;
  final bool paymentIsCredit;
  final String? comment;
  final String? name;
  final bool isPickup;
  final DateTime? approvedDeliveryDay;
  final DateTime? approvedAssemblyDay;
  final bool withRealization;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OrderEntity({
    required this.id,
    required this.creatorId,
    required this.outletId,
    required this.state,
    this.paymentType,
    this.paymentDetails,
    required this.paymentIsCash,
    required this.paymentIsCard,
    required this.paymentIsCredit,
    this.comment,
    this.name,
    required this.isPickup,
    this.approvedDeliveryDay,
    this.approvedAssemblyDay,
    required this.withRealization,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['creator_id'] = Variable<int>(creatorId);
    map['outlet_id'] = Variable<int>(outletId);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || paymentType != null) {
      map['payment_type'] = Variable<String>(paymentType);
    }
    if (!nullToAbsent || paymentDetails != null) {
      map['payment_details'] = Variable<String>(paymentDetails);
    }
    map['payment_is_cash'] = Variable<bool>(paymentIsCash);
    map['payment_is_card'] = Variable<bool>(paymentIsCard);
    map['payment_is_credit'] = Variable<bool>(paymentIsCredit);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['is_pickup'] = Variable<bool>(isPickup);
    if (!nullToAbsent || approvedDeliveryDay != null) {
      map['approved_delivery_day'] = Variable<DateTime>(approvedDeliveryDay);
    }
    if (!nullToAbsent || approvedAssemblyDay != null) {
      map['approved_assembly_day'] = Variable<DateTime>(approvedAssemblyDay);
    }
    map['with_realization'] = Variable<bool>(withRealization);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      creatorId: Value(creatorId),
      outletId: Value(outletId),
      state: Value(state),
      paymentType: paymentType == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentType),
      paymentDetails: paymentDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDetails),
      paymentIsCash: Value(paymentIsCash),
      paymentIsCard: Value(paymentIsCard),
      paymentIsCredit: Value(paymentIsCredit),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      isPickup: Value(isPickup),
      approvedDeliveryDay: approvedDeliveryDay == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedDeliveryDay),
      approvedAssemblyDay: approvedAssemblyDay == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAssemblyDay),
      withRealization: Value(withRealization),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrderEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderEntity(
      id: serializer.fromJson<int>(json['id']),
      creatorId: serializer.fromJson<int>(json['creatorId']),
      outletId: serializer.fromJson<int>(json['outletId']),
      state: serializer.fromJson<String>(json['state']),
      paymentType: serializer.fromJson<String?>(json['paymentType']),
      paymentDetails: serializer.fromJson<String?>(json['paymentDetails']),
      paymentIsCash: serializer.fromJson<bool>(json['paymentIsCash']),
      paymentIsCard: serializer.fromJson<bool>(json['paymentIsCard']),
      paymentIsCredit: serializer.fromJson<bool>(json['paymentIsCredit']),
      comment: serializer.fromJson<String?>(json['comment']),
      name: serializer.fromJson<String?>(json['name']),
      isPickup: serializer.fromJson<bool>(json['isPickup']),
      approvedDeliveryDay: serializer.fromJson<DateTime?>(
        json['approvedDeliveryDay'],
      ),
      approvedAssemblyDay: serializer.fromJson<DateTime?>(
        json['approvedAssemblyDay'],
      ),
      withRealization: serializer.fromJson<bool>(json['withRealization']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'creatorId': serializer.toJson<int>(creatorId),
      'outletId': serializer.toJson<int>(outletId),
      'state': serializer.toJson<String>(state),
      'paymentType': serializer.toJson<String?>(paymentType),
      'paymentDetails': serializer.toJson<String?>(paymentDetails),
      'paymentIsCash': serializer.toJson<bool>(paymentIsCash),
      'paymentIsCard': serializer.toJson<bool>(paymentIsCard),
      'paymentIsCredit': serializer.toJson<bool>(paymentIsCredit),
      'comment': serializer.toJson<String?>(comment),
      'name': serializer.toJson<String?>(name),
      'isPickup': serializer.toJson<bool>(isPickup),
      'approvedDeliveryDay': serializer.toJson<DateTime?>(approvedDeliveryDay),
      'approvedAssemblyDay': serializer.toJson<DateTime?>(approvedAssemblyDay),
      'withRealization': serializer.toJson<bool>(withRealization),
      'failureReason': serializer.toJson<String?>(failureReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrderEntity copyWith({
    int? id,
    int? creatorId,
    int? outletId,
    String? state,
    Value<String?> paymentType = const Value.absent(),
    Value<String?> paymentDetails = const Value.absent(),
    bool? paymentIsCash,
    bool? paymentIsCard,
    bool? paymentIsCredit,
    Value<String?> comment = const Value.absent(),
    Value<String?> name = const Value.absent(),
    bool? isPickup,
    Value<DateTime?> approvedDeliveryDay = const Value.absent(),
    Value<DateTime?> approvedAssemblyDay = const Value.absent(),
    bool? withRealization,
    Value<String?> failureReason = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OrderEntity(
    id: id ?? this.id,
    creatorId: creatorId ?? this.creatorId,
    outletId: outletId ?? this.outletId,
    state: state ?? this.state,
    paymentType: paymentType.present ? paymentType.value : this.paymentType,
    paymentDetails: paymentDetails.present
        ? paymentDetails.value
        : this.paymentDetails,
    paymentIsCash: paymentIsCash ?? this.paymentIsCash,
    paymentIsCard: paymentIsCard ?? this.paymentIsCard,
    paymentIsCredit: paymentIsCredit ?? this.paymentIsCredit,
    comment: comment.present ? comment.value : this.comment,
    name: name.present ? name.value : this.name,
    isPickup: isPickup ?? this.isPickup,
    approvedDeliveryDay: approvedDeliveryDay.present
        ? approvedDeliveryDay.value
        : this.approvedDeliveryDay,
    approvedAssemblyDay: approvedAssemblyDay.present
        ? approvedAssemblyDay.value
        : this.approvedAssemblyDay,
    withRealization: withRealization ?? this.withRealization,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OrderEntity copyWithCompanion(OrdersCompanion data) {
    return OrderEntity(
      id: data.id.present ? data.id.value : this.id,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      outletId: data.outletId.present ? data.outletId.value : this.outletId,
      state: data.state.present ? data.state.value : this.state,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      paymentDetails: data.paymentDetails.present
          ? data.paymentDetails.value
          : this.paymentDetails,
      paymentIsCash: data.paymentIsCash.present
          ? data.paymentIsCash.value
          : this.paymentIsCash,
      paymentIsCard: data.paymentIsCard.present
          ? data.paymentIsCard.value
          : this.paymentIsCard,
      paymentIsCredit: data.paymentIsCredit.present
          ? data.paymentIsCredit.value
          : this.paymentIsCredit,
      comment: data.comment.present ? data.comment.value : this.comment,
      name: data.name.present ? data.name.value : this.name,
      isPickup: data.isPickup.present ? data.isPickup.value : this.isPickup,
      approvedDeliveryDay: data.approvedDeliveryDay.present
          ? data.approvedDeliveryDay.value
          : this.approvedDeliveryDay,
      approvedAssemblyDay: data.approvedAssemblyDay.present
          ? data.approvedAssemblyDay.value
          : this.approvedAssemblyDay,
      withRealization: data.withRealization.present
          ? data.withRealization.value
          : this.withRealization,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderEntity(')
          ..write('id: $id, ')
          ..write('creatorId: $creatorId, ')
          ..write('outletId: $outletId, ')
          ..write('state: $state, ')
          ..write('paymentType: $paymentType, ')
          ..write('paymentDetails: $paymentDetails, ')
          ..write('paymentIsCash: $paymentIsCash, ')
          ..write('paymentIsCard: $paymentIsCard, ')
          ..write('paymentIsCredit: $paymentIsCredit, ')
          ..write('comment: $comment, ')
          ..write('name: $name, ')
          ..write('isPickup: $isPickup, ')
          ..write('approvedDeliveryDay: $approvedDeliveryDay, ')
          ..write('approvedAssemblyDay: $approvedAssemblyDay, ')
          ..write('withRealization: $withRealization, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    creatorId,
    outletId,
    state,
    paymentType,
    paymentDetails,
    paymentIsCash,
    paymentIsCard,
    paymentIsCredit,
    comment,
    name,
    isPickup,
    approvedDeliveryDay,
    approvedAssemblyDay,
    withRealization,
    failureReason,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderEntity &&
          other.id == this.id &&
          other.creatorId == this.creatorId &&
          other.outletId == this.outletId &&
          other.state == this.state &&
          other.paymentType == this.paymentType &&
          other.paymentDetails == this.paymentDetails &&
          other.paymentIsCash == this.paymentIsCash &&
          other.paymentIsCard == this.paymentIsCard &&
          other.paymentIsCredit == this.paymentIsCredit &&
          other.comment == this.comment &&
          other.name == this.name &&
          other.isPickup == this.isPickup &&
          other.approvedDeliveryDay == this.approvedDeliveryDay &&
          other.approvedAssemblyDay == this.approvedAssemblyDay &&
          other.withRealization == this.withRealization &&
          other.failureReason == this.failureReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<OrderEntity> {
  final Value<int> id;
  final Value<int> creatorId;
  final Value<int> outletId;
  final Value<String> state;
  final Value<String?> paymentType;
  final Value<String?> paymentDetails;
  final Value<bool> paymentIsCash;
  final Value<bool> paymentIsCard;
  final Value<bool> paymentIsCredit;
  final Value<String?> comment;
  final Value<String?> name;
  final Value<bool> isPickup;
  final Value<DateTime?> approvedDeliveryDay;
  final Value<DateTime?> approvedAssemblyDay;
  final Value<bool> withRealization;
  final Value<String?> failureReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.outletId = const Value.absent(),
    this.state = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.paymentDetails = const Value.absent(),
    this.paymentIsCash = const Value.absent(),
    this.paymentIsCard = const Value.absent(),
    this.paymentIsCredit = const Value.absent(),
    this.comment = const Value.absent(),
    this.name = const Value.absent(),
    this.isPickup = const Value.absent(),
    this.approvedDeliveryDay = const Value.absent(),
    this.approvedAssemblyDay = const Value.absent(),
    this.withRealization = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    required int creatorId,
    required int outletId,
    required String state,
    this.paymentType = const Value.absent(),
    this.paymentDetails = const Value.absent(),
    this.paymentIsCash = const Value.absent(),
    this.paymentIsCard = const Value.absent(),
    this.paymentIsCredit = const Value.absent(),
    this.comment = const Value.absent(),
    this.name = const Value.absent(),
    this.isPickup = const Value.absent(),
    this.approvedDeliveryDay = const Value.absent(),
    this.approvedAssemblyDay = const Value.absent(),
    this.withRealization = const Value.absent(),
    this.failureReason = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : creatorId = Value(creatorId),
       outletId = Value(outletId),
       state = Value(state),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OrderEntity> custom({
    Expression<int>? id,
    Expression<int>? creatorId,
    Expression<int>? outletId,
    Expression<String>? state,
    Expression<String>? paymentType,
    Expression<String>? paymentDetails,
    Expression<bool>? paymentIsCash,
    Expression<bool>? paymentIsCard,
    Expression<bool>? paymentIsCredit,
    Expression<String>? comment,
    Expression<String>? name,
    Expression<bool>? isPickup,
    Expression<DateTime>? approvedDeliveryDay,
    Expression<DateTime>? approvedAssemblyDay,
    Expression<bool>? withRealization,
    Expression<String>? failureReason,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creatorId != null) 'creator_id': creatorId,
      if (outletId != null) 'outlet_id': outletId,
      if (state != null) 'state': state,
      if (paymentType != null) 'payment_type': paymentType,
      if (paymentDetails != null) 'payment_details': paymentDetails,
      if (paymentIsCash != null) 'payment_is_cash': paymentIsCash,
      if (paymentIsCard != null) 'payment_is_card': paymentIsCard,
      if (paymentIsCredit != null) 'payment_is_credit': paymentIsCredit,
      if (comment != null) 'comment': comment,
      if (name != null) 'name': name,
      if (isPickup != null) 'is_pickup': isPickup,
      if (approvedDeliveryDay != null)
        'approved_delivery_day': approvedDeliveryDay,
      if (approvedAssemblyDay != null)
        'approved_assembly_day': approvedAssemblyDay,
      if (withRealization != null) 'with_realization': withRealization,
      if (failureReason != null) 'failure_reason': failureReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrdersCompanion copyWith({
    Value<int>? id,
    Value<int>? creatorId,
    Value<int>? outletId,
    Value<String>? state,
    Value<String?>? paymentType,
    Value<String?>? paymentDetails,
    Value<bool>? paymentIsCash,
    Value<bool>? paymentIsCard,
    Value<bool>? paymentIsCredit,
    Value<String?>? comment,
    Value<String?>? name,
    Value<bool>? isPickup,
    Value<DateTime?>? approvedDeliveryDay,
    Value<DateTime?>? approvedAssemblyDay,
    Value<bool>? withRealization,
    Value<String?>? failureReason,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      outletId: outletId ?? this.outletId,
      state: state ?? this.state,
      paymentType: paymentType ?? this.paymentType,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      paymentIsCash: paymentIsCash ?? this.paymentIsCash,
      paymentIsCard: paymentIsCard ?? this.paymentIsCard,
      paymentIsCredit: paymentIsCredit ?? this.paymentIsCredit,
      comment: comment ?? this.comment,
      name: name ?? this.name,
      isPickup: isPickup ?? this.isPickup,
      approvedDeliveryDay: approvedDeliveryDay ?? this.approvedDeliveryDay,
      approvedAssemblyDay: approvedAssemblyDay ?? this.approvedAssemblyDay,
      withRealization: withRealization ?? this.withRealization,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (outletId.present) {
      map['outlet_id'] = Variable<int>(outletId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (paymentDetails.present) {
      map['payment_details'] = Variable<String>(paymentDetails.value);
    }
    if (paymentIsCash.present) {
      map['payment_is_cash'] = Variable<bool>(paymentIsCash.value);
    }
    if (paymentIsCard.present) {
      map['payment_is_card'] = Variable<bool>(paymentIsCard.value);
    }
    if (paymentIsCredit.present) {
      map['payment_is_credit'] = Variable<bool>(paymentIsCredit.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isPickup.present) {
      map['is_pickup'] = Variable<bool>(isPickup.value);
    }
    if (approvedDeliveryDay.present) {
      map['approved_delivery_day'] = Variable<DateTime>(
        approvedDeliveryDay.value,
      );
    }
    if (approvedAssemblyDay.present) {
      map['approved_assembly_day'] = Variable<DateTime>(
        approvedAssemblyDay.value,
      );
    }
    if (withRealization.present) {
      map['with_realization'] = Variable<bool>(withRealization.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('creatorId: $creatorId, ')
          ..write('outletId: $outletId, ')
          ..write('state: $state, ')
          ..write('paymentType: $paymentType, ')
          ..write('paymentDetails: $paymentDetails, ')
          ..write('paymentIsCash: $paymentIsCash, ')
          ..write('paymentIsCard: $paymentIsCard, ')
          ..write('paymentIsCredit: $paymentIsCredit, ')
          ..write('comment: $comment, ')
          ..write('name: $name, ')
          ..write('isPickup: $isPickup, ')
          ..write('approvedDeliveryDay: $approvedDeliveryDay, ')
          ..write('approvedAssemblyDay: $approvedAssemblyDay, ')
          ..write('withRealization: $withRealization, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrderLinesTable extends OrderLines
    with TableInfo<$OrderLinesTable, OrderLineEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stockItemIdMeta = const VerificationMeta(
    'stockItemId',
  );
  @override
  late final GeneratedColumn<int> stockItemId = GeneratedColumn<int>(
    'stock_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerUnitMeta = const VerificationMeta(
    'pricePerUnit',
  );
  @override
  late final GeneratedColumn<int> pricePerUnit = GeneratedColumn<int>(
    'price_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    stockItemId,
    quantity,
    pricePerUnit,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderLineEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('stock_item_id')) {
      context.handle(
        _stockItemIdMeta,
        stockItemId.isAcceptableOrUnknown(
          data['stock_item_id']!,
          _stockItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockItemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
        _pricePerUnitMeta,
        pricePerUnit.isAcceptableOrUnknown(
          data['price_per_unit']!,
          _pricePerUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerUnitMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderLineEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderLineEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_id'],
      )!,
      stockItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_item_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      pricePerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_unit'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrderLinesTable createAlias(String alias) {
    return $OrderLinesTable(attachedDatabase, alias);
  }
}

class OrderLineEntity extends DataClass implements Insertable<OrderLineEntity> {
  final int id;
  final int orderId;
  final int stockItemId;
  final int quantity;
  final int pricePerUnit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OrderLineEntity({
    required this.id,
    required this.orderId,
    required this.stockItemId,
    required this.quantity,
    required this.pricePerUnit,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['stock_item_id'] = Variable<int>(stockItemId);
    map['quantity'] = Variable<int>(quantity);
    map['price_per_unit'] = Variable<int>(pricePerUnit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrderLinesCompanion toCompanion(bool nullToAbsent) {
    return OrderLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      stockItemId: Value(stockItemId),
      quantity: Value(quantity),
      pricePerUnit: Value(pricePerUnit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrderLineEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderLineEntity(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      stockItemId: serializer.fromJson<int>(json['stockItemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      pricePerUnit: serializer.fromJson<int>(json['pricePerUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'stockItemId': serializer.toJson<int>(stockItemId),
      'quantity': serializer.toJson<int>(quantity),
      'pricePerUnit': serializer.toJson<int>(pricePerUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrderLineEntity copyWith({
    int? id,
    int? orderId,
    int? stockItemId,
    int? quantity,
    int? pricePerUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OrderLineEntity(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    stockItemId: stockItemId ?? this.stockItemId,
    quantity: quantity ?? this.quantity,
    pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OrderLineEntity copyWithCompanion(OrderLinesCompanion data) {
    return OrderLineEntity(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      stockItemId: data.stockItemId.present
          ? data.stockItemId.value
          : this.stockItemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderLineEntity(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('stockItemId: $stockItemId, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderId,
    stockItemId,
    quantity,
    pricePerUnit,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderLineEntity &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.stockItemId == this.stockItemId &&
          other.quantity == this.quantity &&
          other.pricePerUnit == this.pricePerUnit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrderLinesCompanion extends UpdateCompanion<OrderLineEntity> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int> stockItemId;
  final Value<int> quantity;
  final Value<int> pricePerUnit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const OrderLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.stockItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrderLinesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required int stockItemId,
    required int quantity,
    required int pricePerUnit,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : orderId = Value(orderId),
       stockItemId = Value(stockItemId),
       quantity = Value(quantity),
       pricePerUnit = Value(pricePerUnit),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OrderLineEntity> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? stockItemId,
    Expression<int>? quantity,
    Expression<int>? pricePerUnit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (stockItemId != null) 'stock_item_id': stockItemId,
      if (quantity != null) 'quantity': quantity,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrderLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? orderId,
    Value<int>? stockItemId,
    Value<int>? quantity,
    Value<int>? pricePerUnit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return OrderLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      stockItemId: stockItemId ?? this.stockItemId,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (stockItemId.present) {
      map['stock_item_id'] = Variable<int>(stockItemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<int>(pricePerUnit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('stockItemId: $stockItemId, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StockItemsTable extends StockItems
    with TableInfo<$StockItemsTable, StockItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productCodeMeta = const VerificationMeta(
    'productCode',
  );
  @override
  late final GeneratedColumn<int> productCode = GeneratedColumn<int>(
    'product_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (code)',
    ),
  );
  static const VerificationMeta _warehouseIdMeta = const VerificationMeta(
    'warehouseId',
  );
  @override
  late final GeneratedColumn<int> warehouseId = GeneratedColumn<int>(
    'warehouse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warehouseNameMeta = const VerificationMeta(
    'warehouseName',
  );
  @override
  late final GeneratedColumn<String> warehouseName = GeneratedColumn<String>(
    'warehouse_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warehouseVendorIdMeta = const VerificationMeta(
    'warehouseVendorId',
  );
  @override
  late final GeneratedColumn<String> warehouseVendorId =
      GeneratedColumn<String>(
        'warehouse_vendor_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isPickUpPointMeta = const VerificationMeta(
    'isPickUpPoint',
  );
  @override
  late final GeneratedColumn<bool> isPickUpPoint = GeneratedColumn<bool>(
    'is_pick_up_point',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pick_up_point" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _multiplicityMeta = const VerificationMeta(
    'multiplicity',
  );
  @override
  late final GeneratedColumn<int> multiplicity = GeneratedColumn<int>(
    'multiplicity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicStockMeta = const VerificationMeta(
    'publicStock',
  );
  @override
  late final GeneratedColumn<String> publicStock = GeneratedColumn<String>(
    'public_stock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultPriceMeta = const VerificationMeta(
    'defaultPrice',
  );
  @override
  late final GeneratedColumn<int> defaultPrice = GeneratedColumn<int>(
    'default_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<int> discountValue = GeneratedColumn<int>(
    'discount_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _availablePriceMeta = const VerificationMeta(
    'availablePrice',
  );
  @override
  late final GeneratedColumn<int> availablePrice = GeneratedColumn<int>(
    'available_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _offerPriceMeta = const VerificationMeta(
    'offerPrice',
  );
  @override
  late final GeneratedColumn<int> offerPrice = GeneratedColumn<int>(
    'offer_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('RUB'),
  );
  static const VerificationMeta _priceTypeMeta = const VerificationMeta(
    'priceType',
  );
  @override
  late final GeneratedColumn<String> priceType = GeneratedColumn<String>(
    'price_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promotionJsonMeta = const VerificationMeta(
    'promotionJson',
  );
  @override
  late final GeneratedColumn<String> promotionJson = GeneratedColumn<String>(
    'promotion_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productCode,
    warehouseId,
    warehouseName,
    warehouseVendorId,
    isPickUpPoint,
    stock,
    multiplicity,
    publicStock,
    defaultPrice,
    discountValue,
    availablePrice,
    offerPrice,
    currency,
    priceType,
    promotionJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_code')) {
      context.handle(
        _productCodeMeta,
        productCode.isAcceptableOrUnknown(
          data['product_code']!,
          _productCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productCodeMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
        _warehouseIdMeta,
        warehouseId.isAcceptableOrUnknown(
          data['warehouse_id']!,
          _warehouseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('warehouse_name')) {
      context.handle(
        _warehouseNameMeta,
        warehouseName.isAcceptableOrUnknown(
          data['warehouse_name']!,
          _warehouseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseNameMeta);
    }
    if (data.containsKey('warehouse_vendor_id')) {
      context.handle(
        _warehouseVendorIdMeta,
        warehouseVendorId.isAcceptableOrUnknown(
          data['warehouse_vendor_id']!,
          _warehouseVendorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warehouseVendorIdMeta);
    }
    if (data.containsKey('is_pick_up_point')) {
      context.handle(
        _isPickUpPointMeta,
        isPickUpPoint.isAcceptableOrUnknown(
          data['is_pick_up_point']!,
          _isPickUpPointMeta,
        ),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('multiplicity')) {
      context.handle(
        _multiplicityMeta,
        multiplicity.isAcceptableOrUnknown(
          data['multiplicity']!,
          _multiplicityMeta,
        ),
      );
    }
    if (data.containsKey('public_stock')) {
      context.handle(
        _publicStockMeta,
        publicStock.isAcceptableOrUnknown(
          data['public_stock']!,
          _publicStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publicStockMeta);
    }
    if (data.containsKey('default_price')) {
      context.handle(
        _defaultPriceMeta,
        defaultPrice.isAcceptableOrUnknown(
          data['default_price']!,
          _defaultPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultPriceMeta);
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    if (data.containsKey('available_price')) {
      context.handle(
        _availablePriceMeta,
        availablePrice.isAcceptableOrUnknown(
          data['available_price']!,
          _availablePriceMeta,
        ),
      );
    }
    if (data.containsKey('offer_price')) {
      context.handle(
        _offerPriceMeta,
        offerPrice.isAcceptableOrUnknown(data['offer_price']!, _offerPriceMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('price_type')) {
      context.handle(
        _priceTypeMeta,
        priceType.isAcceptableOrUnknown(data['price_type']!, _priceTypeMeta),
      );
    }
    if (data.containsKey('promotion_json')) {
      context.handle(
        _promotionJsonMeta,
        promotionJson.isAcceptableOrUnknown(
          data['promotion_json']!,
          _promotionJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {productCode, warehouseId},
  ];
  @override
  StockItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_code'],
      )!,
      warehouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warehouse_id'],
      )!,
      warehouseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warehouse_name'],
      )!,
      warehouseVendorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warehouse_vendor_id'],
      )!,
      isPickUpPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pick_up_point'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      multiplicity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}multiplicity'],
      ),
      publicStock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_stock'],
      )!,
      defaultPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_price'],
      )!,
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_value'],
      )!,
      availablePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_price'],
      ),
      offerPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offer_price'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      priceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_type'],
      ),
      promotionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promotion_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StockItemsTable createAlias(String alias) {
    return $StockItemsTable(attachedDatabase, alias);
  }
}

class StockItemData extends DataClass implements Insertable<StockItemData> {
  /// Уникальный ID StockItem
  final int id;

  /// Ссылка на продукт
  final int productCode;

  /// Данные склада (денормализованы для производительности)
  final int warehouseId;
  final String warehouseName;
  final String warehouseVendorId;
  final bool isPickUpPoint;

  /// Остатки товара
  final int stock;
  final int? multiplicity;
  final String publicStock;

  /// Ценообразование (все в копейках)
  final int defaultPrice;
  final int discountValue;
  final int? availablePrice;
  final int? offerPrice;
  final String currency;

  /// Тип цены: "regional_base", "differential_price", "promotion"
  final String? priceType;

  /// Промоакция (JSON для гибкости)
  final String? promotionJson;

  /// Метки времени
  final DateTime createdAt;
  final DateTime updatedAt;
  const StockItemData({
    required this.id,
    required this.productCode,
    required this.warehouseId,
    required this.warehouseName,
    required this.warehouseVendorId,
    required this.isPickUpPoint,
    required this.stock,
    this.multiplicity,
    required this.publicStock,
    required this.defaultPrice,
    required this.discountValue,
    this.availablePrice,
    this.offerPrice,
    required this.currency,
    this.priceType,
    this.promotionJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_code'] = Variable<int>(productCode);
    map['warehouse_id'] = Variable<int>(warehouseId);
    map['warehouse_name'] = Variable<String>(warehouseName);
    map['warehouse_vendor_id'] = Variable<String>(warehouseVendorId);
    map['is_pick_up_point'] = Variable<bool>(isPickUpPoint);
    map['stock'] = Variable<int>(stock);
    if (!nullToAbsent || multiplicity != null) {
      map['multiplicity'] = Variable<int>(multiplicity);
    }
    map['public_stock'] = Variable<String>(publicStock);
    map['default_price'] = Variable<int>(defaultPrice);
    map['discount_value'] = Variable<int>(discountValue);
    if (!nullToAbsent || availablePrice != null) {
      map['available_price'] = Variable<int>(availablePrice);
    }
    if (!nullToAbsent || offerPrice != null) {
      map['offer_price'] = Variable<int>(offerPrice);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || priceType != null) {
      map['price_type'] = Variable<String>(priceType);
    }
    if (!nullToAbsent || promotionJson != null) {
      map['promotion_json'] = Variable<String>(promotionJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StockItemsCompanion toCompanion(bool nullToAbsent) {
    return StockItemsCompanion(
      id: Value(id),
      productCode: Value(productCode),
      warehouseId: Value(warehouseId),
      warehouseName: Value(warehouseName),
      warehouseVendorId: Value(warehouseVendorId),
      isPickUpPoint: Value(isPickUpPoint),
      stock: Value(stock),
      multiplicity: multiplicity == null && nullToAbsent
          ? const Value.absent()
          : Value(multiplicity),
      publicStock: Value(publicStock),
      defaultPrice: Value(defaultPrice),
      discountValue: Value(discountValue),
      availablePrice: availablePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(availablePrice),
      offerPrice: offerPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(offerPrice),
      currency: Value(currency),
      priceType: priceType == null && nullToAbsent
          ? const Value.absent()
          : Value(priceType),
      promotionJson: promotionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(promotionJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StockItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockItemData(
      id: serializer.fromJson<int>(json['id']),
      productCode: serializer.fromJson<int>(json['productCode']),
      warehouseId: serializer.fromJson<int>(json['warehouseId']),
      warehouseName: serializer.fromJson<String>(json['warehouseName']),
      warehouseVendorId: serializer.fromJson<String>(json['warehouseVendorId']),
      isPickUpPoint: serializer.fromJson<bool>(json['isPickUpPoint']),
      stock: serializer.fromJson<int>(json['stock']),
      multiplicity: serializer.fromJson<int?>(json['multiplicity']),
      publicStock: serializer.fromJson<String>(json['publicStock']),
      defaultPrice: serializer.fromJson<int>(json['defaultPrice']),
      discountValue: serializer.fromJson<int>(json['discountValue']),
      availablePrice: serializer.fromJson<int?>(json['availablePrice']),
      offerPrice: serializer.fromJson<int?>(json['offerPrice']),
      currency: serializer.fromJson<String>(json['currency']),
      priceType: serializer.fromJson<String?>(json['priceType']),
      promotionJson: serializer.fromJson<String?>(json['promotionJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productCode': serializer.toJson<int>(productCode),
      'warehouseId': serializer.toJson<int>(warehouseId),
      'warehouseName': serializer.toJson<String>(warehouseName),
      'warehouseVendorId': serializer.toJson<String>(warehouseVendorId),
      'isPickUpPoint': serializer.toJson<bool>(isPickUpPoint),
      'stock': serializer.toJson<int>(stock),
      'multiplicity': serializer.toJson<int?>(multiplicity),
      'publicStock': serializer.toJson<String>(publicStock),
      'defaultPrice': serializer.toJson<int>(defaultPrice),
      'discountValue': serializer.toJson<int>(discountValue),
      'availablePrice': serializer.toJson<int?>(availablePrice),
      'offerPrice': serializer.toJson<int?>(offerPrice),
      'currency': serializer.toJson<String>(currency),
      'priceType': serializer.toJson<String?>(priceType),
      'promotionJson': serializer.toJson<String?>(promotionJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StockItemData copyWith({
    int? id,
    int? productCode,
    int? warehouseId,
    String? warehouseName,
    String? warehouseVendorId,
    bool? isPickUpPoint,
    int? stock,
    Value<int?> multiplicity = const Value.absent(),
    String? publicStock,
    int? defaultPrice,
    int? discountValue,
    Value<int?> availablePrice = const Value.absent(),
    Value<int?> offerPrice = const Value.absent(),
    String? currency,
    Value<String?> priceType = const Value.absent(),
    Value<String?> promotionJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StockItemData(
    id: id ?? this.id,
    productCode: productCode ?? this.productCode,
    warehouseId: warehouseId ?? this.warehouseId,
    warehouseName: warehouseName ?? this.warehouseName,
    warehouseVendorId: warehouseVendorId ?? this.warehouseVendorId,
    isPickUpPoint: isPickUpPoint ?? this.isPickUpPoint,
    stock: stock ?? this.stock,
    multiplicity: multiplicity.present ? multiplicity.value : this.multiplicity,
    publicStock: publicStock ?? this.publicStock,
    defaultPrice: defaultPrice ?? this.defaultPrice,
    discountValue: discountValue ?? this.discountValue,
    availablePrice: availablePrice.present
        ? availablePrice.value
        : this.availablePrice,
    offerPrice: offerPrice.present ? offerPrice.value : this.offerPrice,
    currency: currency ?? this.currency,
    priceType: priceType.present ? priceType.value : this.priceType,
    promotionJson: promotionJson.present
        ? promotionJson.value
        : this.promotionJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StockItemData copyWithCompanion(StockItemsCompanion data) {
    return StockItemData(
      id: data.id.present ? data.id.value : this.id,
      productCode: data.productCode.present
          ? data.productCode.value
          : this.productCode,
      warehouseId: data.warehouseId.present
          ? data.warehouseId.value
          : this.warehouseId,
      warehouseName: data.warehouseName.present
          ? data.warehouseName.value
          : this.warehouseName,
      warehouseVendorId: data.warehouseVendorId.present
          ? data.warehouseVendorId.value
          : this.warehouseVendorId,
      isPickUpPoint: data.isPickUpPoint.present
          ? data.isPickUpPoint.value
          : this.isPickUpPoint,
      stock: data.stock.present ? data.stock.value : this.stock,
      multiplicity: data.multiplicity.present
          ? data.multiplicity.value
          : this.multiplicity,
      publicStock: data.publicStock.present
          ? data.publicStock.value
          : this.publicStock,
      defaultPrice: data.defaultPrice.present
          ? data.defaultPrice.value
          : this.defaultPrice,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      availablePrice: data.availablePrice.present
          ? data.availablePrice.value
          : this.availablePrice,
      offerPrice: data.offerPrice.present
          ? data.offerPrice.value
          : this.offerPrice,
      currency: data.currency.present ? data.currency.value : this.currency,
      priceType: data.priceType.present ? data.priceType.value : this.priceType,
      promotionJson: data.promotionJson.present
          ? data.promotionJson.value
          : this.promotionJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockItemData(')
          ..write('id: $id, ')
          ..write('productCode: $productCode, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('warehouseName: $warehouseName, ')
          ..write('warehouseVendorId: $warehouseVendorId, ')
          ..write('isPickUpPoint: $isPickUpPoint, ')
          ..write('stock: $stock, ')
          ..write('multiplicity: $multiplicity, ')
          ..write('publicStock: $publicStock, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('discountValue: $discountValue, ')
          ..write('availablePrice: $availablePrice, ')
          ..write('offerPrice: $offerPrice, ')
          ..write('currency: $currency, ')
          ..write('priceType: $priceType, ')
          ..write('promotionJson: $promotionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productCode,
    warehouseId,
    warehouseName,
    warehouseVendorId,
    isPickUpPoint,
    stock,
    multiplicity,
    publicStock,
    defaultPrice,
    discountValue,
    availablePrice,
    offerPrice,
    currency,
    priceType,
    promotionJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockItemData &&
          other.id == this.id &&
          other.productCode == this.productCode &&
          other.warehouseId == this.warehouseId &&
          other.warehouseName == this.warehouseName &&
          other.warehouseVendorId == this.warehouseVendorId &&
          other.isPickUpPoint == this.isPickUpPoint &&
          other.stock == this.stock &&
          other.multiplicity == this.multiplicity &&
          other.publicStock == this.publicStock &&
          other.defaultPrice == this.defaultPrice &&
          other.discountValue == this.discountValue &&
          other.availablePrice == this.availablePrice &&
          other.offerPrice == this.offerPrice &&
          other.currency == this.currency &&
          other.priceType == this.priceType &&
          other.promotionJson == this.promotionJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StockItemsCompanion extends UpdateCompanion<StockItemData> {
  final Value<int> id;
  final Value<int> productCode;
  final Value<int> warehouseId;
  final Value<String> warehouseName;
  final Value<String> warehouseVendorId;
  final Value<bool> isPickUpPoint;
  final Value<int> stock;
  final Value<int?> multiplicity;
  final Value<String> publicStock;
  final Value<int> defaultPrice;
  final Value<int> discountValue;
  final Value<int?> availablePrice;
  final Value<int?> offerPrice;
  final Value<String> currency;
  final Value<String?> priceType;
  final Value<String?> promotionJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const StockItemsCompanion({
    this.id = const Value.absent(),
    this.productCode = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.warehouseName = const Value.absent(),
    this.warehouseVendorId = const Value.absent(),
    this.isPickUpPoint = const Value.absent(),
    this.stock = const Value.absent(),
    this.multiplicity = const Value.absent(),
    this.publicStock = const Value.absent(),
    this.defaultPrice = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.availablePrice = const Value.absent(),
    this.offerPrice = const Value.absent(),
    this.currency = const Value.absent(),
    this.priceType = const Value.absent(),
    this.promotionJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StockItemsCompanion.insert({
    this.id = const Value.absent(),
    required int productCode,
    required int warehouseId,
    required String warehouseName,
    required String warehouseVendorId,
    this.isPickUpPoint = const Value.absent(),
    this.stock = const Value.absent(),
    this.multiplicity = const Value.absent(),
    required String publicStock,
    required int defaultPrice,
    this.discountValue = const Value.absent(),
    this.availablePrice = const Value.absent(),
    this.offerPrice = const Value.absent(),
    this.currency = const Value.absent(),
    this.priceType = const Value.absent(),
    this.promotionJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : productCode = Value(productCode),
       warehouseId = Value(warehouseId),
       warehouseName = Value(warehouseName),
       warehouseVendorId = Value(warehouseVendorId),
       publicStock = Value(publicStock),
       defaultPrice = Value(defaultPrice);
  static Insertable<StockItemData> custom({
    Expression<int>? id,
    Expression<int>? productCode,
    Expression<int>? warehouseId,
    Expression<String>? warehouseName,
    Expression<String>? warehouseVendorId,
    Expression<bool>? isPickUpPoint,
    Expression<int>? stock,
    Expression<int>? multiplicity,
    Expression<String>? publicStock,
    Expression<int>? defaultPrice,
    Expression<int>? discountValue,
    Expression<int>? availablePrice,
    Expression<int>? offerPrice,
    Expression<String>? currency,
    Expression<String>? priceType,
    Expression<String>? promotionJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productCode != null) 'product_code': productCode,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (warehouseName != null) 'warehouse_name': warehouseName,
      if (warehouseVendorId != null) 'warehouse_vendor_id': warehouseVendorId,
      if (isPickUpPoint != null) 'is_pick_up_point': isPickUpPoint,
      if (stock != null) 'stock': stock,
      if (multiplicity != null) 'multiplicity': multiplicity,
      if (publicStock != null) 'public_stock': publicStock,
      if (defaultPrice != null) 'default_price': defaultPrice,
      if (discountValue != null) 'discount_value': discountValue,
      if (availablePrice != null) 'available_price': availablePrice,
      if (offerPrice != null) 'offer_price': offerPrice,
      if (currency != null) 'currency': currency,
      if (priceType != null) 'price_type': priceType,
      if (promotionJson != null) 'promotion_json': promotionJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StockItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? productCode,
    Value<int>? warehouseId,
    Value<String>? warehouseName,
    Value<String>? warehouseVendorId,
    Value<bool>? isPickUpPoint,
    Value<int>? stock,
    Value<int?>? multiplicity,
    Value<String>? publicStock,
    Value<int>? defaultPrice,
    Value<int>? discountValue,
    Value<int?>? availablePrice,
    Value<int?>? offerPrice,
    Value<String>? currency,
    Value<String?>? priceType,
    Value<String?>? promotionJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return StockItemsCompanion(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseVendorId: warehouseVendorId ?? this.warehouseVendorId,
      isPickUpPoint: isPickUpPoint ?? this.isPickUpPoint,
      stock: stock ?? this.stock,
      multiplicity: multiplicity ?? this.multiplicity,
      publicStock: publicStock ?? this.publicStock,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      discountValue: discountValue ?? this.discountValue,
      availablePrice: availablePrice ?? this.availablePrice,
      offerPrice: offerPrice ?? this.offerPrice,
      currency: currency ?? this.currency,
      priceType: priceType ?? this.priceType,
      promotionJson: promotionJson ?? this.promotionJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<int>(productCode.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<int>(warehouseId.value);
    }
    if (warehouseName.present) {
      map['warehouse_name'] = Variable<String>(warehouseName.value);
    }
    if (warehouseVendorId.present) {
      map['warehouse_vendor_id'] = Variable<String>(warehouseVendorId.value);
    }
    if (isPickUpPoint.present) {
      map['is_pick_up_point'] = Variable<bool>(isPickUpPoint.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (multiplicity.present) {
      map['multiplicity'] = Variable<int>(multiplicity.value);
    }
    if (publicStock.present) {
      map['public_stock'] = Variable<String>(publicStock.value);
    }
    if (defaultPrice.present) {
      map['default_price'] = Variable<int>(defaultPrice.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<int>(discountValue.value);
    }
    if (availablePrice.present) {
      map['available_price'] = Variable<int>(availablePrice.value);
    }
    if (offerPrice.present) {
      map['offer_price'] = Variable<int>(offerPrice.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (priceType.present) {
      map['price_type'] = Variable<String>(priceType.value);
    }
    if (promotionJson.present) {
      map['promotion_json'] = Variable<String>(promotionJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockItemsCompanion(')
          ..write('id: $id, ')
          ..write('productCode: $productCode, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('warehouseName: $warehouseName, ')
          ..write('warehouseVendorId: $warehouseVendorId, ')
          ..write('isPickUpPoint: $isPickUpPoint, ')
          ..write('stock: $stock, ')
          ..write('multiplicity: $multiplicity, ')
          ..write('publicStock: $publicStock, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('discountValue: $discountValue, ')
          ..write('availablePrice: $availablePrice, ')
          ..write('offerPrice: $offerPrice, ')
          ..write('currency: $currency, ')
          ..write('priceType: $priceType, ')
          ..write('promotionJson: $promotionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrderJobsTable extends OrderJobs
    with TableInfo<$OrderJobsTable, OrderJobEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _jobTypeMeta = const VerificationMeta(
    'jobType',
  );
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
    'job_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRunAtMeta = const VerificationMeta(
    'nextRunAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRunAt = GeneratedColumn<DateTime>(
    'next_run_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    jobType,
    payloadJson,
    status,
    attempts,
    nextRunAt,
    failureReason,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderJobEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('job_type')) {
      context.handle(
        _jobTypeMeta,
        jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_run_at')) {
      context.handle(
        _nextRunAtMeta,
        nextRunAt.isAcceptableOrUnknown(data['next_run_at']!, _nextRunAtMeta),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderJobEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderJobEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_id'],
      )!,
      jobType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_run_at'],
      ),
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrderJobsTable createAlias(String alias) {
    return $OrderJobsTable(attachedDatabase, alias);
  }
}

class OrderJobEntity extends DataClass implements Insertable<OrderJobEntity> {
  final String id;
  final int orderId;
  final String jobType;
  final String payloadJson;
  final String status;
  final int attempts;
  final DateTime? nextRunAt;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OrderJobEntity({
    required this.id,
    required this.orderId,
    required this.jobType,
    required this.payloadJson,
    required this.status,
    required this.attempts,
    this.nextRunAt,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<int>(orderId);
    map['job_type'] = Variable<String>(jobType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextRunAt != null) {
      map['next_run_at'] = Variable<DateTime>(nextRunAt);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrderJobsCompanion toCompanion(bool nullToAbsent) {
    return OrderJobsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      jobType: Value(jobType),
      payloadJson: Value(payloadJson),
      status: Value(status),
      attempts: Value(attempts),
      nextRunAt: nextRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRunAt),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrderJobEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderJobEntity(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      jobType: serializer.fromJson<String>(json['jobType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextRunAt: serializer.fromJson<DateTime?>(json['nextRunAt']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<int>(orderId),
      'jobType': serializer.toJson<String>(jobType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'nextRunAt': serializer.toJson<DateTime?>(nextRunAt),
      'failureReason': serializer.toJson<String?>(failureReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrderJobEntity copyWith({
    String? id,
    int? orderId,
    String? jobType,
    String? payloadJson,
    String? status,
    int? attempts,
    Value<DateTime?> nextRunAt = const Value.absent(),
    Value<String?> failureReason = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OrderJobEntity(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    jobType: jobType ?? this.jobType,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    nextRunAt: nextRunAt.present ? nextRunAt.value : this.nextRunAt,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OrderJobEntity copyWithCompanion(OrderJobsCompanion data) {
    return OrderJobEntity(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextRunAt: data.nextRunAt.present ? data.nextRunAt.value : this.nextRunAt,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderJobEntity(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('jobType: $jobType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderId,
    jobType,
    payloadJson,
    status,
    attempts,
    nextRunAt,
    failureReason,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderJobEntity &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.jobType == this.jobType &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.nextRunAt == this.nextRunAt &&
          other.failureReason == this.failureReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrderJobsCompanion extends UpdateCompanion<OrderJobEntity> {
  final Value<String> id;
  final Value<int> orderId;
  final Value<String> jobType;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> attempts;
  final Value<DateTime?> nextRunAt;
  final Value<String?> failureReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OrderJobsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.jobType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderJobsCompanion.insert({
    required String id,
    required int orderId,
    required String jobType,
    required String payloadJson,
    required String status,
    this.attempts = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       jobType = Value(jobType),
       payloadJson = Value(payloadJson),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OrderJobEntity> custom({
    Expression<String>? id,
    Expression<int>? orderId,
    Expression<String>? jobType,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<DateTime>? nextRunAt,
    Expression<String>? failureReason,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (jobType != null) 'job_type': jobType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (nextRunAt != null) 'next_run_at': nextRunAt,
      if (failureReason != null) 'failure_reason': failureReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderJobsCompanion copyWith({
    Value<String>? id,
    Value<int>? orderId,
    Value<String>? jobType,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<int>? attempts,
    Value<DateTime?>? nextRunAt,
    Value<String?>? failureReason,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OrderJobsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      jobType: jobType ?? this.jobType,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextRunAt.present) {
      map['next_run_at'] = Variable<DateTime>(nextRunAt.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderJobsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('jobType: $jobType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarehousesTable extends Warehouses
    with TableInfo<$WarehousesTable, WarehouseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarehousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vendorIdMeta = const VerificationMeta(
    'vendorId',
  );
  @override
  late final GeneratedColumn<String> vendorId = GeneratedColumn<String>(
    'vendor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionCodeMeta = const VerificationMeta(
    'regionCode',
  );
  @override
  late final GeneratedColumn<String> regionCode = GeneratedColumn<String>(
    'region_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPickUpPointMeta = const VerificationMeta(
    'isPickUpPoint',
  );
  @override
  late final GeneratedColumn<bool> isPickUpPoint = GeneratedColumn<bool>(
    'is_pick_up_point',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pick_up_point" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    vendorId,
    regionCode,
    isPickUpPoint,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warehouses';
  @override
  VerificationContext validateIntegrity(
    Insertable<WarehouseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('vendor_id')) {
      context.handle(
        _vendorIdMeta,
        vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('region_code')) {
      context.handle(
        _regionCodeMeta,
        regionCode.isAcceptableOrUnknown(data['region_code']!, _regionCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_regionCodeMeta);
    }
    if (data.containsKey('is_pick_up_point')) {
      context.handle(
        _isPickUpPointMeta,
        isPickUpPoint.isAcceptableOrUnknown(
          data['is_pick_up_point']!,
          _isPickUpPointMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WarehouseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WarehouseData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      vendorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_id'],
      )!,
      regionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_code'],
      )!,
      isPickUpPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pick_up_point'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WarehousesTable createAlias(String alias) {
    return $WarehousesTable(attachedDatabase, alias);
  }
}

class WarehouseData extends DataClass implements Insertable<WarehouseData> {
  final int id;
  final String name;
  final String vendorId;
  final String regionCode;
  final bool isPickUpPoint;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WarehouseData({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.regionCode,
    required this.isPickUpPoint,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['vendor_id'] = Variable<String>(vendorId);
    map['region_code'] = Variable<String>(regionCode);
    map['is_pick_up_point'] = Variable<bool>(isPickUpPoint);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WarehousesCompanion toCompanion(bool nullToAbsent) {
    return WarehousesCompanion(
      id: Value(id),
      name: Value(name),
      vendorId: Value(vendorId),
      regionCode: Value(regionCode),
      isPickUpPoint: Value(isPickUpPoint),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WarehouseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WarehouseData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      vendorId: serializer.fromJson<String>(json['vendorId']),
      regionCode: serializer.fromJson<String>(json['regionCode']),
      isPickUpPoint: serializer.fromJson<bool>(json['isPickUpPoint']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'vendorId': serializer.toJson<String>(vendorId),
      'regionCode': serializer.toJson<String>(regionCode),
      'isPickUpPoint': serializer.toJson<bool>(isPickUpPoint),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WarehouseData copyWith({
    int? id,
    String? name,
    String? vendorId,
    String? regionCode,
    bool? isPickUpPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WarehouseData(
    id: id ?? this.id,
    name: name ?? this.name,
    vendorId: vendorId ?? this.vendorId,
    regionCode: regionCode ?? this.regionCode,
    isPickUpPoint: isPickUpPoint ?? this.isPickUpPoint,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WarehouseData copyWithCompanion(WarehousesCompanion data) {
    return WarehouseData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      regionCode: data.regionCode.present
          ? data.regionCode.value
          : this.regionCode,
      isPickUpPoint: data.isPickUpPoint.present
          ? data.isPickUpPoint.value
          : this.isPickUpPoint,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WarehouseData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('vendorId: $vendorId, ')
          ..write('regionCode: $regionCode, ')
          ..write('isPickUpPoint: $isPickUpPoint, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    vendorId,
    regionCode,
    isPickUpPoint,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarehouseData &&
          other.id == this.id &&
          other.name == this.name &&
          other.vendorId == this.vendorId &&
          other.regionCode == this.regionCode &&
          other.isPickUpPoint == this.isPickUpPoint &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WarehousesCompanion extends UpdateCompanion<WarehouseData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> vendorId;
  final Value<String> regionCode;
  final Value<bool> isPickUpPoint;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WarehousesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.regionCode = const Value.absent(),
    this.isPickUpPoint = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WarehousesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String vendorId,
    required String regionCode,
    this.isPickUpPoint = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       vendorId = Value(vendorId),
       regionCode = Value(regionCode);
  static Insertable<WarehouseData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? vendorId,
    Expression<String>? regionCode,
    Expression<bool>? isPickUpPoint,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (vendorId != null) 'vendor_id': vendorId,
      if (regionCode != null) 'region_code': regionCode,
      if (isPickUpPoint != null) 'is_pick_up_point': isPickUpPoint,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WarehousesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? vendorId,
    Value<String>? regionCode,
    Value<bool>? isPickUpPoint,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WarehousesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      vendorId: vendorId ?? this.vendorId,
      regionCode: regionCode ?? this.regionCode,
      isPickUpPoint: isPickUpPoint ?? this.isPickUpPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<String>(vendorId.value);
    }
    if (regionCode.present) {
      map['region_code'] = Variable<String>(regionCode.value);
    }
    if (isPickUpPoint.present) {
      map['is_pick_up_point'] = Variable<bool>(isPickUpPoint.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarehousesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('vendorId: $vendorId, ')
          ..write('regionCode: $regionCode, ')
          ..write('isPickUpPoint: $isPickUpPoint, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs
    with TableInfo<$SyncLogsTable, SyncLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskMeta = const VerificationMeta('task');
  @override
  late final GeneratedColumn<String> task = GeneratedColumn<String>(
    'task',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('info'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionCodeMeta = const VerificationMeta(
    'regionCode',
  );
  @override
  late final GeneratedColumn<String> regionCode = GeneratedColumn<String>(
    'region_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tradingPointExternalIdMeta =
      const VerificationMeta('tradingPointExternalId');
  @override
  late final GeneratedColumn<String> tradingPointExternalId =
      GeneratedColumn<String>(
        'trading_point_external_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    task,
    eventType,
    status,
    message,
    detailsJson,
    regionCode,
    tradingPointExternalId,
    durationMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task')) {
      context.handle(
        _taskMeta,
        task.isAcceptableOrUnknown(data['task']!, _taskMeta),
      );
    } else if (isInserting) {
      context.missing(_taskMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('region_code')) {
      context.handle(
        _regionCodeMeta,
        regionCode.isAcceptableOrUnknown(data['region_code']!, _regionCodeMeta),
      );
    }
    if (data.containsKey('trading_point_external_id')) {
      context.handle(
        _tradingPointExternalIdMeta,
        tradingPointExternalId.isAcceptableOrUnknown(
          data['trading_point_external_id']!,
          _tradingPointExternalIdMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      task: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      ),
      regionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_code'],
      ),
      tradingPointExternalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trading_point_external_id'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class SyncLogRow extends DataClass implements Insertable<SyncLogRow> {
  final int id;
  final String task;
  final String eventType;
  final String? status;
  final String message;
  final String? detailsJson;
  final String? regionCode;
  final String? tradingPointExternalId;
  final int? durationMs;
  final DateTime createdAt;
  const SyncLogRow({
    required this.id,
    required this.task,
    required this.eventType,
    this.status,
    required this.message,
    this.detailsJson,
    this.regionCode,
    this.tradingPointExternalId,
    this.durationMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task'] = Variable<String>(task);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    if (!nullToAbsent || regionCode != null) {
      map['region_code'] = Variable<String>(regionCode);
    }
    if (!nullToAbsent || tradingPointExternalId != null) {
      map['trading_point_external_id'] = Variable<String>(
        tradingPointExternalId,
      );
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      task: Value(task),
      eventType: Value(eventType),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      message: Value(message),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
      regionCode: regionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(regionCode),
      tradingPointExternalId: tradingPointExternalId == null && nullToAbsent
          ? const Value.absent()
          : Value(tradingPointExternalId),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      createdAt: Value(createdAt),
    );
  }

  factory SyncLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLogRow(
      id: serializer.fromJson<int>(json['id']),
      task: serializer.fromJson<String>(json['task']),
      eventType: serializer.fromJson<String>(json['eventType']),
      status: serializer.fromJson<String?>(json['status']),
      message: serializer.fromJson<String>(json['message']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
      regionCode: serializer.fromJson<String?>(json['regionCode']),
      tradingPointExternalId: serializer.fromJson<String?>(
        json['tradingPointExternalId'],
      ),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'task': serializer.toJson<String>(task),
      'eventType': serializer.toJson<String>(eventType),
      'status': serializer.toJson<String?>(status),
      'message': serializer.toJson<String>(message),
      'detailsJson': serializer.toJson<String?>(detailsJson),
      'regionCode': serializer.toJson<String?>(regionCode),
      'tradingPointExternalId': serializer.toJson<String?>(
        tradingPointExternalId,
      ),
      'durationMs': serializer.toJson<int?>(durationMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncLogRow copyWith({
    int? id,
    String? task,
    String? eventType,
    Value<String?> status = const Value.absent(),
    String? message,
    Value<String?> detailsJson = const Value.absent(),
    Value<String?> regionCode = const Value.absent(),
    Value<String?> tradingPointExternalId = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    DateTime? createdAt,
  }) => SyncLogRow(
    id: id ?? this.id,
    task: task ?? this.task,
    eventType: eventType ?? this.eventType,
    status: status.present ? status.value : this.status,
    message: message ?? this.message,
    detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
    regionCode: regionCode.present ? regionCode.value : this.regionCode,
    tradingPointExternalId: tradingPointExternalId.present
        ? tradingPointExternalId.value
        : this.tradingPointExternalId,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncLogRow copyWithCompanion(SyncLogsCompanion data) {
    return SyncLogRow(
      id: data.id.present ? data.id.value : this.id,
      task: data.task.present ? data.task.value : this.task,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      regionCode: data.regionCode.present
          ? data.regionCode.value
          : this.regionCode,
      tradingPointExternalId: data.tradingPointExternalId.present
          ? data.tradingPointExternalId.value
          : this.tradingPointExternalId,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogRow(')
          ..write('id: $id, ')
          ..write('task: $task, ')
          ..write('eventType: $eventType, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('regionCode: $regionCode, ')
          ..write('tradingPointExternalId: $tradingPointExternalId, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    task,
    eventType,
    status,
    message,
    detailsJson,
    regionCode,
    tradingPointExternalId,
    durationMs,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogRow &&
          other.id == this.id &&
          other.task == this.task &&
          other.eventType == this.eventType &&
          other.status == this.status &&
          other.message == this.message &&
          other.detailsJson == this.detailsJson &&
          other.regionCode == this.regionCode &&
          other.tradingPointExternalId == this.tradingPointExternalId &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt);
}

class SyncLogsCompanion extends UpdateCompanion<SyncLogRow> {
  final Value<int> id;
  final Value<String> task;
  final Value<String> eventType;
  final Value<String?> status;
  final Value<String> message;
  final Value<String?> detailsJson;
  final Value<String?> regionCode;
  final Value<String?> tradingPointExternalId;
  final Value<int?> durationMs;
  final Value<DateTime> createdAt;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.task = const Value.absent(),
    this.eventType = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.regionCode = const Value.absent(),
    this.tradingPointExternalId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    this.id = const Value.absent(),
    required String task,
    this.eventType = const Value.absent(),
    this.status = const Value.absent(),
    required String message,
    this.detailsJson = const Value.absent(),
    this.regionCode = const Value.absent(),
    this.tradingPointExternalId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : task = Value(task),
       message = Value(message);
  static Insertable<SyncLogRow> custom({
    Expression<int>? id,
    Expression<String>? task,
    Expression<String>? eventType,
    Expression<String>? status,
    Expression<String>? message,
    Expression<String>? detailsJson,
    Expression<String>? regionCode,
    Expression<String>? tradingPointExternalId,
    Expression<int>? durationMs,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (task != null) 'task': task,
      if (eventType != null) 'event_type': eventType,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (detailsJson != null) 'details_json': detailsJson,
      if (regionCode != null) 'region_code': regionCode,
      if (tradingPointExternalId != null)
        'trading_point_external_id': tradingPointExternalId,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? task,
    Value<String>? eventType,
    Value<String?>? status,
    Value<String>? message,
    Value<String?>? detailsJson,
    Value<String?>? regionCode,
    Value<String?>? tradingPointExternalId,
    Value<int?>? durationMs,
    Value<DateTime>? createdAt,
  }) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      task: task ?? this.task,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      message: message ?? this.message,
      detailsJson: detailsJson ?? this.detailsJson,
      regionCode: regionCode ?? this.regionCode,
      tradingPointExternalId:
          tradingPointExternalId ?? this.tradingPointExternalId,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (task.present) {
      map['task'] = Variable<String>(task.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (regionCode.present) {
      map['region_code'] = Variable<String>(regionCode.value);
    }
    if (tradingPointExternalId.present) {
      map['trading_point_external_id'] = Variable<String>(
        tradingPointExternalId.value,
      );
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('task: $task, ')
          ..write('eventType: $eventType, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('regionCode: $regionCode, ')
          ..write('tradingPointExternalId: $tradingPointExternalId, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $PointsOfInterestTable pointsOfInterest = $PointsOfInterestTable(
    this,
  );
  late final $TradingPointsTable tradingPoints = $TradingPointsTable(this);
  late final $TradingPointEntitiesTable tradingPointEntities =
      $TradingPointEntitiesTable(this);
  late final $EmployeeTradingPointAssignmentsTable
  employeeTradingPointAssignments = $EmployeeTradingPointAssignmentsTable(this);
  late final $UserTracksTable userTracks = $UserTracksTable(this);
  late final $CompactTracksTable compactTracks = $CompactTracksTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $WorkDaysTable workDays = $WorkDaysTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderLinesTable orderLines = $OrderLinesTable(this);
  late final $StockItemsTable stockItems = $StockItemsTable(this);
  late final $OrderJobsTable orderJobs = $OrderJobsTable(this);
  late final $WarehousesTable warehouses = $WarehousesTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    employees,
    routes,
    pointsOfInterest,
    tradingPoints,
    tradingPointEntities,
    employeeTradingPointAssignments,
    userTracks,
    compactTracks,
    appUsers,
    workDays,
    categories,
    products,
    orders,
    orderLines,
    stockItems,
    orderJobs,
    warehouses,
    syncLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('compact_tracks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('order_lines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('order_jobs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String externalId,
      required String role,
      required String phoneNumber,
      required String hashedPassword,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> externalId,
      Value<String> role,
      Value<String> phoneNumber,
      Value<String> hashedPassword,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserData> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserTracksTable, List<UserTrackData>>
  _userTracksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userTracks,
    aliasName: $_aliasNameGenerator(db.users.id, db.userTracks.userId),
  );

  $$UserTracksTableProcessedTableManager get userTracksRefs {
    final manager = $$UserTracksTableTableManager(
      $_db,
      $_db.userTracks,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userTracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppUsersTable, List<AppUserData>>
  _appUsersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appUsers,
    aliasName: $_aliasNameGenerator(db.users.id, db.appUsers.userId),
  );

  $$AppUsersTableProcessedTableManager get appUsersRefs {
    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appUsersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashedPassword => $composableBuilder(
    column: $table.hashedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userTracksRefs(
    Expression<bool> Function($$UserTracksTableFilterComposer f) f,
  ) {
    final $$UserTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTracks,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTracksTableFilterComposer(
            $db: $db,
            $table: $db.userTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appUsersRefs(
    Expression<bool> Function($$AppUsersTableFilterComposer f) f,
  ) {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashedPassword => $composableBuilder(
    column: $table.hashedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hashedPassword => $composableBuilder(
    column: $table.hashedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> userTracksRefs<T extends Object>(
    Expression<T> Function($$UserTracksTableAnnotationComposer a) f,
  ) {
    final $$UserTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTracks,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.userTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> appUsersRefs<T extends Object>(
    Expression<T> Function($$AppUsersTableAnnotationComposer a) f,
  ) {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserData,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserData, $$UsersTableReferences),
          UserData,
          PrefetchHooks Function({bool userTracksRefs, bool appUsersRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> hashedPassword = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                externalId: externalId,
                role: role,
                phoneNumber: phoneNumber,
                hashedPassword: hashedPassword,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String externalId,
                required String role,
                required String phoneNumber,
                required String hashedPassword,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                externalId: externalId,
                role: role,
                phoneNumber: phoneNumber,
                hashedPassword: hashedPassword,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({userTracksRefs = false, appUsersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userTracksRefs) db.userTracks,
                    if (appUsersRefs) db.appUsers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userTracksRefs)
                        await $_getPrefetchedData<
                          UserData,
                          $UsersTable,
                          UserTrackData
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._userTracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userTracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appUsersRefs)
                        await $_getPrefetchedData<
                          UserData,
                          $UsersTable,
                          AppUserData
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._appUsersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).appUsersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserData,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserData, $$UsersTableReferences),
      UserData,
      PrefetchHooks Function({bool userTracksRefs, bool appUsersRefs})
    >;
typedef $$EmployeesTableCreateCompanionBuilder =
    EmployeesCompanion Function({
      Value<int> id,
      required String lastName,
      required String firstName,
      Value<String?> middleName,
      required String role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EmployeesTableUpdateCompanionBuilder =
    EmployeesCompanion Function({
      Value<int> id,
      Value<String> lastName,
      Value<String> firstName,
      Value<String?> middleName,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$EmployeesTableReferences
    extends BaseReferences<_$AppDatabase, $EmployeesTable, EmployeeData> {
  $$EmployeesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutesTable, List<RouteData>> _routesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.routes,
    aliasName: $_aliasNameGenerator(db.employees.id, db.routes.employeeId),
  );

  $$RoutesTableProcessedTableManager get routesRefs {
    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.employeeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EmployeeTradingPointAssignmentsTable,
    List<EmployeeTradingPointAssignment>
  >
  _employeeTradingPointAssignmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.employeeTradingPointAssignments,
        aliasName: $_aliasNameGenerator(
          db.employees.id,
          db.employeeTradingPointAssignments.employeeId,
        ),
      );

  $$EmployeeTradingPointAssignmentsTableProcessedTableManager
  get employeeTradingPointAssignmentsRefs {
    final manager = $$EmployeeTradingPointAssignmentsTableTableManager(
      $_db,
      $_db.employeeTradingPointAssignments,
    ).filter((f) => f.employeeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _employeeTradingPointAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppUsersTable, List<AppUserData>>
  _appUsersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appUsers,
    aliasName: $_aliasNameGenerator(db.employees.id, db.appUsers.employeeId),
  );

  $$AppUsersTableProcessedTableManager get appUsersRefs {
    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.employeeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appUsersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<OrderEntity>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: $_aliasNameGenerator(db.employees.id, db.orders.creatorId),
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.creatorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routesRefs(
    Expression<bool> Function($$RoutesTableFilterComposer f) f,
  ) {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> employeeTradingPointAssignmentsRefs(
    Expression<bool> Function(
      $$EmployeeTradingPointAssignmentsTableFilterComposer f,
    )
    f,
  ) {
    final $$EmployeeTradingPointAssignmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.employeeTradingPointAssignments,
          getReferencedColumn: (t) => t.employeeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EmployeeTradingPointAssignmentsTableFilterComposer(
                $db: $db,
                $table: $db.employeeTradingPointAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> appUsersRefs(
    Expression<bool> Function($$AppUsersTableFilterComposer f) f,
  ) {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.creatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> routesRefs<T extends Object>(
    Expression<T> Function($$RoutesTableAnnotationComposer a) f,
  ) {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> employeeTradingPointAssignmentsRefs<T extends Object>(
    Expression<T> Function(
      $$EmployeeTradingPointAssignmentsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$EmployeeTradingPointAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.employeeTradingPointAssignments,
          getReferencedColumn: (t) => t.employeeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EmployeeTradingPointAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.employeeTradingPointAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> appUsersRefs<T extends Object>(
    Expression<T> Function($$AppUsersTableAnnotationComposer a) f,
  ) {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.creatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          EmployeeData,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (EmployeeData, $$EmployeesTableReferences),
          EmployeeData,
          PrefetchHooks Function({
            bool routesRefs,
            bool employeeTradingPointAssignmentsRefs,
            bool appUsersRefs,
            bool ordersRefs,
          })
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EmployeesCompanion(
                id: id,
                lastName: lastName,
                firstName: firstName,
                middleName: middleName,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String lastName,
                required String firstName,
                Value<String?> middleName = const Value.absent(),
                required String role,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EmployeesCompanion.insert(
                id: id,
                lastName: lastName,
                firstName: firstName,
                middleName: middleName,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmployeesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routesRefs = false,
                employeeTradingPointAssignmentsRefs = false,
                appUsersRefs = false,
                ordersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routesRefs) db.routes,
                    if (employeeTradingPointAssignmentsRefs)
                      db.employeeTradingPointAssignments,
                    if (appUsersRefs) db.appUsers,
                    if (ordersRefs) db.orders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routesRefs)
                        await $_getPrefetchedData<
                          EmployeeData,
                          $EmployeesTable,
                          RouteData
                        >(
                          currentTable: table,
                          referencedTable: $$EmployeesTableReferences
                              ._routesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmployeesTableReferences(
                                db,
                                table,
                                p0,
                              ).routesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.employeeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (employeeTradingPointAssignmentsRefs)
                        await $_getPrefetchedData<
                          EmployeeData,
                          $EmployeesTable,
                          EmployeeTradingPointAssignment
                        >(
                          currentTable: table,
                          referencedTable: $$EmployeesTableReferences
                              ._employeeTradingPointAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmployeesTableReferences(
                                db,
                                table,
                                p0,
                              ).employeeTradingPointAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.employeeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appUsersRefs)
                        await $_getPrefetchedData<
                          EmployeeData,
                          $EmployeesTable,
                          AppUserData
                        >(
                          currentTable: table,
                          referencedTable: $$EmployeesTableReferences
                              ._appUsersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmployeesTableReferences(
                                db,
                                table,
                                p0,
                              ).appUsersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.employeeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ordersRefs)
                        await $_getPrefetchedData<
                          EmployeeData,
                          $EmployeesTable,
                          OrderEntity
                        >(
                          currentTable: table,
                          referencedTable: $$EmployeesTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmployeesTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.creatorId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      EmployeeData,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (EmployeeData, $$EmployeesTableReferences),
      EmployeeData,
      PrefetchHooks Function({
        bool routesRefs,
        bool employeeTradingPointAssignmentsRefs,
        bool appUsersRefs,
        bool ordersRefs,
      })
    >;
typedef $$RoutesTableCreateCompanionBuilder =
    RoutesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      required String status,
      Value<int?> employeeId,
    });
typedef $$RoutesTableUpdateCompanionBuilder =
    RoutesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<String> status,
      Value<int?> employeeId,
    });

final class $$RoutesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutesTable, RouteData> {
  $$RoutesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EmployeesTable _employeeIdTable(_$AppDatabase db) => db.employees
      .createAlias($_aliasNameGenerator(db.routes.employeeId, db.employees.id));

  $$EmployeesTableProcessedTableManager? get employeeId {
    final $_column = $_itemColumn<int>('employee_id');
    if ($_column == null) return null;
    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PointsOfInterestTable, List<PointOfInterestData>>
  _pointsOfInterestRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pointsOfInterest,
    aliasName: $_aliasNameGenerator(db.routes.id, db.pointsOfInterest.routeId),
  );

  $$PointsOfInterestTableProcessedTableManager get pointsOfInterestRefs {
    final manager = $$PointsOfInterestTableTableManager(
      $_db,
      $_db.pointsOfInterest,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pointsOfInterestRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserTracksTable, List<UserTrackData>>
  _userTracksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userTracks,
    aliasName: $_aliasNameGenerator(db.routes.id, db.userTracks.routeId),
  );

  $$UserTracksTableProcessedTableManager get userTracksRefs {
    final manager = $$UserTracksTableTableManager(
      $_db,
      $_db.userTracks,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userTracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pointsOfInterestRefs(
    Expression<bool> Function($$PointsOfInterestTableFilterComposer f) f,
  ) {
    final $$PointsOfInterestTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointsOfInterest,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsOfInterestTableFilterComposer(
            $db: $db,
            $table: $db.pointsOfInterest,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userTracksRefs(
    Expression<bool> Function($$UserTracksTableFilterComposer f) f,
  ) {
    final $$UserTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTracks,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTracksTableFilterComposer(
            $db: $db,
            $table: $db.userTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$EmployeesTableAnnotationComposer get employeeId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pointsOfInterestRefs<T extends Object>(
    Expression<T> Function($$PointsOfInterestTableAnnotationComposer a) f,
  ) {
    final $$PointsOfInterestTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointsOfInterest,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsOfInterestTableAnnotationComposer(
            $db: $db,
            $table: $db.pointsOfInterest,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userTracksRefs<T extends Object>(
    Expression<T> Function($$UserTracksTableAnnotationComposer a) f,
  ) {
    final $$UserTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTracks,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.userTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutesTable,
          RouteData,
          $$RoutesTableFilterComposer,
          $$RoutesTableOrderingComposer,
          $$RoutesTableAnnotationComposer,
          $$RoutesTableCreateCompanionBuilder,
          $$RoutesTableUpdateCompanionBuilder,
          (RouteData, $$RoutesTableReferences),
          RouteData,
          PrefetchHooks Function({
            bool employeeId,
            bool pointsOfInterestRefs,
            bool userTracksRefs,
          })
        > {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> employeeId = const Value.absent(),
              }) => RoutesCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startTime: startTime,
                endTime: endTime,
                status: status,
                employeeId: employeeId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                required String status,
                Value<int?> employeeId = const Value.absent(),
              }) => RoutesCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startTime: startTime,
                endTime: endTime,
                status: status,
                employeeId: employeeId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoutesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                employeeId = false,
                pointsOfInterestRefs = false,
                userTracksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pointsOfInterestRefs) db.pointsOfInterest,
                    if (userTracksRefs) db.userTracks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (employeeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.employeeId,
                                    referencedTable: $$RoutesTableReferences
                                        ._employeeIdTable(db),
                                    referencedColumn: $$RoutesTableReferences
                                        ._employeeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pointsOfInterestRefs)
                        await $_getPrefetchedData<
                          RouteData,
                          $RoutesTable,
                          PointOfInterestData
                        >(
                          currentTable: table,
                          referencedTable: $$RoutesTableReferences
                              ._pointsOfInterestRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutesTableReferences(
                                db,
                                table,
                                p0,
                              ).pointsOfInterestRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userTracksRefs)
                        await $_getPrefetchedData<
                          RouteData,
                          $RoutesTable,
                          UserTrackData
                        >(
                          currentTable: table,
                          referencedTable: $$RoutesTableReferences
                              ._userTracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutesTableReferences(
                                db,
                                table,
                                p0,
                              ).userTracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutesTable,
      RouteData,
      $$RoutesTableFilterComposer,
      $$RoutesTableOrderingComposer,
      $$RoutesTableAnnotationComposer,
      $$RoutesTableCreateCompanionBuilder,
      $$RoutesTableUpdateCompanionBuilder,
      (RouteData, $$RoutesTableReferences),
      RouteData,
      PrefetchHooks Function({
        bool employeeId,
        bool pointsOfInterestRefs,
        bool userTracksRefs,
      })
    >;
typedef $$PointsOfInterestTableCreateCompanionBuilder =
    PointsOfInterestCompanion Function({
      Value<int> id,
      required int routeId,
      required String name,
      Value<String?> description,
      required double latitude,
      required double longitude,
      required String status,
      Value<DateTime> createdAt,
      Value<DateTime?> visitedAt,
      Value<String?> notes,
      required String type,
    });
typedef $$PointsOfInterestTableUpdateCompanionBuilder =
    PointsOfInterestCompanion Function({
      Value<int> id,
      Value<int> routeId,
      Value<String> name,
      Value<String?> description,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> visitedAt,
      Value<String?> notes,
      Value<String> type,
    });

final class $$PointsOfInterestTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PointsOfInterestTable,
          PointOfInterestData
        > {
  $$PointsOfInterestTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutesTable _routeIdTable(_$AppDatabase db) => db.routes.createAlias(
    $_aliasNameGenerator(db.pointsOfInterest.routeId, db.routes.id),
  );

  $$RoutesTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<int>('route_id')!;

    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TradingPointsTable, List<TradingPointData>>
  _tradingPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tradingPoints,
    aliasName: $_aliasNameGenerator(
      db.pointsOfInterest.id,
      db.tradingPoints.pointOfInterestId,
    ),
  );

  $$TradingPointsTableProcessedTableManager get tradingPointsRefs {
    final manager = $$TradingPointsTableTableManager(
      $_db,
      $_db.tradingPoints,
    ).filter((f) => f.pointOfInterestId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tradingPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PointsOfInterestTableFilterComposer
    extends Composer<_$AppDatabase, $PointsOfInterestTable> {
  $$PointsOfInterestTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutesTableFilterComposer get routeId {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tradingPointsRefs(
    Expression<bool> Function($$TradingPointsTableFilterComposer f) f,
  ) {
    final $$TradingPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tradingPoints,
      getReferencedColumn: (t) => t.pointOfInterestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TradingPointsTableFilterComposer(
            $db: $db,
            $table: $db.tradingPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PointsOfInterestTableOrderingComposer
    extends Composer<_$AppDatabase, $PointsOfInterestTable> {
  $$PointsOfInterestTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutesTableOrderingComposer get routeId {
    final $$RoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableOrderingComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PointsOfInterestTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointsOfInterestTable> {
  $$PointsOfInterestTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$RoutesTableAnnotationComposer get routeId {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tradingPointsRefs<T extends Object>(
    Expression<T> Function($$TradingPointsTableAnnotationComposer a) f,
  ) {
    final $$TradingPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tradingPoints,
      getReferencedColumn: (t) => t.pointOfInterestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TradingPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.tradingPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PointsOfInterestTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PointsOfInterestTable,
          PointOfInterestData,
          $$PointsOfInterestTableFilterComposer,
          $$PointsOfInterestTableOrderingComposer,
          $$PointsOfInterestTableAnnotationComposer,
          $$PointsOfInterestTableCreateCompanionBuilder,
          $$PointsOfInterestTableUpdateCompanionBuilder,
          (PointOfInterestData, $$PointsOfInterestTableReferences),
          PointOfInterestData,
          PrefetchHooks Function({bool routeId, bool tradingPointsRefs})
        > {
  $$PointsOfInterestTableTableManager(
    _$AppDatabase db,
    $PointsOfInterestTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointsOfInterestTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointsOfInterestTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointsOfInterestTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> visitedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => PointsOfInterestCompanion(
                id: id,
                routeId: routeId,
                name: name,
                description: description,
                latitude: latitude,
                longitude: longitude,
                status: status,
                createdAt: createdAt,
                visitedAt: visitedAt,
                notes: notes,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeId,
                required String name,
                Value<String?> description = const Value.absent(),
                required double latitude,
                required double longitude,
                required String status,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> visitedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String type,
              }) => PointsOfInterestCompanion.insert(
                id: id,
                routeId: routeId,
                name: name,
                description: description,
                latitude: latitude,
                longitude: longitude,
                status: status,
                createdAt: createdAt,
                visitedAt: visitedAt,
                notes: notes,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PointsOfInterestTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routeId = false, tradingPointsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tradingPointsRefs) db.tradingPoints,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routeId,
                                    referencedTable:
                                        $$PointsOfInterestTableReferences
                                            ._routeIdTable(db),
                                    referencedColumn:
                                        $$PointsOfInterestTableReferences
                                            ._routeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tradingPointsRefs)
                        await $_getPrefetchedData<
                          PointOfInterestData,
                          $PointsOfInterestTable,
                          TradingPointData
                        >(
                          currentTable: table,
                          referencedTable: $$PointsOfInterestTableReferences
                              ._tradingPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PointsOfInterestTableReferences(
                                db,
                                table,
                                p0,
                              ).tradingPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pointOfInterestId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PointsOfInterestTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PointsOfInterestTable,
      PointOfInterestData,
      $$PointsOfInterestTableFilterComposer,
      $$PointsOfInterestTableOrderingComposer,
      $$PointsOfInterestTableAnnotationComposer,
      $$PointsOfInterestTableCreateCompanionBuilder,
      $$PointsOfInterestTableUpdateCompanionBuilder,
      (PointOfInterestData, $$PointsOfInterestTableReferences),
      PointOfInterestData,
      PrefetchHooks Function({bool routeId, bool tradingPointsRefs})
    >;
typedef $$TradingPointsTableCreateCompanionBuilder =
    TradingPointsCompanion Function({
      Value<int> id,
      required int pointOfInterestId,
      Value<String?> address,
      Value<String?> contactPerson,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> workingHours,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$TradingPointsTableUpdateCompanionBuilder =
    TradingPointsCompanion Function({
      Value<int> id,
      Value<int> pointOfInterestId,
      Value<String?> address,
      Value<String?> contactPerson,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> workingHours,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

final class $$TradingPointsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TradingPointsTable, TradingPointData> {
  $$TradingPointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PointsOfInterestTable _pointOfInterestIdTable(_$AppDatabase db) =>
      db.pointsOfInterest.createAlias(
        $_aliasNameGenerator(
          db.tradingPoints.pointOfInterestId,
          db.pointsOfInterest.id,
        ),
      );

  $$PointsOfInterestTableProcessedTableManager get pointOfInterestId {
    final $_column = $_itemColumn<int>('point_of_interest_id')!;

    final manager = $$PointsOfInterestTableTableManager(
      $_db,
      $_db.pointsOfInterest,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pointOfInterestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TradingPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TradingPointsTable> {
  $$TradingPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workingHours => $composableBuilder(
    column: $table.workingHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PointsOfInterestTableFilterComposer get pointOfInterestId {
    final $$PointsOfInterestTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointOfInterestId,
      referencedTable: $db.pointsOfInterest,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsOfInterestTableFilterComposer(
            $db: $db,
            $table: $db.pointsOfInterest,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TradingPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TradingPointsTable> {
  $$TradingPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workingHours => $composableBuilder(
    column: $table.workingHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PointsOfInterestTableOrderingComposer get pointOfInterestId {
    final $$PointsOfInterestTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointOfInterestId,
      referencedTable: $db.pointsOfInterest,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsOfInterestTableOrderingComposer(
            $db: $db,
            $table: $db.pointsOfInterest,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TradingPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradingPointsTable> {
  $$TradingPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get workingHours => $composableBuilder(
    column: $table.workingHours,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PointsOfInterestTableAnnotationComposer get pointOfInterestId {
    final $$PointsOfInterestTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointOfInterestId,
      referencedTable: $db.pointsOfInterest,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsOfInterestTableAnnotationComposer(
            $db: $db,
            $table: $db.pointsOfInterest,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TradingPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradingPointsTable,
          TradingPointData,
          $$TradingPointsTableFilterComposer,
          $$TradingPointsTableOrderingComposer,
          $$TradingPointsTableAnnotationComposer,
          $$TradingPointsTableCreateCompanionBuilder,
          $$TradingPointsTableUpdateCompanionBuilder,
          (TradingPointData, $$TradingPointsTableReferences),
          TradingPointData,
          PrefetchHooks Function({bool pointOfInterestId})
        > {
  $$TradingPointsTableTableManager(_$AppDatabase db, $TradingPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradingPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradingPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradingPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pointOfInterestId = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> workingHours = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TradingPointsCompanion(
                id: id,
                pointOfInterestId: pointOfInterestId,
                address: address,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                workingHours: workingHours,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pointOfInterestId,
                Value<String?> address = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> workingHours = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TradingPointsCompanion.insert(
                id: id,
                pointOfInterestId: pointOfInterestId,
                address: address,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                workingHours: workingHours,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TradingPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pointOfInterestId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pointOfInterestId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pointOfInterestId,
                                referencedTable: $$TradingPointsTableReferences
                                    ._pointOfInterestIdTable(db),
                                referencedColumn: $$TradingPointsTableReferences
                                    ._pointOfInterestIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TradingPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradingPointsTable,
      TradingPointData,
      $$TradingPointsTableFilterComposer,
      $$TradingPointsTableOrderingComposer,
      $$TradingPointsTableAnnotationComposer,
      $$TradingPointsTableCreateCompanionBuilder,
      $$TradingPointsTableUpdateCompanionBuilder,
      (TradingPointData, $$TradingPointsTableReferences),
      TradingPointData,
      PrefetchHooks Function({bool pointOfInterestId})
    >;
typedef $$TradingPointEntitiesTableCreateCompanionBuilder =
    TradingPointEntitiesCompanion Function({
      Value<int> id,
      required String externalId,
      required String name,
      Value<String?> inn,
      Value<String> region,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$TradingPointEntitiesTableUpdateCompanionBuilder =
    TradingPointEntitiesCompanion Function({
      Value<int> id,
      Value<String> externalId,
      Value<String> name,
      Value<String?> inn,
      Value<String> region,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

final class $$TradingPointEntitiesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TradingPointEntitiesTable,
          TradingPointEntity
        > {
  $$TradingPointEntitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$OrdersTable, List<OrderEntity>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: $_aliasNameGenerator(
      db.tradingPointEntities.id,
      db.orders.outletId,
    ),
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.outletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TradingPointEntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $TradingPointEntitiesTable> {
  $$TradingPointEntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inn => $composableBuilder(
    column: $table.inn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.outletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TradingPointEntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $TradingPointEntitiesTable> {
  $$TradingPointEntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inn => $composableBuilder(
    column: $table.inn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TradingPointEntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradingPointEntitiesTable> {
  $$TradingPointEntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get inn =>
      $composableBuilder(column: $table.inn, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.outletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TradingPointEntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradingPointEntitiesTable,
          TradingPointEntity,
          $$TradingPointEntitiesTableFilterComposer,
          $$TradingPointEntitiesTableOrderingComposer,
          $$TradingPointEntitiesTableAnnotationComposer,
          $$TradingPointEntitiesTableCreateCompanionBuilder,
          $$TradingPointEntitiesTableUpdateCompanionBuilder,
          (TradingPointEntity, $$TradingPointEntitiesTableReferences),
          TradingPointEntity,
          PrefetchHooks Function({bool ordersRefs})
        > {
  $$TradingPointEntitiesTableTableManager(
    _$AppDatabase db,
    $TradingPointEntitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradingPointEntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradingPointEntitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TradingPointEntitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> inn = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TradingPointEntitiesCompanion(
                id: id,
                externalId: externalId,
                name: name,
                inn: inn,
                region: region,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String externalId,
                required String name,
                Value<String?> inn = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TradingPointEntitiesCompanion.insert(
                id: id,
                externalId: externalId,
                name: name,
                inn: inn,
                region: region,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TradingPointEntitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ordersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ordersRefs) db.orders],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ordersRefs)
                    await $_getPrefetchedData<
                      TradingPointEntity,
                      $TradingPointEntitiesTable,
                      OrderEntity
                    >(
                      currentTable: table,
                      referencedTable: $$TradingPointEntitiesTableReferences
                          ._ordersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TradingPointEntitiesTableReferences(
                            db,
                            table,
                            p0,
                          ).ordersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.outletId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TradingPointEntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradingPointEntitiesTable,
      TradingPointEntity,
      $$TradingPointEntitiesTableFilterComposer,
      $$TradingPointEntitiesTableOrderingComposer,
      $$TradingPointEntitiesTableAnnotationComposer,
      $$TradingPointEntitiesTableCreateCompanionBuilder,
      $$TradingPointEntitiesTableUpdateCompanionBuilder,
      (TradingPointEntity, $$TradingPointEntitiesTableReferences),
      TradingPointEntity,
      PrefetchHooks Function({bool ordersRefs})
    >;
typedef $$EmployeeTradingPointAssignmentsTableCreateCompanionBuilder =
    EmployeeTradingPointAssignmentsCompanion Function({
      required int employeeId,
      required String tradingPointExternalId,
      Value<DateTime> assignedAt,
      Value<int> rowid,
    });
typedef $$EmployeeTradingPointAssignmentsTableUpdateCompanionBuilder =
    EmployeeTradingPointAssignmentsCompanion Function({
      Value<int> employeeId,
      Value<String> tradingPointExternalId,
      Value<DateTime> assignedAt,
      Value<int> rowid,
    });

final class $$EmployeeTradingPointAssignmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EmployeeTradingPointAssignmentsTable,
          EmployeeTradingPointAssignment
        > {
  $$EmployeeTradingPointAssignmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EmployeesTable _employeeIdTable(_$AppDatabase db) =>
      db.employees.createAlias(
        $_aliasNameGenerator(
          db.employeeTradingPointAssignments.employeeId,
          db.employees.id,
        ),
      );

  $$EmployeesTableProcessedTableManager get employeeId {
    final $_column = $_itemColumn<int>('employee_id')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmployeeTradingPointAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeeTradingPointAssignmentsTable> {
  $$EmployeeTradingPointAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tradingPointExternalId => $composableBuilder(
    column: $table.tradingPointExternalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmployeeTradingPointAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeeTradingPointAssignmentsTable> {
  $$EmployeeTradingPointAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tradingPointExternalId => $composableBuilder(
    column: $table.tradingPointExternalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmployeeTradingPointAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeeTradingPointAssignmentsTable> {
  $$EmployeeTradingPointAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tradingPointExternalId => $composableBuilder(
    column: $table.tradingPointExternalId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => column,
  );

  $$EmployeesTableAnnotationComposer get employeeId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmployeeTradingPointAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeeTradingPointAssignmentsTable,
          EmployeeTradingPointAssignment,
          $$EmployeeTradingPointAssignmentsTableFilterComposer,
          $$EmployeeTradingPointAssignmentsTableOrderingComposer,
          $$EmployeeTradingPointAssignmentsTableAnnotationComposer,
          $$EmployeeTradingPointAssignmentsTableCreateCompanionBuilder,
          $$EmployeeTradingPointAssignmentsTableUpdateCompanionBuilder,
          (
            EmployeeTradingPointAssignment,
            $$EmployeeTradingPointAssignmentsTableReferences,
          ),
          EmployeeTradingPointAssignment,
          PrefetchHooks Function({bool employeeId})
        > {
  $$EmployeeTradingPointAssignmentsTableTableManager(
    _$AppDatabase db,
    $EmployeeTradingPointAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeeTradingPointAssignmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EmployeeTradingPointAssignmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EmployeeTradingPointAssignmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> employeeId = const Value.absent(),
                Value<String> tradingPointExternalId = const Value.absent(),
                Value<DateTime> assignedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeeTradingPointAssignmentsCompanion(
                employeeId: employeeId,
                tradingPointExternalId: tradingPointExternalId,
                assignedAt: assignedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int employeeId,
                required String tradingPointExternalId,
                Value<DateTime> assignedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeeTradingPointAssignmentsCompanion.insert(
                employeeId: employeeId,
                tradingPointExternalId: tradingPointExternalId,
                assignedAt: assignedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmployeeTradingPointAssignmentsTableReferences(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({employeeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (employeeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.employeeId,
                                referencedTable:
                                    $$EmployeeTradingPointAssignmentsTableReferences
                                        ._employeeIdTable(db),
                                referencedColumn:
                                    $$EmployeeTradingPointAssignmentsTableReferences
                                        ._employeeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EmployeeTradingPointAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeeTradingPointAssignmentsTable,
      EmployeeTradingPointAssignment,
      $$EmployeeTradingPointAssignmentsTableFilterComposer,
      $$EmployeeTradingPointAssignmentsTableOrderingComposer,
      $$EmployeeTradingPointAssignmentsTableAnnotationComposer,
      $$EmployeeTradingPointAssignmentsTableCreateCompanionBuilder,
      $$EmployeeTradingPointAssignmentsTableUpdateCompanionBuilder,
      (
        EmployeeTradingPointAssignment,
        $$EmployeeTradingPointAssignmentsTableReferences,
      ),
      EmployeeTradingPointAssignment,
      PrefetchHooks Function({bool employeeId})
    >;
typedef $$UserTracksTableCreateCompanionBuilder =
    UserTracksCompanion Function({
      Value<int> id,
      required int userId,
      Value<int?> routeId,
      required DateTime startTime,
      Value<DateTime?> endTime,
      required String status,
      Value<int> totalPoints,
      Value<double> totalDistanceKm,
      Value<int> totalDurationSeconds,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserTracksTableUpdateCompanionBuilder =
    UserTracksCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int?> routeId,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<String> status,
      Value<int> totalPoints,
      Value<double> totalDistanceKm,
      Value<int> totalDurationSeconds,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$UserTracksTableReferences
    extends BaseReferences<_$AppDatabase, $UserTracksTable, UserTrackData> {
  $$UserTracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.userTracks.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoutesTable _routeIdTable(_$AppDatabase db) => db.routes.createAlias(
    $_aliasNameGenerator(db.userTracks.routeId, db.routes.id),
  );

  $$RoutesTableProcessedTableManager? get routeId {
    final $_column = $_itemColumn<int>('route_id');
    if ($_column == null) return null;
    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CompactTracksTable, List<CompactTrackData>>
  _compactTracksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compactTracks,
    aliasName: $_aliasNameGenerator(
      db.userTracks.id,
      db.compactTracks.userTrackId,
    ),
  );

  $$CompactTracksTableProcessedTableManager get compactTracksRefs {
    final manager = $$CompactTracksTableTableManager(
      $_db,
      $_db.compactTracks,
    ).filter((f) => f.userTrackId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_compactTracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserTracksTableFilterComposer
    extends Composer<_$AppDatabase, $UserTracksTable> {
  $$UserTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutesTableFilterComposer get routeId {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> compactTracksRefs(
    Expression<bool> Function($$CompactTracksTableFilterComposer f) f,
  ) {
    final $$CompactTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compactTracks,
      getReferencedColumn: (t) => t.userTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompactTracksTableFilterComposer(
            $db: $db,
            $table: $db.compactTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $UserTracksTable> {
  $$UserTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutesTableOrderingComposer get routeId {
    final $$RoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableOrderingComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserTracksTable> {
  $$UserTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutesTableAnnotationComposer get routeId {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> compactTracksRefs<T extends Object>(
    Expression<T> Function($$CompactTracksTableAnnotationComposer a) f,
  ) {
    final $$CompactTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compactTracks,
      getReferencedColumn: (t) => t.userTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompactTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.compactTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserTracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserTracksTable,
          UserTrackData,
          $$UserTracksTableFilterComposer,
          $$UserTracksTableOrderingComposer,
          $$UserTracksTableAnnotationComposer,
          $$UserTracksTableCreateCompanionBuilder,
          $$UserTracksTableUpdateCompanionBuilder,
          (UserTrackData, $$UserTracksTableReferences),
          UserTrackData,
          PrefetchHooks Function({
            bool userId,
            bool routeId,
            bool compactTracksRefs,
          })
        > {
  $$UserTracksTableTableManager(_$AppDatabase db, $UserTracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int?> routeId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> totalPoints = const Value.absent(),
                Value<double> totalDistanceKm = const Value.absent(),
                Value<int> totalDurationSeconds = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserTracksCompanion(
                id: id,
                userId: userId,
                routeId: routeId,
                startTime: startTime,
                endTime: endTime,
                status: status,
                totalPoints: totalPoints,
                totalDistanceKm: totalDistanceKm,
                totalDurationSeconds: totalDurationSeconds,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                Value<int?> routeId = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                required String status,
                Value<int> totalPoints = const Value.absent(),
                Value<double> totalDistanceKm = const Value.absent(),
                Value<int> totalDurationSeconds = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserTracksCompanion.insert(
                id: id,
                userId: userId,
                routeId: routeId,
                startTime: startTime,
                endTime: endTime,
                status: status,
                totalPoints: totalPoints,
                totalDistanceKm: totalDistanceKm,
                totalDurationSeconds: totalDurationSeconds,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userId = false, routeId = false, compactTracksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (compactTracksRefs) db.compactTracks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable: $$UserTracksTableReferences
                                        ._userIdTable(db),
                                    referencedColumn:
                                        $$UserTracksTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (routeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routeId,
                                    referencedTable: $$UserTracksTableReferences
                                        ._routeIdTable(db),
                                    referencedColumn:
                                        $$UserTracksTableReferences
                                            ._routeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (compactTracksRefs)
                        await $_getPrefetchedData<
                          UserTrackData,
                          $UserTracksTable,
                          CompactTrackData
                        >(
                          currentTable: table,
                          referencedTable: $$UserTracksTableReferences
                              ._compactTracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).compactTracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserTracksTable,
      UserTrackData,
      $$UserTracksTableFilterComposer,
      $$UserTracksTableOrderingComposer,
      $$UserTracksTableAnnotationComposer,
      $$UserTracksTableCreateCompanionBuilder,
      $$UserTracksTableUpdateCompanionBuilder,
      (UserTrackData, $$UserTracksTableReferences),
      UserTrackData,
      PrefetchHooks Function({
        bool userId,
        bool routeId,
        bool compactTracksRefs,
      })
    >;
typedef $$CompactTracksTableCreateCompanionBuilder =
    CompactTracksCompanion Function({
      Value<int> id,
      required int userTrackId,
      required int segmentOrder,
      required Uint8List coordinatesBlob,
      required Uint8List timestampsBlob,
      required Uint8List speedsBlob,
      required Uint8List accuraciesBlob,
      required Uint8List bearingsBlob,
      Value<DateTime> createdAt,
    });
typedef $$CompactTracksTableUpdateCompanionBuilder =
    CompactTracksCompanion Function({
      Value<int> id,
      Value<int> userTrackId,
      Value<int> segmentOrder,
      Value<Uint8List> coordinatesBlob,
      Value<Uint8List> timestampsBlob,
      Value<Uint8List> speedsBlob,
      Value<Uint8List> accuraciesBlob,
      Value<Uint8List> bearingsBlob,
      Value<DateTime> createdAt,
    });

final class $$CompactTracksTableReferences
    extends
        BaseReferences<_$AppDatabase, $CompactTracksTable, CompactTrackData> {
  $$CompactTracksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserTracksTable _userTrackIdTable(_$AppDatabase db) =>
      db.userTracks.createAlias(
        $_aliasNameGenerator(db.compactTracks.userTrackId, db.userTracks.id),
      );

  $$UserTracksTableProcessedTableManager get userTrackId {
    final $_column = $_itemColumn<int>('user_track_id')!;

    final manager = $$UserTracksTableTableManager(
      $_db,
      $_db.userTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompactTracksTableFilterComposer
    extends Composer<_$AppDatabase, $CompactTracksTable> {
  $$CompactTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentOrder => $composableBuilder(
    column: $table.segmentOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get coordinatesBlob => $composableBuilder(
    column: $table.coordinatesBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get timestampsBlob => $composableBuilder(
    column: $table.timestampsBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get speedsBlob => $composableBuilder(
    column: $table.speedsBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get accuraciesBlob => $composableBuilder(
    column: $table.accuraciesBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bearingsBlob => $composableBuilder(
    column: $table.bearingsBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserTracksTableFilterComposer get userTrackId {
    final $$UserTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userTrackId,
      referencedTable: $db.userTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTracksTableFilterComposer(
            $db: $db,
            $table: $db.userTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompactTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $CompactTracksTable> {
  $$CompactTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentOrder => $composableBuilder(
    column: $table.segmentOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get coordinatesBlob => $composableBuilder(
    column: $table.coordinatesBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get timestampsBlob => $composableBuilder(
    column: $table.timestampsBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get speedsBlob => $composableBuilder(
    column: $table.speedsBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get accuraciesBlob => $composableBuilder(
    column: $table.accuraciesBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bearingsBlob => $composableBuilder(
    column: $table.bearingsBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserTracksTableOrderingComposer get userTrackId {
    final $$UserTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userTrackId,
      referencedTable: $db.userTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTracksTableOrderingComposer(
            $db: $db,
            $table: $db.userTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompactTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompactTracksTable> {
  $$CompactTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get segmentOrder => $composableBuilder(
    column: $table.segmentOrder,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get coordinatesBlob => $composableBuilder(
    column: $table.coordinatesBlob,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get timestampsBlob => $composableBuilder(
    column: $table.timestampsBlob,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get speedsBlob => $composableBuilder(
    column: $table.speedsBlob,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get accuraciesBlob => $composableBuilder(
    column: $table.accuraciesBlob,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get bearingsBlob => $composableBuilder(
    column: $table.bearingsBlob,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UserTracksTableAnnotationComposer get userTrackId {
    final $$UserTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userTrackId,
      referencedTable: $db.userTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.userTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompactTracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompactTracksTable,
          CompactTrackData,
          $$CompactTracksTableFilterComposer,
          $$CompactTracksTableOrderingComposer,
          $$CompactTracksTableAnnotationComposer,
          $$CompactTracksTableCreateCompanionBuilder,
          $$CompactTracksTableUpdateCompanionBuilder,
          (CompactTrackData, $$CompactTracksTableReferences),
          CompactTrackData,
          PrefetchHooks Function({bool userTrackId})
        > {
  $$CompactTracksTableTableManager(_$AppDatabase db, $CompactTracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompactTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompactTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompactTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userTrackId = const Value.absent(),
                Value<int> segmentOrder = const Value.absent(),
                Value<Uint8List> coordinatesBlob = const Value.absent(),
                Value<Uint8List> timestampsBlob = const Value.absent(),
                Value<Uint8List> speedsBlob = const Value.absent(),
                Value<Uint8List> accuraciesBlob = const Value.absent(),
                Value<Uint8List> bearingsBlob = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CompactTracksCompanion(
                id: id,
                userTrackId: userTrackId,
                segmentOrder: segmentOrder,
                coordinatesBlob: coordinatesBlob,
                timestampsBlob: timestampsBlob,
                speedsBlob: speedsBlob,
                accuraciesBlob: accuraciesBlob,
                bearingsBlob: bearingsBlob,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userTrackId,
                required int segmentOrder,
                required Uint8List coordinatesBlob,
                required Uint8List timestampsBlob,
                required Uint8List speedsBlob,
                required Uint8List accuraciesBlob,
                required Uint8List bearingsBlob,
                Value<DateTime> createdAt = const Value.absent(),
              }) => CompactTracksCompanion.insert(
                id: id,
                userTrackId: userTrackId,
                segmentOrder: segmentOrder,
                coordinatesBlob: coordinatesBlob,
                timestampsBlob: timestampsBlob,
                speedsBlob: speedsBlob,
                accuraciesBlob: accuraciesBlob,
                bearingsBlob: bearingsBlob,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompactTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userTrackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userTrackId,
                                referencedTable: $$CompactTracksTableReferences
                                    ._userTrackIdTable(db),
                                referencedColumn: $$CompactTracksTableReferences
                                    ._userTrackIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompactTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompactTracksTable,
      CompactTrackData,
      $$CompactTracksTableFilterComposer,
      $$CompactTracksTableOrderingComposer,
      $$CompactTracksTableAnnotationComposer,
      $$CompactTracksTableCreateCompanionBuilder,
      $$CompactTracksTableUpdateCompanionBuilder,
      (CompactTrackData, $$CompactTracksTableReferences),
      CompactTrackData,
      PrefetchHooks Function({bool userTrackId})
    >;
typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> employeeId,
      required int userId,
      Value<int?> selectedTradingPointId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> employeeId,
      Value<int> userId,
      Value<int?> selectedTradingPointId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$AppUsersTableReferences
    extends BaseReferences<_$AppDatabase, $AppUsersTable, AppUserData> {
  $$AppUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EmployeesTable _employeeIdTable(_$AppDatabase db) =>
      db.employees.createAlias(
        $_aliasNameGenerator(db.appUsers.employeeId, db.employees.id),
      );

  $$EmployeesTableProcessedTableManager get employeeId {
    final $_column = $_itemColumn<int>('employee_id')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.appUsers.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get selectedTradingPointId => $composableBuilder(
    column: $table.selectedTradingPointId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get selectedTradingPointId => $composableBuilder(
    column: $table.selectedTradingPointId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get selectedTradingPointId => $composableBuilder(
    column: $table.selectedTradingPointId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EmployeesTableAnnotationComposer get employeeId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUserData,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUserData, $$AppUsersTableReferences),
          AppUserData,
          PrefetchHooks Function({bool employeeId, bool userId})
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> employeeId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int?> selectedTradingPointId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppUsersCompanion(
                employeeId: employeeId,
                userId: userId,
                selectedTradingPointId: selectedTradingPointId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> employeeId = const Value.absent(),
                required int userId,
                Value<int?> selectedTradingPointId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppUsersCompanion.insert(
                employeeId: employeeId,
                userId: userId,
                selectedTradingPointId: selectedTradingPointId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({employeeId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (employeeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.employeeId,
                                referencedTable: $$AppUsersTableReferences
                                    ._employeeIdTable(db),
                                referencedColumn: $$AppUsersTableReferences
                                    ._employeeIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$AppUsersTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$AppUsersTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUserData,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUserData, $$AppUsersTableReferences),
      AppUserData,
      PrefetchHooks Function({bool employeeId, bool userId})
    >;
typedef $$WorkDaysTableCreateCompanionBuilder =
    WorkDaysCompanion Function({
      Value<int> id,
      required int user,
      required DateTime date,
      Value<int?> routeId,
      Value<int?> trackId,
      Value<String> status,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WorkDaysTableUpdateCompanionBuilder =
    WorkDaysCompanion Function({
      Value<int> id,
      Value<int> user,
      Value<DateTime> date,
      Value<int?> routeId,
      Value<int?> trackId,
      Value<String> status,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WorkDaysTableFilterComposer
    extends Composer<_$AppDatabase, $WorkDaysTable> {
  $$WorkDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get user => $composableBuilder(
    column: $table.user,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkDaysTable> {
  $$WorkDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get user => $composableBuilder(
    column: $table.user,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkDaysTable> {
  $$WorkDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get user =>
      $composableBuilder(column: $table.user, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<int> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkDaysTable,
          WorkDayData,
          $$WorkDaysTableFilterComposer,
          $$WorkDaysTableOrderingComposer,
          $$WorkDaysTableAnnotationComposer,
          $$WorkDaysTableCreateCompanionBuilder,
          $$WorkDaysTableUpdateCompanionBuilder,
          (
            WorkDayData,
            BaseReferences<_$AppDatabase, $WorkDaysTable, WorkDayData>,
          ),
          WorkDayData,
          PrefetchHooks Function()
        > {
  $$WorkDaysTableTableManager(_$AppDatabase db, $WorkDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> user = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> routeId = const Value.absent(),
                Value<int?> trackId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkDaysCompanion(
                id: id,
                user: user,
                date: date,
                routeId: routeId,
                trackId: trackId,
                status: status,
                startTime: startTime,
                endTime: endTime,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int user,
                required DateTime date,
                Value<int?> routeId = const Value.absent(),
                Value<int?> trackId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkDaysCompanion.insert(
                id: id,
                user: user,
                date: date,
                routeId: routeId,
                trackId: trackId,
                status: status,
                startTime: startTime,
                endTime: endTime,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkDaysTable,
      WorkDayData,
      $$WorkDaysTableFilterComposer,
      $$WorkDaysTableOrderingComposer,
      $$WorkDaysTableAnnotationComposer,
      $$WorkDaysTableCreateCompanionBuilder,
      $$WorkDaysTableUpdateCompanionBuilder,
      (WorkDayData, BaseReferences<_$AppDatabase, $WorkDaysTable, WorkDayData>),
      WorkDayData,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required int categoryId,
      required int lft,
      required int lvl,
      required int rgt,
      Value<String?> description,
      Value<String?> query,
      required int count,
      Value<int?> parentId,
      required String rawJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> categoryId,
      Value<int> lft,
      Value<int> lvl,
      Value<int> rgt,
      Value<String?> description,
      Value<String?> query,
      Value<int> count,
      Value<int?> parentId,
      Value<String> rawJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lft => $composableBuilder(
    column: $table.lft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lvl => $composableBuilder(
    column: $table.lvl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rgt => $composableBuilder(
    column: $table.rgt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lft => $composableBuilder(
    column: $table.lft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lvl => $composableBuilder(
    column: $table.lvl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rgt => $composableBuilder(
    column: $table.rgt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lft =>
      $composableBuilder(column: $table.lft, builder: (column) => column);

  GeneratedColumn<int> get lvl =>
      $composableBuilder(column: $table.lvl, builder: (column) => column);

  GeneratedColumn<int> get rgt =>
      $composableBuilder(column: $table.rgt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryData,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryData,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData>,
          ),
          CategoryData,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> lft = const Value.absent(),
                Value<int> lvl = const Value.absent(),
                Value<int> rgt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> query = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                categoryId: categoryId,
                lft: lft,
                lvl: lvl,
                rgt: rgt,
                description: description,
                query: query,
                count: count,
                parentId: parentId,
                rawJson: rawJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int categoryId,
                required int lft,
                required int lvl,
                required int rgt,
                Value<String?> description = const Value.absent(),
                Value<String?> query = const Value.absent(),
                required int count,
                Value<int?> parentId = const Value.absent(),
                required String rawJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                categoryId: categoryId,
                lft: lft,
                lvl: lvl,
                rgt: rgt,
                description: description,
                query: query,
                count: count,
                parentId: parentId,
                rawJson: rawJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryData,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryData,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData>,
      ),
      CategoryData,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      required int catalogId,
      required int code,
      required int bcode,
      required String title,
      Value<String?> description,
      Value<String?> vendorCode,
      Value<int?> amountInPackage,
      required bool novelty,
      required bool popular,
      required bool isMarked,
      required bool canBuy,
      Value<int?> categoryId,
      Value<int?> typeId,
      Value<int?> priceListCategoryId,
      Value<String?> defaultImageJson,
      Value<String?> imagesJson,
      Value<String?> barcodesJson,
      Value<String?> howToUse,
      Value<String?> ingredients,
      required String rawJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<int> catalogId,
      Value<int> code,
      Value<int> bcode,
      Value<String> title,
      Value<String?> description,
      Value<String?> vendorCode,
      Value<int?> amountInPackage,
      Value<bool> novelty,
      Value<bool> popular,
      Value<bool> isMarked,
      Value<bool> canBuy,
      Value<int?> categoryId,
      Value<int?> typeId,
      Value<int?> priceListCategoryId,
      Value<String?> defaultImageJson,
      Value<String?> imagesJson,
      Value<String?> barcodesJson,
      Value<String?> howToUse,
      Value<String?> ingredients,
      Value<String> rawJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductData> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StockItemsTable, List<StockItemData>>
  _stockItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockItems,
    aliasName: $_aliasNameGenerator(
      db.products.code,
      db.stockItems.productCode,
    ),
  );

  $$StockItemsTableProcessedTableManager get stockItemsRefs {
    final manager = $$StockItemsTableTableManager(
      $_db,
      $_db.stockItems,
    ).filter((f) => f.productCode.code.sqlEquals($_itemColumn<int>('code')!));

    final cache = $_typedResult.readTableOrNull(_stockItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bcode => $composableBuilder(
    column: $table.bcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendorCode => $composableBuilder(
    column: $table.vendorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountInPackage => $composableBuilder(
    column: $table.amountInPackage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get novelty => $composableBuilder(
    column: $table.novelty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get popular => $composableBuilder(
    column: $table.popular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMarked => $composableBuilder(
    column: $table.isMarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canBuy => $composableBuilder(
    column: $table.canBuy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get typeId => $composableBuilder(
    column: $table.typeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceListCategoryId => $composableBuilder(
    column: $table.priceListCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultImageJson => $composableBuilder(
    column: $table.defaultImageJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagesJson => $composableBuilder(
    column: $table.imagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcodesJson => $composableBuilder(
    column: $table.barcodesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get howToUse => $composableBuilder(
    column: $table.howToUse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stockItemsRefs(
    Expression<bool> Function($$StockItemsTableFilterComposer f) f,
  ) {
    final $$StockItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.stockItems,
      getReferencedColumn: (t) => t.productCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockItemsTableFilterComposer(
            $db: $db,
            $table: $db.stockItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bcode => $composableBuilder(
    column: $table.bcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendorCode => $composableBuilder(
    column: $table.vendorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountInPackage => $composableBuilder(
    column: $table.amountInPackage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get novelty => $composableBuilder(
    column: $table.novelty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get popular => $composableBuilder(
    column: $table.popular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMarked => $composableBuilder(
    column: $table.isMarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canBuy => $composableBuilder(
    column: $table.canBuy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get typeId => $composableBuilder(
    column: $table.typeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceListCategoryId => $composableBuilder(
    column: $table.priceListCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultImageJson => $composableBuilder(
    column: $table.defaultImageJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagesJson => $composableBuilder(
    column: $table.imagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodesJson => $composableBuilder(
    column: $table.barcodesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get howToUse => $composableBuilder(
    column: $table.howToUse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<int> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get bcode =>
      $composableBuilder(column: $table.bcode, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vendorCode => $composableBuilder(
    column: $table.vendorCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountInPackage => $composableBuilder(
    column: $table.amountInPackage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get novelty =>
      $composableBuilder(column: $table.novelty, builder: (column) => column);

  GeneratedColumn<bool> get popular =>
      $composableBuilder(column: $table.popular, builder: (column) => column);

  GeneratedColumn<bool> get isMarked =>
      $composableBuilder(column: $table.isMarked, builder: (column) => column);

  GeneratedColumn<bool> get canBuy =>
      $composableBuilder(column: $table.canBuy, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get typeId =>
      $composableBuilder(column: $table.typeId, builder: (column) => column);

  GeneratedColumn<int> get priceListCategoryId => $composableBuilder(
    column: $table.priceListCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultImageJson => $composableBuilder(
    column: $table.defaultImageJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagesJson => $composableBuilder(
    column: $table.imagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcodesJson => $composableBuilder(
    column: $table.barcodesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get howToUse =>
      $composableBuilder(column: $table.howToUse, builder: (column) => column);

  GeneratedColumn<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> stockItemsRefs<T extends Object>(
    Expression<T> Function($$StockItemsTableAnnotationComposer a) f,
  ) {
    final $$StockItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.stockItems,
      getReferencedColumn: (t) => t.productCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductData,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductData, $$ProductsTableReferences),
          ProductData,
          PrefetchHooks Function({bool stockItemsRefs})
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catalogId = const Value.absent(),
                Value<int> code = const Value.absent(),
                Value<int> bcode = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> vendorCode = const Value.absent(),
                Value<int?> amountInPackage = const Value.absent(),
                Value<bool> novelty = const Value.absent(),
                Value<bool> popular = const Value.absent(),
                Value<bool> isMarked = const Value.absent(),
                Value<bool> canBuy = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> typeId = const Value.absent(),
                Value<int?> priceListCategoryId = const Value.absent(),
                Value<String?> defaultImageJson = const Value.absent(),
                Value<String?> imagesJson = const Value.absent(),
                Value<String?> barcodesJson = const Value.absent(),
                Value<String?> howToUse = const Value.absent(),
                Value<String?> ingredients = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                catalogId: catalogId,
                code: code,
                bcode: bcode,
                title: title,
                description: description,
                vendorCode: vendorCode,
                amountInPackage: amountInPackage,
                novelty: novelty,
                popular: popular,
                isMarked: isMarked,
                canBuy: canBuy,
                categoryId: categoryId,
                typeId: typeId,
                priceListCategoryId: priceListCategoryId,
                defaultImageJson: defaultImageJson,
                imagesJson: imagesJson,
                barcodesJson: barcodesJson,
                howToUse: howToUse,
                ingredients: ingredients,
                rawJson: rawJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catalogId,
                required int code,
                required int bcode,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> vendorCode = const Value.absent(),
                Value<int?> amountInPackage = const Value.absent(),
                required bool novelty,
                required bool popular,
                required bool isMarked,
                required bool canBuy,
                Value<int?> categoryId = const Value.absent(),
                Value<int?> typeId = const Value.absent(),
                Value<int?> priceListCategoryId = const Value.absent(),
                Value<String?> defaultImageJson = const Value.absent(),
                Value<String?> imagesJson = const Value.absent(),
                Value<String?> barcodesJson = const Value.absent(),
                Value<String?> howToUse = const Value.absent(),
                Value<String?> ingredients = const Value.absent(),
                required String rawJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                catalogId: catalogId,
                code: code,
                bcode: bcode,
                title: title,
                description: description,
                vendorCode: vendorCode,
                amountInPackage: amountInPackage,
                novelty: novelty,
                popular: popular,
                isMarked: isMarked,
                canBuy: canBuy,
                categoryId: categoryId,
                typeId: typeId,
                priceListCategoryId: priceListCategoryId,
                defaultImageJson: defaultImageJson,
                imagesJson: imagesJson,
                barcodesJson: barcodesJson,
                howToUse: howToUse,
                ingredients: ingredients,
                rawJson: rawJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stockItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (stockItemsRefs) db.stockItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stockItemsRefs)
                    await $_getPrefetchedData<
                      ProductData,
                      $ProductsTable,
                      StockItemData
                    >(
                      currentTable: table,
                      referencedTable: $$ProductsTableReferences
                          ._stockItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProductsTableReferences(
                        db,
                        table,
                        p0,
                      ).stockItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.productCode == item.code,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductData,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductData, $$ProductsTableReferences),
      ProductData,
      PrefetchHooks Function({bool stockItemsRefs})
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      Value<int> id,
      required int creatorId,
      required int outletId,
      required String state,
      Value<String?> paymentType,
      Value<String?> paymentDetails,
      Value<bool> paymentIsCash,
      Value<bool> paymentIsCard,
      Value<bool> paymentIsCredit,
      Value<String?> comment,
      Value<String?> name,
      Value<bool> isPickup,
      Value<DateTime?> approvedDeliveryDay,
      Value<DateTime?> approvedAssemblyDay,
      Value<bool> withRealization,
      Value<String?> failureReason,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$OrdersTableUpdateCompanionBuilder =
    OrdersCompanion Function({
      Value<int> id,
      Value<int> creatorId,
      Value<int> outletId,
      Value<String> state,
      Value<String?> paymentType,
      Value<String?> paymentDetails,
      Value<bool> paymentIsCash,
      Value<bool> paymentIsCard,
      Value<bool> paymentIsCredit,
      Value<String?> comment,
      Value<String?> name,
      Value<bool> isPickup,
      Value<DateTime?> approvedDeliveryDay,
      Value<DateTime?> approvedAssemblyDay,
      Value<bool> withRealization,
      Value<String?> failureReason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, OrderEntity> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EmployeesTable _creatorIdTable(_$AppDatabase db) => db.employees
      .createAlias($_aliasNameGenerator(db.orders.creatorId, db.employees.id));

  $$EmployeesTableProcessedTableManager get creatorId {
    final $_column = $_itemColumn<int>('creator_id')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TradingPointEntitiesTable _outletIdTable(_$AppDatabase db) =>
      db.tradingPointEntities.createAlias(
        $_aliasNameGenerator(db.orders.outletId, db.tradingPointEntities.id),
      );

  $$TradingPointEntitiesTableProcessedTableManager get outletId {
    final $_column = $_itemColumn<int>('outlet_id')!;

    final manager = $$TradingPointEntitiesTableTableManager(
      $_db,
      $_db.tradingPointEntities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_outletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OrderLinesTable, List<OrderLineEntity>>
  _orderLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderLines,
    aliasName: $_aliasNameGenerator(db.orders.id, db.orderLines.orderId),
  );

  $$OrderLinesTableProcessedTableManager get orderLinesRefs {
    final manager = $$OrderLinesTableTableManager(
      $_db,
      $_db.orderLines,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrderJobsTable, List<OrderJobEntity>>
  _orderJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderJobs,
    aliasName: $_aliasNameGenerator(db.orders.id, db.orderJobs.orderId),
  );

  $$OrderJobsTableProcessedTableManager get orderJobsRefs {
    final manager = $$OrderJobsTableTableManager(
      $_db,
      $_db.orderJobs,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentDetails => $composableBuilder(
    column: $table.paymentDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paymentIsCash => $composableBuilder(
    column: $table.paymentIsCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paymentIsCard => $composableBuilder(
    column: $table.paymentIsCard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paymentIsCredit => $composableBuilder(
    column: $table.paymentIsCredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPickup => $composableBuilder(
    column: $table.isPickup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get approvedDeliveryDay => $composableBuilder(
    column: $table.approvedDeliveryDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get approvedAssemblyDay => $composableBuilder(
    column: $table.approvedAssemblyDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get withRealization => $composableBuilder(
    column: $table.withRealization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EmployeesTableFilterComposer get creatorId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TradingPointEntitiesTableFilterComposer get outletId {
    final $$TradingPointEntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outletId,
      referencedTable: $db.tradingPointEntities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TradingPointEntitiesTableFilterComposer(
            $db: $db,
            $table: $db.tradingPointEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> orderLinesRefs(
    Expression<bool> Function($$OrderLinesTableFilterComposer f) f,
  ) {
    final $$OrderLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderLines,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderLinesTableFilterComposer(
            $db: $db,
            $table: $db.orderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orderJobsRefs(
    Expression<bool> Function($$OrderJobsTableFilterComposer f) f,
  ) {
    final $$OrderJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderJobs,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderJobsTableFilterComposer(
            $db: $db,
            $table: $db.orderJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentDetails => $composableBuilder(
    column: $table.paymentDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paymentIsCash => $composableBuilder(
    column: $table.paymentIsCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paymentIsCard => $composableBuilder(
    column: $table.paymentIsCard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paymentIsCredit => $composableBuilder(
    column: $table.paymentIsCredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPickup => $composableBuilder(
    column: $table.isPickup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get approvedDeliveryDay => $composableBuilder(
    column: $table.approvedDeliveryDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get approvedAssemblyDay => $composableBuilder(
    column: $table.approvedAssemblyDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get withRealization => $composableBuilder(
    column: $table.withRealization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmployeesTableOrderingComposer get creatorId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TradingPointEntitiesTableOrderingComposer get outletId {
    final $$TradingPointEntitiesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.outletId,
          referencedTable: $db.tradingPointEntities,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TradingPointEntitiesTableOrderingComposer(
                $db: $db,
                $table: $db.tradingPointEntities,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentDetails => $composableBuilder(
    column: $table.paymentDetails,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paymentIsCash => $composableBuilder(
    column: $table.paymentIsCash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paymentIsCard => $composableBuilder(
    column: $table.paymentIsCard,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paymentIsCredit => $composableBuilder(
    column: $table.paymentIsCredit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isPickup =>
      $composableBuilder(column: $table.isPickup, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedDeliveryDay => $composableBuilder(
    column: $table.approvedDeliveryDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get approvedAssemblyDay => $composableBuilder(
    column: $table.approvedAssemblyDay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get withRealization => $composableBuilder(
    column: $table.withRealization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EmployeesTableAnnotationComposer get creatorId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TradingPointEntitiesTableAnnotationComposer get outletId {
    final $$TradingPointEntitiesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.outletId,
          referencedTable: $db.tradingPointEntities,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TradingPointEntitiesTableAnnotationComposer(
                $db: $db,
                $table: $db.tradingPointEntities,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> orderLinesRefs<T extends Object>(
    Expression<T> Function($$OrderLinesTableAnnotationComposer a) f,
  ) {
    final $$OrderLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderLines,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.orderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> orderJobsRefs<T extends Object>(
    Expression<T> Function($$OrderJobsTableAnnotationComposer a) f,
  ) {
    final $$OrderJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderJobs,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          OrderEntity,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (OrderEntity, $$OrdersTableReferences),
          OrderEntity,
          PrefetchHooks Function({
            bool creatorId,
            bool outletId,
            bool orderLinesRefs,
            bool orderJobsRefs,
          })
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> creatorId = const Value.absent(),
                Value<int> outletId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> paymentType = const Value.absent(),
                Value<String?> paymentDetails = const Value.absent(),
                Value<bool> paymentIsCash = const Value.absent(),
                Value<bool> paymentIsCard = const Value.absent(),
                Value<bool> paymentIsCredit = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<bool> isPickup = const Value.absent(),
                Value<DateTime?> approvedDeliveryDay = const Value.absent(),
                Value<DateTime?> approvedAssemblyDay = const Value.absent(),
                Value<bool> withRealization = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                creatorId: creatorId,
                outletId: outletId,
                state: state,
                paymentType: paymentType,
                paymentDetails: paymentDetails,
                paymentIsCash: paymentIsCash,
                paymentIsCard: paymentIsCard,
                paymentIsCredit: paymentIsCredit,
                comment: comment,
                name: name,
                isPickup: isPickup,
                approvedDeliveryDay: approvedDeliveryDay,
                approvedAssemblyDay: approvedAssemblyDay,
                withRealization: withRealization,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int creatorId,
                required int outletId,
                required String state,
                Value<String?> paymentType = const Value.absent(),
                Value<String?> paymentDetails = const Value.absent(),
                Value<bool> paymentIsCash = const Value.absent(),
                Value<bool> paymentIsCard = const Value.absent(),
                Value<bool> paymentIsCredit = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<bool> isPickup = const Value.absent(),
                Value<DateTime?> approvedDeliveryDay = const Value.absent(),
                Value<DateTime?> approvedAssemblyDay = const Value.absent(),
                Value<bool> withRealization = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => OrdersCompanion.insert(
                id: id,
                creatorId: creatorId,
                outletId: outletId,
                state: state,
                paymentType: paymentType,
                paymentDetails: paymentDetails,
                paymentIsCash: paymentIsCash,
                paymentIsCard: paymentIsCard,
                paymentIsCredit: paymentIsCredit,
                comment: comment,
                name: name,
                isPickup: isPickup,
                approvedDeliveryDay: approvedDeliveryDay,
                approvedAssemblyDay: approvedAssemblyDay,
                withRealization: withRealization,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$OrdersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                creatorId = false,
                outletId = false,
                orderLinesRefs = false,
                orderJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (orderLinesRefs) db.orderLines,
                    if (orderJobsRefs) db.orderJobs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (creatorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.creatorId,
                                    referencedTable: $$OrdersTableReferences
                                        ._creatorIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._creatorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (outletId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.outletId,
                                    referencedTable: $$OrdersTableReferences
                                        ._outletIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._outletIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (orderLinesRefs)
                        await $_getPrefetchedData<
                          OrderEntity,
                          $OrdersTable,
                          OrderLineEntity
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._orderLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).orderLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (orderJobsRefs)
                        await $_getPrefetchedData<
                          OrderEntity,
                          $OrdersTable,
                          OrderJobEntity
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._orderJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).orderJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      OrderEntity,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (OrderEntity, $$OrdersTableReferences),
      OrderEntity,
      PrefetchHooks Function({
        bool creatorId,
        bool outletId,
        bool orderLinesRefs,
        bool orderJobsRefs,
      })
    >;
typedef $$OrderLinesTableCreateCompanionBuilder =
    OrderLinesCompanion Function({
      Value<int> id,
      required int orderId,
      required int stockItemId,
      required int quantity,
      required int pricePerUnit,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$OrderLinesTableUpdateCompanionBuilder =
    OrderLinesCompanion Function({
      Value<int> id,
      Value<int> orderId,
      Value<int> stockItemId,
      Value<int> quantity,
      Value<int> pricePerUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$OrderLinesTableReferences
    extends BaseReferences<_$AppDatabase, $OrderLinesTable, OrderLineEntity> {
  $$OrderLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders.createAlias(
    $_aliasNameGenerator(db.orderLines.orderId, db.orders.id),
  );

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderLinesTable> {
  $$OrderLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockItemId => $composableBuilder(
    column: $table.stockItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderLinesTable> {
  $$OrderLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockItemId => $composableBuilder(
    column: $table.stockItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderLinesTable> {
  $$OrderLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stockItemId => $composableBuilder(
    column: $table.stockItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderLinesTable,
          OrderLineEntity,
          $$OrderLinesTableFilterComposer,
          $$OrderLinesTableOrderingComposer,
          $$OrderLinesTableAnnotationComposer,
          $$OrderLinesTableCreateCompanionBuilder,
          $$OrderLinesTableUpdateCompanionBuilder,
          (OrderLineEntity, $$OrderLinesTableReferences),
          OrderLineEntity,
          PrefetchHooks Function({bool orderId})
        > {
  $$OrderLinesTableTableManager(_$AppDatabase db, $OrderLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> orderId = const Value.absent(),
                Value<int> stockItemId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> pricePerUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OrderLinesCompanion(
                id: id,
                orderId: orderId,
                stockItemId: stockItemId,
                quantity: quantity,
                pricePerUnit: pricePerUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int orderId,
                required int stockItemId,
                required int quantity,
                required int pricePerUnit,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => OrderLinesCompanion.insert(
                id: id,
                orderId: orderId,
                stockItemId: stockItemId,
                quantity: quantity,
                pricePerUnit: pricePerUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrderLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$OrderLinesTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$OrderLinesTableReferences
                                    ._orderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrderLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderLinesTable,
      OrderLineEntity,
      $$OrderLinesTableFilterComposer,
      $$OrderLinesTableOrderingComposer,
      $$OrderLinesTableAnnotationComposer,
      $$OrderLinesTableCreateCompanionBuilder,
      $$OrderLinesTableUpdateCompanionBuilder,
      (OrderLineEntity, $$OrderLinesTableReferences),
      OrderLineEntity,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$StockItemsTableCreateCompanionBuilder =
    StockItemsCompanion Function({
      Value<int> id,
      required int productCode,
      required int warehouseId,
      required String warehouseName,
      required String warehouseVendorId,
      Value<bool> isPickUpPoint,
      Value<int> stock,
      Value<int?> multiplicity,
      required String publicStock,
      required int defaultPrice,
      Value<int> discountValue,
      Value<int?> availablePrice,
      Value<int?> offerPrice,
      Value<String> currency,
      Value<String?> priceType,
      Value<String?> promotionJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$StockItemsTableUpdateCompanionBuilder =
    StockItemsCompanion Function({
      Value<int> id,
      Value<int> productCode,
      Value<int> warehouseId,
      Value<String> warehouseName,
      Value<String> warehouseVendorId,
      Value<bool> isPickUpPoint,
      Value<int> stock,
      Value<int?> multiplicity,
      Value<String> publicStock,
      Value<int> defaultPrice,
      Value<int> discountValue,
      Value<int?> availablePrice,
      Value<int?> offerPrice,
      Value<String> currency,
      Value<String?> priceType,
      Value<String?> promotionJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$StockItemsTableReferences
    extends BaseReferences<_$AppDatabase, $StockItemsTable, StockItemData> {
  $$StockItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productCodeTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.stockItems.productCode, db.products.code),
      );

  $$ProductsTableProcessedTableManager get productCode {
    final $_column = $_itemColumn<int>('product_code')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warehouseName => $composableBuilder(
    column: $table.warehouseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warehouseVendorId => $composableBuilder(
    column: $table.warehouseVendorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPickUpPoint => $composableBuilder(
    column: $table.isPickUpPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get multiplicity => $composableBuilder(
    column: $table.multiplicity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicStock => $composableBuilder(
    column: $table.publicStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availablePrice => $composableBuilder(
    column: $table.availablePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offerPrice => $composableBuilder(
    column: $table.offerPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceType => $composableBuilder(
    column: $table.priceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promotionJson => $composableBuilder(
    column: $table.promotionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productCode {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productCode,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warehouseName => $composableBuilder(
    column: $table.warehouseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warehouseVendorId => $composableBuilder(
    column: $table.warehouseVendorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPickUpPoint => $composableBuilder(
    column: $table.isPickUpPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get multiplicity => $composableBuilder(
    column: $table.multiplicity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicStock => $composableBuilder(
    column: $table.publicStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availablePrice => $composableBuilder(
    column: $table.availablePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offerPrice => $composableBuilder(
    column: $table.offerPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceType => $composableBuilder(
    column: $table.priceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promotionJson => $composableBuilder(
    column: $table.promotionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productCode {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productCode,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get warehouseId => $composableBuilder(
    column: $table.warehouseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warehouseName => $composableBuilder(
    column: $table.warehouseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warehouseVendorId => $composableBuilder(
    column: $table.warehouseVendorId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPickUpPoint => $composableBuilder(
    column: $table.isPickUpPoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get multiplicity => $composableBuilder(
    column: $table.multiplicity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicStock => $composableBuilder(
    column: $table.publicStock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get availablePrice => $composableBuilder(
    column: $table.availablePrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get offerPrice => $composableBuilder(
    column: $table.offerPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get priceType =>
      $composableBuilder(column: $table.priceType, builder: (column) => column);

  GeneratedColumn<String> get promotionJson => $composableBuilder(
    column: $table.promotionJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productCode {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productCode,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockItemsTable,
          StockItemData,
          $$StockItemsTableFilterComposer,
          $$StockItemsTableOrderingComposer,
          $$StockItemsTableAnnotationComposer,
          $$StockItemsTableCreateCompanionBuilder,
          $$StockItemsTableUpdateCompanionBuilder,
          (StockItemData, $$StockItemsTableReferences),
          StockItemData,
          PrefetchHooks Function({bool productCode})
        > {
  $$StockItemsTableTableManager(_$AppDatabase db, $StockItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productCode = const Value.absent(),
                Value<int> warehouseId = const Value.absent(),
                Value<String> warehouseName = const Value.absent(),
                Value<String> warehouseVendorId = const Value.absent(),
                Value<bool> isPickUpPoint = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int?> multiplicity = const Value.absent(),
                Value<String> publicStock = const Value.absent(),
                Value<int> defaultPrice = const Value.absent(),
                Value<int> discountValue = const Value.absent(),
                Value<int?> availablePrice = const Value.absent(),
                Value<int?> offerPrice = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> priceType = const Value.absent(),
                Value<String?> promotionJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StockItemsCompanion(
                id: id,
                productCode: productCode,
                warehouseId: warehouseId,
                warehouseName: warehouseName,
                warehouseVendorId: warehouseVendorId,
                isPickUpPoint: isPickUpPoint,
                stock: stock,
                multiplicity: multiplicity,
                publicStock: publicStock,
                defaultPrice: defaultPrice,
                discountValue: discountValue,
                availablePrice: availablePrice,
                offerPrice: offerPrice,
                currency: currency,
                priceType: priceType,
                promotionJson: promotionJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productCode,
                required int warehouseId,
                required String warehouseName,
                required String warehouseVendorId,
                Value<bool> isPickUpPoint = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int?> multiplicity = const Value.absent(),
                required String publicStock,
                required int defaultPrice,
                Value<int> discountValue = const Value.absent(),
                Value<int?> availablePrice = const Value.absent(),
                Value<int?> offerPrice = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> priceType = const Value.absent(),
                Value<String?> promotionJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StockItemsCompanion.insert(
                id: id,
                productCode: productCode,
                warehouseId: warehouseId,
                warehouseName: warehouseName,
                warehouseVendorId: warehouseVendorId,
                isPickUpPoint: isPickUpPoint,
                stock: stock,
                multiplicity: multiplicity,
                publicStock: publicStock,
                defaultPrice: defaultPrice,
                discountValue: discountValue,
                availablePrice: availablePrice,
                offerPrice: offerPrice,
                currency: currency,
                priceType: priceType,
                promotionJson: promotionJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productCode,
                                referencedTable: $$StockItemsTableReferences
                                    ._productCodeTable(db),
                                referencedColumn: $$StockItemsTableReferences
                                    ._productCodeTable(db)
                                    .code,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StockItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockItemsTable,
      StockItemData,
      $$StockItemsTableFilterComposer,
      $$StockItemsTableOrderingComposer,
      $$StockItemsTableAnnotationComposer,
      $$StockItemsTableCreateCompanionBuilder,
      $$StockItemsTableUpdateCompanionBuilder,
      (StockItemData, $$StockItemsTableReferences),
      StockItemData,
      PrefetchHooks Function({bool productCode})
    >;
typedef $$OrderJobsTableCreateCompanionBuilder =
    OrderJobsCompanion Function({
      required String id,
      required int orderId,
      required String jobType,
      required String payloadJson,
      required String status,
      Value<int> attempts,
      Value<DateTime?> nextRunAt,
      Value<String?> failureReason,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OrderJobsTableUpdateCompanionBuilder =
    OrderJobsCompanion Function({
      Value<String> id,
      Value<int> orderId,
      Value<String> jobType,
      Value<String> payloadJson,
      Value<String> status,
      Value<int> attempts,
      Value<DateTime?> nextRunAt,
      Value<String?> failureReason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$OrderJobsTableReferences
    extends BaseReferences<_$AppDatabase, $OrderJobsTable, OrderJobEntity> {
  $$OrderJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders.createAlias(
    $_aliasNameGenerator(db.orderJobs.orderId, db.orders.id),
  );

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrderJobsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderJobsTable> {
  $$OrderJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderJobsTable> {
  $$OrderJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderJobsTable> {
  $$OrderJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRunAt =>
      $composableBuilder(column: $table.nextRunAt, builder: (column) => column);

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderJobsTable,
          OrderJobEntity,
          $$OrderJobsTableFilterComposer,
          $$OrderJobsTableOrderingComposer,
          $$OrderJobsTableAnnotationComposer,
          $$OrderJobsTableCreateCompanionBuilder,
          $$OrderJobsTableUpdateCompanionBuilder,
          (OrderJobEntity, $$OrderJobsTableReferences),
          OrderJobEntity,
          PrefetchHooks Function({bool orderId})
        > {
  $$OrderJobsTableTableManager(_$AppDatabase db, $OrderJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> orderId = const Value.absent(),
                Value<String> jobType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextRunAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderJobsCompanion(
                id: id,
                orderId: orderId,
                jobType: jobType,
                payloadJson: payloadJson,
                status: status,
                attempts: attempts,
                nextRunAt: nextRunAt,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int orderId,
                required String jobType,
                required String payloadJson,
                required String status,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextRunAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OrderJobsCompanion.insert(
                id: id,
                orderId: orderId,
                jobType: jobType,
                payloadJson: payloadJson,
                status: status,
                attempts: attempts,
                nextRunAt: nextRunAt,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrderJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$OrderJobsTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$OrderJobsTableReferences
                                    ._orderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrderJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderJobsTable,
      OrderJobEntity,
      $$OrderJobsTableFilterComposer,
      $$OrderJobsTableOrderingComposer,
      $$OrderJobsTableAnnotationComposer,
      $$OrderJobsTableCreateCompanionBuilder,
      $$OrderJobsTableUpdateCompanionBuilder,
      (OrderJobEntity, $$OrderJobsTableReferences),
      OrderJobEntity,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$WarehousesTableCreateCompanionBuilder =
    WarehousesCompanion Function({
      Value<int> id,
      required String name,
      required String vendorId,
      required String regionCode,
      Value<bool> isPickUpPoint,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WarehousesTableUpdateCompanionBuilder =
    WarehousesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> vendorId,
      Value<String> regionCode,
      Value<bool> isPickUpPoint,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WarehousesTableFilterComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendorId => $composableBuilder(
    column: $table.vendorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPickUpPoint => $composableBuilder(
    column: $table.isPickUpPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WarehousesTableOrderingComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendorId => $composableBuilder(
    column: $table.vendorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPickUpPoint => $composableBuilder(
    column: $table.isPickUpPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WarehousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get vendorId =>
      $composableBuilder(column: $table.vendorId, builder: (column) => column);

  GeneratedColumn<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPickUpPoint => $composableBuilder(
    column: $table.isPickUpPoint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WarehousesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WarehousesTable,
          WarehouseData,
          $$WarehousesTableFilterComposer,
          $$WarehousesTableOrderingComposer,
          $$WarehousesTableAnnotationComposer,
          $$WarehousesTableCreateCompanionBuilder,
          $$WarehousesTableUpdateCompanionBuilder,
          (
            WarehouseData,
            BaseReferences<_$AppDatabase, $WarehousesTable, WarehouseData>,
          ),
          WarehouseData,
          PrefetchHooks Function()
        > {
  $$WarehousesTableTableManager(_$AppDatabase db, $WarehousesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarehousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarehousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarehousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> vendorId = const Value.absent(),
                Value<String> regionCode = const Value.absent(),
                Value<bool> isPickUpPoint = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WarehousesCompanion(
                id: id,
                name: name,
                vendorId: vendorId,
                regionCode: regionCode,
                isPickUpPoint: isPickUpPoint,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String vendorId,
                required String regionCode,
                Value<bool> isPickUpPoint = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WarehousesCompanion.insert(
                id: id,
                name: name,
                vendorId: vendorId,
                regionCode: regionCode,
                isPickUpPoint: isPickUpPoint,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WarehousesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WarehousesTable,
      WarehouseData,
      $$WarehousesTableFilterComposer,
      $$WarehousesTableOrderingComposer,
      $$WarehousesTableAnnotationComposer,
      $$WarehousesTableCreateCompanionBuilder,
      $$WarehousesTableUpdateCompanionBuilder,
      (
        WarehouseData,
        BaseReferences<_$AppDatabase, $WarehousesTable, WarehouseData>,
      ),
      WarehouseData,
      PrefetchHooks Function()
    >;
typedef $$SyncLogsTableCreateCompanionBuilder =
    SyncLogsCompanion Function({
      Value<int> id,
      required String task,
      Value<String> eventType,
      Value<String?> status,
      required String message,
      Value<String?> detailsJson,
      Value<String?> regionCode,
      Value<String?> tradingPointExternalId,
      Value<int?> durationMs,
      Value<DateTime> createdAt,
    });
typedef $$SyncLogsTableUpdateCompanionBuilder =
    SyncLogsCompanion Function({
      Value<int> id,
      Value<String> task,
      Value<String> eventType,
      Value<String?> status,
      Value<String> message,
      Value<String?> detailsJson,
      Value<String?> regionCode,
      Value<String?> tradingPointExternalId,
      Value<int?> durationMs,
      Value<DateTime> createdAt,
    });

class $$SyncLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get task => $composableBuilder(
    column: $table.task,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradingPointExternalId => $composableBuilder(
    column: $table.tradingPointExternalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get task => $composableBuilder(
    column: $table.task,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradingPointExternalId => $composableBuilder(
    column: $table.tradingPointExternalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get task =>
      $composableBuilder(column: $table.task, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regionCode => $composableBuilder(
    column: $table.regionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tradingPointExternalId => $composableBuilder(
    column: $table.tradingPointExternalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogsTable,
          SyncLogRow,
          $$SyncLogsTableFilterComposer,
          $$SyncLogsTableOrderingComposer,
          $$SyncLogsTableAnnotationComposer,
          $$SyncLogsTableCreateCompanionBuilder,
          $$SyncLogsTableUpdateCompanionBuilder,
          (
            SyncLogRow,
            BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLogRow>,
          ),
          SyncLogRow,
          PrefetchHooks Function()
        > {
  $$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> task = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> detailsJson = const Value.absent(),
                Value<String?> regionCode = const Value.absent(),
                Value<String?> tradingPointExternalId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncLogsCompanion(
                id: id,
                task: task,
                eventType: eventType,
                status: status,
                message: message,
                detailsJson: detailsJson,
                regionCode: regionCode,
                tradingPointExternalId: tradingPointExternalId,
                durationMs: durationMs,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String task,
                Value<String> eventType = const Value.absent(),
                Value<String?> status = const Value.absent(),
                required String message,
                Value<String?> detailsJson = const Value.absent(),
                Value<String?> regionCode = const Value.absent(),
                Value<String?> tradingPointExternalId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncLogsCompanion.insert(
                id: id,
                task: task,
                eventType: eventType,
                status: status,
                message: message,
                detailsJson: detailsJson,
                regionCode: regionCode,
                tradingPointExternalId: tradingPointExternalId,
                durationMs: durationMs,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogsTable,
      SyncLogRow,
      $$SyncLogsTableFilterComposer,
      $$SyncLogsTableOrderingComposer,
      $$SyncLogsTableAnnotationComposer,
      $$SyncLogsTableCreateCompanionBuilder,
      $$SyncLogsTableUpdateCompanionBuilder,
      (SyncLogRow, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLogRow>),
      SyncLogRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$PointsOfInterestTableTableManager get pointsOfInterest =>
      $$PointsOfInterestTableTableManager(_db, _db.pointsOfInterest);
  $$TradingPointsTableTableManager get tradingPoints =>
      $$TradingPointsTableTableManager(_db, _db.tradingPoints);
  $$TradingPointEntitiesTableTableManager get tradingPointEntities =>
      $$TradingPointEntitiesTableTableManager(_db, _db.tradingPointEntities);
  $$EmployeeTradingPointAssignmentsTableTableManager
  get employeeTradingPointAssignments =>
      $$EmployeeTradingPointAssignmentsTableTableManager(
        _db,
        _db.employeeTradingPointAssignments,
      );
  $$UserTracksTableTableManager get userTracks =>
      $$UserTracksTableTableManager(_db, _db.userTracks);
  $$CompactTracksTableTableManager get compactTracks =>
      $$CompactTracksTableTableManager(_db, _db.compactTracks);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$WorkDaysTableTableManager get workDays =>
      $$WorkDaysTableTableManager(_db, _db.workDays);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderLinesTableTableManager get orderLines =>
      $$OrderLinesTableTableManager(_db, _db.orderLines);
  $$StockItemsTableTableManager get stockItems =>
      $$StockItemsTableTableManager(_db, _db.stockItems);
  $$OrderJobsTableTableManager get orderJobs =>
      $$OrderJobsTableTableManager(_db, _db.orderJobs);
  $$WarehousesTableTableManager get warehouses =>
      $$WarehousesTableTableManager(_db, _db.warehouses);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db, _db.syncLogs);
}
