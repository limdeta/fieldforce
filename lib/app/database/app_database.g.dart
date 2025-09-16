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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _externalIdMeta =
      const VerificationMeta('externalId');
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
      'external_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hashedPasswordMeta =
      const VerificationMeta('hashedPassword');
  @override
  late final GeneratedColumn<String> hashedPassword = GeneratedColumn<String>(
      'hashed_password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, externalId, role, phoneNumber, hashedPassword, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
          _externalIdMeta,
          externalId.isAcceptableOrUnknown(
              data['external_id']!, _externalIdMeta));
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('hashed_password')) {
      context.handle(
          _hashedPasswordMeta,
          hashedPassword.isAcceptableOrUnknown(
              data['hashed_password']!, _hashedPasswordMeta));
    } else if (isInserting) {
      context.missing(_hashedPasswordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      externalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      hashedPassword: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hashed_password'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  const UserData(
      {required this.id,
      required this.externalId,
      required this.role,
      required this.phoneNumber,
      required this.hashedPassword,
      required this.createdAt,
      required this.updatedAt});
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

  factory UserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  UserData copyWith(
          {int? id,
          String? externalId,
          String? role,
          String? phoneNumber,
          String? hashedPassword,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserData(
        id: id ?? this.id,
        externalId: externalId ?? this.externalId,
        role: role ?? this.role,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        hashedPassword: hashedPassword ?? this.hashedPassword,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
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
      id, externalId, role, phoneNumber, hashedPassword, createdAt, updatedAt);
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
  })  : externalId = Value(externalId),
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

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? externalId,
      Value<String>? role,
      Value<String>? phoneNumber,
      Value<String>? hashedPassword,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _middleNameMeta =
      const VerificationMeta('middleName');
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
      'middle_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, lastName, firstName, middleName, role, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(Insertable<EmployeeData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
          _middleNameMeta,
          middleName.isAcceptableOrUnknown(
              data['middle_name']!, _middleNameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmployeeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      middleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}middle_name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  const EmployeeData(
      {required this.id,
      required this.lastName,
      required this.firstName,
      this.middleName,
      required this.role,
      required this.createdAt,
      required this.updatedAt});
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

  factory EmployeeData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  EmployeeData copyWith(
          {int? id,
          String? lastName,
          String? firstName,
          Value<String?> middleName = const Value.absent(),
          String? role,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      EmployeeData(
        id: id ?? this.id,
        lastName: lastName ?? this.lastName,
        firstName: firstName ?? this.firstName,
        middleName: middleName.present ? middleName.value : this.middleName,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
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
      id, lastName, firstName, middleName, role, createdAt, updatedAt);
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
  })  : lastName = Value(lastName),
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

  EmployeesCompanion copyWith(
      {Value<int>? id,
      Value<String>? lastName,
      Value<String>? firstName,
      Value<String?>? middleName,
      Value<String>? role,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
      'employee_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES employees (id)'));
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
        employeeId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(Insertable<RouteData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(
              data['employee_id']!, _employeeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}employee_id']),
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
  const RouteData(
      {required this.id,
      required this.name,
      this.description,
      required this.createdAt,
      this.updatedAt,
      this.startTime,
      this.endTime,
      required this.status,
      this.employeeId});
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

  factory RouteData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  RouteData copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> startTime = const Value.absent(),
          Value<DateTime?> endTime = const Value.absent(),
          String? status,
          Value<int?> employeeId = const Value.absent()}) =>
      RouteData(
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
  int get hashCode => Object.hash(id, name, description, createdAt, updatedAt,
      startTime, endTime, status, employeeId);
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
  })  : name = Value(name),
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

  RoutesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? startTime,
      Value<DateTime?>? endTime,
      Value<String>? status,
      Value<int?>? employeeId}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _routeIdMeta =
      const VerificationMeta('routeId');
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
      'route_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routes (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _visitedAtMeta =
      const VerificationMeta('visitedAt');
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
      'visited_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
        type
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'points_of_interest';
  @override
  VerificationContext validateIntegrity(
      Insertable<PointOfInterestData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(_routeIdMeta,
          routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta));
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('visited_at')) {
      context.handle(_visitedAtMeta,
          visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}route_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      visitedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}visited_at']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
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
  const PointOfInterestData(
      {required this.id,
      required this.routeId,
      required this.name,
      this.description,
      required this.latitude,
      required this.longitude,
      required this.status,
      required this.createdAt,
      this.visitedAt,
      this.notes,
      required this.type});
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
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      type: Value(type),
    );
  }

  factory PointOfInterestData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  PointOfInterestData copyWith(
          {int? id,
          int? routeId,
          String? name,
          Value<String?> description = const Value.absent(),
          double? latitude,
          double? longitude,
          String? status,
          DateTime? createdAt,
          Value<DateTime?> visitedAt = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? type}) =>
      PointOfInterestData(
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
  int get hashCode => Object.hash(id, routeId, name, description, latitude,
      longitude, status, createdAt, visitedAt, notes, type);
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
  })  : routeId = Value(routeId),
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

  PointsOfInterestCompanion copyWith(
      {Value<int>? id,
      Value<int>? routeId,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime?>? visitedAt,
      Value<String?>? notes,
      Value<String>? type}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pointOfInterestIdMeta =
      const VerificationMeta('pointOfInterestId');
  @override
  late final GeneratedColumn<int> pointOfInterestId = GeneratedColumn<int>(
      'point_of_interest_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES points_of_interest (id)'));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactPersonMeta =
      const VerificationMeta('contactPerson');
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
      'contact_person', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _workingHoursMeta =
      const VerificationMeta('workingHours');
  @override
  late final GeneratedColumn<String> workingHours = GeneratedColumn<String>(
      'working_hours', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trading_points';
  @override
  VerificationContext validateIntegrity(Insertable<TradingPointData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('point_of_interest_id')) {
      context.handle(
          _pointOfInterestIdMeta,
          pointOfInterestId.isAcceptableOrUnknown(
              data['point_of_interest_id']!, _pointOfInterestIdMeta));
    } else if (isInserting) {
      context.missing(_pointOfInterestIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('contact_person')) {
      context.handle(
          _contactPersonMeta,
          contactPerson.isAcceptableOrUnknown(
              data['contact_person']!, _contactPersonMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('working_hours')) {
      context.handle(
          _workingHoursMeta,
          workingHours.isAcceptableOrUnknown(
              data['working_hours']!, _workingHoursMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradingPointData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradingPointData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pointOfInterestId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}point_of_interest_id'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      contactPerson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_person']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      workingHours: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}working_hours']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
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
  const TradingPointData(
      {required this.id,
      required this.pointOfInterestId,
      this.address,
      this.contactPerson,
      this.phone,
      this.email,
      this.workingHours,
      required this.isActive,
      required this.createdAt,
      this.updatedAt});
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
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
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

  factory TradingPointData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  TradingPointData copyWith(
          {int? id,
          int? pointOfInterestId,
          Value<String?> address = const Value.absent(),
          Value<String?> contactPerson = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> workingHours = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      TradingPointData(
        id: id ?? this.id,
        pointOfInterestId: pointOfInterestId ?? this.pointOfInterestId,
        address: address.present ? address.value : this.address,
        contactPerson:
            contactPerson.present ? contactPerson.value : this.contactPerson,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        workingHours:
            workingHours.present ? workingHours.value : this.workingHours,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
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
  int get hashCode => Object.hash(id, pointOfInterestId, address, contactPerson,
      phone, email, workingHours, isActive, createdAt, updatedAt);
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

  TradingPointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? pointOfInterestId,
      Value<String?>? address,
      Value<String?>? contactPerson,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? workingHours,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _externalIdMeta =
      const VerificationMeta('externalId');
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
      'external_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _innMeta = const VerificationMeta('inn');
  @override
  late final GeneratedColumn<String> inn = GeneratedColumn<String>(
      'inn', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, externalId, name, inn, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trading_point_entities';
  @override
  VerificationContext validateIntegrity(Insertable<TradingPointEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
          _externalIdMeta,
          externalId.isAcceptableOrUnknown(
              data['external_id']!, _externalIdMeta));
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('inn')) {
      context.handle(
          _innMeta, inn.isAcceptableOrUnknown(data['inn']!, _innMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradingPointEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradingPointEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      externalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      inn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}inn']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
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
  const TradingPointEntity(
      {required this.id,
      required this.externalId,
      required this.name,
      this.inn,
      required this.createdAt,
      this.updatedAt});
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

  factory TradingPointEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  TradingPointEntity copyWith(
          {int? id,
          String? externalId,
          String? name,
          Value<String?> inn = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      TradingPointEntity(
        id: id ?? this.id,
        externalId: externalId ?? this.externalId,
        name: name ?? this.name,
        inn: inn.present ? inn.value : this.inn,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
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
  })  : externalId = Value(externalId),
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

  TradingPointEntitiesCompanion copyWith(
      {Value<int>? id,
      Value<String>? externalId,
      Value<String>? name,
      Value<String?>? inn,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt}) {
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
        TableInfo<$EmployeeTradingPointAssignmentsTable,
            EmployeeTradingPointAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeeTradingPointAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
      'employee_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES employees (id)'));
  static const VerificationMeta _tradingPointExternalIdMeta =
      const VerificationMeta('tradingPointExternalId');
  @override
  late final GeneratedColumn<String> tradingPointExternalId =
      GeneratedColumn<String>('trading_point_external_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedAtMeta =
      const VerificationMeta('assignedAt');
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
      'assigned_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [employeeId, tradingPointExternalId, assignedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employee_trading_point_assignments';
  @override
  VerificationContext validateIntegrity(
      Insertable<EmployeeTradingPointAssignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(
              data['employee_id']!, _employeeIdMeta));
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('trading_point_external_id')) {
      context.handle(
          _tradingPointExternalIdMeta,
          tradingPointExternalId.isAcceptableOrUnknown(
              data['trading_point_external_id']!, _tradingPointExternalIdMeta));
    } else if (isInserting) {
      context.missing(_tradingPointExternalIdMeta);
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
          _assignedAtMeta,
          assignedAt.isAcceptableOrUnknown(
              data['assigned_at']!, _assignedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {employeeId, tradingPointExternalId};
  @override
  EmployeeTradingPointAssignment map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeTradingPointAssignment(
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}employee_id'])!,
      tradingPointExternalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trading_point_external_id'])!,
      assignedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}assigned_at'])!,
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
  const EmployeeTradingPointAssignment(
      {required this.employeeId,
      required this.tradingPointExternalId,
      required this.assignedAt});
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

  factory EmployeeTradingPointAssignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeTradingPointAssignment(
      employeeId: serializer.fromJson<int>(json['employeeId']),
      tradingPointExternalId:
          serializer.fromJson<String>(json['tradingPointExternalId']),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'employeeId': serializer.toJson<int>(employeeId),
      'tradingPointExternalId':
          serializer.toJson<String>(tradingPointExternalId),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
    };
  }

  EmployeeTradingPointAssignment copyWith(
          {int? employeeId,
          String? tradingPointExternalId,
          DateTime? assignedAt}) =>
      EmployeeTradingPointAssignment(
        employeeId: employeeId ?? this.employeeId,
        tradingPointExternalId:
            tradingPointExternalId ?? this.tradingPointExternalId,
        assignedAt: assignedAt ?? this.assignedAt,
      );
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
  })  : employeeId = Value(employeeId),
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

  EmployeeTradingPointAssignmentsCompanion copyWith(
      {Value<int>? employeeId,
      Value<String>? tradingPointExternalId,
      Value<DateTime>? assignedAt,
      Value<int>? rowid}) {
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
      map['trading_point_external_id'] =
          Variable<String>(tradingPointExternalId.value);
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _routeIdMeta =
      const VerificationMeta('routeId');
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
      'route_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routes (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _totalPointsMeta =
      const VerificationMeta('totalPoints');
  @override
  late final GeneratedColumn<int> totalPoints = GeneratedColumn<int>(
      'total_points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalDistanceKmMeta =
      const VerificationMeta('totalDistanceKm');
  @override
  late final GeneratedColumn<double> totalDistanceKm = GeneratedColumn<double>(
      'total_distance_km', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalDurationSecondsMeta =
      const VerificationMeta('totalDurationSeconds');
  @override
  late final GeneratedColumn<int> totalDurationSeconds = GeneratedColumn<int>(
      'total_duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_tracks';
  @override
  VerificationContext validateIntegrity(Insertable<UserTrackData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(_routeIdMeta,
          routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_points')) {
      context.handle(
          _totalPointsMeta,
          totalPoints.isAcceptableOrUnknown(
              data['total_points']!, _totalPointsMeta));
    }
    if (data.containsKey('total_distance_km')) {
      context.handle(
          _totalDistanceKmMeta,
          totalDistanceKm.isAcceptableOrUnknown(
              data['total_distance_km']!, _totalDistanceKmMeta));
    }
    if (data.containsKey('total_duration_seconds')) {
      context.handle(
          _totalDurationSecondsMeta,
          totalDurationSeconds.isAcceptableOrUnknown(
              data['total_duration_seconds']!, _totalDurationSecondsMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTrackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTrackData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      routeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}route_id']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_points'])!,
      totalDistanceKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_distance_km'])!,
      totalDurationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_duration_seconds'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  const UserTrackData(
      {required this.id,
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
      required this.updatedAt});
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

  factory UserTrackData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
      totalDurationSeconds:
          serializer.fromJson<int>(json['totalDurationSeconds']),
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

  UserTrackData copyWith(
          {int? id,
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
          DateTime? updatedAt}) =>
      UserTrackData(
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
      updatedAt);
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
  })  : userId = Value(userId),
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

  UserTracksCompanion copyWith(
      {Value<int>? id,
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
      Value<DateTime>? updatedAt}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userTrackIdMeta =
      const VerificationMeta('userTrackId');
  @override
  late final GeneratedColumn<int> userTrackId = GeneratedColumn<int>(
      'user_track_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_tracks (id) ON DELETE CASCADE'));
  static const VerificationMeta _segmentOrderMeta =
      const VerificationMeta('segmentOrder');
  @override
  late final GeneratedColumn<int> segmentOrder = GeneratedColumn<int>(
      'segment_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _coordinatesBlobMeta =
      const VerificationMeta('coordinatesBlob');
  @override
  late final GeneratedColumn<Uint8List> coordinatesBlob =
      GeneratedColumn<Uint8List>('coordinates_blob', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _timestampsBlobMeta =
      const VerificationMeta('timestampsBlob');
  @override
  late final GeneratedColumn<Uint8List> timestampsBlob =
      GeneratedColumn<Uint8List>('timestamps_blob', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _speedsBlobMeta =
      const VerificationMeta('speedsBlob');
  @override
  late final GeneratedColumn<Uint8List> speedsBlob = GeneratedColumn<Uint8List>(
      'speeds_blob', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _accuraciesBlobMeta =
      const VerificationMeta('accuraciesBlob');
  @override
  late final GeneratedColumn<Uint8List> accuraciesBlob =
      GeneratedColumn<Uint8List>('accuracies_blob', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _bearingsBlobMeta =
      const VerificationMeta('bearingsBlob');
  @override
  late final GeneratedColumn<Uint8List> bearingsBlob =
      GeneratedColumn<Uint8List>('bearings_blob', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compact_tracks';
  @override
  VerificationContext validateIntegrity(Insertable<CompactTrackData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_track_id')) {
      context.handle(
          _userTrackIdMeta,
          userTrackId.isAcceptableOrUnknown(
              data['user_track_id']!, _userTrackIdMeta));
    } else if (isInserting) {
      context.missing(_userTrackIdMeta);
    }
    if (data.containsKey('segment_order')) {
      context.handle(
          _segmentOrderMeta,
          segmentOrder.isAcceptableOrUnknown(
              data['segment_order']!, _segmentOrderMeta));
    } else if (isInserting) {
      context.missing(_segmentOrderMeta);
    }
    if (data.containsKey('coordinates_blob')) {
      context.handle(
          _coordinatesBlobMeta,
          coordinatesBlob.isAcceptableOrUnknown(
              data['coordinates_blob']!, _coordinatesBlobMeta));
    } else if (isInserting) {
      context.missing(_coordinatesBlobMeta);
    }
    if (data.containsKey('timestamps_blob')) {
      context.handle(
          _timestampsBlobMeta,
          timestampsBlob.isAcceptableOrUnknown(
              data['timestamps_blob']!, _timestampsBlobMeta));
    } else if (isInserting) {
      context.missing(_timestampsBlobMeta);
    }
    if (data.containsKey('speeds_blob')) {
      context.handle(
          _speedsBlobMeta,
          speedsBlob.isAcceptableOrUnknown(
              data['speeds_blob']!, _speedsBlobMeta));
    } else if (isInserting) {
      context.missing(_speedsBlobMeta);
    }
    if (data.containsKey('accuracies_blob')) {
      context.handle(
          _accuraciesBlobMeta,
          accuraciesBlob.isAcceptableOrUnknown(
              data['accuracies_blob']!, _accuraciesBlobMeta));
    } else if (isInserting) {
      context.missing(_accuraciesBlobMeta);
    }
    if (data.containsKey('bearings_blob')) {
      context.handle(
          _bearingsBlobMeta,
          bearingsBlob.isAcceptableOrUnknown(
              data['bearings_blob']!, _bearingsBlobMeta));
    } else if (isInserting) {
      context.missing(_bearingsBlobMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompactTrackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompactTrackData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userTrackId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_track_id'])!,
      segmentOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}segment_order'])!,
      coordinatesBlob: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}coordinates_blob'])!,
      timestampsBlob: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}timestamps_blob'])!,
      speedsBlob: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}speeds_blob'])!,
      accuraciesBlob: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}accuracies_blob'])!,
      bearingsBlob: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}bearings_blob'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  const CompactTrackData(
      {required this.id,
      required this.userTrackId,
      required this.segmentOrder,
      required this.coordinatesBlob,
      required this.timestampsBlob,
      required this.speedsBlob,
      required this.accuraciesBlob,
      required this.bearingsBlob,
      required this.createdAt});
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

  factory CompactTrackData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  CompactTrackData copyWith(
          {int? id,
          int? userTrackId,
          int? segmentOrder,
          Uint8List? coordinatesBlob,
          Uint8List? timestampsBlob,
          Uint8List? speedsBlob,
          Uint8List? accuraciesBlob,
          Uint8List? bearingsBlob,
          DateTime? createdAt}) =>
      CompactTrackData(
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
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompactTrackData &&
          other.id == this.id &&
          other.userTrackId == this.userTrackId &&
          other.segmentOrder == this.segmentOrder &&
          $driftBlobEquality.equals(
              other.coordinatesBlob, this.coordinatesBlob) &&
          $driftBlobEquality.equals(
              other.timestampsBlob, this.timestampsBlob) &&
          $driftBlobEquality.equals(other.speedsBlob, this.speedsBlob) &&
          $driftBlobEquality.equals(
              other.accuraciesBlob, this.accuraciesBlob) &&
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
  })  : userTrackId = Value(userTrackId),
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

  CompactTracksCompanion copyWith(
      {Value<int>? id,
      Value<int>? userTrackId,
      Value<int>? segmentOrder,
      Value<Uint8List>? coordinatesBlob,
      Value<Uint8List>? timestampsBlob,
      Value<Uint8List>? speedsBlob,
      Value<Uint8List>? accuraciesBlob,
      Value<Uint8List>? bearingsBlob,
      Value<DateTime>? createdAt}) {
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
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
      'employee_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES employees (id)'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [employeeId, userId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(Insertable<AppUserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(
              data['employee_id']!, _employeeIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {employeeId};
  @override
  AppUserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserData(
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}employee_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  const AppUserData(
      {required this.employeeId,
      required this.userId,
      required this.createdAt,
      required this.updatedAt});
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

  factory AppUserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  AppUserData copyWith(
          {int? employeeId,
          int? userId,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AppUserData(
        employeeId: employeeId ?? this.employeeId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
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

  AppUsersCompanion copyWith(
      {Value<int>? employeeId,
      Value<int>? userId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
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

class $WorkDaysTable extends WorkDays
    with TableInfo<$WorkDaysTable, WorkDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<int> user = GeneratedColumn<int>(
      'user', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _routeIdMeta =
      const VerificationMeta('routeId');
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
      'route_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
      'track_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('planned'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_days';
  @override
  VerificationContext validateIntegrity(Insertable<WorkDayData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user')) {
      context.handle(
          _userMeta, user.isAcceptableOrUnknown(data['user']!, _userMeta));
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(_routeIdMeta,
          routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      user: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      routeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}route_id']),
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  const WorkDayData(
      {required this.id,
      required this.user,
      required this.date,
      this.routeId,
      this.trackId,
      required this.status,
      this.startTime,
      this.endTime,
      this.metadata,
      required this.createdAt,
      required this.updatedAt});
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

  factory WorkDayData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  WorkDayData copyWith(
          {int? id,
          int? user,
          DateTime? date,
          Value<int?> routeId = const Value.absent(),
          Value<int?> trackId = const Value.absent(),
          String? status,
          Value<DateTime?> startTime = const Value.absent(),
          Value<DateTime?> endTime = const Value.absent(),
          Value<String?> metadata = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      WorkDayData(
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
  int get hashCode => Object.hash(id, user, date, routeId, trackId, status,
      startTime, endTime, metadata, createdAt, updatedAt);
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
  })  : user = Value(user),
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

  WorkDaysCompanion copyWith(
      {Value<int>? id,
      Value<int>? user,
      Value<DateTime>? date,
      Value<int?>? routeId,
      Value<int?>? trackId,
      Value<String>? status,
      Value<DateTime?>? startTime,
      Value<DateTime?>? endTime,
      Value<String?>? metadata,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lftMeta = const VerificationMeta('lft');
  @override
  late final GeneratedColumn<int> lft = GeneratedColumn<int>(
      'lft', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lvlMeta = const VerificationMeta('lvl');
  @override
  late final GeneratedColumn<int> lvl = GeneratedColumn<int>(
      'lvl', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rgtMeta = const VerificationMeta('rgt');
  @override
  late final GeneratedColumn<int> rgt = GeneratedColumn<int>(
      'rgt', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
      'query', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('lft')) {
      context.handle(
          _lftMeta, lft.isAcceptableOrUnknown(data['lft']!, _lftMeta));
    } else if (isInserting) {
      context.missing(_lftMeta);
    }
    if (data.containsKey('lvl')) {
      context.handle(
          _lvlMeta, lvl.isAcceptableOrUnknown(data['lvl']!, _lvlMeta));
    } else if (isInserting) {
      context.missing(_lvlMeta);
    }
    if (data.containsKey('rgt')) {
      context.handle(
          _rgtMeta, rgt.isAcceptableOrUnknown(data['rgt']!, _rgtMeta));
    } else if (isInserting) {
      context.missing(_rgtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
          _queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      lft: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lft'])!,
      lvl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lvl'])!,
      rgt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rgt'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      query: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query']),
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  const CategoryData(
      {required this.id,
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
      required this.updatedAt});
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
      query:
          query == null && nullToAbsent ? const Value.absent() : Value(query),
      count: Value(count),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      rawJson: Value(rawJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  CategoryData copyWith(
          {int? id,
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
          DateTime? updatedAt}) =>
      CategoryData(
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
  int get hashCode => Object.hash(id, name, categoryId, lft, lvl, rgt,
      description, query, count, parentId, rawJson, createdAt, updatedAt);
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
  })  : name = Value(name),
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

  CategoriesCompanion copyWith(
      {Value<int>? id,
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
      Value<DateTime>? updatedAt}) {
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _catalogIdMeta =
      const VerificationMeta('catalogId');
  @override
  late final GeneratedColumn<int> catalogId = GeneratedColumn<int>(
      'catalog_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<int> code = GeneratedColumn<int>(
      'code', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bcodeMeta = const VerificationMeta('bcode');
  @override
  late final GeneratedColumn<int> bcode = GeneratedColumn<int>(
      'bcode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vendorCodeMeta =
      const VerificationMeta('vendorCode');
  @override
  late final GeneratedColumn<String> vendorCode = GeneratedColumn<String>(
      'vendor_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountInPackageMeta =
      const VerificationMeta('amountInPackage');
  @override
  late final GeneratedColumn<int> amountInPackage = GeneratedColumn<int>(
      'amount_in_package', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noveltyMeta =
      const VerificationMeta('novelty');
  @override
  late final GeneratedColumn<bool> novelty = GeneratedColumn<bool>(
      'novelty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("novelty" IN (0, 1))'));
  static const VerificationMeta _popularMeta =
      const VerificationMeta('popular');
  @override
  late final GeneratedColumn<bool> popular = GeneratedColumn<bool>(
      'popular', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("popular" IN (0, 1))'));
  static const VerificationMeta _isMarkedMeta =
      const VerificationMeta('isMarked');
  @override
  late final GeneratedColumn<bool> isMarked = GeneratedColumn<bool>(
      'is_marked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_marked" IN (0, 1))'));
  static const VerificationMeta _canBuyMeta = const VerificationMeta('canBuy');
  @override
  late final GeneratedColumn<bool> canBuy = GeneratedColumn<bool>(
      'can_buy', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("can_buy" IN (0, 1))'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
      'type_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
        rawJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('catalog_id')) {
      context.handle(_catalogIdMeta,
          catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta));
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('bcode')) {
      context.handle(
          _bcodeMeta, bcode.isAcceptableOrUnknown(data['bcode']!, _bcodeMeta));
    } else if (isInserting) {
      context.missing(_bcodeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('vendor_code')) {
      context.handle(
          _vendorCodeMeta,
          vendorCode.isAcceptableOrUnknown(
              data['vendor_code']!, _vendorCodeMeta));
    }
    if (data.containsKey('amount_in_package')) {
      context.handle(
          _amountInPackageMeta,
          amountInPackage.isAcceptableOrUnknown(
              data['amount_in_package']!, _amountInPackageMeta));
    }
    if (data.containsKey('novelty')) {
      context.handle(_noveltyMeta,
          novelty.isAcceptableOrUnknown(data['novelty']!, _noveltyMeta));
    } else if (isInserting) {
      context.missing(_noveltyMeta);
    }
    if (data.containsKey('popular')) {
      context.handle(_popularMeta,
          popular.isAcceptableOrUnknown(data['popular']!, _popularMeta));
    } else if (isInserting) {
      context.missing(_popularMeta);
    }
    if (data.containsKey('is_marked')) {
      context.handle(_isMarkedMeta,
          isMarked.isAcceptableOrUnknown(data['is_marked']!, _isMarkedMeta));
    } else if (isInserting) {
      context.missing(_isMarkedMeta);
    }
    if (data.containsKey('can_buy')) {
      context.handle(_canBuyMeta,
          canBuy.isAcceptableOrUnknown(data['can_buy']!, _canBuyMeta));
    } else if (isInserting) {
      context.missing(_canBuyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('type_id')) {
      context.handle(_typeIdMeta,
          typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta));
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      catalogId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}catalog_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}code'])!,
      bcode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bcode'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      vendorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_code']),
      amountInPackage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_in_package']),
      novelty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}novelty'])!,
      popular: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}popular'])!,
      isMarked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_marked'])!,
      canBuy: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_buy'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      typeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type_id']),
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  final String rawJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProductData(
      {required this.id,
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
      required this.rawJson,
      required this.createdAt,
      required this.updatedAt});
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
      typeId:
          typeId == null && nullToAbsent ? const Value.absent() : Value(typeId),
      rawJson: Value(rawJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
      'rawJson': serializer.toJson<String>(rawJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductData copyWith(
          {int? id,
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
          String? rawJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProductData(
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
        rawJson: rawJson ?? this.rawJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
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
          ..write('rawJson: $rawJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      rawJson,
      createdAt,
      updatedAt);
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
    required String rawJson,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : catalogId = Value(catalogId),
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
      if (rawJson != null) 'raw_json': rawJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
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
      Value<String>? rawJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
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
          ..write('rawJson: $rawJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $UsersTable users = $UsersTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $PointsOfInterestTable pointsOfInterest =
      $PointsOfInterestTable(this);
  late final $TradingPointsTable tradingPoints = $TradingPointsTable(this);
  late final $TradingPointEntitiesTable tradingPointEntities =
      $TradingPointEntitiesTable(this);
  late final $EmployeeTradingPointAssignmentsTable
      employeeTradingPointAssignments =
      $EmployeeTradingPointAssignmentsTable(this);
  late final $UserTracksTable userTracks = $UserTracksTable(this);
  late final $CompactTracksTable compactTracks = $CompactTracksTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $WorkDaysTable workDays = $WorkDaysTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
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
        products
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('user_tracks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('compact_tracks', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}
