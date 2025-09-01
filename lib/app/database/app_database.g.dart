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
  final DateTime createdAt;
  final DateTime? updatedAt;
  const TradingPointEntity({
    required this.id,
    required this.externalId,
    required this.name,
    this.inn,
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  TradingPointEntity copyWith({
    int? id,
    String? externalId,
    String? name,
    Value<String?> inn = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => TradingPointEntity(
    id: id ?? this.id,
    externalId: externalId ?? this.externalId,
    name: name ?? this.name,
    inn: inn.present ? inn.value : this.inn,
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, externalId, name, inn, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradingPointEntity &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.inn == this.inn &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TradingPointEntitiesCompanion
    extends UpdateCompanion<TradingPointEntity> {
  final Value<int> id;
  final Value<String> externalId;
  final Value<String> name;
  final Value<String?> inn;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const TradingPointEntitiesCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.inn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TradingPointEntitiesCompanion.insert({
    this.id = const Value.absent(),
    required String externalId,
    required String name,
    this.inn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : externalId = Value(externalId),
       name = Value(name);
  static Insertable<TradingPointEntity> custom({
    Expression<int>? id,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? inn,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (inn != null) 'inn': inn,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TradingPointEntitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? externalId,
    Value<String>? name,
    Value<String?>? inn,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return TradingPointEntitiesCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      inn: inn ?? this.inn,
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
  final DateTime createdAt;
  final DateTime updatedAt;
  const AppUserData({
    required this.employeeId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['employee_id'] = Variable<int>(employeeId);
    map['user_id'] = Variable<int>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      employeeId: Value(employeeId),
      userId: Value(userId),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppUserData copyWith({
    int? employeeId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AppUserData(
    employeeId: employeeId ?? this.employeeId,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppUserData copyWithCompanion(AppUsersCompanion data) {
    return AppUserData(
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserData(')
          ..write('employeeId: $employeeId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(employeeId, userId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserData &&
          other.employeeId == this.employeeId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUserData> {
  final Value<int> employeeId;
  final Value<int> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AppUsersCompanion({
    this.employeeId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.employeeId = const Value.absent(),
    required int userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<AppUserData> custom({
    Expression<int>? employeeId,
    Expression<int>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (employeeId != null) 'employee_id': employeeId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppUsersCompanion copyWith({
    Value<int>? employeeId,
    Value<int>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AppUsersCompanion(
      employeeId: employeeId ?? this.employeeId,
      userId: userId ?? this.userId,
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routesRefs) db.routes,
                    if (employeeTradingPointAssignmentsRefs)
                      db.employeeTradingPointAssignments,
                    if (appUsersRefs) db.appUsers,
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
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$TradingPointEntitiesTableUpdateCompanionBuilder =
    TradingPointEntitiesCompanion Function({
      Value<int> id,
      Value<String> externalId,
      Value<String> name,
      Value<String?> inn,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
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
          (
            TradingPointEntity,
            BaseReferences<
              _$AppDatabase,
              $TradingPointEntitiesTable,
              TradingPointEntity
            >,
          ),
          TradingPointEntity,
          PrefetchHooks Function()
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TradingPointEntitiesCompanion(
                id: id,
                externalId: externalId,
                name: name,
                inn: inn,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String externalId,
                required String name,
                Value<String?> inn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TradingPointEntitiesCompanion.insert(
                id: id,
                externalId: externalId,
                name: name,
                inn: inn,
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
      (
        TradingPointEntity,
        BaseReferences<
          _$AppDatabase,
          $TradingPointEntitiesTable,
          TradingPointEntity
        >,
      ),
      TradingPointEntity,
      PrefetchHooks Function()
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
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> employeeId,
      Value<int> userId,
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppUsersCompanion(
                employeeId: employeeId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> employeeId = const Value.absent(),
                required int userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppUsersCompanion.insert(
                employeeId: employeeId,
                userId: userId,
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
}
