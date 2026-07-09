// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CreditCardsTable extends CreditCards
    with TableInfo<$CreditCardsTable, CreditCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bankMeta = const VerificationMeta('bank');
  @override
  late final GeneratedColumn<String> bank = GeneratedColumn<String>(
    'bank',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFourDigitsMeta = const VerificationMeta(
    'lastFourDigits',
  );
  @override
  late final GeneratedColumn<String> lastFourDigits = GeneratedColumn<String>(
    'last_four_digits',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _networkMeta = const VerificationMeta(
    'network',
  );
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
    'network',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitPaiseMeta = const VerificationMeta(
    'creditLimitPaise',
  );
  @override
  late final GeneratedColumn<int> creditLimitPaise = GeneratedColumn<int>(
    'credit_limit_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billDayOfMonthMeta = const VerificationMeta(
    'billDayOfMonth',
  );
  @override
  late final GeneratedColumn<int> billDayOfMonth = GeneratedColumn<int>(
    'bill_day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateOffsetDaysMeta = const VerificationMeta(
    'dueDateOffsetDays',
  );
  @override
  late final GeneratedColumn<int> dueDateOffsetDays = GeneratedColumn<int>(
    'due_date_offset_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bank,
    lastFourDigits,
    nickname,
    network,
    creditLimitPaise,
    billDayOfMonth,
    dueDateOffsetDays,
    colorValue,
    iconName,
    notes,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank')) {
      context.handle(
        _bankMeta,
        bank.isAcceptableOrUnknown(data['bank']!, _bankMeta),
      );
    } else if (isInserting) {
      context.missing(_bankMeta);
    }
    if (data.containsKey('last_four_digits')) {
      context.handle(
        _lastFourDigitsMeta,
        lastFourDigits.isAcceptableOrUnknown(
          data['last_four_digits']!,
          _lastFourDigitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastFourDigitsMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('network')) {
      context.handle(
        _networkMeta,
        network.isAcceptableOrUnknown(data['network']!, _networkMeta),
      );
    }
    if (data.containsKey('credit_limit_paise')) {
      context.handle(
        _creditLimitPaiseMeta,
        creditLimitPaise.isAcceptableOrUnknown(
          data['credit_limit_paise']!,
          _creditLimitPaiseMeta,
        ),
      );
    }
    if (data.containsKey('bill_day_of_month')) {
      context.handle(
        _billDayOfMonthMeta,
        billDayOfMonth.isAcceptableOrUnknown(
          data['bill_day_of_month']!,
          _billDayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('due_date_offset_days')) {
      context.handle(
        _dueDateOffsetDaysMeta,
        dueDateOffsetDays.isAcceptableOrUnknown(
          data['due_date_offset_days']!,
          _dueDateOffsetDaysMeta,
        ),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank'],
      )!,
      lastFourDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_four_digits'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      network: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network'],
      ),
      creditLimitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_paise'],
      ),
      billDayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_day_of_month'],
      ),
      dueDateOffsetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date_offset_days'],
      ),
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CreditCardsTable createAlias(String alias) {
    return $CreditCardsTable(attachedDatabase, alias);
  }
}

class CreditCard extends DataClass implements Insertable<CreditCard> {
  final int id;
  final String bank;
  final String lastFourDigits;
  final String nickname;
  final String? network;
  final int? creditLimitPaise;
  final int? billDayOfMonth;
  final int? dueDateOffsetDays;
  final int colorValue;
  final String iconName;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  const CreditCard({
    required this.id,
    required this.bank,
    required this.lastFourDigits,
    required this.nickname,
    this.network,
    this.creditLimitPaise,
    this.billDayOfMonth,
    this.dueDateOffsetDays,
    required this.colorValue,
    required this.iconName,
    this.notes,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank'] = Variable<String>(bank);
    map['last_four_digits'] = Variable<String>(lastFourDigits);
    map['nickname'] = Variable<String>(nickname);
    if (!nullToAbsent || network != null) {
      map['network'] = Variable<String>(network);
    }
    if (!nullToAbsent || creditLimitPaise != null) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise);
    }
    if (!nullToAbsent || billDayOfMonth != null) {
      map['bill_day_of_month'] = Variable<int>(billDayOfMonth);
    }
    if (!nullToAbsent || dueDateOffsetDays != null) {
      map['due_date_offset_days'] = Variable<int>(dueDateOffsetDays);
    }
    map['color_value'] = Variable<int>(colorValue);
    map['icon_name'] = Variable<String>(iconName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CreditCardsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardsCompanion(
      id: Value(id),
      bank: Value(bank),
      lastFourDigits: Value(lastFourDigits),
      nickname: Value(nickname),
      network: network == null && nullToAbsent
          ? const Value.absent()
          : Value(network),
      creditLimitPaise: creditLimitPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimitPaise),
      billDayOfMonth: billDayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(billDayOfMonth),
      dueDateOffsetDays: dueDateOffsetDays == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDateOffsetDays),
      colorValue: Value(colorValue),
      iconName: Value(iconName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory CreditCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditCard(
      id: serializer.fromJson<int>(json['id']),
      bank: serializer.fromJson<String>(json['bank']),
      lastFourDigits: serializer.fromJson<String>(json['lastFourDigits']),
      nickname: serializer.fromJson<String>(json['nickname']),
      network: serializer.fromJson<String?>(json['network']),
      creditLimitPaise: serializer.fromJson<int?>(json['creditLimitPaise']),
      billDayOfMonth: serializer.fromJson<int?>(json['billDayOfMonth']),
      dueDateOffsetDays: serializer.fromJson<int?>(json['dueDateOffsetDays']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconName: serializer.fromJson<String>(json['iconName']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bank': serializer.toJson<String>(bank),
      'lastFourDigits': serializer.toJson<String>(lastFourDigits),
      'nickname': serializer.toJson<String>(nickname),
      'network': serializer.toJson<String?>(network),
      'creditLimitPaise': serializer.toJson<int?>(creditLimitPaise),
      'billDayOfMonth': serializer.toJson<int?>(billDayOfMonth),
      'dueDateOffsetDays': serializer.toJson<int?>(dueDateOffsetDays),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconName': serializer.toJson<String>(iconName),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CreditCard copyWith({
    int? id,
    String? bank,
    String? lastFourDigits,
    String? nickname,
    Value<String?> network = const Value.absent(),
    Value<int?> creditLimitPaise = const Value.absent(),
    Value<int?> billDayOfMonth = const Value.absent(),
    Value<int?> dueDateOffsetDays = const Value.absent(),
    int? colorValue,
    String? iconName,
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
  }) => CreditCard(
    id: id ?? this.id,
    bank: bank ?? this.bank,
    lastFourDigits: lastFourDigits ?? this.lastFourDigits,
    nickname: nickname ?? this.nickname,
    network: network.present ? network.value : this.network,
    creditLimitPaise: creditLimitPaise.present
        ? creditLimitPaise.value
        : this.creditLimitPaise,
    billDayOfMonth: billDayOfMonth.present
        ? billDayOfMonth.value
        : this.billDayOfMonth,
    dueDateOffsetDays: dueDateOffsetDays.present
        ? dueDateOffsetDays.value
        : this.dueDateOffsetDays,
    colorValue: colorValue ?? this.colorValue,
    iconName: iconName ?? this.iconName,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  CreditCard copyWithCompanion(CreditCardsCompanion data) {
    return CreditCard(
      id: data.id.present ? data.id.value : this.id,
      bank: data.bank.present ? data.bank.value : this.bank,
      lastFourDigits: data.lastFourDigits.present
          ? data.lastFourDigits.value
          : this.lastFourDigits,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      network: data.network.present ? data.network.value : this.network,
      creditLimitPaise: data.creditLimitPaise.present
          ? data.creditLimitPaise.value
          : this.creditLimitPaise,
      billDayOfMonth: data.billDayOfMonth.present
          ? data.billDayOfMonth.value
          : this.billDayOfMonth,
      dueDateOffsetDays: data.dueDateOffsetDays.present
          ? data.dueDateOffsetDays.value
          : this.dueDateOffsetDays,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditCard(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('nickname: $nickname, ')
          ..write('network: $network, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('billDayOfMonth: $billDayOfMonth, ')
          ..write('dueDateOffsetDays: $dueDateOffsetDays, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconName: $iconName, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bank,
    lastFourDigits,
    nickname,
    network,
    creditLimitPaise,
    billDayOfMonth,
    dueDateOffsetDays,
    colorValue,
    iconName,
    notes,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditCard &&
          other.id == this.id &&
          other.bank == this.bank &&
          other.lastFourDigits == this.lastFourDigits &&
          other.nickname == this.nickname &&
          other.network == this.network &&
          other.creditLimitPaise == this.creditLimitPaise &&
          other.billDayOfMonth == this.billDayOfMonth &&
          other.dueDateOffsetDays == this.dueDateOffsetDays &&
          other.colorValue == this.colorValue &&
          other.iconName == this.iconName &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class CreditCardsCompanion extends UpdateCompanion<CreditCard> {
  final Value<int> id;
  final Value<String> bank;
  final Value<String> lastFourDigits;
  final Value<String> nickname;
  final Value<String?> network;
  final Value<int?> creditLimitPaise;
  final Value<int?> billDayOfMonth;
  final Value<int?> dueDateOffsetDays;
  final Value<int> colorValue;
  final Value<String> iconName;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const CreditCardsCompanion({
    this.id = const Value.absent(),
    this.bank = const Value.absent(),
    this.lastFourDigits = const Value.absent(),
    this.nickname = const Value.absent(),
    this.network = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.billDayOfMonth = const Value.absent(),
    this.dueDateOffsetDays = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconName = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CreditCardsCompanion.insert({
    this.id = const Value.absent(),
    required String bank,
    required String lastFourDigits,
    required String nickname,
    this.network = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.billDayOfMonth = const Value.absent(),
    this.dueDateOffsetDays = const Value.absent(),
    required int colorValue,
    required String iconName,
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
  }) : bank = Value(bank),
       lastFourDigits = Value(lastFourDigits),
       nickname = Value(nickname),
       colorValue = Value(colorValue),
       iconName = Value(iconName),
       createdAt = Value(createdAt);
  static Insertable<CreditCard> custom({
    Expression<int>? id,
    Expression<String>? bank,
    Expression<String>? lastFourDigits,
    Expression<String>? nickname,
    Expression<String>? network,
    Expression<int>? creditLimitPaise,
    Expression<int>? billDayOfMonth,
    Expression<int>? dueDateOffsetDays,
    Expression<int>? colorValue,
    Expression<String>? iconName,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bank != null) 'bank': bank,
      if (lastFourDigits != null) 'last_four_digits': lastFourDigits,
      if (nickname != null) 'nickname': nickname,
      if (network != null) 'network': network,
      if (creditLimitPaise != null) 'credit_limit_paise': creditLimitPaise,
      if (billDayOfMonth != null) 'bill_day_of_month': billDayOfMonth,
      if (dueDateOffsetDays != null) 'due_date_offset_days': dueDateOffsetDays,
      if (colorValue != null) 'color_value': colorValue,
      if (iconName != null) 'icon_name': iconName,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CreditCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? bank,
    Value<String>? lastFourDigits,
    Value<String>? nickname,
    Value<String?>? network,
    Value<int?>? creditLimitPaise,
    Value<int?>? billDayOfMonth,
    Value<int?>? dueDateOffsetDays,
    Value<int>? colorValue,
    Value<String>? iconName,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
  }) {
    return CreditCardsCompanion(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      nickname: nickname ?? this.nickname,
      network: network ?? this.network,
      creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
      billDayOfMonth: billDayOfMonth ?? this.billDayOfMonth,
      dueDateOffsetDays: dueDateOffsetDays ?? this.dueDateOffsetDays,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bank.present) {
      map['bank'] = Variable<String>(bank.value);
    }
    if (lastFourDigits.present) {
      map['last_four_digits'] = Variable<String>(lastFourDigits.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (creditLimitPaise.present) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise.value);
    }
    if (billDayOfMonth.present) {
      map['bill_day_of_month'] = Variable<int>(billDayOfMonth.value);
    }
    if (dueDateOffsetDays.present) {
      map['due_date_offset_days'] = Variable<int>(dueDateOffsetDays.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardsCompanion(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('nickname: $nickname, ')
          ..write('network: $network, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('billDayOfMonth: $billDayOfMonth, ')
          ..write('dueDateOffsetDays: $dueDateOffsetDays, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconName: $iconName, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BillingCyclesTable extends BillingCycles
    with TableInfo<$BillingCyclesTable, BillingCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillingCyclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _creditCardIdMeta = const VerificationMeta(
    'creditCardId',
  );
  @override
  late final GeneratedColumn<int> creditCardId = GeneratedColumn<int>(
    'credit_card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billGeneratedMeta = const VerificationMeta(
    'billGenerated',
  );
  @override
  late final GeneratedColumn<bool> billGenerated = GeneratedColumn<bool>(
    'bill_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bill_generated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentsAppliedPaiseMeta =
      const VerificationMeta('paymentsAppliedPaise');
  @override
  late final GeneratedColumn<int> paymentsAppliedPaise = GeneratedColumn<int>(
    'payments_applied_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    creditCardId,
    startDate,
    endDate,
    billGenerated,
    dueDate,
    paymentsAppliedPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'billing_cycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillingCycle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('credit_card_id')) {
      context.handle(
        _creditCardIdMeta,
        creditCardId.isAcceptableOrUnknown(
          data['credit_card_id']!,
          _creditCardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditCardIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('bill_generated')) {
      context.handle(
        _billGeneratedMeta,
        billGenerated.isAcceptableOrUnknown(
          data['bill_generated']!,
          _billGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('payments_applied_paise')) {
      context.handle(
        _paymentsAppliedPaiseMeta,
        paymentsAppliedPaise.isAcceptableOrUnknown(
          data['payments_applied_paise']!,
          _paymentsAppliedPaiseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillingCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillingCycle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      creditCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_card_id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      billGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bill_generated'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      paymentsAppliedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payments_applied_paise'],
      )!,
    );
  }

  @override
  $BillingCyclesTable createAlias(String alias) {
    return $BillingCyclesTable(attachedDatabase, alias);
  }
}

class BillingCycle extends DataClass implements Insertable<BillingCycle> {
  final int id;
  final int creditCardId;
  final DateTime startDate;
  final DateTime endDate;
  final bool billGenerated;
  final DateTime? dueDate;
  final int paymentsAppliedPaise;
  const BillingCycle({
    required this.id,
    required this.creditCardId,
    required this.startDate,
    required this.endDate,
    required this.billGenerated,
    this.dueDate,
    required this.paymentsAppliedPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['credit_card_id'] = Variable<int>(creditCardId);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['bill_generated'] = Variable<bool>(billGenerated);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['payments_applied_paise'] = Variable<int>(paymentsAppliedPaise);
    return map;
  }

  BillingCyclesCompanion toCompanion(bool nullToAbsent) {
    return BillingCyclesCompanion(
      id: Value(id),
      creditCardId: Value(creditCardId),
      startDate: Value(startDate),
      endDate: Value(endDate),
      billGenerated: Value(billGenerated),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      paymentsAppliedPaise: Value(paymentsAppliedPaise),
    );
  }

  factory BillingCycle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillingCycle(
      id: serializer.fromJson<int>(json['id']),
      creditCardId: serializer.fromJson<int>(json['creditCardId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      billGenerated: serializer.fromJson<bool>(json['billGenerated']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      paymentsAppliedPaise: serializer.fromJson<int>(
        json['paymentsAppliedPaise'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'creditCardId': serializer.toJson<int>(creditCardId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'billGenerated': serializer.toJson<bool>(billGenerated),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'paymentsAppliedPaise': serializer.toJson<int>(paymentsAppliedPaise),
    };
  }

  BillingCycle copyWith({
    int? id,
    int? creditCardId,
    DateTime? startDate,
    DateTime? endDate,
    bool? billGenerated,
    Value<DateTime?> dueDate = const Value.absent(),
    int? paymentsAppliedPaise,
  }) => BillingCycle(
    id: id ?? this.id,
    creditCardId: creditCardId ?? this.creditCardId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    billGenerated: billGenerated ?? this.billGenerated,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    paymentsAppliedPaise: paymentsAppliedPaise ?? this.paymentsAppliedPaise,
  );
  BillingCycle copyWithCompanion(BillingCyclesCompanion data) {
    return BillingCycle(
      id: data.id.present ? data.id.value : this.id,
      creditCardId: data.creditCardId.present
          ? data.creditCardId.value
          : this.creditCardId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      billGenerated: data.billGenerated.present
          ? data.billGenerated.value
          : this.billGenerated,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paymentsAppliedPaise: data.paymentsAppliedPaise.present
          ? data.paymentsAppliedPaise.value
          : this.paymentsAppliedPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillingCycle(')
          ..write('id: $id, ')
          ..write('creditCardId: $creditCardId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('billGenerated: $billGenerated, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentsAppliedPaise: $paymentsAppliedPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    creditCardId,
    startDate,
    endDate,
    billGenerated,
    dueDate,
    paymentsAppliedPaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillingCycle &&
          other.id == this.id &&
          other.creditCardId == this.creditCardId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.billGenerated == this.billGenerated &&
          other.dueDate == this.dueDate &&
          other.paymentsAppliedPaise == this.paymentsAppliedPaise);
}

class BillingCyclesCompanion extends UpdateCompanion<BillingCycle> {
  final Value<int> id;
  final Value<int> creditCardId;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<bool> billGenerated;
  final Value<DateTime?> dueDate;
  final Value<int> paymentsAppliedPaise;
  const BillingCyclesCompanion({
    this.id = const Value.absent(),
    this.creditCardId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.billGenerated = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paymentsAppliedPaise = const Value.absent(),
  });
  BillingCyclesCompanion.insert({
    this.id = const Value.absent(),
    required int creditCardId,
    required DateTime startDate,
    required DateTime endDate,
    this.billGenerated = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paymentsAppliedPaise = const Value.absent(),
  }) : creditCardId = Value(creditCardId),
       startDate = Value(startDate),
       endDate = Value(endDate);
  static Insertable<BillingCycle> custom({
    Expression<int>? id,
    Expression<int>? creditCardId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? billGenerated,
    Expression<DateTime>? dueDate,
    Expression<int>? paymentsAppliedPaise,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creditCardId != null) 'credit_card_id': creditCardId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (billGenerated != null) 'bill_generated': billGenerated,
      if (dueDate != null) 'due_date': dueDate,
      if (paymentsAppliedPaise != null)
        'payments_applied_paise': paymentsAppliedPaise,
    });
  }

  BillingCyclesCompanion copyWith({
    Value<int>? id,
    Value<int>? creditCardId,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<bool>? billGenerated,
    Value<DateTime?>? dueDate,
    Value<int>? paymentsAppliedPaise,
  }) {
    return BillingCyclesCompanion(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      billGenerated: billGenerated ?? this.billGenerated,
      dueDate: dueDate ?? this.dueDate,
      paymentsAppliedPaise: paymentsAppliedPaise ?? this.paymentsAppliedPaise,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (creditCardId.present) {
      map['credit_card_id'] = Variable<int>(creditCardId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (billGenerated.present) {
      map['bill_generated'] = Variable<bool>(billGenerated.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (paymentsAppliedPaise.present) {
      map['payments_applied_paise'] = Variable<int>(paymentsAppliedPaise.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillingCyclesCompanion(')
          ..write('id: $id, ')
          ..write('creditCardId: $creditCardId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('billGenerated: $billGenerated, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentsAppliedPaise: $paymentsAppliedPaise')
          ..write(')'))
        .toString();
  }
}

class $BankAccountsTable extends BankAccounts
    with TableInfo<$BankAccountsTable, BankAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankAccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bankMeta = const VerificationMeta('bank');
  @override
  late final GeneratedColumn<String> bank = GeneratedColumn<String>(
    'bank',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFourDigitsMeta = const VerificationMeta(
    'lastFourDigits',
  );
  @override
  late final GeneratedColumn<String> lastFourDigits = GeneratedColumn<String>(
    'last_four_digits',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalancePaiseMeta =
      const VerificationMeta('openingBalancePaise');
  @override
  late final GeneratedColumn<int> openingBalancePaise = GeneratedColumn<int>(
    'opening_balance_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bank,
    lastFourDigits,
    nickname,
    openingBalancePaise,
    colorValue,
    iconName,
    notes,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank')) {
      context.handle(
        _bankMeta,
        bank.isAcceptableOrUnknown(data['bank']!, _bankMeta),
      );
    } else if (isInserting) {
      context.missing(_bankMeta);
    }
    if (data.containsKey('last_four_digits')) {
      context.handle(
        _lastFourDigitsMeta,
        lastFourDigits.isAcceptableOrUnknown(
          data['last_four_digits']!,
          _lastFourDigitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastFourDigitsMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('opening_balance_paise')) {
      context.handle(
        _openingBalancePaiseMeta,
        openingBalancePaise.isAcceptableOrUnknown(
          data['opening_balance_paise']!,
          _openingBalancePaiseMeta,
        ),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank'],
      )!,
      lastFourDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_four_digits'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      openingBalancePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_paise'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BankAccountsTable createAlias(String alias) {
    return $BankAccountsTable(attachedDatabase, alias);
  }
}

class BankAccount extends DataClass implements Insertable<BankAccount> {
  final int id;
  final String bank;
  final String lastFourDigits;
  final String nickname;
  final int openingBalancePaise;
  final int colorValue;
  final String iconName;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  const BankAccount({
    required this.id,
    required this.bank,
    required this.lastFourDigits,
    required this.nickname,
    required this.openingBalancePaise,
    required this.colorValue,
    required this.iconName,
    this.notes,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank'] = Variable<String>(bank);
    map['last_four_digits'] = Variable<String>(lastFourDigits);
    map['nickname'] = Variable<String>(nickname);
    map['opening_balance_paise'] = Variable<int>(openingBalancePaise);
    map['color_value'] = Variable<int>(colorValue);
    map['icon_name'] = Variable<String>(iconName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BankAccountsCompanion toCompanion(bool nullToAbsent) {
    return BankAccountsCompanion(
      id: Value(id),
      bank: Value(bank),
      lastFourDigits: Value(lastFourDigits),
      nickname: Value(nickname),
      openingBalancePaise: Value(openingBalancePaise),
      colorValue: Value(colorValue),
      iconName: Value(iconName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory BankAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankAccount(
      id: serializer.fromJson<int>(json['id']),
      bank: serializer.fromJson<String>(json['bank']),
      lastFourDigits: serializer.fromJson<String>(json['lastFourDigits']),
      nickname: serializer.fromJson<String>(json['nickname']),
      openingBalancePaise: serializer.fromJson<int>(
        json['openingBalancePaise'],
      ),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconName: serializer.fromJson<String>(json['iconName']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bank': serializer.toJson<String>(bank),
      'lastFourDigits': serializer.toJson<String>(lastFourDigits),
      'nickname': serializer.toJson<String>(nickname),
      'openingBalancePaise': serializer.toJson<int>(openingBalancePaise),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconName': serializer.toJson<String>(iconName),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BankAccount copyWith({
    int? id,
    String? bank,
    String? lastFourDigits,
    String? nickname,
    int? openingBalancePaise,
    int? colorValue,
    String? iconName,
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
  }) => BankAccount(
    id: id ?? this.id,
    bank: bank ?? this.bank,
    lastFourDigits: lastFourDigits ?? this.lastFourDigits,
    nickname: nickname ?? this.nickname,
    openingBalancePaise: openingBalancePaise ?? this.openingBalancePaise,
    colorValue: colorValue ?? this.colorValue,
    iconName: iconName ?? this.iconName,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  BankAccount copyWithCompanion(BankAccountsCompanion data) {
    return BankAccount(
      id: data.id.present ? data.id.value : this.id,
      bank: data.bank.present ? data.bank.value : this.bank,
      lastFourDigits: data.lastFourDigits.present
          ? data.lastFourDigits.value
          : this.lastFourDigits,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      openingBalancePaise: data.openingBalancePaise.present
          ? data.openingBalancePaise.value
          : this.openingBalancePaise,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankAccount(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('nickname: $nickname, ')
          ..write('openingBalancePaise: $openingBalancePaise, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconName: $iconName, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bank,
    lastFourDigits,
    nickname,
    openingBalancePaise,
    colorValue,
    iconName,
    notes,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankAccount &&
          other.id == this.id &&
          other.bank == this.bank &&
          other.lastFourDigits == this.lastFourDigits &&
          other.nickname == this.nickname &&
          other.openingBalancePaise == this.openingBalancePaise &&
          other.colorValue == this.colorValue &&
          other.iconName == this.iconName &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class BankAccountsCompanion extends UpdateCompanion<BankAccount> {
  final Value<int> id;
  final Value<String> bank;
  final Value<String> lastFourDigits;
  final Value<String> nickname;
  final Value<int> openingBalancePaise;
  final Value<int> colorValue;
  final Value<String> iconName;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const BankAccountsCompanion({
    this.id = const Value.absent(),
    this.bank = const Value.absent(),
    this.lastFourDigits = const Value.absent(),
    this.nickname = const Value.absent(),
    this.openingBalancePaise = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconName = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BankAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String bank,
    required String lastFourDigits,
    required String nickname,
    this.openingBalancePaise = const Value.absent(),
    required int colorValue,
    required String iconName,
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
  }) : bank = Value(bank),
       lastFourDigits = Value(lastFourDigits),
       nickname = Value(nickname),
       colorValue = Value(colorValue),
       iconName = Value(iconName),
       createdAt = Value(createdAt);
  static Insertable<BankAccount> custom({
    Expression<int>? id,
    Expression<String>? bank,
    Expression<String>? lastFourDigits,
    Expression<String>? nickname,
    Expression<int>? openingBalancePaise,
    Expression<int>? colorValue,
    Expression<String>? iconName,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bank != null) 'bank': bank,
      if (lastFourDigits != null) 'last_four_digits': lastFourDigits,
      if (nickname != null) 'nickname': nickname,
      if (openingBalancePaise != null)
        'opening_balance_paise': openingBalancePaise,
      if (colorValue != null) 'color_value': colorValue,
      if (iconName != null) 'icon_name': iconName,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BankAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? bank,
    Value<String>? lastFourDigits,
    Value<String>? nickname,
    Value<int>? openingBalancePaise,
    Value<int>? colorValue,
    Value<String>? iconName,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
  }) {
    return BankAccountsCompanion(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      nickname: nickname ?? this.nickname,
      openingBalancePaise: openingBalancePaise ?? this.openingBalancePaise,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bank.present) {
      map['bank'] = Variable<String>(bank.value);
    }
    if (lastFourDigits.present) {
      map['last_four_digits'] = Variable<String>(lastFourDigits.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (openingBalancePaise.present) {
      map['opening_balance_paise'] = Variable<int>(openingBalancePaise.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountsCompanion(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('nickname: $nickname, ')
          ..write('openingBalancePaise: $openingBalancePaise, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconName: $iconName, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CardTransactionsTable extends CardTransactions
    with TableInfo<$CardTransactionsTable, CardTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTransactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _creditCardIdMeta = const VerificationMeta(
    'creditCardId',
  );
  @override
  late final GeneratedColumn<int> creditCardId = GeneratedColumn<int>(
    'credit_card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billingCycleIdMeta = const VerificationMeta(
    'billingCycleId',
  );
  @override
  late final GeneratedColumn<int> billingCycleId = GeneratedColumn<int>(
    'billing_cycle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionAtMeta = const VerificationMeta(
    'transactionAt',
  );
  @override
  late final GeneratedColumn<DateTime> transactionAt =
      GeneratedColumn<DateTime>(
        'transaction_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawSmsMeta = const VerificationMeta('rawSms');
  @override
  late final GeneratedColumn<String> rawSms = GeneratedColumn<String>(
    'raw_sms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecoverableMeta = const VerificationMeta(
    'isRecoverable',
  );
  @override
  late final GeneratedColumn<bool> isRecoverable = GeneratedColumn<bool>(
    'is_recoverable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recoverable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recoverablePersonMeta = const VerificationMeta(
    'recoverablePerson',
  );
  @override
  late final GeneratedColumn<String> recoverablePerson =
      GeneratedColumn<String>(
        'recoverable_person',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isReviewedMeta = const VerificationMeta(
    'isReviewed',
  );
  @override
  late final GeneratedColumn<bool> isReviewed = GeneratedColumn<bool>(
    'is_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reviewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    creditCardId,
    billingCycleId,
    kind,
    amountPaise,
    merchant,
    transactionAt,
    source,
    rawSms,
    referenceNumber,
    category,
    isRecoverable,
    recoverablePerson,
    isReviewed,
    notes,
    location,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('credit_card_id')) {
      context.handle(
        _creditCardIdMeta,
        creditCardId.isAcceptableOrUnknown(
          data['credit_card_id']!,
          _creditCardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditCardIdMeta);
    }
    if (data.containsKey('billing_cycle_id')) {
      context.handle(
        _billingCycleIdMeta,
        billingCycleId.isAcceptableOrUnknown(
          data['billing_cycle_id']!,
          _billingCycleIdMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantMeta);
    }
    if (data.containsKey('transaction_at')) {
      context.handle(
        _transactionAtMeta,
        transactionAt.isAcceptableOrUnknown(
          data['transaction_at']!,
          _transactionAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('raw_sms')) {
      context.handle(
        _rawSmsMeta,
        rawSms.isAcceptableOrUnknown(data['raw_sms']!, _rawSmsMeta),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_recoverable')) {
      context.handle(
        _isRecoverableMeta,
        isRecoverable.isAcceptableOrUnknown(
          data['is_recoverable']!,
          _isRecoverableMeta,
        ),
      );
    }
    if (data.containsKey('recoverable_person')) {
      context.handle(
        _recoverablePersonMeta,
        recoverablePerson.isAcceptableOrUnknown(
          data['recoverable_person']!,
          _recoverablePersonMeta,
        ),
      );
    }
    if (data.containsKey('is_reviewed')) {
      context.handle(
        _isReviewedMeta,
        isReviewed.isAcceptableOrUnknown(data['is_reviewed']!, _isReviewedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      creditCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_card_id'],
      )!,
      billingCycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_cycle_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      transactionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      rawSms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sms'],
      ),
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      isRecoverable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recoverable'],
      )!,
      recoverablePerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recoverable_person'],
      ),
      isReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reviewed'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardTransactionsTable createAlias(String alias) {
    return $CardTransactionsTable(attachedDatabase, alias);
  }
}

class CardTransaction extends DataClass implements Insertable<CardTransaction> {
  final int id;
  final int creditCardId;
  final int? billingCycleId;
  final String kind;
  final int amountPaise;
  final String merchant;
  final DateTime transactionAt;
  final String source;
  final String? rawSms;
  final String? referenceNumber;
  final String? category;
  final bool isRecoverable;
  final String? recoverablePerson;
  final bool isReviewed;
  final String? notes;
  final String? location;
  final DateTime createdAt;
  const CardTransaction({
    required this.id,
    required this.creditCardId,
    this.billingCycleId,
    required this.kind,
    required this.amountPaise,
    required this.merchant,
    required this.transactionAt,
    required this.source,
    this.rawSms,
    this.referenceNumber,
    this.category,
    required this.isRecoverable,
    this.recoverablePerson,
    required this.isReviewed,
    this.notes,
    this.location,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['credit_card_id'] = Variable<int>(creditCardId);
    if (!nullToAbsent || billingCycleId != null) {
      map['billing_cycle_id'] = Variable<int>(billingCycleId);
    }
    map['kind'] = Variable<String>(kind);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['merchant'] = Variable<String>(merchant);
    map['transaction_at'] = Variable<DateTime>(transactionAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || rawSms != null) {
      map['raw_sms'] = Variable<String>(rawSms);
    }
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_recoverable'] = Variable<bool>(isRecoverable);
    if (!nullToAbsent || recoverablePerson != null) {
      map['recoverable_person'] = Variable<String>(recoverablePerson);
    }
    map['is_reviewed'] = Variable<bool>(isReviewed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CardTransactionsCompanion(
      id: Value(id),
      creditCardId: Value(creditCardId),
      billingCycleId: billingCycleId == null && nullToAbsent
          ? const Value.absent()
          : Value(billingCycleId),
      kind: Value(kind),
      amountPaise: Value(amountPaise),
      merchant: Value(merchant),
      transactionAt: Value(transactionAt),
      source: Value(source),
      rawSms: rawSms == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSms),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isRecoverable: Value(isRecoverable),
      recoverablePerson: recoverablePerson == null && nullToAbsent
          ? const Value.absent()
          : Value(recoverablePerson),
      isReviewed: Value(isReviewed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      createdAt: Value(createdAt),
    );
  }

  factory CardTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTransaction(
      id: serializer.fromJson<int>(json['id']),
      creditCardId: serializer.fromJson<int>(json['creditCardId']),
      billingCycleId: serializer.fromJson<int?>(json['billingCycleId']),
      kind: serializer.fromJson<String>(json['kind']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      merchant: serializer.fromJson<String>(json['merchant']),
      transactionAt: serializer.fromJson<DateTime>(json['transactionAt']),
      source: serializer.fromJson<String>(json['source']),
      rawSms: serializer.fromJson<String?>(json['rawSms']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      category: serializer.fromJson<String?>(json['category']),
      isRecoverable: serializer.fromJson<bool>(json['isRecoverable']),
      recoverablePerson: serializer.fromJson<String?>(
        json['recoverablePerson'],
      ),
      isReviewed: serializer.fromJson<bool>(json['isReviewed']),
      notes: serializer.fromJson<String?>(json['notes']),
      location: serializer.fromJson<String?>(json['location']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'creditCardId': serializer.toJson<int>(creditCardId),
      'billingCycleId': serializer.toJson<int?>(billingCycleId),
      'kind': serializer.toJson<String>(kind),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'merchant': serializer.toJson<String>(merchant),
      'transactionAt': serializer.toJson<DateTime>(transactionAt),
      'source': serializer.toJson<String>(source),
      'rawSms': serializer.toJson<String?>(rawSms),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'category': serializer.toJson<String?>(category),
      'isRecoverable': serializer.toJson<bool>(isRecoverable),
      'recoverablePerson': serializer.toJson<String?>(recoverablePerson),
      'isReviewed': serializer.toJson<bool>(isReviewed),
      'notes': serializer.toJson<String?>(notes),
      'location': serializer.toJson<String?>(location),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardTransaction copyWith({
    int? id,
    int? creditCardId,
    Value<int?> billingCycleId = const Value.absent(),
    String? kind,
    int? amountPaise,
    String? merchant,
    DateTime? transactionAt,
    String? source,
    Value<String?> rawSms = const Value.absent(),
    Value<String?> referenceNumber = const Value.absent(),
    Value<String?> category = const Value.absent(),
    bool? isRecoverable,
    Value<String?> recoverablePerson = const Value.absent(),
    bool? isReviewed,
    Value<String?> notes = const Value.absent(),
    Value<String?> location = const Value.absent(),
    DateTime? createdAt,
  }) => CardTransaction(
    id: id ?? this.id,
    creditCardId: creditCardId ?? this.creditCardId,
    billingCycleId: billingCycleId.present
        ? billingCycleId.value
        : this.billingCycleId,
    kind: kind ?? this.kind,
    amountPaise: amountPaise ?? this.amountPaise,
    merchant: merchant ?? this.merchant,
    transactionAt: transactionAt ?? this.transactionAt,
    source: source ?? this.source,
    rawSms: rawSms.present ? rawSms.value : this.rawSms,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    category: category.present ? category.value : this.category,
    isRecoverable: isRecoverable ?? this.isRecoverable,
    recoverablePerson: recoverablePerson.present
        ? recoverablePerson.value
        : this.recoverablePerson,
    isReviewed: isReviewed ?? this.isReviewed,
    notes: notes.present ? notes.value : this.notes,
    location: location.present ? location.value : this.location,
    createdAt: createdAt ?? this.createdAt,
  );
  CardTransaction copyWithCompanion(CardTransactionsCompanion data) {
    return CardTransaction(
      id: data.id.present ? data.id.value : this.id,
      creditCardId: data.creditCardId.present
          ? data.creditCardId.value
          : this.creditCardId,
      billingCycleId: data.billingCycleId.present
          ? data.billingCycleId.value
          : this.billingCycleId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      transactionAt: data.transactionAt.present
          ? data.transactionAt.value
          : this.transactionAt,
      source: data.source.present ? data.source.value : this.source,
      rawSms: data.rawSms.present ? data.rawSms.value : this.rawSms,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      category: data.category.present ? data.category.value : this.category,
      isRecoverable: data.isRecoverable.present
          ? data.isRecoverable.value
          : this.isRecoverable,
      recoverablePerson: data.recoverablePerson.present
          ? data.recoverablePerson.value
          : this.recoverablePerson,
      isReviewed: data.isReviewed.present
          ? data.isReviewed.value
          : this.isReviewed,
      notes: data.notes.present ? data.notes.value : this.notes,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTransaction(')
          ..write('id: $id, ')
          ..write('creditCardId: $creditCardId, ')
          ..write('billingCycleId: $billingCycleId, ')
          ..write('kind: $kind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('transactionAt: $transactionAt, ')
          ..write('source: $source, ')
          ..write('rawSms: $rawSms, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('category: $category, ')
          ..write('isRecoverable: $isRecoverable, ')
          ..write('recoverablePerson: $recoverablePerson, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    creditCardId,
    billingCycleId,
    kind,
    amountPaise,
    merchant,
    transactionAt,
    source,
    rawSms,
    referenceNumber,
    category,
    isRecoverable,
    recoverablePerson,
    isReviewed,
    notes,
    location,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTransaction &&
          other.id == this.id &&
          other.creditCardId == this.creditCardId &&
          other.billingCycleId == this.billingCycleId &&
          other.kind == this.kind &&
          other.amountPaise == this.amountPaise &&
          other.merchant == this.merchant &&
          other.transactionAt == this.transactionAt &&
          other.source == this.source &&
          other.rawSms == this.rawSms &&
          other.referenceNumber == this.referenceNumber &&
          other.category == this.category &&
          other.isRecoverable == this.isRecoverable &&
          other.recoverablePerson == this.recoverablePerson &&
          other.isReviewed == this.isReviewed &&
          other.notes == this.notes &&
          other.location == this.location &&
          other.createdAt == this.createdAt);
}

class CardTransactionsCompanion extends UpdateCompanion<CardTransaction> {
  final Value<int> id;
  final Value<int> creditCardId;
  final Value<int?> billingCycleId;
  final Value<String> kind;
  final Value<int> amountPaise;
  final Value<String> merchant;
  final Value<DateTime> transactionAt;
  final Value<String> source;
  final Value<String?> rawSms;
  final Value<String?> referenceNumber;
  final Value<String?> category;
  final Value<bool> isRecoverable;
  final Value<String?> recoverablePerson;
  final Value<bool> isReviewed;
  final Value<String?> notes;
  final Value<String?> location;
  final Value<DateTime> createdAt;
  const CardTransactionsCompanion({
    this.id = const Value.absent(),
    this.creditCardId = const Value.absent(),
    this.billingCycleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.merchant = const Value.absent(),
    this.transactionAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rawSms = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.category = const Value.absent(),
    this.isRecoverable = const Value.absent(),
    this.recoverablePerson = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CardTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int creditCardId,
    this.billingCycleId = const Value.absent(),
    required String kind,
    required int amountPaise,
    required String merchant,
    required DateTime transactionAt,
    required String source,
    this.rawSms = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.category = const Value.absent(),
    this.isRecoverable = const Value.absent(),
    this.recoverablePerson = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime createdAt,
  }) : creditCardId = Value(creditCardId),
       kind = Value(kind),
       amountPaise = Value(amountPaise),
       merchant = Value(merchant),
       transactionAt = Value(transactionAt),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<CardTransaction> custom({
    Expression<int>? id,
    Expression<int>? creditCardId,
    Expression<int>? billingCycleId,
    Expression<String>? kind,
    Expression<int>? amountPaise,
    Expression<String>? merchant,
    Expression<DateTime>? transactionAt,
    Expression<String>? source,
    Expression<String>? rawSms,
    Expression<String>? referenceNumber,
    Expression<String>? category,
    Expression<bool>? isRecoverable,
    Expression<String>? recoverablePerson,
    Expression<bool>? isReviewed,
    Expression<String>? notes,
    Expression<String>? location,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creditCardId != null) 'credit_card_id': creditCardId,
      if (billingCycleId != null) 'billing_cycle_id': billingCycleId,
      if (kind != null) 'kind': kind,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (merchant != null) 'merchant': merchant,
      if (transactionAt != null) 'transaction_at': transactionAt,
      if (source != null) 'source': source,
      if (rawSms != null) 'raw_sms': rawSms,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (category != null) 'category': category,
      if (isRecoverable != null) 'is_recoverable': isRecoverable,
      if (recoverablePerson != null) 'recoverable_person': recoverablePerson,
      if (isReviewed != null) 'is_reviewed': isReviewed,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CardTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? creditCardId,
    Value<int?>? billingCycleId,
    Value<String>? kind,
    Value<int>? amountPaise,
    Value<String>? merchant,
    Value<DateTime>? transactionAt,
    Value<String>? source,
    Value<String?>? rawSms,
    Value<String?>? referenceNumber,
    Value<String?>? category,
    Value<bool>? isRecoverable,
    Value<String?>? recoverablePerson,
    Value<bool>? isReviewed,
    Value<String?>? notes,
    Value<String?>? location,
    Value<DateTime>? createdAt,
  }) {
    return CardTransactionsCompanion(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      billingCycleId: billingCycleId ?? this.billingCycleId,
      kind: kind ?? this.kind,
      amountPaise: amountPaise ?? this.amountPaise,
      merchant: merchant ?? this.merchant,
      transactionAt: transactionAt ?? this.transactionAt,
      source: source ?? this.source,
      rawSms: rawSms ?? this.rawSms,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      category: category ?? this.category,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      recoverablePerson: recoverablePerson ?? this.recoverablePerson,
      isReviewed: isReviewed ?? this.isReviewed,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (creditCardId.present) {
      map['credit_card_id'] = Variable<int>(creditCardId.value);
    }
    if (billingCycleId.present) {
      map['billing_cycle_id'] = Variable<int>(billingCycleId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (transactionAt.present) {
      map['transaction_at'] = Variable<DateTime>(transactionAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rawSms.present) {
      map['raw_sms'] = Variable<String>(rawSms.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isRecoverable.present) {
      map['is_recoverable'] = Variable<bool>(isRecoverable.value);
    }
    if (recoverablePerson.present) {
      map['recoverable_person'] = Variable<String>(recoverablePerson.value);
    }
    if (isReviewed.present) {
      map['is_reviewed'] = Variable<bool>(isReviewed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('creditCardId: $creditCardId, ')
          ..write('billingCycleId: $billingCycleId, ')
          ..write('kind: $kind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('transactionAt: $transactionAt, ')
          ..write('source: $source, ')
          ..write('rawSms: $rawSms, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('category: $category, ')
          ..write('isRecoverable: $isRecoverable, ')
          ..write('recoverablePerson: $recoverablePerson, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CardTransactionReceiptsTable extends CardTransactionReceipts
    with TableInfo<$CardTransactionReceiptsTable, CardTransactionReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTransactionReceiptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cardTransactionIdMeta = const VerificationMeta(
    'cardTransactionId',
  );
  @override
  late final GeneratedColumn<int> cardTransactionId = GeneratedColumn<int>(
    'card_transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardTransactionId,
    filePath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_transaction_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTransactionReceipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_transaction_id')) {
      context.handle(
        _cardTransactionIdMeta,
        cardTransactionId.isAcceptableOrUnknown(
          data['card_transaction_id']!,
          _cardTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardTransactionIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardTransactionReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTransactionReceipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_transaction_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardTransactionReceiptsTable createAlias(String alias) {
    return $CardTransactionReceiptsTable(attachedDatabase, alias);
  }
}

class CardTransactionReceipt extends DataClass
    implements Insertable<CardTransactionReceipt> {
  final int id;
  final int cardTransactionId;
  final String filePath;
  final DateTime createdAt;
  const CardTransactionReceipt({
    required this.id,
    required this.cardTransactionId,
    required this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_transaction_id'] = Variable<int>(cardTransactionId);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardTransactionReceiptsCompanion toCompanion(bool nullToAbsent) {
    return CardTransactionReceiptsCompanion(
      id: Value(id),
      cardTransactionId: Value(cardTransactionId),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory CardTransactionReceipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTransactionReceipt(
      id: serializer.fromJson<int>(json['id']),
      cardTransactionId: serializer.fromJson<int>(json['cardTransactionId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardTransactionId': serializer.toJson<int>(cardTransactionId),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardTransactionReceipt copyWith({
    int? id,
    int? cardTransactionId,
    String? filePath,
    DateTime? createdAt,
  }) => CardTransactionReceipt(
    id: id ?? this.id,
    cardTransactionId: cardTransactionId ?? this.cardTransactionId,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  CardTransactionReceipt copyWithCompanion(
    CardTransactionReceiptsCompanion data,
  ) {
    return CardTransactionReceipt(
      id: data.id.present ? data.id.value : this.id,
      cardTransactionId: data.cardTransactionId.present
          ? data.cardTransactionId.value
          : this.cardTransactionId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTransactionReceipt(')
          ..write('id: $id, ')
          ..write('cardTransactionId: $cardTransactionId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardTransactionId, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTransactionReceipt &&
          other.id == this.id &&
          other.cardTransactionId == this.cardTransactionId &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class CardTransactionReceiptsCompanion
    extends UpdateCompanion<CardTransactionReceipt> {
  final Value<int> id;
  final Value<int> cardTransactionId;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  const CardTransactionReceiptsCompanion({
    this.id = const Value.absent(),
    this.cardTransactionId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CardTransactionReceiptsCompanion.insert({
    this.id = const Value.absent(),
    required int cardTransactionId,
    required String filePath,
    required DateTime createdAt,
  }) : cardTransactionId = Value(cardTransactionId),
       filePath = Value(filePath),
       createdAt = Value(createdAt);
  static Insertable<CardTransactionReceipt> custom({
    Expression<int>? id,
    Expression<int>? cardTransactionId,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardTransactionId != null) 'card_transaction_id': cardTransactionId,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CardTransactionReceiptsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardTransactionId,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
  }) {
    return CardTransactionReceiptsCompanion(
      id: id ?? this.id,
      cardTransactionId: cardTransactionId ?? this.cardTransactionId,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardTransactionId.present) {
      map['card_transaction_id'] = Variable<int>(cardTransactionId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTransactionReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('cardTransactionId: $cardTransactionId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BankAccountTransactionsTable extends BankAccountTransactions
    with TableInfo<$BankAccountTransactionsTable, BankAccountTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankAccountTransactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bankAccountIdMeta = const VerificationMeta(
    'bankAccountId',
  );
  @override
  late final GeneratedColumn<int> bankAccountId = GeneratedColumn<int>(
    'bank_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beneficiaryMeta = const VerificationMeta(
    'beneficiary',
  );
  @override
  late final GeneratedColumn<String> beneficiary = GeneratedColumn<String>(
    'beneficiary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionAtMeta = const VerificationMeta(
    'transactionAt',
  );
  @override
  late final GeneratedColumn<DateTime> transactionAt =
      GeneratedColumn<DateTime>(
        'transaction_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawSmsMeta = const VerificationMeta('rawSms');
  @override
  late final GeneratedColumn<String> rawSms = GeneratedColumn<String>(
    'raw_sms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReviewedMeta = const VerificationMeta(
    'isReviewed',
  );
  @override
  late final GeneratedColumn<bool> isReviewed = GeneratedColumn<bool>(
    'is_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reviewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankAccountId,
    kind,
    amountPaise,
    merchant,
    beneficiary,
    category,
    transactionAt,
    source,
    rawSms,
    referenceNumber,
    isReviewed,
    notes,
    location,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_account_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankAccountTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
        _bankAccountIdMeta,
        bankAccountId.isAcceptableOrUnknown(
          data['bank_account_id']!,
          _bankAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bankAccountIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('beneficiary')) {
      context.handle(
        _beneficiaryMeta,
        beneficiary.isAcceptableOrUnknown(
          data['beneficiary']!,
          _beneficiaryMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('transaction_at')) {
      context.handle(
        _transactionAtMeta,
        transactionAt.isAcceptableOrUnknown(
          data['transaction_at']!,
          _transactionAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('raw_sms')) {
      context.handle(
        _rawSmsMeta,
        rawSms.isAcceptableOrUnknown(data['raw_sms']!, _rawSmsMeta),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('is_reviewed')) {
      context.handle(
        _isReviewedMeta,
        isReviewed.isAcceptableOrUnknown(data['is_reviewed']!, _isReviewedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankAccountTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankAccountTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bankAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_account_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      beneficiary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiary'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      transactionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      rawSms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sms'],
      ),
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      isReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reviewed'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BankAccountTransactionsTable createAlias(String alias) {
    return $BankAccountTransactionsTable(attachedDatabase, alias);
  }
}

class BankAccountTransaction extends DataClass
    implements Insertable<BankAccountTransaction> {
  final int id;
  final int bankAccountId;
  final String kind;
  final int amountPaise;
  final String? merchant;
  final String? beneficiary;
  final String? category;
  final DateTime transactionAt;
  final String source;
  final String? rawSms;
  final String? referenceNumber;
  final bool isReviewed;
  final String? notes;
  final String? location;
  final DateTime createdAt;
  const BankAccountTransaction({
    required this.id,
    required this.bankAccountId,
    required this.kind,
    required this.amountPaise,
    this.merchant,
    this.beneficiary,
    this.category,
    required this.transactionAt,
    required this.source,
    this.rawSms,
    this.referenceNumber,
    required this.isReviewed,
    this.notes,
    this.location,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank_account_id'] = Variable<int>(bankAccountId);
    map['kind'] = Variable<String>(kind);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || beneficiary != null) {
      map['beneficiary'] = Variable<String>(beneficiary);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['transaction_at'] = Variable<DateTime>(transactionAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || rawSms != null) {
      map['raw_sms'] = Variable<String>(rawSms);
    }
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    map['is_reviewed'] = Variable<bool>(isReviewed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BankAccountTransactionsCompanion toCompanion(bool nullToAbsent) {
    return BankAccountTransactionsCompanion(
      id: Value(id),
      bankAccountId: Value(bankAccountId),
      kind: Value(kind),
      amountPaise: Value(amountPaise),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      beneficiary: beneficiary == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiary),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      transactionAt: Value(transactionAt),
      source: Value(source),
      rawSms: rawSms == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSms),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      isReviewed: Value(isReviewed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      createdAt: Value(createdAt),
    );
  }

  factory BankAccountTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankAccountTransaction(
      id: serializer.fromJson<int>(json['id']),
      bankAccountId: serializer.fromJson<int>(json['bankAccountId']),
      kind: serializer.fromJson<String>(json['kind']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      beneficiary: serializer.fromJson<String?>(json['beneficiary']),
      category: serializer.fromJson<String?>(json['category']),
      transactionAt: serializer.fromJson<DateTime>(json['transactionAt']),
      source: serializer.fromJson<String>(json['source']),
      rawSms: serializer.fromJson<String?>(json['rawSms']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      isReviewed: serializer.fromJson<bool>(json['isReviewed']),
      notes: serializer.fromJson<String?>(json['notes']),
      location: serializer.fromJson<String?>(json['location']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bankAccountId': serializer.toJson<int>(bankAccountId),
      'kind': serializer.toJson<String>(kind),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'merchant': serializer.toJson<String?>(merchant),
      'beneficiary': serializer.toJson<String?>(beneficiary),
      'category': serializer.toJson<String?>(category),
      'transactionAt': serializer.toJson<DateTime>(transactionAt),
      'source': serializer.toJson<String>(source),
      'rawSms': serializer.toJson<String?>(rawSms),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'isReviewed': serializer.toJson<bool>(isReviewed),
      'notes': serializer.toJson<String?>(notes),
      'location': serializer.toJson<String?>(location),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BankAccountTransaction copyWith({
    int? id,
    int? bankAccountId,
    String? kind,
    int? amountPaise,
    Value<String?> merchant = const Value.absent(),
    Value<String?> beneficiary = const Value.absent(),
    Value<String?> category = const Value.absent(),
    DateTime? transactionAt,
    String? source,
    Value<String?> rawSms = const Value.absent(),
    Value<String?> referenceNumber = const Value.absent(),
    bool? isReviewed,
    Value<String?> notes = const Value.absent(),
    Value<String?> location = const Value.absent(),
    DateTime? createdAt,
  }) => BankAccountTransaction(
    id: id ?? this.id,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    kind: kind ?? this.kind,
    amountPaise: amountPaise ?? this.amountPaise,
    merchant: merchant.present ? merchant.value : this.merchant,
    beneficiary: beneficiary.present ? beneficiary.value : this.beneficiary,
    category: category.present ? category.value : this.category,
    transactionAt: transactionAt ?? this.transactionAt,
    source: source ?? this.source,
    rawSms: rawSms.present ? rawSms.value : this.rawSms,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    isReviewed: isReviewed ?? this.isReviewed,
    notes: notes.present ? notes.value : this.notes,
    location: location.present ? location.value : this.location,
    createdAt: createdAt ?? this.createdAt,
  );
  BankAccountTransaction copyWithCompanion(
    BankAccountTransactionsCompanion data,
  ) {
    return BankAccountTransaction(
      id: data.id.present ? data.id.value : this.id,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      beneficiary: data.beneficiary.present
          ? data.beneficiary.value
          : this.beneficiary,
      category: data.category.present ? data.category.value : this.category,
      transactionAt: data.transactionAt.present
          ? data.transactionAt.value
          : this.transactionAt,
      source: data.source.present ? data.source.value : this.source,
      rawSms: data.rawSms.present ? data.rawSms.value : this.rawSms,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      isReviewed: data.isReviewed.present
          ? data.isReviewed.value
          : this.isReviewed,
      notes: data.notes.present ? data.notes.value : this.notes,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountTransaction(')
          ..write('id: $id, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('kind: $kind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('beneficiary: $beneficiary, ')
          ..write('category: $category, ')
          ..write('transactionAt: $transactionAt, ')
          ..write('source: $source, ')
          ..write('rawSms: $rawSms, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankAccountId,
    kind,
    amountPaise,
    merchant,
    beneficiary,
    category,
    transactionAt,
    source,
    rawSms,
    referenceNumber,
    isReviewed,
    notes,
    location,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankAccountTransaction &&
          other.id == this.id &&
          other.bankAccountId == this.bankAccountId &&
          other.kind == this.kind &&
          other.amountPaise == this.amountPaise &&
          other.merchant == this.merchant &&
          other.beneficiary == this.beneficiary &&
          other.category == this.category &&
          other.transactionAt == this.transactionAt &&
          other.source == this.source &&
          other.rawSms == this.rawSms &&
          other.referenceNumber == this.referenceNumber &&
          other.isReviewed == this.isReviewed &&
          other.notes == this.notes &&
          other.location == this.location &&
          other.createdAt == this.createdAt);
}

class BankAccountTransactionsCompanion
    extends UpdateCompanion<BankAccountTransaction> {
  final Value<int> id;
  final Value<int> bankAccountId;
  final Value<String> kind;
  final Value<int> amountPaise;
  final Value<String?> merchant;
  final Value<String?> beneficiary;
  final Value<String?> category;
  final Value<DateTime> transactionAt;
  final Value<String> source;
  final Value<String?> rawSms;
  final Value<String?> referenceNumber;
  final Value<bool> isReviewed;
  final Value<String?> notes;
  final Value<String?> location;
  final Value<DateTime> createdAt;
  const BankAccountTransactionsCompanion({
    this.id = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.merchant = const Value.absent(),
    this.beneficiary = const Value.absent(),
    this.category = const Value.absent(),
    this.transactionAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rawSms = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BankAccountTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int bankAccountId,
    required String kind,
    required int amountPaise,
    this.merchant = const Value.absent(),
    this.beneficiary = const Value.absent(),
    this.category = const Value.absent(),
    required DateTime transactionAt,
    required String source,
    this.rawSms = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime createdAt,
  }) : bankAccountId = Value(bankAccountId),
       kind = Value(kind),
       amountPaise = Value(amountPaise),
       transactionAt = Value(transactionAt),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<BankAccountTransaction> custom({
    Expression<int>? id,
    Expression<int>? bankAccountId,
    Expression<String>? kind,
    Expression<int>? amountPaise,
    Expression<String>? merchant,
    Expression<String>? beneficiary,
    Expression<String>? category,
    Expression<DateTime>? transactionAt,
    Expression<String>? source,
    Expression<String>? rawSms,
    Expression<String>? referenceNumber,
    Expression<bool>? isReviewed,
    Expression<String>? notes,
    Expression<String>? location,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (kind != null) 'kind': kind,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (merchant != null) 'merchant': merchant,
      if (beneficiary != null) 'beneficiary': beneficiary,
      if (category != null) 'category': category,
      if (transactionAt != null) 'transaction_at': transactionAt,
      if (source != null) 'source': source,
      if (rawSms != null) 'raw_sms': rawSms,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (isReviewed != null) 'is_reviewed': isReviewed,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BankAccountTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? bankAccountId,
    Value<String>? kind,
    Value<int>? amountPaise,
    Value<String?>? merchant,
    Value<String?>? beneficiary,
    Value<String?>? category,
    Value<DateTime>? transactionAt,
    Value<String>? source,
    Value<String?>? rawSms,
    Value<String?>? referenceNumber,
    Value<bool>? isReviewed,
    Value<String?>? notes,
    Value<String?>? location,
    Value<DateTime>? createdAt,
  }) {
    return BankAccountTransactionsCompanion(
      id: id ?? this.id,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      kind: kind ?? this.kind,
      amountPaise: amountPaise ?? this.amountPaise,
      merchant: merchant ?? this.merchant,
      beneficiary: beneficiary ?? this.beneficiary,
      category: category ?? this.category,
      transactionAt: transactionAt ?? this.transactionAt,
      source: source ?? this.source,
      rawSms: rawSms ?? this.rawSms,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      isReviewed: isReviewed ?? this.isReviewed,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<int>(bankAccountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (beneficiary.present) {
      map['beneficiary'] = Variable<String>(beneficiary.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (transactionAt.present) {
      map['transaction_at'] = Variable<DateTime>(transactionAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rawSms.present) {
      map['raw_sms'] = Variable<String>(rawSms.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (isReviewed.present) {
      map['is_reviewed'] = Variable<bool>(isReviewed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('kind: $kind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('beneficiary: $beneficiary, ')
          ..write('category: $category, ')
          ..write('transactionAt: $transactionAt, ')
          ..write('source: $source, ')
          ..write('rawSms: $rawSms, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
    'onboarding_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _importLastIndexMeta = const VerificationMeta(
    'importLastIndex',
  );
  @override
  late final GeneratedColumn<int> importLastIndex = GeneratedColumn<int>(
    'import_last_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importCompletedMeta = const VerificationMeta(
    'importCompleted',
  );
  @override
  late final GeneratedColumn<bool> importCompleted = GeneratedColumn<bool>(
    'import_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("import_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _locationPermissionExplainedMeta =
      const VerificationMeta('locationPermissionExplained');
  @override
  late final GeneratedColumn<bool> locationPermissionExplained =
      GeneratedColumn<bool>(
        'location_permission_explained',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("location_permission_explained" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _appLockEnabledMeta = const VerificationMeta(
    'appLockEnabled',
  );
  @override
  late final GeneratedColumn<bool> appLockEnabled = GeneratedColumn<bool>(
    'app_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appLockBiometricEnabledMeta =
      const VerificationMeta('appLockBiometricEnabled');
  @override
  late final GeneratedColumn<bool> appLockBiometricEnabled =
      GeneratedColumn<bool>(
        'app_lock_biometric_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("app_lock_biometric_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    onboardingComplete,
    importLastIndex,
    importCompleted,
    locationPermissionExplained,
    themeMode,
    appLockEnabled,
    appLockBiometricEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
        _onboardingCompleteMeta,
        onboardingComplete.isAcceptableOrUnknown(
          data['onboarding_complete']!,
          _onboardingCompleteMeta,
        ),
      );
    }
    if (data.containsKey('import_last_index')) {
      context.handle(
        _importLastIndexMeta,
        importLastIndex.isAcceptableOrUnknown(
          data['import_last_index']!,
          _importLastIndexMeta,
        ),
      );
    }
    if (data.containsKey('import_completed')) {
      context.handle(
        _importCompletedMeta,
        importCompleted.isAcceptableOrUnknown(
          data['import_completed']!,
          _importCompletedMeta,
        ),
      );
    }
    if (data.containsKey('location_permission_explained')) {
      context.handle(
        _locationPermissionExplainedMeta,
        locationPermissionExplained.isAcceptableOrUnknown(
          data['location_permission_explained']!,
          _locationPermissionExplainedMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('app_lock_enabled')) {
      context.handle(
        _appLockEnabledMeta,
        appLockEnabled.isAcceptableOrUnknown(
          data['app_lock_enabled']!,
          _appLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('app_lock_biometric_enabled')) {
      context.handle(
        _appLockBiometricEnabledMeta,
        appLockBiometricEnabled.isAcceptableOrUnknown(
          data['app_lock_biometric_enabled']!,
          _appLockBiometricEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      onboardingComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_complete'],
      )!,
      importLastIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_last_index'],
      )!,
      importCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}import_completed'],
      )!,
      locationPermissionExplained: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}location_permission_explained'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      appLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_enabled'],
      )!,
      appLockBiometricEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_biometric_enabled'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final bool onboardingComplete;
  final int importLastIndex;
  final bool importCompleted;
  final bool locationPermissionExplained;
  final String themeMode;
  final bool appLockEnabled;
  final bool appLockBiometricEnabled;
  const AppSetting({
    required this.id,
    required this.onboardingComplete,
    required this.importLastIndex,
    required this.importCompleted,
    required this.locationPermissionExplained,
    required this.themeMode,
    required this.appLockEnabled,
    required this.appLockBiometricEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    map['import_last_index'] = Variable<int>(importLastIndex);
    map['import_completed'] = Variable<bool>(importCompleted);
    map['location_permission_explained'] = Variable<bool>(
      locationPermissionExplained,
    );
    map['theme_mode'] = Variable<String>(themeMode);
    map['app_lock_enabled'] = Variable<bool>(appLockEnabled);
    map['app_lock_biometric_enabled'] = Variable<bool>(appLockBiometricEnabled);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      onboardingComplete: Value(onboardingComplete),
      importLastIndex: Value(importLastIndex),
      importCompleted: Value(importCompleted),
      locationPermissionExplained: Value(locationPermissionExplained),
      themeMode: Value(themeMode),
      appLockEnabled: Value(appLockEnabled),
      appLockBiometricEnabled: Value(appLockBiometricEnabled),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      importLastIndex: serializer.fromJson<int>(json['importLastIndex']),
      importCompleted: serializer.fromJson<bool>(json['importCompleted']),
      locationPermissionExplained: serializer.fromJson<bool>(
        json['locationPermissionExplained'],
      ),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      appLockEnabled: serializer.fromJson<bool>(json['appLockEnabled']),
      appLockBiometricEnabled: serializer.fromJson<bool>(
        json['appLockBiometricEnabled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'importLastIndex': serializer.toJson<int>(importLastIndex),
      'importCompleted': serializer.toJson<bool>(importCompleted),
      'locationPermissionExplained': serializer.toJson<bool>(
        locationPermissionExplained,
      ),
      'themeMode': serializer.toJson<String>(themeMode),
      'appLockEnabled': serializer.toJson<bool>(appLockEnabled),
      'appLockBiometricEnabled': serializer.toJson<bool>(
        appLockBiometricEnabled,
      ),
    };
  }

  AppSetting copyWith({
    int? id,
    bool? onboardingComplete,
    int? importLastIndex,
    bool? importCompleted,
    bool? locationPermissionExplained,
    String? themeMode,
    bool? appLockEnabled,
    bool? appLockBiometricEnabled,
  }) => AppSetting(
    id: id ?? this.id,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    importLastIndex: importLastIndex ?? this.importLastIndex,
    importCompleted: importCompleted ?? this.importCompleted,
    locationPermissionExplained:
        locationPermissionExplained ?? this.locationPermissionExplained,
    themeMode: themeMode ?? this.themeMode,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    appLockBiometricEnabled:
        appLockBiometricEnabled ?? this.appLockBiometricEnabled,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      importLastIndex: data.importLastIndex.present
          ? data.importLastIndex.value
          : this.importLastIndex,
      importCompleted: data.importCompleted.present
          ? data.importCompleted.value
          : this.importCompleted,
      locationPermissionExplained: data.locationPermissionExplained.present
          ? data.locationPermissionExplained.value
          : this.locationPermissionExplained,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      appLockEnabled: data.appLockEnabled.present
          ? data.appLockEnabled.value
          : this.appLockEnabled,
      appLockBiometricEnabled: data.appLockBiometricEnabled.present
          ? data.appLockBiometricEnabled.value
          : this.appLockBiometricEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('importLastIndex: $importLastIndex, ')
          ..write('importCompleted: $importCompleted, ')
          ..write('locationPermissionExplained: $locationPermissionExplained, ')
          ..write('themeMode: $themeMode, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('appLockBiometricEnabled: $appLockBiometricEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    onboardingComplete,
    importLastIndex,
    importCompleted,
    locationPermissionExplained,
    themeMode,
    appLockEnabled,
    appLockBiometricEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.onboardingComplete == this.onboardingComplete &&
          other.importLastIndex == this.importLastIndex &&
          other.importCompleted == this.importCompleted &&
          other.locationPermissionExplained ==
              this.locationPermissionExplained &&
          other.themeMode == this.themeMode &&
          other.appLockEnabled == this.appLockEnabled &&
          other.appLockBiometricEnabled == this.appLockBiometricEnabled);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> onboardingComplete;
  final Value<int> importLastIndex;
  final Value<bool> importCompleted;
  final Value<bool> locationPermissionExplained;
  final Value<String> themeMode;
  final Value<bool> appLockEnabled;
  final Value<bool> appLockBiometricEnabled;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.importLastIndex = const Value.absent(),
    this.importCompleted = const Value.absent(),
    this.locationPermissionExplained = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.appLockBiometricEnabled = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.importLastIndex = const Value.absent(),
    this.importCompleted = const Value.absent(),
    this.locationPermissionExplained = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.appLockBiometricEnabled = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? onboardingComplete,
    Expression<int>? importLastIndex,
    Expression<bool>? importCompleted,
    Expression<bool>? locationPermissionExplained,
    Expression<String>? themeMode,
    Expression<bool>? appLockEnabled,
    Expression<bool>? appLockBiometricEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (importLastIndex != null) 'import_last_index': importLastIndex,
      if (importCompleted != null) 'import_completed': importCompleted,
      if (locationPermissionExplained != null)
        'location_permission_explained': locationPermissionExplained,
      if (themeMode != null) 'theme_mode': themeMode,
      if (appLockEnabled != null) 'app_lock_enabled': appLockEnabled,
      if (appLockBiometricEnabled != null)
        'app_lock_biometric_enabled': appLockBiometricEnabled,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? onboardingComplete,
    Value<int>? importLastIndex,
    Value<bool>? importCompleted,
    Value<bool>? locationPermissionExplained,
    Value<String>? themeMode,
    Value<bool>? appLockEnabled,
    Value<bool>? appLockBiometricEnabled,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      importLastIndex: importLastIndex ?? this.importLastIndex,
      importCompleted: importCompleted ?? this.importCompleted,
      locationPermissionExplained:
          locationPermissionExplained ?? this.locationPermissionExplained,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockBiometricEnabled:
          appLockBiometricEnabled ?? this.appLockBiometricEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (importLastIndex.present) {
      map['import_last_index'] = Variable<int>(importLastIndex.value);
    }
    if (importCompleted.present) {
      map['import_completed'] = Variable<bool>(importCompleted.value);
    }
    if (locationPermissionExplained.present) {
      map['location_permission_explained'] = Variable<bool>(
        locationPermissionExplained.value,
      );
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (appLockEnabled.present) {
      map['app_lock_enabled'] = Variable<bool>(appLockEnabled.value);
    }
    if (appLockBiometricEnabled.present) {
      map['app_lock_biometric_enabled'] = Variable<bool>(
        appLockBiometricEnabled.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('importLastIndex: $importLastIndex, ')
          ..write('importCompleted: $importCompleted, ')
          ..write('locationPermissionExplained: $locationPermissionExplained, ')
          ..write('themeMode: $themeMode, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('appLockBiometricEnabled: $appLockBiometricEnabled')
          ..write(')'))
        .toString();
  }
}

class $BudgetSettingsTable extends BudgetSettings
    with TableInfo<$BudgetSettingsTable, BudgetSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _monthlyLimitPaiseMeta = const VerificationMeta(
    'monthlyLimitPaise',
  );
  @override
  late final GeneratedColumn<int> monthlyLimitPaise = GeneratedColumn<int>(
    'monthly_limit_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPeriodStartMeta =
      const VerificationMeta('currentPeriodStart');
  @override
  late final GeneratedColumn<DateTime> currentPeriodStart =
      GeneratedColumn<DateTime>(
        'current_period_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _alertThreshold75Meta = const VerificationMeta(
    'alertThreshold75',
  );
  @override
  late final GeneratedColumn<int> alertThreshold75 = GeneratedColumn<int>(
    'alert_threshold75',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(75),
  );
  static const VerificationMeta _alertThreshold90Meta = const VerificationMeta(
    'alertThreshold90',
  );
  @override
  late final GeneratedColumn<int> alertThreshold90 = GeneratedColumn<int>(
    'alert_threshold90',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(90),
  );
  static const VerificationMeta _alertThreshold100Meta = const VerificationMeta(
    'alertThreshold100',
  );
  @override
  late final GeneratedColumn<int> alertThreshold100 = GeneratedColumn<int>(
    'alert_threshold100',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monthlyLimitPaise,
    currentPeriodStart,
    alertThreshold75,
    alertThreshold90,
    alertThreshold100,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monthly_limit_paise')) {
      context.handle(
        _monthlyLimitPaiseMeta,
        monthlyLimitPaise.isAcceptableOrUnknown(
          data['monthly_limit_paise']!,
          _monthlyLimitPaiseMeta,
        ),
      );
    }
    if (data.containsKey('current_period_start')) {
      context.handle(
        _currentPeriodStartMeta,
        currentPeriodStart.isAcceptableOrUnknown(
          data['current_period_start']!,
          _currentPeriodStartMeta,
        ),
      );
    }
    if (data.containsKey('alert_threshold75')) {
      context.handle(
        _alertThreshold75Meta,
        alertThreshold75.isAcceptableOrUnknown(
          data['alert_threshold75']!,
          _alertThreshold75Meta,
        ),
      );
    }
    if (data.containsKey('alert_threshold90')) {
      context.handle(
        _alertThreshold90Meta,
        alertThreshold90.isAcceptableOrUnknown(
          data['alert_threshold90']!,
          _alertThreshold90Meta,
        ),
      );
    }
    if (data.containsKey('alert_threshold100')) {
      context.handle(
        _alertThreshold100Meta,
        alertThreshold100.isAcceptableOrUnknown(
          data['alert_threshold100']!,
          _alertThreshold100Meta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monthlyLimitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_limit_paise'],
      ),
      currentPeriodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}current_period_start'],
      ),
      alertThreshold75: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_threshold75'],
      )!,
      alertThreshold90: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_threshold90'],
      )!,
      alertThreshold100: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_threshold100'],
      )!,
    );
  }

  @override
  $BudgetSettingsTable createAlias(String alias) {
    return $BudgetSettingsTable(attachedDatabase, alias);
  }
}

class BudgetSetting extends DataClass implements Insertable<BudgetSetting> {
  final int id;
  final int? monthlyLimitPaise;
  final DateTime? currentPeriodStart;
  final int alertThreshold75;
  final int alertThreshold90;
  final int alertThreshold100;
  const BudgetSetting({
    required this.id,
    this.monthlyLimitPaise,
    this.currentPeriodStart,
    required this.alertThreshold75,
    required this.alertThreshold90,
    required this.alertThreshold100,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || monthlyLimitPaise != null) {
      map['monthly_limit_paise'] = Variable<int>(monthlyLimitPaise);
    }
    if (!nullToAbsent || currentPeriodStart != null) {
      map['current_period_start'] = Variable<DateTime>(currentPeriodStart);
    }
    map['alert_threshold75'] = Variable<int>(alertThreshold75);
    map['alert_threshold90'] = Variable<int>(alertThreshold90);
    map['alert_threshold100'] = Variable<int>(alertThreshold100);
    return map;
  }

  BudgetSettingsCompanion toCompanion(bool nullToAbsent) {
    return BudgetSettingsCompanion(
      id: Value(id),
      monthlyLimitPaise: monthlyLimitPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyLimitPaise),
      currentPeriodStart: currentPeriodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPeriodStart),
      alertThreshold75: Value(alertThreshold75),
      alertThreshold90: Value(alertThreshold90),
      alertThreshold100: Value(alertThreshold100),
    );
  }

  factory BudgetSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetSetting(
      id: serializer.fromJson<int>(json['id']),
      monthlyLimitPaise: serializer.fromJson<int?>(json['monthlyLimitPaise']),
      currentPeriodStart: serializer.fromJson<DateTime?>(
        json['currentPeriodStart'],
      ),
      alertThreshold75: serializer.fromJson<int>(json['alertThreshold75']),
      alertThreshold90: serializer.fromJson<int>(json['alertThreshold90']),
      alertThreshold100: serializer.fromJson<int>(json['alertThreshold100']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthlyLimitPaise': serializer.toJson<int?>(monthlyLimitPaise),
      'currentPeriodStart': serializer.toJson<DateTime?>(currentPeriodStart),
      'alertThreshold75': serializer.toJson<int>(alertThreshold75),
      'alertThreshold90': serializer.toJson<int>(alertThreshold90),
      'alertThreshold100': serializer.toJson<int>(alertThreshold100),
    };
  }

  BudgetSetting copyWith({
    int? id,
    Value<int?> monthlyLimitPaise = const Value.absent(),
    Value<DateTime?> currentPeriodStart = const Value.absent(),
    int? alertThreshold75,
    int? alertThreshold90,
    int? alertThreshold100,
  }) => BudgetSetting(
    id: id ?? this.id,
    monthlyLimitPaise: monthlyLimitPaise.present
        ? monthlyLimitPaise.value
        : this.monthlyLimitPaise,
    currentPeriodStart: currentPeriodStart.present
        ? currentPeriodStart.value
        : this.currentPeriodStart,
    alertThreshold75: alertThreshold75 ?? this.alertThreshold75,
    alertThreshold90: alertThreshold90 ?? this.alertThreshold90,
    alertThreshold100: alertThreshold100 ?? this.alertThreshold100,
  );
  BudgetSetting copyWithCompanion(BudgetSettingsCompanion data) {
    return BudgetSetting(
      id: data.id.present ? data.id.value : this.id,
      monthlyLimitPaise: data.monthlyLimitPaise.present
          ? data.monthlyLimitPaise.value
          : this.monthlyLimitPaise,
      currentPeriodStart: data.currentPeriodStart.present
          ? data.currentPeriodStart.value
          : this.currentPeriodStart,
      alertThreshold75: data.alertThreshold75.present
          ? data.alertThreshold75.value
          : this.alertThreshold75,
      alertThreshold90: data.alertThreshold90.present
          ? data.alertThreshold90.value
          : this.alertThreshold90,
      alertThreshold100: data.alertThreshold100.present
          ? data.alertThreshold100.value
          : this.alertThreshold100,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetSetting(')
          ..write('id: $id, ')
          ..write('monthlyLimitPaise: $monthlyLimitPaise, ')
          ..write('currentPeriodStart: $currentPeriodStart, ')
          ..write('alertThreshold75: $alertThreshold75, ')
          ..write('alertThreshold90: $alertThreshold90, ')
          ..write('alertThreshold100: $alertThreshold100')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    monthlyLimitPaise,
    currentPeriodStart,
    alertThreshold75,
    alertThreshold90,
    alertThreshold100,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetSetting &&
          other.id == this.id &&
          other.monthlyLimitPaise == this.monthlyLimitPaise &&
          other.currentPeriodStart == this.currentPeriodStart &&
          other.alertThreshold75 == this.alertThreshold75 &&
          other.alertThreshold90 == this.alertThreshold90 &&
          other.alertThreshold100 == this.alertThreshold100);
}

class BudgetSettingsCompanion extends UpdateCompanion<BudgetSetting> {
  final Value<int> id;
  final Value<int?> monthlyLimitPaise;
  final Value<DateTime?> currentPeriodStart;
  final Value<int> alertThreshold75;
  final Value<int> alertThreshold90;
  final Value<int> alertThreshold100;
  const BudgetSettingsCompanion({
    this.id = const Value.absent(),
    this.monthlyLimitPaise = const Value.absent(),
    this.currentPeriodStart = const Value.absent(),
    this.alertThreshold75 = const Value.absent(),
    this.alertThreshold90 = const Value.absent(),
    this.alertThreshold100 = const Value.absent(),
  });
  BudgetSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.monthlyLimitPaise = const Value.absent(),
    this.currentPeriodStart = const Value.absent(),
    this.alertThreshold75 = const Value.absent(),
    this.alertThreshold90 = const Value.absent(),
    this.alertThreshold100 = const Value.absent(),
  });
  static Insertable<BudgetSetting> custom({
    Expression<int>? id,
    Expression<int>? monthlyLimitPaise,
    Expression<DateTime>? currentPeriodStart,
    Expression<int>? alertThreshold75,
    Expression<int>? alertThreshold90,
    Expression<int>? alertThreshold100,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthlyLimitPaise != null) 'monthly_limit_paise': monthlyLimitPaise,
      if (currentPeriodStart != null)
        'current_period_start': currentPeriodStart,
      if (alertThreshold75 != null) 'alert_threshold75': alertThreshold75,
      if (alertThreshold90 != null) 'alert_threshold90': alertThreshold90,
      if (alertThreshold100 != null) 'alert_threshold100': alertThreshold100,
    });
  }

  BudgetSettingsCompanion copyWith({
    Value<int>? id,
    Value<int?>? monthlyLimitPaise,
    Value<DateTime?>? currentPeriodStart,
    Value<int>? alertThreshold75,
    Value<int>? alertThreshold90,
    Value<int>? alertThreshold100,
  }) {
    return BudgetSettingsCompanion(
      id: id ?? this.id,
      monthlyLimitPaise: monthlyLimitPaise ?? this.monthlyLimitPaise,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      alertThreshold75: alertThreshold75 ?? this.alertThreshold75,
      alertThreshold90: alertThreshold90 ?? this.alertThreshold90,
      alertThreshold100: alertThreshold100 ?? this.alertThreshold100,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthlyLimitPaise.present) {
      map['monthly_limit_paise'] = Variable<int>(monthlyLimitPaise.value);
    }
    if (currentPeriodStart.present) {
      map['current_period_start'] = Variable<DateTime>(
        currentPeriodStart.value,
      );
    }
    if (alertThreshold75.present) {
      map['alert_threshold75'] = Variable<int>(alertThreshold75.value);
    }
    if (alertThreshold90.present) {
      map['alert_threshold90'] = Variable<int>(alertThreshold90.value);
    }
    if (alertThreshold100.present) {
      map['alert_threshold100'] = Variable<int>(alertThreshold100.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetSettingsCompanion(')
          ..write('id: $id, ')
          ..write('monthlyLimitPaise: $monthlyLimitPaise, ')
          ..write('currentPeriodStart: $currentPeriodStart, ')
          ..write('alertThreshold75: $alertThreshold75, ')
          ..write('alertThreshold90: $alertThreshold90, ')
          ..write('alertThreshold100: $alertThreshold100')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetsTable extends CategoryBudgets
    with TableInfo<$CategoryBudgetsTable, CategoryBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitPaiseMeta = const VerificationMeta(
    'limitPaise',
  );
  @override
  late final GeneratedColumn<int> limitPaise = GeneratedColumn<int>(
    'limit_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, category, limitPaise];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('limit_paise')) {
      context.handle(
        _limitPaiseMeta,
        limitPaise.isAcceptableOrUnknown(data['limit_paise']!, _limitPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_limitPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      limitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_paise'],
      )!,
    );
  }

  @override
  $CategoryBudgetsTable createAlias(String alias) {
    return $CategoryBudgetsTable(attachedDatabase, alias);
  }
}

class CategoryBudget extends DataClass implements Insertable<CategoryBudget> {
  final int id;
  final String category;
  final int limitPaise;
  const CategoryBudget({
    required this.id,
    required this.category,
    required this.limitPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['limit_paise'] = Variable<int>(limitPaise);
    return map;
  }

  CategoryBudgetsCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetsCompanion(
      id: Value(id),
      category: Value(category),
      limitPaise: Value(limitPaise),
    );
  }

  factory CategoryBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryBudget(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      limitPaise: serializer.fromJson<int>(json['limitPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'limitPaise': serializer.toJson<int>(limitPaise),
    };
  }

  CategoryBudget copyWith({int? id, String? category, int? limitPaise}) =>
      CategoryBudget(
        id: id ?? this.id,
        category: category ?? this.category,
        limitPaise: limitPaise ?? this.limitPaise,
      );
  CategoryBudget copyWithCompanion(CategoryBudgetsCompanion data) {
    return CategoryBudget(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      limitPaise: data.limitPaise.present
          ? data.limitPaise.value
          : this.limitPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudget(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('limitPaise: $limitPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, limitPaise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryBudget &&
          other.id == this.id &&
          other.category == this.category &&
          other.limitPaise == this.limitPaise);
}

class CategoryBudgetsCompanion extends UpdateCompanion<CategoryBudget> {
  final Value<int> id;
  final Value<String> category;
  final Value<int> limitPaise;
  const CategoryBudgetsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.limitPaise = const Value.absent(),
  });
  CategoryBudgetsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required int limitPaise,
  }) : category = Value(category),
       limitPaise = Value(limitPaise);
  static Insertable<CategoryBudget> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<int>? limitPaise,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (limitPaise != null) 'limit_paise': limitPaise,
    });
  }

  CategoryBudgetsCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<int>? limitPaise,
  }) {
    return CategoryBudgetsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      limitPaise: limitPaise ?? this.limitPaise,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (limitPaise.present) {
      map['limit_paise'] = Variable<int>(limitPaise.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('limitPaise: $limitPaise')
          ..write(')'))
        .toString();
  }
}

class $BudgetAlertCrossingsTable extends BudgetAlertCrossings
    with TableInfo<$BudgetAlertCrossingsTable, BudgetAlertCrossing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetAlertCrossingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _budgetKeyMeta = const VerificationMeta(
    'budgetKey',
  );
  @override
  late final GeneratedColumn<String> budgetKey = GeneratedColumn<String>(
    'budget_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<String> threshold = GeneratedColumn<String>(
    'threshold',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, budgetKey, threshold, periodStart];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_alert_crossings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetAlertCrossing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('budget_key')) {
      context.handle(
        _budgetKeyMeta,
        budgetKey.isAcceptableOrUnknown(data['budget_key']!, _budgetKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetKeyMeta);
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetAlertCrossing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetAlertCrossing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      budgetKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_key'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}threshold'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
    );
  }

  @override
  $BudgetAlertCrossingsTable createAlias(String alias) {
    return $BudgetAlertCrossingsTable(attachedDatabase, alias);
  }
}

class BudgetAlertCrossing extends DataClass
    implements Insertable<BudgetAlertCrossing> {
  final int id;
  final String budgetKey;
  final String threshold;
  final DateTime periodStart;
  const BudgetAlertCrossing({
    required this.id,
    required this.budgetKey,
    required this.threshold,
    required this.periodStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['budget_key'] = Variable<String>(budgetKey);
    map['threshold'] = Variable<String>(threshold);
    map['period_start'] = Variable<DateTime>(periodStart);
    return map;
  }

  BudgetAlertCrossingsCompanion toCompanion(bool nullToAbsent) {
    return BudgetAlertCrossingsCompanion(
      id: Value(id),
      budgetKey: Value(budgetKey),
      threshold: Value(threshold),
      periodStart: Value(periodStart),
    );
  }

  factory BudgetAlertCrossing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetAlertCrossing(
      id: serializer.fromJson<int>(json['id']),
      budgetKey: serializer.fromJson<String>(json['budgetKey']),
      threshold: serializer.fromJson<String>(json['threshold']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'budgetKey': serializer.toJson<String>(budgetKey),
      'threshold': serializer.toJson<String>(threshold),
      'periodStart': serializer.toJson<DateTime>(periodStart),
    };
  }

  BudgetAlertCrossing copyWith({
    int? id,
    String? budgetKey,
    String? threshold,
    DateTime? periodStart,
  }) => BudgetAlertCrossing(
    id: id ?? this.id,
    budgetKey: budgetKey ?? this.budgetKey,
    threshold: threshold ?? this.threshold,
    periodStart: periodStart ?? this.periodStart,
  );
  BudgetAlertCrossing copyWithCompanion(BudgetAlertCrossingsCompanion data) {
    return BudgetAlertCrossing(
      id: data.id.present ? data.id.value : this.id,
      budgetKey: data.budgetKey.present ? data.budgetKey.value : this.budgetKey,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAlertCrossing(')
          ..write('id: $id, ')
          ..write('budgetKey: $budgetKey, ')
          ..write('threshold: $threshold, ')
          ..write('periodStart: $periodStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, budgetKey, threshold, periodStart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetAlertCrossing &&
          other.id == this.id &&
          other.budgetKey == this.budgetKey &&
          other.threshold == this.threshold &&
          other.periodStart == this.periodStart);
}

class BudgetAlertCrossingsCompanion
    extends UpdateCompanion<BudgetAlertCrossing> {
  final Value<int> id;
  final Value<String> budgetKey;
  final Value<String> threshold;
  final Value<DateTime> periodStart;
  const BudgetAlertCrossingsCompanion({
    this.id = const Value.absent(),
    this.budgetKey = const Value.absent(),
    this.threshold = const Value.absent(),
    this.periodStart = const Value.absent(),
  });
  BudgetAlertCrossingsCompanion.insert({
    this.id = const Value.absent(),
    required String budgetKey,
    required String threshold,
    required DateTime periodStart,
  }) : budgetKey = Value(budgetKey),
       threshold = Value(threshold),
       periodStart = Value(periodStart);
  static Insertable<BudgetAlertCrossing> custom({
    Expression<int>? id,
    Expression<String>? budgetKey,
    Expression<String>? threshold,
    Expression<DateTime>? periodStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetKey != null) 'budget_key': budgetKey,
      if (threshold != null) 'threshold': threshold,
      if (periodStart != null) 'period_start': periodStart,
    });
  }

  BudgetAlertCrossingsCompanion copyWith({
    Value<int>? id,
    Value<String>? budgetKey,
    Value<String>? threshold,
    Value<DateTime>? periodStart,
  }) {
    return BudgetAlertCrossingsCompanion(
      id: id ?? this.id,
      budgetKey: budgetKey ?? this.budgetKey,
      threshold: threshold ?? this.threshold,
      periodStart: periodStart ?? this.periodStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (budgetKey.present) {
      map['budget_key'] = Variable<String>(budgetKey.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<String>(threshold.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAlertCrossingsCompanion(')
          ..write('id: $id, ')
          ..write('budgetKey: $budgetKey, ')
          ..write('threshold: $threshold, ')
          ..write('periodStart: $periodStart')
          ..write(')'))
        .toString();
  }
}

class $RecoveryLinksTable extends RecoveryLinks
    with TableInfo<$RecoveryLinksTable, RecoveryLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveryLinksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _creditTransactionIdMeta =
      const VerificationMeta('creditTransactionId');
  @override
  late final GeneratedColumn<int> creditTransactionId = GeneratedColumn<int>(
    'credit_transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recoverableTransactionIdMeta =
      const VerificationMeta('recoverableTransactionId');
  @override
  late final GeneratedColumn<int> recoverableTransactionId =
      GeneratedColumn<int>(
        'recoverable_transaction_id',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    creditTransactionId,
    recoverableTransactionId,
    amountPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recovery_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoveryLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('credit_transaction_id')) {
      context.handle(
        _creditTransactionIdMeta,
        creditTransactionId.isAcceptableOrUnknown(
          data['credit_transaction_id']!,
          _creditTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditTransactionIdMeta);
    }
    if (data.containsKey('recoverable_transaction_id')) {
      context.handle(
        _recoverableTransactionIdMeta,
        recoverableTransactionId.isAcceptableOrUnknown(
          data['recoverable_transaction_id']!,
          _recoverableTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoverableTransactionIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      creditTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_transaction_id'],
      )!,
      recoverableTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recoverable_transaction_id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
    );
  }

  @override
  $RecoveryLinksTable createAlias(String alias) {
    return $RecoveryLinksTable(attachedDatabase, alias);
  }
}

class RecoveryLink extends DataClass implements Insertable<RecoveryLink> {
  final int id;
  final int creditTransactionId;
  final int recoverableTransactionId;
  final int amountPaise;
  const RecoveryLink({
    required this.id,
    required this.creditTransactionId,
    required this.recoverableTransactionId,
    required this.amountPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['credit_transaction_id'] = Variable<int>(creditTransactionId);
    map['recoverable_transaction_id'] = Variable<int>(recoverableTransactionId);
    map['amount_paise'] = Variable<int>(amountPaise);
    return map;
  }

  RecoveryLinksCompanion toCompanion(bool nullToAbsent) {
    return RecoveryLinksCompanion(
      id: Value(id),
      creditTransactionId: Value(creditTransactionId),
      recoverableTransactionId: Value(recoverableTransactionId),
      amountPaise: Value(amountPaise),
    );
  }

  factory RecoveryLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryLink(
      id: serializer.fromJson<int>(json['id']),
      creditTransactionId: serializer.fromJson<int>(
        json['creditTransactionId'],
      ),
      recoverableTransactionId: serializer.fromJson<int>(
        json['recoverableTransactionId'],
      ),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'creditTransactionId': serializer.toJson<int>(creditTransactionId),
      'recoverableTransactionId': serializer.toJson<int>(
        recoverableTransactionId,
      ),
      'amountPaise': serializer.toJson<int>(amountPaise),
    };
  }

  RecoveryLink copyWith({
    int? id,
    int? creditTransactionId,
    int? recoverableTransactionId,
    int? amountPaise,
  }) => RecoveryLink(
    id: id ?? this.id,
    creditTransactionId: creditTransactionId ?? this.creditTransactionId,
    recoverableTransactionId:
        recoverableTransactionId ?? this.recoverableTransactionId,
    amountPaise: amountPaise ?? this.amountPaise,
  );
  RecoveryLink copyWithCompanion(RecoveryLinksCompanion data) {
    return RecoveryLink(
      id: data.id.present ? data.id.value : this.id,
      creditTransactionId: data.creditTransactionId.present
          ? data.creditTransactionId.value
          : this.creditTransactionId,
      recoverableTransactionId: data.recoverableTransactionId.present
          ? data.recoverableTransactionId.value
          : this.recoverableTransactionId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryLink(')
          ..write('id: $id, ')
          ..write('creditTransactionId: $creditTransactionId, ')
          ..write('recoverableTransactionId: $recoverableTransactionId, ')
          ..write('amountPaise: $amountPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    creditTransactionId,
    recoverableTransactionId,
    amountPaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryLink &&
          other.id == this.id &&
          other.creditTransactionId == this.creditTransactionId &&
          other.recoverableTransactionId == this.recoverableTransactionId &&
          other.amountPaise == this.amountPaise);
}

class RecoveryLinksCompanion extends UpdateCompanion<RecoveryLink> {
  final Value<int> id;
  final Value<int> creditTransactionId;
  final Value<int> recoverableTransactionId;
  final Value<int> amountPaise;
  const RecoveryLinksCompanion({
    this.id = const Value.absent(),
    this.creditTransactionId = const Value.absent(),
    this.recoverableTransactionId = const Value.absent(),
    this.amountPaise = const Value.absent(),
  });
  RecoveryLinksCompanion.insert({
    this.id = const Value.absent(),
    required int creditTransactionId,
    required int recoverableTransactionId,
    required int amountPaise,
  }) : creditTransactionId = Value(creditTransactionId),
       recoverableTransactionId = Value(recoverableTransactionId),
       amountPaise = Value(amountPaise);
  static Insertable<RecoveryLink> custom({
    Expression<int>? id,
    Expression<int>? creditTransactionId,
    Expression<int>? recoverableTransactionId,
    Expression<int>? amountPaise,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creditTransactionId != null)
        'credit_transaction_id': creditTransactionId,
      if (recoverableTransactionId != null)
        'recoverable_transaction_id': recoverableTransactionId,
      if (amountPaise != null) 'amount_paise': amountPaise,
    });
  }

  RecoveryLinksCompanion copyWith({
    Value<int>? id,
    Value<int>? creditTransactionId,
    Value<int>? recoverableTransactionId,
    Value<int>? amountPaise,
  }) {
    return RecoveryLinksCompanion(
      id: id ?? this.id,
      creditTransactionId: creditTransactionId ?? this.creditTransactionId,
      recoverableTransactionId:
          recoverableTransactionId ?? this.recoverableTransactionId,
      amountPaise: amountPaise ?? this.amountPaise,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (creditTransactionId.present) {
      map['credit_transaction_id'] = Variable<int>(creditTransactionId.value);
    }
    if (recoverableTransactionId.present) {
      map['recoverable_transaction_id'] = Variable<int>(
        recoverableTransactionId.value,
      );
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryLinksCompanion(')
          ..write('id: $id, ')
          ..write('creditTransactionId: $creditTransactionId, ')
          ..write('recoverableTransactionId: $recoverableTransactionId, ')
          ..write('amountPaise: $amountPaise')
          ..write(')'))
        .toString();
  }
}

class $RecoverablePersonsTable extends RecoverablePersons
    with TableInfo<$RecoverablePersonsTable, RecoverablePerson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoverablePersonsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, lastUsedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recoverable_persons';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoverablePerson> instance, {
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
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoverablePerson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoverablePerson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $RecoverablePersonsTable createAlias(String alias) {
    return $RecoverablePersonsTable(attachedDatabase, alias);
  }
}

class RecoverablePerson extends DataClass
    implements Insertable<RecoverablePerson> {
  final int id;
  final String name;
  final DateTime lastUsedAt;
  const RecoverablePerson({
    required this.id,
    required this.name,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  RecoverablePersonsCompanion toCompanion(bool nullToAbsent) {
    return RecoverablePersonsCompanion(
      id: Value(id),
      name: Value(name),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory RecoverablePerson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoverablePerson(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  RecoverablePerson copyWith({int? id, String? name, DateTime? lastUsedAt}) =>
      RecoverablePerson(
        id: id ?? this.id,
        name: name ?? this.name,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      );
  RecoverablePerson copyWithCompanion(RecoverablePersonsCompanion data) {
    return RecoverablePerson(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoverablePerson(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoverablePerson &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastUsedAt == this.lastUsedAt);
}

class RecoverablePersonsCompanion extends UpdateCompanion<RecoverablePerson> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> lastUsedAt;
  const RecoverablePersonsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  RecoverablePersonsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime lastUsedAt,
  }) : name = Value(name),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<RecoverablePerson> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  RecoverablePersonsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? lastUsedAt,
  }) {
    return RecoverablePersonsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
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
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoverablePersonsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }
}

class $MerchantsTable extends Merchants
    with TableInfo<$MerchantsTable, Merchant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _rawNameMeta = const VerificationMeta(
    'rawName',
  );
  @override
  late final GeneratedColumn<String> rawName = GeneratedColumn<String>(
    'raw_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultCategoryMeta = const VerificationMeta(
    'defaultCategory',
  );
  @override
  late final GeneratedColumn<String> defaultCategory = GeneratedColumn<String>(
    'default_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isUserCustomizedMeta = const VerificationMeta(
    'isUserCustomized',
  );
  @override
  late final GeneratedColumn<bool> isUserCustomized = GeneratedColumn<bool>(
    'is_user_customized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user_customized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawName,
    displayName,
    defaultCategory,
    isUserCustomized,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Merchant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_name')) {
      context.handle(
        _rawNameMeta,
        rawName.isAcceptableOrUnknown(data['raw_name']!, _rawNameMeta),
      );
    } else if (isInserting) {
      context.missing(_rawNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('default_category')) {
      context.handle(
        _defaultCategoryMeta,
        defaultCategory.isAcceptableOrUnknown(
          data['default_category']!,
          _defaultCategoryMeta,
        ),
      );
    }
    if (data.containsKey('is_user_customized')) {
      context.handle(
        _isUserCustomizedMeta,
        isUserCustomized.isAcceptableOrUnknown(
          data['is_user_customized']!,
          _isUserCustomizedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Merchant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Merchant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      defaultCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_category'],
      ),
      isUserCustomized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user_customized'],
      )!,
    );
  }

  @override
  $MerchantsTable createAlias(String alias) {
    return $MerchantsTable(attachedDatabase, alias);
  }
}

class Merchant extends DataClass implements Insertable<Merchant> {
  final int id;
  final String rawName;
  final String? displayName;
  final String? defaultCategory;
  final bool isUserCustomized;
  const Merchant({
    required this.id,
    required this.rawName,
    this.displayName,
    this.defaultCategory,
    required this.isUserCustomized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_name'] = Variable<String>(rawName);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || defaultCategory != null) {
      map['default_category'] = Variable<String>(defaultCategory);
    }
    map['is_user_customized'] = Variable<bool>(isUserCustomized);
    return map;
  }

  MerchantsCompanion toCompanion(bool nullToAbsent) {
    return MerchantsCompanion(
      id: Value(id),
      rawName: Value(rawName),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      defaultCategory: defaultCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultCategory),
      isUserCustomized: Value(isUserCustomized),
    );
  }

  factory Merchant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Merchant(
      id: serializer.fromJson<int>(json['id']),
      rawName: serializer.fromJson<String>(json['rawName']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      defaultCategory: serializer.fromJson<String?>(json['defaultCategory']),
      isUserCustomized: serializer.fromJson<bool>(json['isUserCustomized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawName': serializer.toJson<String>(rawName),
      'displayName': serializer.toJson<String?>(displayName),
      'defaultCategory': serializer.toJson<String?>(defaultCategory),
      'isUserCustomized': serializer.toJson<bool>(isUserCustomized),
    };
  }

  Merchant copyWith({
    int? id,
    String? rawName,
    Value<String?> displayName = const Value.absent(),
    Value<String?> defaultCategory = const Value.absent(),
    bool? isUserCustomized,
  }) => Merchant(
    id: id ?? this.id,
    rawName: rawName ?? this.rawName,
    displayName: displayName.present ? displayName.value : this.displayName,
    defaultCategory: defaultCategory.present
        ? defaultCategory.value
        : this.defaultCategory,
    isUserCustomized: isUserCustomized ?? this.isUserCustomized,
  );
  Merchant copyWithCompanion(MerchantsCompanion data) {
    return Merchant(
      id: data.id.present ? data.id.value : this.id,
      rawName: data.rawName.present ? data.rawName.value : this.rawName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      defaultCategory: data.defaultCategory.present
          ? data.defaultCategory.value
          : this.defaultCategory,
      isUserCustomized: data.isUserCustomized.present
          ? data.isUserCustomized.value
          : this.isUserCustomized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Merchant(')
          ..write('id: $id, ')
          ..write('rawName: $rawName, ')
          ..write('displayName: $displayName, ')
          ..write('defaultCategory: $defaultCategory, ')
          ..write('isUserCustomized: $isUserCustomized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rawName, displayName, defaultCategory, isUserCustomized);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Merchant &&
          other.id == this.id &&
          other.rawName == this.rawName &&
          other.displayName == this.displayName &&
          other.defaultCategory == this.defaultCategory &&
          other.isUserCustomized == this.isUserCustomized);
}

class MerchantsCompanion extends UpdateCompanion<Merchant> {
  final Value<int> id;
  final Value<String> rawName;
  final Value<String?> displayName;
  final Value<String?> defaultCategory;
  final Value<bool> isUserCustomized;
  const MerchantsCompanion({
    this.id = const Value.absent(),
    this.rawName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.defaultCategory = const Value.absent(),
    this.isUserCustomized = const Value.absent(),
  });
  MerchantsCompanion.insert({
    this.id = const Value.absent(),
    required String rawName,
    this.displayName = const Value.absent(),
    this.defaultCategory = const Value.absent(),
    this.isUserCustomized = const Value.absent(),
  }) : rawName = Value(rawName);
  static Insertable<Merchant> custom({
    Expression<int>? id,
    Expression<String>? rawName,
    Expression<String>? displayName,
    Expression<String>? defaultCategory,
    Expression<bool>? isUserCustomized,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawName != null) 'raw_name': rawName,
      if (displayName != null) 'display_name': displayName,
      if (defaultCategory != null) 'default_category': defaultCategory,
      if (isUserCustomized != null) 'is_user_customized': isUserCustomized,
    });
  }

  MerchantsCompanion copyWith({
    Value<int>? id,
    Value<String>? rawName,
    Value<String?>? displayName,
    Value<String?>? defaultCategory,
    Value<bool>? isUserCustomized,
  }) {
    return MerchantsCompanion(
      id: id ?? this.id,
      rawName: rawName ?? this.rawName,
      displayName: displayName ?? this.displayName,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      isUserCustomized: isUserCustomized ?? this.isUserCustomized,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawName.present) {
      map['raw_name'] = Variable<String>(rawName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (defaultCategory.present) {
      map['default_category'] = Variable<String>(defaultCategory.value);
    }
    if (isUserCustomized.present) {
      map['is_user_customized'] = Variable<bool>(isUserCustomized.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantsCompanion(')
          ..write('id: $id, ')
          ..write('rawName: $rawName, ')
          ..write('displayName: $displayName, ')
          ..write('defaultCategory: $defaultCategory, ')
          ..write('isUserCustomized: $isUserCustomized')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isBuiltIn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
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
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final bool isBuiltIn;
  const Category({
    required this.id,
    required this.name,
    required this.isBuiltIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      isBuiltIn: Value(isBuiltIn),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
    };
  }

  Category copyWith({int? id, String? name, bool? isBuiltIn}) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isBuiltIn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.isBuiltIn == this.isBuiltIn);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isBuiltIn;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isBuiltIn = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isBuiltIn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isBuiltIn,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
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
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({int? id, String? name}) =>
      Tag(id: id ?? this.id, name: name ?? this.name);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $CardTransactionTagsTable extends CardTransactionTags
    with TableInfo<$CardTransactionTagsTable, CardTransactionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardTransactionIdMeta = const VerificationMeta(
    'cardTransactionId',
  );
  @override
  late final GeneratedColumn<int> cardTransactionId = GeneratedColumn<int>(
    'card_transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardTransactionId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_transaction_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTransactionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_transaction_id')) {
      context.handle(
        _cardTransactionIdMeta,
        cardTransactionId.isAcceptableOrUnknown(
          data['card_transaction_id']!,
          _cardTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardTransactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardTransactionId, tagId};
  @override
  CardTransactionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTransactionTag(
      cardTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_transaction_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $CardTransactionTagsTable createAlias(String alias) {
    return $CardTransactionTagsTable(attachedDatabase, alias);
  }
}

class CardTransactionTag extends DataClass
    implements Insertable<CardTransactionTag> {
  final int cardTransactionId;
  final int tagId;
  const CardTransactionTag({
    required this.cardTransactionId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_transaction_id'] = Variable<int>(cardTransactionId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  CardTransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return CardTransactionTagsCompanion(
      cardTransactionId: Value(cardTransactionId),
      tagId: Value(tagId),
    );
  }

  factory CardTransactionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTransactionTag(
      cardTransactionId: serializer.fromJson<int>(json['cardTransactionId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardTransactionId': serializer.toJson<int>(cardTransactionId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  CardTransactionTag copyWith({int? cardTransactionId, int? tagId}) =>
      CardTransactionTag(
        cardTransactionId: cardTransactionId ?? this.cardTransactionId,
        tagId: tagId ?? this.tagId,
      );
  CardTransactionTag copyWithCompanion(CardTransactionTagsCompanion data) {
    return CardTransactionTag(
      cardTransactionId: data.cardTransactionId.present
          ? data.cardTransactionId.value
          : this.cardTransactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTransactionTag(')
          ..write('cardTransactionId: $cardTransactionId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardTransactionId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTransactionTag &&
          other.cardTransactionId == this.cardTransactionId &&
          other.tagId == this.tagId);
}

class CardTransactionTagsCompanion extends UpdateCompanion<CardTransactionTag> {
  final Value<int> cardTransactionId;
  final Value<int> tagId;
  final Value<int> rowid;
  const CardTransactionTagsCompanion({
    this.cardTransactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTransactionTagsCompanion.insert({
    required int cardTransactionId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : cardTransactionId = Value(cardTransactionId),
       tagId = Value(tagId);
  static Insertable<CardTransactionTag> custom({
    Expression<int>? cardTransactionId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardTransactionId != null) 'card_transaction_id': cardTransactionId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTransactionTagsCompanion copyWith({
    Value<int>? cardTransactionId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return CardTransactionTagsCompanion(
      cardTransactionId: cardTransactionId ?? this.cardTransactionId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardTransactionId.present) {
      map['card_transaction_id'] = Variable<int>(cardTransactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTransactionTagsCompanion(')
          ..write('cardTransactionId: $cardTransactionId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MerchantDefaultTagsTable extends MerchantDefaultTags
    with TableInfo<$MerchantDefaultTagsTable, MerchantDefaultTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantDefaultTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _merchantIdMeta = const VerificationMeta(
    'merchantId',
  );
  @override
  late final GeneratedColumn<int> merchantId = GeneratedColumn<int>(
    'merchant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [merchantId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_default_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantDefaultTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('merchant_id')) {
      context.handle(
        _merchantIdMeta,
        merchantId.isAcceptableOrUnknown(data['merchant_id']!, _merchantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {merchantId, tagId};
  @override
  MerchantDefaultTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantDefaultTag(
      merchantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merchant_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $MerchantDefaultTagsTable createAlias(String alias) {
    return $MerchantDefaultTagsTable(attachedDatabase, alias);
  }
}

class MerchantDefaultTag extends DataClass
    implements Insertable<MerchantDefaultTag> {
  final int merchantId;
  final int tagId;
  const MerchantDefaultTag({required this.merchantId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['merchant_id'] = Variable<int>(merchantId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  MerchantDefaultTagsCompanion toCompanion(bool nullToAbsent) {
    return MerchantDefaultTagsCompanion(
      merchantId: Value(merchantId),
      tagId: Value(tagId),
    );
  }

  factory MerchantDefaultTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantDefaultTag(
      merchantId: serializer.fromJson<int>(json['merchantId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'merchantId': serializer.toJson<int>(merchantId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  MerchantDefaultTag copyWith({int? merchantId, int? tagId}) =>
      MerchantDefaultTag(
        merchantId: merchantId ?? this.merchantId,
        tagId: tagId ?? this.tagId,
      );
  MerchantDefaultTag copyWithCompanion(MerchantDefaultTagsCompanion data) {
    return MerchantDefaultTag(
      merchantId: data.merchantId.present
          ? data.merchantId.value
          : this.merchantId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantDefaultTag(')
          ..write('merchantId: $merchantId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(merchantId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantDefaultTag &&
          other.merchantId == this.merchantId &&
          other.tagId == this.tagId);
}

class MerchantDefaultTagsCompanion extends UpdateCompanion<MerchantDefaultTag> {
  final Value<int> merchantId;
  final Value<int> tagId;
  final Value<int> rowid;
  const MerchantDefaultTagsCompanion({
    this.merchantId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantDefaultTagsCompanion.insert({
    required int merchantId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : merchantId = Value(merchantId),
       tagId = Value(tagId);
  static Insertable<MerchantDefaultTag> custom({
    Expression<int>? merchantId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (merchantId != null) 'merchant_id': merchantId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantDefaultTagsCompanion copyWith({
    Value<int>? merchantId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return MerchantDefaultTagsCompanion(
      merchantId: merchantId ?? this.merchantId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (merchantId.present) {
      map['merchant_id'] = Variable<int>(merchantId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantDefaultTagsCompanion(')
          ..write('merchantId: $merchantId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionLinksTable extends TransactionLinks
    with TableInfo<$TransactionLinksTable, TransactionLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionLinksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardTransactionIdMeta = const VerificationMeta(
    'cardTransactionId',
  );
  @override
  late final GeneratedColumn<int> cardTransactionId = GeneratedColumn<int>(
    'card_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankAccountTransactionIdMeta =
      const VerificationMeta('bankAccountTransactionId');
  @override
  late final GeneratedColumn<int> bankAccountTransactionId =
      GeneratedColumn<int>(
        'bank_account_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _linkedCardTransactionIdMeta =
      const VerificationMeta('linkedCardTransactionId');
  @override
  late final GeneratedColumn<int> linkedCardTransactionId =
      GeneratedColumn<int>(
        'linked_card_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _linkedBankAccountTransactionIdMeta =
      const VerificationMeta('linkedBankAccountTransactionId');
  @override
  late final GeneratedColumn<int> linkedBankAccountTransactionId =
      GeneratedColumn<int>(
        'linked_bank_account_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    cardTransactionId,
    bankAccountTransactionId,
    linkedCardTransactionId,
    linkedBankAccountTransactionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('card_transaction_id')) {
      context.handle(
        _cardTransactionIdMeta,
        cardTransactionId.isAcceptableOrUnknown(
          data['card_transaction_id']!,
          _cardTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('bank_account_transaction_id')) {
      context.handle(
        _bankAccountTransactionIdMeta,
        bankAccountTransactionId.isAcceptableOrUnknown(
          data['bank_account_transaction_id']!,
          _bankAccountTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_card_transaction_id')) {
      context.handle(
        _linkedCardTransactionIdMeta,
        linkedCardTransactionId.isAcceptableOrUnknown(
          data['linked_card_transaction_id']!,
          _linkedCardTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_bank_account_transaction_id')) {
      context.handle(
        _linkedBankAccountTransactionIdMeta,
        linkedBankAccountTransactionId.isAcceptableOrUnknown(
          data['linked_bank_account_transaction_id']!,
          _linkedBankAccountTransactionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      cardTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_transaction_id'],
      ),
      bankAccountTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_account_transaction_id'],
      ),
      linkedCardTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_card_transaction_id'],
      ),
      linkedBankAccountTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_bank_account_transaction_id'],
      ),
    );
  }

  @override
  $TransactionLinksTable createAlias(String alias) {
    return $TransactionLinksTable(attachedDatabase, alias);
  }
}

class TransactionLink extends DataClass implements Insertable<TransactionLink> {
  final int id;
  final String kind;
  final int? cardTransactionId;
  final int? bankAccountTransactionId;
  final int? linkedCardTransactionId;
  final int? linkedBankAccountTransactionId;
  const TransactionLink({
    required this.id,
    required this.kind,
    this.cardTransactionId,
    this.bankAccountTransactionId,
    this.linkedCardTransactionId,
    this.linkedBankAccountTransactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || cardTransactionId != null) {
      map['card_transaction_id'] = Variable<int>(cardTransactionId);
    }
    if (!nullToAbsent || bankAccountTransactionId != null) {
      map['bank_account_transaction_id'] = Variable<int>(
        bankAccountTransactionId,
      );
    }
    if (!nullToAbsent || linkedCardTransactionId != null) {
      map['linked_card_transaction_id'] = Variable<int>(
        linkedCardTransactionId,
      );
    }
    if (!nullToAbsent || linkedBankAccountTransactionId != null) {
      map['linked_bank_account_transaction_id'] = Variable<int>(
        linkedBankAccountTransactionId,
      );
    }
    return map;
  }

  TransactionLinksCompanion toCompanion(bool nullToAbsent) {
    return TransactionLinksCompanion(
      id: Value(id),
      kind: Value(kind),
      cardTransactionId: cardTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardTransactionId),
      bankAccountTransactionId: bankAccountTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountTransactionId),
      linkedCardTransactionId: linkedCardTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedCardTransactionId),
      linkedBankAccountTransactionId:
          linkedBankAccountTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedBankAccountTransactionId),
    );
  }

  factory TransactionLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionLink(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      cardTransactionId: serializer.fromJson<int?>(json['cardTransactionId']),
      bankAccountTransactionId: serializer.fromJson<int?>(
        json['bankAccountTransactionId'],
      ),
      linkedCardTransactionId: serializer.fromJson<int?>(
        json['linkedCardTransactionId'],
      ),
      linkedBankAccountTransactionId: serializer.fromJson<int?>(
        json['linkedBankAccountTransactionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'cardTransactionId': serializer.toJson<int?>(cardTransactionId),
      'bankAccountTransactionId': serializer.toJson<int?>(
        bankAccountTransactionId,
      ),
      'linkedCardTransactionId': serializer.toJson<int?>(
        linkedCardTransactionId,
      ),
      'linkedBankAccountTransactionId': serializer.toJson<int?>(
        linkedBankAccountTransactionId,
      ),
    };
  }

  TransactionLink copyWith({
    int? id,
    String? kind,
    Value<int?> cardTransactionId = const Value.absent(),
    Value<int?> bankAccountTransactionId = const Value.absent(),
    Value<int?> linkedCardTransactionId = const Value.absent(),
    Value<int?> linkedBankAccountTransactionId = const Value.absent(),
  }) => TransactionLink(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    cardTransactionId: cardTransactionId.present
        ? cardTransactionId.value
        : this.cardTransactionId,
    bankAccountTransactionId: bankAccountTransactionId.present
        ? bankAccountTransactionId.value
        : this.bankAccountTransactionId,
    linkedCardTransactionId: linkedCardTransactionId.present
        ? linkedCardTransactionId.value
        : this.linkedCardTransactionId,
    linkedBankAccountTransactionId: linkedBankAccountTransactionId.present
        ? linkedBankAccountTransactionId.value
        : this.linkedBankAccountTransactionId,
  );
  TransactionLink copyWithCompanion(TransactionLinksCompanion data) {
    return TransactionLink(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      cardTransactionId: data.cardTransactionId.present
          ? data.cardTransactionId.value
          : this.cardTransactionId,
      bankAccountTransactionId: data.bankAccountTransactionId.present
          ? data.bankAccountTransactionId.value
          : this.bankAccountTransactionId,
      linkedCardTransactionId: data.linkedCardTransactionId.present
          ? data.linkedCardTransactionId.value
          : this.linkedCardTransactionId,
      linkedBankAccountTransactionId:
          data.linkedBankAccountTransactionId.present
          ? data.linkedBankAccountTransactionId.value
          : this.linkedBankAccountTransactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionLink(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('cardTransactionId: $cardTransactionId, ')
          ..write('bankAccountTransactionId: $bankAccountTransactionId, ')
          ..write('linkedCardTransactionId: $linkedCardTransactionId, ')
          ..write(
            'linkedBankAccountTransactionId: $linkedBankAccountTransactionId',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    cardTransactionId,
    bankAccountTransactionId,
    linkedCardTransactionId,
    linkedBankAccountTransactionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionLink &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.cardTransactionId == this.cardTransactionId &&
          other.bankAccountTransactionId == this.bankAccountTransactionId &&
          other.linkedCardTransactionId == this.linkedCardTransactionId &&
          other.linkedBankAccountTransactionId ==
              this.linkedBankAccountTransactionId);
}

class TransactionLinksCompanion extends UpdateCompanion<TransactionLink> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int?> cardTransactionId;
  final Value<int?> bankAccountTransactionId;
  final Value<int?> linkedCardTransactionId;
  final Value<int?> linkedBankAccountTransactionId;
  const TransactionLinksCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.cardTransactionId = const Value.absent(),
    this.bankAccountTransactionId = const Value.absent(),
    this.linkedCardTransactionId = const Value.absent(),
    this.linkedBankAccountTransactionId = const Value.absent(),
  });
  TransactionLinksCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.cardTransactionId = const Value.absent(),
    this.bankAccountTransactionId = const Value.absent(),
    this.linkedCardTransactionId = const Value.absent(),
    this.linkedBankAccountTransactionId = const Value.absent(),
  }) : kind = Value(kind);
  static Insertable<TransactionLink> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? cardTransactionId,
    Expression<int>? bankAccountTransactionId,
    Expression<int>? linkedCardTransactionId,
    Expression<int>? linkedBankAccountTransactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (cardTransactionId != null) 'card_transaction_id': cardTransactionId,
      if (bankAccountTransactionId != null)
        'bank_account_transaction_id': bankAccountTransactionId,
      if (linkedCardTransactionId != null)
        'linked_card_transaction_id': linkedCardTransactionId,
      if (linkedBankAccountTransactionId != null)
        'linked_bank_account_transaction_id': linkedBankAccountTransactionId,
    });
  }

  TransactionLinksCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<int?>? cardTransactionId,
    Value<int?>? bankAccountTransactionId,
    Value<int?>? linkedCardTransactionId,
    Value<int?>? linkedBankAccountTransactionId,
  }) {
    return TransactionLinksCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      cardTransactionId: cardTransactionId ?? this.cardTransactionId,
      bankAccountTransactionId:
          bankAccountTransactionId ?? this.bankAccountTransactionId,
      linkedCardTransactionId:
          linkedCardTransactionId ?? this.linkedCardTransactionId,
      linkedBankAccountTransactionId:
          linkedBankAccountTransactionId ?? this.linkedBankAccountTransactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (cardTransactionId.present) {
      map['card_transaction_id'] = Variable<int>(cardTransactionId.value);
    }
    if (bankAccountTransactionId.present) {
      map['bank_account_transaction_id'] = Variable<int>(
        bankAccountTransactionId.value,
      );
    }
    if (linkedCardTransactionId.present) {
      map['linked_card_transaction_id'] = Variable<int>(
        linkedCardTransactionId.value,
      );
    }
    if (linkedBankAccountTransactionId.present) {
      map['linked_bank_account_transaction_id'] = Variable<int>(
        linkedBankAccountTransactionId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionLinksCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('cardTransactionId: $cardTransactionId, ')
          ..write('bankAccountTransactionId: $bankAccountTransactionId, ')
          ..write('linkedCardTransactionId: $linkedCardTransactionId, ')
          ..write(
            'linkedBankAccountTransactionId: $linkedBankAccountTransactionId',
          )
          ..write(')'))
        .toString();
  }
}

class $SmsSendersTable extends SmsSenders
    with TableInfo<$SmsSendersTable, SmsSender> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsSendersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, address, isBuiltIn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_senders';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmsSender> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsSender map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsSender(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
    );
  }

  @override
  $SmsSendersTable createAlias(String alias) {
    return $SmsSendersTable(attachedDatabase, alias);
  }
}

class SmsSender extends DataClass implements Insertable<SmsSender> {
  final int id;
  final String address;
  final bool isBuiltIn;
  const SmsSender({
    required this.id,
    required this.address,
    required this.isBuiltIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['address'] = Variable<String>(address);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    return map;
  }

  SmsSendersCompanion toCompanion(bool nullToAbsent) {
    return SmsSendersCompanion(
      id: Value(id),
      address: Value(address),
      isBuiltIn: Value(isBuiltIn),
    );
  }

  factory SmsSender.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsSender(
      id: serializer.fromJson<int>(json['id']),
      address: serializer.fromJson<String>(json['address']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'address': serializer.toJson<String>(address),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
    };
  }

  SmsSender copyWith({int? id, String? address, bool? isBuiltIn}) => SmsSender(
    id: id ?? this.id,
    address: address ?? this.address,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );
  SmsSender copyWithCompanion(SmsSendersCompanion data) {
    return SmsSender(
      id: data.id.present ? data.id.value : this.id,
      address: data.address.present ? data.address.value : this.address,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsSender(')
          ..write('id: $id, ')
          ..write('address: $address, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, address, isBuiltIn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsSender &&
          other.id == this.id &&
          other.address == this.address &&
          other.isBuiltIn == this.isBuiltIn);
}

class SmsSendersCompanion extends UpdateCompanion<SmsSender> {
  final Value<int> id;
  final Value<String> address;
  final Value<bool> isBuiltIn;
  const SmsSendersCompanion({
    this.id = const Value.absent(),
    this.address = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
  });
  SmsSendersCompanion.insert({
    this.id = const Value.absent(),
    required String address,
    this.isBuiltIn = const Value.absent(),
  }) : address = Value(address);
  static Insertable<SmsSender> custom({
    Expression<int>? id,
    Expression<String>? address,
    Expression<bool>? isBuiltIn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (address != null) 'address': address,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
    });
  }

  SmsSendersCompanion copyWith({
    Value<int>? id,
    Value<String>? address,
    Value<bool>? isBuiltIn,
  }) {
    return SmsSendersCompanion(
      id: id ?? this.id,
      address: address ?? this.address,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsSendersCompanion(')
          ..write('id: $id, ')
          ..write('address: $address, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CreditCardsTable creditCards = $CreditCardsTable(this);
  late final $BillingCyclesTable billingCycles = $BillingCyclesTable(this);
  late final $BankAccountsTable bankAccounts = $BankAccountsTable(this);
  late final $CardTransactionsTable cardTransactions = $CardTransactionsTable(
    this,
  );
  late final $CardTransactionReceiptsTable cardTransactionReceipts =
      $CardTransactionReceiptsTable(this);
  late final $BankAccountTransactionsTable bankAccountTransactions =
      $BankAccountTransactionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BudgetSettingsTable budgetSettings = $BudgetSettingsTable(this);
  late final $CategoryBudgetsTable categoryBudgets = $CategoryBudgetsTable(
    this,
  );
  late final $BudgetAlertCrossingsTable budgetAlertCrossings =
      $BudgetAlertCrossingsTable(this);
  late final $RecoveryLinksTable recoveryLinks = $RecoveryLinksTable(this);
  late final $RecoverablePersonsTable recoverablePersons =
      $RecoverablePersonsTable(this);
  late final $MerchantsTable merchants = $MerchantsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CardTransactionTagsTable cardTransactionTags =
      $CardTransactionTagsTable(this);
  late final $MerchantDefaultTagsTable merchantDefaultTags =
      $MerchantDefaultTagsTable(this);
  late final $TransactionLinksTable transactionLinks = $TransactionLinksTable(
    this,
  );
  late final $SmsSendersTable smsSenders = $SmsSendersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    creditCards,
    billingCycles,
    bankAccounts,
    cardTransactions,
    cardTransactionReceipts,
    bankAccountTransactions,
    appSettings,
    budgetSettings,
    categoryBudgets,
    budgetAlertCrossings,
    recoveryLinks,
    recoverablePersons,
    merchants,
    categories,
    tags,
    cardTransactionTags,
    merchantDefaultTags,
    transactionLinks,
    smsSenders,
  ];
}

typedef $$CreditCardsTableCreateCompanionBuilder =
    CreditCardsCompanion Function({
      Value<int> id,
      required String bank,
      required String lastFourDigits,
      required String nickname,
      Value<String?> network,
      Value<int?> creditLimitPaise,
      Value<int?> billDayOfMonth,
      Value<int?> dueDateOffsetDays,
      required int colorValue,
      required String iconName,
      Value<String?> notes,
      Value<bool> isArchived,
      required DateTime createdAt,
    });
typedef $$CreditCardsTableUpdateCompanionBuilder =
    CreditCardsCompanion Function({
      Value<int> id,
      Value<String> bank,
      Value<String> lastFourDigits,
      Value<String> nickname,
      Value<String?> network,
      Value<int?> creditLimitPaise,
      Value<int?> billDayOfMonth,
      Value<int?> dueDateOffsetDays,
      Value<int> colorValue,
      Value<String> iconName,
      Value<String?> notes,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });

class $$CreditCardsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableFilterComposer({
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

  ColumnFilters<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastFourDigits => $composableBuilder(
    column: $table.lastFourDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billDayOfMonth => $composableBuilder(
    column: $table.billDayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDateOffsetDays => $composableBuilder(
    column: $table.dueDateOffsetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CreditCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableOrderingComposer({
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

  ColumnOrderings<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastFourDigits => $composableBuilder(
    column: $table.lastFourDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billDayOfMonth => $composableBuilder(
    column: $table.billDayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDateOffsetDays => $composableBuilder(
    column: $table.dueDateOffsetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CreditCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bank =>
      $composableBuilder(column: $table.bank, builder: (column) => column);

  GeneratedColumn<String> get lastFourDigits => $composableBuilder(
    column: $table.lastFourDigits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billDayOfMonth => $composableBuilder(
    column: $table.billDayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDateOffsetDays => $composableBuilder(
    column: $table.dueDateOffsetDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CreditCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditCardsTable,
          CreditCard,
          $$CreditCardsTableFilterComposer,
          $$CreditCardsTableOrderingComposer,
          $$CreditCardsTableAnnotationComposer,
          $$CreditCardsTableCreateCompanionBuilder,
          $$CreditCardsTableUpdateCompanionBuilder,
          (
            CreditCard,
            BaseReferences<_$AppDatabase, $CreditCardsTable, CreditCard>,
          ),
          CreditCard,
          PrefetchHooks Function()
        > {
  $$CreditCardsTableTableManager(_$AppDatabase db, $CreditCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bank = const Value.absent(),
                Value<String> lastFourDigits = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String?> network = const Value.absent(),
                Value<int?> creditLimitPaise = const Value.absent(),
                Value<int?> billDayOfMonth = const Value.absent(),
                Value<int?> dueDateOffsetDays = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CreditCardsCompanion(
                id: id,
                bank: bank,
                lastFourDigits: lastFourDigits,
                nickname: nickname,
                network: network,
                creditLimitPaise: creditLimitPaise,
                billDayOfMonth: billDayOfMonth,
                dueDateOffsetDays: dueDateOffsetDays,
                colorValue: colorValue,
                iconName: iconName,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bank,
                required String lastFourDigits,
                required String nickname,
                Value<String?> network = const Value.absent(),
                Value<int?> creditLimitPaise = const Value.absent(),
                Value<int?> billDayOfMonth = const Value.absent(),
                Value<int?> dueDateOffsetDays = const Value.absent(),
                required int colorValue,
                required String iconName,
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
              }) => CreditCardsCompanion.insert(
                id: id,
                bank: bank,
                lastFourDigits: lastFourDigits,
                nickname: nickname,
                network: network,
                creditLimitPaise: creditLimitPaise,
                billDayOfMonth: billDayOfMonth,
                dueDateOffsetDays: dueDateOffsetDays,
                colorValue: colorValue,
                iconName: iconName,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CreditCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditCardsTable,
      CreditCard,
      $$CreditCardsTableFilterComposer,
      $$CreditCardsTableOrderingComposer,
      $$CreditCardsTableAnnotationComposer,
      $$CreditCardsTableCreateCompanionBuilder,
      $$CreditCardsTableUpdateCompanionBuilder,
      (
        CreditCard,
        BaseReferences<_$AppDatabase, $CreditCardsTable, CreditCard>,
      ),
      CreditCard,
      PrefetchHooks Function()
    >;
typedef $$BillingCyclesTableCreateCompanionBuilder =
    BillingCyclesCompanion Function({
      Value<int> id,
      required int creditCardId,
      required DateTime startDate,
      required DateTime endDate,
      Value<bool> billGenerated,
      Value<DateTime?> dueDate,
      Value<int> paymentsAppliedPaise,
    });
typedef $$BillingCyclesTableUpdateCompanionBuilder =
    BillingCyclesCompanion Function({
      Value<int> id,
      Value<int> creditCardId,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<bool> billGenerated,
      Value<DateTime?> dueDate,
      Value<int> paymentsAppliedPaise,
    });

class $$BillingCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $BillingCyclesTable> {
  $$BillingCyclesTableFilterComposer({
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

  ColumnFilters<int> get creditCardId => $composableBuilder(
    column: $table.creditCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get billGenerated => $composableBuilder(
    column: $table.billGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentsAppliedPaise => $composableBuilder(
    column: $table.paymentsAppliedPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillingCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $BillingCyclesTable> {
  $$BillingCyclesTableOrderingComposer({
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

  ColumnOrderings<int> get creditCardId => $composableBuilder(
    column: $table.creditCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get billGenerated => $composableBuilder(
    column: $table.billGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentsAppliedPaise => $composableBuilder(
    column: $table.paymentsAppliedPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillingCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillingCyclesTable> {
  $$BillingCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get creditCardId => $composableBuilder(
    column: $table.creditCardId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get billGenerated => $composableBuilder(
    column: $table.billGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get paymentsAppliedPaise => $composableBuilder(
    column: $table.paymentsAppliedPaise,
    builder: (column) => column,
  );
}

class $$BillingCyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillingCyclesTable,
          BillingCycle,
          $$BillingCyclesTableFilterComposer,
          $$BillingCyclesTableOrderingComposer,
          $$BillingCyclesTableAnnotationComposer,
          $$BillingCyclesTableCreateCompanionBuilder,
          $$BillingCyclesTableUpdateCompanionBuilder,
          (
            BillingCycle,
            BaseReferences<_$AppDatabase, $BillingCyclesTable, BillingCycle>,
          ),
          BillingCycle,
          PrefetchHooks Function()
        > {
  $$BillingCyclesTableTableManager(_$AppDatabase db, $BillingCyclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillingCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillingCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillingCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> creditCardId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<bool> billGenerated = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> paymentsAppliedPaise = const Value.absent(),
              }) => BillingCyclesCompanion(
                id: id,
                creditCardId: creditCardId,
                startDate: startDate,
                endDate: endDate,
                billGenerated: billGenerated,
                dueDate: dueDate,
                paymentsAppliedPaise: paymentsAppliedPaise,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int creditCardId,
                required DateTime startDate,
                required DateTime endDate,
                Value<bool> billGenerated = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> paymentsAppliedPaise = const Value.absent(),
              }) => BillingCyclesCompanion.insert(
                id: id,
                creditCardId: creditCardId,
                startDate: startDate,
                endDate: endDate,
                billGenerated: billGenerated,
                dueDate: dueDate,
                paymentsAppliedPaise: paymentsAppliedPaise,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillingCyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillingCyclesTable,
      BillingCycle,
      $$BillingCyclesTableFilterComposer,
      $$BillingCyclesTableOrderingComposer,
      $$BillingCyclesTableAnnotationComposer,
      $$BillingCyclesTableCreateCompanionBuilder,
      $$BillingCyclesTableUpdateCompanionBuilder,
      (
        BillingCycle,
        BaseReferences<_$AppDatabase, $BillingCyclesTable, BillingCycle>,
      ),
      BillingCycle,
      PrefetchHooks Function()
    >;
typedef $$BankAccountsTableCreateCompanionBuilder =
    BankAccountsCompanion Function({
      Value<int> id,
      required String bank,
      required String lastFourDigits,
      required String nickname,
      Value<int> openingBalancePaise,
      required int colorValue,
      required String iconName,
      Value<String?> notes,
      Value<bool> isArchived,
      required DateTime createdAt,
    });
typedef $$BankAccountsTableUpdateCompanionBuilder =
    BankAccountsCompanion Function({
      Value<int> id,
      Value<String> bank,
      Value<String> lastFourDigits,
      Value<String> nickname,
      Value<int> openingBalancePaise,
      Value<int> colorValue,
      Value<String> iconName,
      Value<String?> notes,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });

class $$BankAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableFilterComposer({
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

  ColumnFilters<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastFourDigits => $composableBuilder(
    column: $table.lastFourDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableOrderingComposer({
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

  ColumnOrderings<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastFourDigits => $composableBuilder(
    column: $table.lastFourDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bank =>
      $composableBuilder(column: $table.bank, builder: (column) => column);

  GeneratedColumn<String> get lastFourDigits => $composableBuilder(
    column: $table.lastFourDigits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BankAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankAccountsTable,
          BankAccount,
          $$BankAccountsTableFilterComposer,
          $$BankAccountsTableOrderingComposer,
          $$BankAccountsTableAnnotationComposer,
          $$BankAccountsTableCreateCompanionBuilder,
          $$BankAccountsTableUpdateCompanionBuilder,
          (
            BankAccount,
            BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>,
          ),
          BankAccount,
          PrefetchHooks Function()
        > {
  $$BankAccountsTableTableManager(_$AppDatabase db, $BankAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bank = const Value.absent(),
                Value<String> lastFourDigits = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int> openingBalancePaise = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BankAccountsCompanion(
                id: id,
                bank: bank,
                lastFourDigits: lastFourDigits,
                nickname: nickname,
                openingBalancePaise: openingBalancePaise,
                colorValue: colorValue,
                iconName: iconName,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bank,
                required String lastFourDigits,
                required String nickname,
                Value<int> openingBalancePaise = const Value.absent(),
                required int colorValue,
                required String iconName,
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
              }) => BankAccountsCompanion.insert(
                id: id,
                bank: bank,
                lastFourDigits: lastFourDigits,
                nickname: nickname,
                openingBalancePaise: openingBalancePaise,
                colorValue: colorValue,
                iconName: iconName,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankAccountsTable,
      BankAccount,
      $$BankAccountsTableFilterComposer,
      $$BankAccountsTableOrderingComposer,
      $$BankAccountsTableAnnotationComposer,
      $$BankAccountsTableCreateCompanionBuilder,
      $$BankAccountsTableUpdateCompanionBuilder,
      (
        BankAccount,
        BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>,
      ),
      BankAccount,
      PrefetchHooks Function()
    >;
typedef $$CardTransactionsTableCreateCompanionBuilder =
    CardTransactionsCompanion Function({
      Value<int> id,
      required int creditCardId,
      Value<int?> billingCycleId,
      required String kind,
      required int amountPaise,
      required String merchant,
      required DateTime transactionAt,
      required String source,
      Value<String?> rawSms,
      Value<String?> referenceNumber,
      Value<String?> category,
      Value<bool> isRecoverable,
      Value<String?> recoverablePerson,
      Value<bool> isReviewed,
      Value<String?> notes,
      Value<String?> location,
      required DateTime createdAt,
    });
typedef $$CardTransactionsTableUpdateCompanionBuilder =
    CardTransactionsCompanion Function({
      Value<int> id,
      Value<int> creditCardId,
      Value<int?> billingCycleId,
      Value<String> kind,
      Value<int> amountPaise,
      Value<String> merchant,
      Value<DateTime> transactionAt,
      Value<String> source,
      Value<String?> rawSms,
      Value<String?> referenceNumber,
      Value<String?> category,
      Value<bool> isRecoverable,
      Value<String?> recoverablePerson,
      Value<bool> isReviewed,
      Value<String?> notes,
      Value<String?> location,
      Value<DateTime> createdAt,
    });

class $$CardTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTransactionsTable> {
  $$CardTransactionsTableFilterComposer({
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

  ColumnFilters<int> get creditCardId => $composableBuilder(
    column: $table.creditCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingCycleId => $composableBuilder(
    column: $table.billingCycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionAt => $composableBuilder(
    column: $table.transactionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecoverable => $composableBuilder(
    column: $table.isRecoverable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recoverablePerson => $composableBuilder(
    column: $table.recoverablePerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTransactionsTable> {
  $$CardTransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get creditCardId => $composableBuilder(
    column: $table.creditCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingCycleId => $composableBuilder(
    column: $table.billingCycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionAt => $composableBuilder(
    column: $table.transactionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecoverable => $composableBuilder(
    column: $table.isRecoverable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recoverablePerson => $composableBuilder(
    column: $table.recoverablePerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTransactionsTable> {
  $$CardTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get creditCardId => $composableBuilder(
    column: $table.creditCardId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingCycleId => $composableBuilder(
    column: $table.billingCycleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionAt => $composableBuilder(
    column: $table.transactionAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get rawSms =>
      $composableBuilder(column: $table.rawSms, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isRecoverable => $composableBuilder(
    column: $table.isRecoverable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recoverablePerson => $composableBuilder(
    column: $table.recoverablePerson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CardTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTransactionsTable,
          CardTransaction,
          $$CardTransactionsTableFilterComposer,
          $$CardTransactionsTableOrderingComposer,
          $$CardTransactionsTableAnnotationComposer,
          $$CardTransactionsTableCreateCompanionBuilder,
          $$CardTransactionsTableUpdateCompanionBuilder,
          (
            CardTransaction,
            BaseReferences<
              _$AppDatabase,
              $CardTransactionsTable,
              CardTransaction
            >,
          ),
          CardTransaction,
          PrefetchHooks Function()
        > {
  $$CardTransactionsTableTableManager(
    _$AppDatabase db,
    $CardTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> creditCardId = const Value.absent(),
                Value<int?> billingCycleId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<DateTime> transactionAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> rawSms = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isRecoverable = const Value.absent(),
                Value<String?> recoverablePerson = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CardTransactionsCompanion(
                id: id,
                creditCardId: creditCardId,
                billingCycleId: billingCycleId,
                kind: kind,
                amountPaise: amountPaise,
                merchant: merchant,
                transactionAt: transactionAt,
                source: source,
                rawSms: rawSms,
                referenceNumber: referenceNumber,
                category: category,
                isRecoverable: isRecoverable,
                recoverablePerson: recoverablePerson,
                isReviewed: isReviewed,
                notes: notes,
                location: location,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int creditCardId,
                Value<int?> billingCycleId = const Value.absent(),
                required String kind,
                required int amountPaise,
                required String merchant,
                required DateTime transactionAt,
                required String source,
                Value<String?> rawSms = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isRecoverable = const Value.absent(),
                Value<String?> recoverablePerson = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required DateTime createdAt,
              }) => CardTransactionsCompanion.insert(
                id: id,
                creditCardId: creditCardId,
                billingCycleId: billingCycleId,
                kind: kind,
                amountPaise: amountPaise,
                merchant: merchant,
                transactionAt: transactionAt,
                source: source,
                rawSms: rawSms,
                referenceNumber: referenceNumber,
                category: category,
                isRecoverable: isRecoverable,
                recoverablePerson: recoverablePerson,
                isReviewed: isReviewed,
                notes: notes,
                location: location,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTransactionsTable,
      CardTransaction,
      $$CardTransactionsTableFilterComposer,
      $$CardTransactionsTableOrderingComposer,
      $$CardTransactionsTableAnnotationComposer,
      $$CardTransactionsTableCreateCompanionBuilder,
      $$CardTransactionsTableUpdateCompanionBuilder,
      (
        CardTransaction,
        BaseReferences<_$AppDatabase, $CardTransactionsTable, CardTransaction>,
      ),
      CardTransaction,
      PrefetchHooks Function()
    >;
typedef $$CardTransactionReceiptsTableCreateCompanionBuilder =
    CardTransactionReceiptsCompanion Function({
      Value<int> id,
      required int cardTransactionId,
      required String filePath,
      required DateTime createdAt,
    });
typedef $$CardTransactionReceiptsTableUpdateCompanionBuilder =
    CardTransactionReceiptsCompanion Function({
      Value<int> id,
      Value<int> cardTransactionId,
      Value<String> filePath,
      Value<DateTime> createdAt,
    });

class $$CardTransactionReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTransactionReceiptsTable> {
  $$CardTransactionReceiptsTableFilterComposer({
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

  ColumnFilters<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardTransactionReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTransactionReceiptsTable> {
  $$CardTransactionReceiptsTableOrderingComposer({
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

  ColumnOrderings<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardTransactionReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTransactionReceiptsTable> {
  $$CardTransactionReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CardTransactionReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTransactionReceiptsTable,
          CardTransactionReceipt,
          $$CardTransactionReceiptsTableFilterComposer,
          $$CardTransactionReceiptsTableOrderingComposer,
          $$CardTransactionReceiptsTableAnnotationComposer,
          $$CardTransactionReceiptsTableCreateCompanionBuilder,
          $$CardTransactionReceiptsTableUpdateCompanionBuilder,
          (
            CardTransactionReceipt,
            BaseReferences<
              _$AppDatabase,
              $CardTransactionReceiptsTable,
              CardTransactionReceipt
            >,
          ),
          CardTransactionReceipt,
          PrefetchHooks Function()
        > {
  $$CardTransactionReceiptsTableTableManager(
    _$AppDatabase db,
    $CardTransactionReceiptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTransactionReceiptsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CardTransactionReceiptsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CardTransactionReceiptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardTransactionId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CardTransactionReceiptsCompanion(
                id: id,
                cardTransactionId: cardTransactionId,
                filePath: filePath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardTransactionId,
                required String filePath,
                required DateTime createdAt,
              }) => CardTransactionReceiptsCompanion.insert(
                id: id,
                cardTransactionId: cardTransactionId,
                filePath: filePath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardTransactionReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTransactionReceiptsTable,
      CardTransactionReceipt,
      $$CardTransactionReceiptsTableFilterComposer,
      $$CardTransactionReceiptsTableOrderingComposer,
      $$CardTransactionReceiptsTableAnnotationComposer,
      $$CardTransactionReceiptsTableCreateCompanionBuilder,
      $$CardTransactionReceiptsTableUpdateCompanionBuilder,
      (
        CardTransactionReceipt,
        BaseReferences<
          _$AppDatabase,
          $CardTransactionReceiptsTable,
          CardTransactionReceipt
        >,
      ),
      CardTransactionReceipt,
      PrefetchHooks Function()
    >;
typedef $$BankAccountTransactionsTableCreateCompanionBuilder =
    BankAccountTransactionsCompanion Function({
      Value<int> id,
      required int bankAccountId,
      required String kind,
      required int amountPaise,
      Value<String?> merchant,
      Value<String?> beneficiary,
      Value<String?> category,
      required DateTime transactionAt,
      required String source,
      Value<String?> rawSms,
      Value<String?> referenceNumber,
      Value<bool> isReviewed,
      Value<String?> notes,
      Value<String?> location,
      required DateTime createdAt,
    });
typedef $$BankAccountTransactionsTableUpdateCompanionBuilder =
    BankAccountTransactionsCompanion Function({
      Value<int> id,
      Value<int> bankAccountId,
      Value<String> kind,
      Value<int> amountPaise,
      Value<String?> merchant,
      Value<String?> beneficiary,
      Value<String?> category,
      Value<DateTime> transactionAt,
      Value<String> source,
      Value<String?> rawSms,
      Value<String?> referenceNumber,
      Value<bool> isReviewed,
      Value<String?> notes,
      Value<String?> location,
      Value<DateTime> createdAt,
    });

class $$BankAccountTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $BankAccountTransactionsTable> {
  $$BankAccountTransactionsTableFilterComposer({
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

  ColumnFilters<int> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiary => $composableBuilder(
    column: $table.beneficiary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionAt => $composableBuilder(
    column: $table.transactionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankAccountTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankAccountTransactionsTable> {
  $$BankAccountTransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiary => $composableBuilder(
    column: $table.beneficiary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionAt => $composableBuilder(
    column: $table.transactionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankAccountTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankAccountTransactionsTable> {
  $$BankAccountTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get beneficiary => $composableBuilder(
    column: $table.beneficiary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionAt => $composableBuilder(
    column: $table.transactionAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get rawSms =>
      $composableBuilder(column: $table.rawSms, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BankAccountTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankAccountTransactionsTable,
          BankAccountTransaction,
          $$BankAccountTransactionsTableFilterComposer,
          $$BankAccountTransactionsTableOrderingComposer,
          $$BankAccountTransactionsTableAnnotationComposer,
          $$BankAccountTransactionsTableCreateCompanionBuilder,
          $$BankAccountTransactionsTableUpdateCompanionBuilder,
          (
            BankAccountTransaction,
            BaseReferences<
              _$AppDatabase,
              $BankAccountTransactionsTable,
              BankAccountTransaction
            >,
          ),
          BankAccountTransaction,
          PrefetchHooks Function()
        > {
  $$BankAccountTransactionsTableTableManager(
    _$AppDatabase db,
    $BankAccountTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankAccountTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BankAccountTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BankAccountTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bankAccountId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> beneficiary = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<DateTime> transactionAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> rawSms = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BankAccountTransactionsCompanion(
                id: id,
                bankAccountId: bankAccountId,
                kind: kind,
                amountPaise: amountPaise,
                merchant: merchant,
                beneficiary: beneficiary,
                category: category,
                transactionAt: transactionAt,
                source: source,
                rawSms: rawSms,
                referenceNumber: referenceNumber,
                isReviewed: isReviewed,
                notes: notes,
                location: location,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bankAccountId,
                required String kind,
                required int amountPaise,
                Value<String?> merchant = const Value.absent(),
                Value<String?> beneficiary = const Value.absent(),
                Value<String?> category = const Value.absent(),
                required DateTime transactionAt,
                required String source,
                Value<String?> rawSms = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required DateTime createdAt,
              }) => BankAccountTransactionsCompanion.insert(
                id: id,
                bankAccountId: bankAccountId,
                kind: kind,
                amountPaise: amountPaise,
                merchant: merchant,
                beneficiary: beneficiary,
                category: category,
                transactionAt: transactionAt,
                source: source,
                rawSms: rawSms,
                referenceNumber: referenceNumber,
                isReviewed: isReviewed,
                notes: notes,
                location: location,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankAccountTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankAccountTransactionsTable,
      BankAccountTransaction,
      $$BankAccountTransactionsTableFilterComposer,
      $$BankAccountTransactionsTableOrderingComposer,
      $$BankAccountTransactionsTableAnnotationComposer,
      $$BankAccountTransactionsTableCreateCompanionBuilder,
      $$BankAccountTransactionsTableUpdateCompanionBuilder,
      (
        BankAccountTransaction,
        BaseReferences<
          _$AppDatabase,
          $BankAccountTransactionsTable,
          BankAccountTransaction
        >,
      ),
      BankAccountTransaction,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> onboardingComplete,
      Value<int> importLastIndex,
      Value<bool> importCompleted,
      Value<bool> locationPermissionExplained,
      Value<String> themeMode,
      Value<bool> appLockEnabled,
      Value<bool> appLockBiometricEnabled,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> onboardingComplete,
      Value<int> importLastIndex,
      Value<bool> importCompleted,
      Value<bool> locationPermissionExplained,
      Value<String> themeMode,
      Value<bool> appLockEnabled,
      Value<bool> appLockBiometricEnabled,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importLastIndex => $composableBuilder(
    column: $table.importLastIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get importCompleted => $composableBuilder(
    column: $table.importCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locationPermissionExplained => $composableBuilder(
    column: $table.locationPermissionExplained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appLockBiometricEnabled => $composableBuilder(
    column: $table.appLockBiometricEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importLastIndex => $composableBuilder(
    column: $table.importLastIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get importCompleted => $composableBuilder(
    column: $table.importCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locationPermissionExplained => $composableBuilder(
    column: $table.locationPermissionExplained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockBiometricEnabled => $composableBuilder(
    column: $table.appLockBiometricEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importLastIndex => $composableBuilder(
    column: $table.importLastIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get importCompleted => $composableBuilder(
    column: $table.importCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locationPermissionExplained => $composableBuilder(
    column: $table.locationPermissionExplained,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appLockBiometricEnabled => $composableBuilder(
    column: $table.appLockBiometricEnabled,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<int> importLastIndex = const Value.absent(),
                Value<bool> importCompleted = const Value.absent(),
                Value<bool> locationPermissionExplained = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> appLockBiometricEnabled = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                onboardingComplete: onboardingComplete,
                importLastIndex: importLastIndex,
                importCompleted: importCompleted,
                locationPermissionExplained: locationPermissionExplained,
                themeMode: themeMode,
                appLockEnabled: appLockEnabled,
                appLockBiometricEnabled: appLockBiometricEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<int> importLastIndex = const Value.absent(),
                Value<bool> importCompleted = const Value.absent(),
                Value<bool> locationPermissionExplained = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> appLockBiometricEnabled = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                onboardingComplete: onboardingComplete,
                importLastIndex: importLastIndex,
                importCompleted: importCompleted,
                locationPermissionExplained: locationPermissionExplained,
                themeMode: themeMode,
                appLockEnabled: appLockEnabled,
                appLockBiometricEnabled: appLockBiometricEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$BudgetSettingsTableCreateCompanionBuilder =
    BudgetSettingsCompanion Function({
      Value<int> id,
      Value<int?> monthlyLimitPaise,
      Value<DateTime?> currentPeriodStart,
      Value<int> alertThreshold75,
      Value<int> alertThreshold90,
      Value<int> alertThreshold100,
    });
typedef $$BudgetSettingsTableUpdateCompanionBuilder =
    BudgetSettingsCompanion Function({
      Value<int> id,
      Value<int?> monthlyLimitPaise,
      Value<DateTime?> currentPeriodStart,
      Value<int> alertThreshold75,
      Value<int> alertThreshold90,
      Value<int> alertThreshold100,
    });

class $$BudgetSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetSettingsTable> {
  $$BudgetSettingsTableFilterComposer({
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

  ColumnFilters<int> get monthlyLimitPaise => $composableBuilder(
    column: $table.monthlyLimitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get currentPeriodStart => $composableBuilder(
    column: $table.currentPeriodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertThreshold75 => $composableBuilder(
    column: $table.alertThreshold75,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertThreshold90 => $composableBuilder(
    column: $table.alertThreshold90,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertThreshold100 => $composableBuilder(
    column: $table.alertThreshold100,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetSettingsTable> {
  $$BudgetSettingsTableOrderingComposer({
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

  ColumnOrderings<int> get monthlyLimitPaise => $composableBuilder(
    column: $table.monthlyLimitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get currentPeriodStart => $composableBuilder(
    column: $table.currentPeriodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertThreshold75 => $composableBuilder(
    column: $table.alertThreshold75,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertThreshold90 => $composableBuilder(
    column: $table.alertThreshold90,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertThreshold100 => $composableBuilder(
    column: $table.alertThreshold100,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetSettingsTable> {
  $$BudgetSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get monthlyLimitPaise => $composableBuilder(
    column: $table.monthlyLimitPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get currentPeriodStart => $composableBuilder(
    column: $table.currentPeriodStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alertThreshold75 => $composableBuilder(
    column: $table.alertThreshold75,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alertThreshold90 => $composableBuilder(
    column: $table.alertThreshold90,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alertThreshold100 => $composableBuilder(
    column: $table.alertThreshold100,
    builder: (column) => column,
  );
}

class $$BudgetSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetSettingsTable,
          BudgetSetting,
          $$BudgetSettingsTableFilterComposer,
          $$BudgetSettingsTableOrderingComposer,
          $$BudgetSettingsTableAnnotationComposer,
          $$BudgetSettingsTableCreateCompanionBuilder,
          $$BudgetSettingsTableUpdateCompanionBuilder,
          (
            BudgetSetting,
            BaseReferences<_$AppDatabase, $BudgetSettingsTable, BudgetSetting>,
          ),
          BudgetSetting,
          PrefetchHooks Function()
        > {
  $$BudgetSettingsTableTableManager(
    _$AppDatabase db,
    $BudgetSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> monthlyLimitPaise = const Value.absent(),
                Value<DateTime?> currentPeriodStart = const Value.absent(),
                Value<int> alertThreshold75 = const Value.absent(),
                Value<int> alertThreshold90 = const Value.absent(),
                Value<int> alertThreshold100 = const Value.absent(),
              }) => BudgetSettingsCompanion(
                id: id,
                monthlyLimitPaise: monthlyLimitPaise,
                currentPeriodStart: currentPeriodStart,
                alertThreshold75: alertThreshold75,
                alertThreshold90: alertThreshold90,
                alertThreshold100: alertThreshold100,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> monthlyLimitPaise = const Value.absent(),
                Value<DateTime?> currentPeriodStart = const Value.absent(),
                Value<int> alertThreshold75 = const Value.absent(),
                Value<int> alertThreshold90 = const Value.absent(),
                Value<int> alertThreshold100 = const Value.absent(),
              }) => BudgetSettingsCompanion.insert(
                id: id,
                monthlyLimitPaise: monthlyLimitPaise,
                currentPeriodStart: currentPeriodStart,
                alertThreshold75: alertThreshold75,
                alertThreshold90: alertThreshold90,
                alertThreshold100: alertThreshold100,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetSettingsTable,
      BudgetSetting,
      $$BudgetSettingsTableFilterComposer,
      $$BudgetSettingsTableOrderingComposer,
      $$BudgetSettingsTableAnnotationComposer,
      $$BudgetSettingsTableCreateCompanionBuilder,
      $$BudgetSettingsTableUpdateCompanionBuilder,
      (
        BudgetSetting,
        BaseReferences<_$AppDatabase, $BudgetSettingsTable, BudgetSetting>,
      ),
      BudgetSetting,
      PrefetchHooks Function()
    >;
typedef $$CategoryBudgetsTableCreateCompanionBuilder =
    CategoryBudgetsCompanion Function({
      Value<int> id,
      required String category,
      required int limitPaise,
    });
typedef $$CategoryBudgetsTableUpdateCompanionBuilder =
    CategoryBudgetsCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<int> limitPaise,
    });

class $$CategoryBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => column,
  );
}

class $$CategoryBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryBudgetsTable,
          CategoryBudget,
          $$CategoryBudgetsTableFilterComposer,
          $$CategoryBudgetsTableOrderingComposer,
          $$CategoryBudgetsTableAnnotationComposer,
          $$CategoryBudgetsTableCreateCompanionBuilder,
          $$CategoryBudgetsTableUpdateCompanionBuilder,
          (
            CategoryBudget,
            BaseReferences<
              _$AppDatabase,
              $CategoryBudgetsTable,
              CategoryBudget
            >,
          ),
          CategoryBudget,
          PrefetchHooks Function()
        > {
  $$CategoryBudgetsTableTableManager(
    _$AppDatabase db,
    $CategoryBudgetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> limitPaise = const Value.absent(),
              }) => CategoryBudgetsCompanion(
                id: id,
                category: category,
                limitPaise: limitPaise,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required int limitPaise,
              }) => CategoryBudgetsCompanion.insert(
                id: id,
                category: category,
                limitPaise: limitPaise,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryBudgetsTable,
      CategoryBudget,
      $$CategoryBudgetsTableFilterComposer,
      $$CategoryBudgetsTableOrderingComposer,
      $$CategoryBudgetsTableAnnotationComposer,
      $$CategoryBudgetsTableCreateCompanionBuilder,
      $$CategoryBudgetsTableUpdateCompanionBuilder,
      (
        CategoryBudget,
        BaseReferences<_$AppDatabase, $CategoryBudgetsTable, CategoryBudget>,
      ),
      CategoryBudget,
      PrefetchHooks Function()
    >;
typedef $$BudgetAlertCrossingsTableCreateCompanionBuilder =
    BudgetAlertCrossingsCompanion Function({
      Value<int> id,
      required String budgetKey,
      required String threshold,
      required DateTime periodStart,
    });
typedef $$BudgetAlertCrossingsTableUpdateCompanionBuilder =
    BudgetAlertCrossingsCompanion Function({
      Value<int> id,
      Value<String> budgetKey,
      Value<String> threshold,
      Value<DateTime> periodStart,
    });

class $$BudgetAlertCrossingsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetAlertCrossingsTable> {
  $$BudgetAlertCrossingsTableFilterComposer({
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

  ColumnFilters<String> get budgetKey => $composableBuilder(
    column: $table.budgetKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetAlertCrossingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetAlertCrossingsTable> {
  $$BudgetAlertCrossingsTableOrderingComposer({
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

  ColumnOrderings<String> get budgetKey => $composableBuilder(
    column: $table.budgetKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetAlertCrossingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetAlertCrossingsTable> {
  $$BudgetAlertCrossingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get budgetKey =>
      $composableBuilder(column: $table.budgetKey, builder: (column) => column);

  GeneratedColumn<String> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );
}

class $$BudgetAlertCrossingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetAlertCrossingsTable,
          BudgetAlertCrossing,
          $$BudgetAlertCrossingsTableFilterComposer,
          $$BudgetAlertCrossingsTableOrderingComposer,
          $$BudgetAlertCrossingsTableAnnotationComposer,
          $$BudgetAlertCrossingsTableCreateCompanionBuilder,
          $$BudgetAlertCrossingsTableUpdateCompanionBuilder,
          (
            BudgetAlertCrossing,
            BaseReferences<
              _$AppDatabase,
              $BudgetAlertCrossingsTable,
              BudgetAlertCrossing
            >,
          ),
          BudgetAlertCrossing,
          PrefetchHooks Function()
        > {
  $$BudgetAlertCrossingsTableTableManager(
    _$AppDatabase db,
    $BudgetAlertCrossingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetAlertCrossingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetAlertCrossingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BudgetAlertCrossingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> budgetKey = const Value.absent(),
                Value<String> threshold = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
              }) => BudgetAlertCrossingsCompanion(
                id: id,
                budgetKey: budgetKey,
                threshold: threshold,
                periodStart: periodStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String budgetKey,
                required String threshold,
                required DateTime periodStart,
              }) => BudgetAlertCrossingsCompanion.insert(
                id: id,
                budgetKey: budgetKey,
                threshold: threshold,
                periodStart: periodStart,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetAlertCrossingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetAlertCrossingsTable,
      BudgetAlertCrossing,
      $$BudgetAlertCrossingsTableFilterComposer,
      $$BudgetAlertCrossingsTableOrderingComposer,
      $$BudgetAlertCrossingsTableAnnotationComposer,
      $$BudgetAlertCrossingsTableCreateCompanionBuilder,
      $$BudgetAlertCrossingsTableUpdateCompanionBuilder,
      (
        BudgetAlertCrossing,
        BaseReferences<
          _$AppDatabase,
          $BudgetAlertCrossingsTable,
          BudgetAlertCrossing
        >,
      ),
      BudgetAlertCrossing,
      PrefetchHooks Function()
    >;
typedef $$RecoveryLinksTableCreateCompanionBuilder =
    RecoveryLinksCompanion Function({
      Value<int> id,
      required int creditTransactionId,
      required int recoverableTransactionId,
      required int amountPaise,
    });
typedef $$RecoveryLinksTableUpdateCompanionBuilder =
    RecoveryLinksCompanion Function({
      Value<int> id,
      Value<int> creditTransactionId,
      Value<int> recoverableTransactionId,
      Value<int> amountPaise,
    });

class $$RecoveryLinksTableFilterComposer
    extends Composer<_$AppDatabase, $RecoveryLinksTable> {
  $$RecoveryLinksTableFilterComposer({
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

  ColumnFilters<int> get creditTransactionId => $composableBuilder(
    column: $table.creditTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recoverableTransactionId => $composableBuilder(
    column: $table.recoverableTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecoveryLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $RecoveryLinksTable> {
  $$RecoveryLinksTableOrderingComposer({
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

  ColumnOrderings<int> get creditTransactionId => $composableBuilder(
    column: $table.creditTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recoverableTransactionId => $composableBuilder(
    column: $table.recoverableTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoveryLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecoveryLinksTable> {
  $$RecoveryLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get creditTransactionId => $composableBuilder(
    column: $table.creditTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recoverableTransactionId => $composableBuilder(
    column: $table.recoverableTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );
}

class $$RecoveryLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecoveryLinksTable,
          RecoveryLink,
          $$RecoveryLinksTableFilterComposer,
          $$RecoveryLinksTableOrderingComposer,
          $$RecoveryLinksTableAnnotationComposer,
          $$RecoveryLinksTableCreateCompanionBuilder,
          $$RecoveryLinksTableUpdateCompanionBuilder,
          (
            RecoveryLink,
            BaseReferences<_$AppDatabase, $RecoveryLinksTable, RecoveryLink>,
          ),
          RecoveryLink,
          PrefetchHooks Function()
        > {
  $$RecoveryLinksTableTableManager(_$AppDatabase db, $RecoveryLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoveryLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoveryLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoveryLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> creditTransactionId = const Value.absent(),
                Value<int> recoverableTransactionId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
              }) => RecoveryLinksCompanion(
                id: id,
                creditTransactionId: creditTransactionId,
                recoverableTransactionId: recoverableTransactionId,
                amountPaise: amountPaise,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int creditTransactionId,
                required int recoverableTransactionId,
                required int amountPaise,
              }) => RecoveryLinksCompanion.insert(
                id: id,
                creditTransactionId: creditTransactionId,
                recoverableTransactionId: recoverableTransactionId,
                amountPaise: amountPaise,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoveryLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecoveryLinksTable,
      RecoveryLink,
      $$RecoveryLinksTableFilterComposer,
      $$RecoveryLinksTableOrderingComposer,
      $$RecoveryLinksTableAnnotationComposer,
      $$RecoveryLinksTableCreateCompanionBuilder,
      $$RecoveryLinksTableUpdateCompanionBuilder,
      (
        RecoveryLink,
        BaseReferences<_$AppDatabase, $RecoveryLinksTable, RecoveryLink>,
      ),
      RecoveryLink,
      PrefetchHooks Function()
    >;
typedef $$RecoverablePersonsTableCreateCompanionBuilder =
    RecoverablePersonsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime lastUsedAt,
    });
typedef $$RecoverablePersonsTableUpdateCompanionBuilder =
    RecoverablePersonsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> lastUsedAt,
    });

class $$RecoverablePersonsTableFilterComposer
    extends Composer<_$AppDatabase, $RecoverablePersonsTable> {
  $$RecoverablePersonsTableFilterComposer({
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

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecoverablePersonsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecoverablePersonsTable> {
  $$RecoverablePersonsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoverablePersonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecoverablePersonsTable> {
  $$RecoverablePersonsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$RecoverablePersonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecoverablePersonsTable,
          RecoverablePerson,
          $$RecoverablePersonsTableFilterComposer,
          $$RecoverablePersonsTableOrderingComposer,
          $$RecoverablePersonsTableAnnotationComposer,
          $$RecoverablePersonsTableCreateCompanionBuilder,
          $$RecoverablePersonsTableUpdateCompanionBuilder,
          (
            RecoverablePerson,
            BaseReferences<
              _$AppDatabase,
              $RecoverablePersonsTable,
              RecoverablePerson
            >,
          ),
          RecoverablePerson,
          PrefetchHooks Function()
        > {
  $$RecoverablePersonsTableTableManager(
    _$AppDatabase db,
    $RecoverablePersonsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoverablePersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoverablePersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoverablePersonsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
              }) => RecoverablePersonsCompanion(
                id: id,
                name: name,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime lastUsedAt,
              }) => RecoverablePersonsCompanion.insert(
                id: id,
                name: name,
                lastUsedAt: lastUsedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoverablePersonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecoverablePersonsTable,
      RecoverablePerson,
      $$RecoverablePersonsTableFilterComposer,
      $$RecoverablePersonsTableOrderingComposer,
      $$RecoverablePersonsTableAnnotationComposer,
      $$RecoverablePersonsTableCreateCompanionBuilder,
      $$RecoverablePersonsTableUpdateCompanionBuilder,
      (
        RecoverablePerson,
        BaseReferences<
          _$AppDatabase,
          $RecoverablePersonsTable,
          RecoverablePerson
        >,
      ),
      RecoverablePerson,
      PrefetchHooks Function()
    >;
typedef $$MerchantsTableCreateCompanionBuilder =
    MerchantsCompanion Function({
      Value<int> id,
      required String rawName,
      Value<String?> displayName,
      Value<String?> defaultCategory,
      Value<bool> isUserCustomized,
    });
typedef $$MerchantsTableUpdateCompanionBuilder =
    MerchantsCompanion Function({
      Value<int> id,
      Value<String> rawName,
      Value<String?> displayName,
      Value<String?> defaultCategory,
      Value<bool> isUserCustomized,
    });

class $$MerchantsTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantsTable> {
  $$MerchantsTableFilterComposer({
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

  ColumnFilters<String> get rawName => $composableBuilder(
    column: $table.rawName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCategory => $composableBuilder(
    column: $table.defaultCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUserCustomized => $composableBuilder(
    column: $table.isUserCustomized,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantsTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantsTable> {
  $$MerchantsTableOrderingComposer({
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

  ColumnOrderings<String> get rawName => $composableBuilder(
    column: $table.rawName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCategory => $composableBuilder(
    column: $table.defaultCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUserCustomized => $composableBuilder(
    column: $table.isUserCustomized,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantsTable> {
  $$MerchantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawName =>
      $composableBuilder(column: $table.rawName, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultCategory => $composableBuilder(
    column: $table.defaultCategory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUserCustomized => $composableBuilder(
    column: $table.isUserCustomized,
    builder: (column) => column,
  );
}

class $$MerchantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantsTable,
          Merchant,
          $$MerchantsTableFilterComposer,
          $$MerchantsTableOrderingComposer,
          $$MerchantsTableAnnotationComposer,
          $$MerchantsTableCreateCompanionBuilder,
          $$MerchantsTableUpdateCompanionBuilder,
          (Merchant, BaseReferences<_$AppDatabase, $MerchantsTable, Merchant>),
          Merchant,
          PrefetchHooks Function()
        > {
  $$MerchantsTableTableManager(_$AppDatabase db, $MerchantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawName = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> defaultCategory = const Value.absent(),
                Value<bool> isUserCustomized = const Value.absent(),
              }) => MerchantsCompanion(
                id: id,
                rawName: rawName,
                displayName: displayName,
                defaultCategory: defaultCategory,
                isUserCustomized: isUserCustomized,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawName,
                Value<String?> displayName = const Value.absent(),
                Value<String?> defaultCategory = const Value.absent(),
                Value<bool> isUserCustomized = const Value.absent(),
              }) => MerchantsCompanion.insert(
                id: id,
                rawName: rawName,
                displayName: displayName,
                defaultCategory: defaultCategory,
                isUserCustomized: isUserCustomized,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantsTable,
      Merchant,
      $$MerchantsTableFilterComposer,
      $$MerchantsTableOrderingComposer,
      $$MerchantsTableAnnotationComposer,
      $$MerchantsTableCreateCompanionBuilder,
      $$MerchantsTableUpdateCompanionBuilder,
      (Merchant, BaseReferences<_$AppDatabase, $MerchantsTable, Merchant>),
      Merchant,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isBuiltIn,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isBuiltIn,
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

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
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

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
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

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
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
                Value<bool> isBuiltIn = const Value.absent(),
              }) =>
                  CategoriesCompanion(id: id, name: name, isBuiltIn: isBuiltIn),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isBuiltIn = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
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
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({Value<int> id, required String name});
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({Value<int> id, Value<String> name});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
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
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TagsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TagsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$CardTransactionTagsTableCreateCompanionBuilder =
    CardTransactionTagsCompanion Function({
      required int cardTransactionId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$CardTransactionTagsTableUpdateCompanionBuilder =
    CardTransactionTagsCompanion Function({
      Value<int> cardTransactionId,
      Value<int> tagId,
      Value<int> rowid,
    });

class $$CardTransactionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTransactionTagsTable> {
  $$CardTransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardTransactionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTransactionTagsTable> {
  $$CardTransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardTransactionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTransactionTagsTable> {
  $$CardTransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$CardTransactionTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTransactionTagsTable,
          CardTransactionTag,
          $$CardTransactionTagsTableFilterComposer,
          $$CardTransactionTagsTableOrderingComposer,
          $$CardTransactionTagsTableAnnotationComposer,
          $$CardTransactionTagsTableCreateCompanionBuilder,
          $$CardTransactionTagsTableUpdateCompanionBuilder,
          (
            CardTransactionTag,
            BaseReferences<
              _$AppDatabase,
              $CardTransactionTagsTable,
              CardTransactionTag
            >,
          ),
          CardTransactionTag,
          PrefetchHooks Function()
        > {
  $$CardTransactionTagsTableTableManager(
    _$AppDatabase db,
    $CardTransactionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTransactionTagsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CardTransactionTagsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> cardTransactionId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTransactionTagsCompanion(
                cardTransactionId: cardTransactionId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int cardTransactionId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => CardTransactionTagsCompanion.insert(
                cardTransactionId: cardTransactionId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardTransactionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTransactionTagsTable,
      CardTransactionTag,
      $$CardTransactionTagsTableFilterComposer,
      $$CardTransactionTagsTableOrderingComposer,
      $$CardTransactionTagsTableAnnotationComposer,
      $$CardTransactionTagsTableCreateCompanionBuilder,
      $$CardTransactionTagsTableUpdateCompanionBuilder,
      (
        CardTransactionTag,
        BaseReferences<
          _$AppDatabase,
          $CardTransactionTagsTable,
          CardTransactionTag
        >,
      ),
      CardTransactionTag,
      PrefetchHooks Function()
    >;
typedef $$MerchantDefaultTagsTableCreateCompanionBuilder =
    MerchantDefaultTagsCompanion Function({
      required int merchantId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$MerchantDefaultTagsTableUpdateCompanionBuilder =
    MerchantDefaultTagsCompanion Function({
      Value<int> merchantId,
      Value<int> tagId,
      Value<int> rowid,
    });

class $$MerchantDefaultTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantDefaultTagsTable> {
  $$MerchantDefaultTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantDefaultTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantDefaultTagsTable> {
  $$MerchantDefaultTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantDefaultTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantDefaultTagsTable> {
  $$MerchantDefaultTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get merchantId => $composableBuilder(
    column: $table.merchantId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$MerchantDefaultTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantDefaultTagsTable,
          MerchantDefaultTag,
          $$MerchantDefaultTagsTableFilterComposer,
          $$MerchantDefaultTagsTableOrderingComposer,
          $$MerchantDefaultTagsTableAnnotationComposer,
          $$MerchantDefaultTagsTableCreateCompanionBuilder,
          $$MerchantDefaultTagsTableUpdateCompanionBuilder,
          (
            MerchantDefaultTag,
            BaseReferences<
              _$AppDatabase,
              $MerchantDefaultTagsTable,
              MerchantDefaultTag
            >,
          ),
          MerchantDefaultTag,
          PrefetchHooks Function()
        > {
  $$MerchantDefaultTagsTableTableManager(
    _$AppDatabase db,
    $MerchantDefaultTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantDefaultTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantDefaultTagsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MerchantDefaultTagsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> merchantId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantDefaultTagsCompanion(
                merchantId: merchantId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int merchantId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => MerchantDefaultTagsCompanion.insert(
                merchantId: merchantId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantDefaultTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantDefaultTagsTable,
      MerchantDefaultTag,
      $$MerchantDefaultTagsTableFilterComposer,
      $$MerchantDefaultTagsTableOrderingComposer,
      $$MerchantDefaultTagsTableAnnotationComposer,
      $$MerchantDefaultTagsTableCreateCompanionBuilder,
      $$MerchantDefaultTagsTableUpdateCompanionBuilder,
      (
        MerchantDefaultTag,
        BaseReferences<
          _$AppDatabase,
          $MerchantDefaultTagsTable,
          MerchantDefaultTag
        >,
      ),
      MerchantDefaultTag,
      PrefetchHooks Function()
    >;
typedef $$TransactionLinksTableCreateCompanionBuilder =
    TransactionLinksCompanion Function({
      Value<int> id,
      required String kind,
      Value<int?> cardTransactionId,
      Value<int?> bankAccountTransactionId,
      Value<int?> linkedCardTransactionId,
      Value<int?> linkedBankAccountTransactionId,
    });
typedef $$TransactionLinksTableUpdateCompanionBuilder =
    TransactionLinksCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<int?> cardTransactionId,
      Value<int?> bankAccountTransactionId,
      Value<int?> linkedCardTransactionId,
      Value<int?> linkedBankAccountTransactionId,
    });

class $$TransactionLinksTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionLinksTable> {
  $$TransactionLinksTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bankAccountTransactionId => $composableBuilder(
    column: $table.bankAccountTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedCardTransactionId => $composableBuilder(
    column: $table.linkedCardTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedBankAccountTransactionId => $composableBuilder(
    column: $table.linkedBankAccountTransactionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionLinksTable> {
  $$TransactionLinksTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bankAccountTransactionId => $composableBuilder(
    column: $table.bankAccountTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedCardTransactionId => $composableBuilder(
    column: $table.linkedCardTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedBankAccountTransactionId => $composableBuilder(
    column: $table.linkedBankAccountTransactionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionLinksTable> {
  $$TransactionLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get cardTransactionId => $composableBuilder(
    column: $table.cardTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bankAccountTransactionId => $composableBuilder(
    column: $table.bankAccountTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedCardTransactionId => $composableBuilder(
    column: $table.linkedCardTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedBankAccountTransactionId => $composableBuilder(
    column: $table.linkedBankAccountTransactionId,
    builder: (column) => column,
  );
}

class $$TransactionLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionLinksTable,
          TransactionLink,
          $$TransactionLinksTableFilterComposer,
          $$TransactionLinksTableOrderingComposer,
          $$TransactionLinksTableAnnotationComposer,
          $$TransactionLinksTableCreateCompanionBuilder,
          $$TransactionLinksTableUpdateCompanionBuilder,
          (
            TransactionLink,
            BaseReferences<
              _$AppDatabase,
              $TransactionLinksTable,
              TransactionLink
            >,
          ),
          TransactionLink,
          PrefetchHooks Function()
        > {
  $$TransactionLinksTableTableManager(
    _$AppDatabase db,
    $TransactionLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> cardTransactionId = const Value.absent(),
                Value<int?> bankAccountTransactionId = const Value.absent(),
                Value<int?> linkedCardTransactionId = const Value.absent(),
                Value<int?> linkedBankAccountTransactionId =
                    const Value.absent(),
              }) => TransactionLinksCompanion(
                id: id,
                kind: kind,
                cardTransactionId: cardTransactionId,
                bankAccountTransactionId: bankAccountTransactionId,
                linkedCardTransactionId: linkedCardTransactionId,
                linkedBankAccountTransactionId: linkedBankAccountTransactionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                Value<int?> cardTransactionId = const Value.absent(),
                Value<int?> bankAccountTransactionId = const Value.absent(),
                Value<int?> linkedCardTransactionId = const Value.absent(),
                Value<int?> linkedBankAccountTransactionId =
                    const Value.absent(),
              }) => TransactionLinksCompanion.insert(
                id: id,
                kind: kind,
                cardTransactionId: cardTransactionId,
                bankAccountTransactionId: bankAccountTransactionId,
                linkedCardTransactionId: linkedCardTransactionId,
                linkedBankAccountTransactionId: linkedBankAccountTransactionId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionLinksTable,
      TransactionLink,
      $$TransactionLinksTableFilterComposer,
      $$TransactionLinksTableOrderingComposer,
      $$TransactionLinksTableAnnotationComposer,
      $$TransactionLinksTableCreateCompanionBuilder,
      $$TransactionLinksTableUpdateCompanionBuilder,
      (
        TransactionLink,
        BaseReferences<_$AppDatabase, $TransactionLinksTable, TransactionLink>,
      ),
      TransactionLink,
      PrefetchHooks Function()
    >;
typedef $$SmsSendersTableCreateCompanionBuilder =
    SmsSendersCompanion Function({
      Value<int> id,
      required String address,
      Value<bool> isBuiltIn,
    });
typedef $$SmsSendersTableUpdateCompanionBuilder =
    SmsSendersCompanion Function({
      Value<int> id,
      Value<String> address,
      Value<bool> isBuiltIn,
    });

class $$SmsSendersTableFilterComposer
    extends Composer<_$AppDatabase, $SmsSendersTable> {
  $$SmsSendersTableFilterComposer({
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

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmsSendersTableOrderingComposer
    extends Composer<_$AppDatabase, $SmsSendersTable> {
  $$SmsSendersTableOrderingComposer({
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

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmsSendersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmsSendersTable> {
  $$SmsSendersTableAnnotationComposer({
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

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);
}

class $$SmsSendersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmsSendersTable,
          SmsSender,
          $$SmsSendersTableFilterComposer,
          $$SmsSendersTableOrderingComposer,
          $$SmsSendersTableAnnotationComposer,
          $$SmsSendersTableCreateCompanionBuilder,
          $$SmsSendersTableUpdateCompanionBuilder,
          (
            SmsSender,
            BaseReferences<_$AppDatabase, $SmsSendersTable, SmsSender>,
          ),
          SmsSender,
          PrefetchHooks Function()
        > {
  $$SmsSendersTableTableManager(_$AppDatabase db, $SmsSendersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsSendersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsSendersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsSendersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
              }) => SmsSendersCompanion(
                id: id,
                address: address,
                isBuiltIn: isBuiltIn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String address,
                Value<bool> isBuiltIn = const Value.absent(),
              }) => SmsSendersCompanion.insert(
                id: id,
                address: address,
                isBuiltIn: isBuiltIn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmsSendersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmsSendersTable,
      SmsSender,
      $$SmsSendersTableFilterComposer,
      $$SmsSendersTableOrderingComposer,
      $$SmsSendersTableAnnotationComposer,
      $$SmsSendersTableCreateCompanionBuilder,
      $$SmsSendersTableUpdateCompanionBuilder,
      (SmsSender, BaseReferences<_$AppDatabase, $SmsSendersTable, SmsSender>),
      SmsSender,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CreditCardsTableTableManager get creditCards =>
      $$CreditCardsTableTableManager(_db, _db.creditCards);
  $$BillingCyclesTableTableManager get billingCycles =>
      $$BillingCyclesTableTableManager(_db, _db.billingCycles);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db, _db.bankAccounts);
  $$CardTransactionsTableTableManager get cardTransactions =>
      $$CardTransactionsTableTableManager(_db, _db.cardTransactions);
  $$CardTransactionReceiptsTableTableManager get cardTransactionReceipts =>
      $$CardTransactionReceiptsTableTableManager(
        _db,
        _db.cardTransactionReceipts,
      );
  $$BankAccountTransactionsTableTableManager get bankAccountTransactions =>
      $$BankAccountTransactionsTableTableManager(
        _db,
        _db.bankAccountTransactions,
      );
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BudgetSettingsTableTableManager get budgetSettings =>
      $$BudgetSettingsTableTableManager(_db, _db.budgetSettings);
  $$CategoryBudgetsTableTableManager get categoryBudgets =>
      $$CategoryBudgetsTableTableManager(_db, _db.categoryBudgets);
  $$BudgetAlertCrossingsTableTableManager get budgetAlertCrossings =>
      $$BudgetAlertCrossingsTableTableManager(_db, _db.budgetAlertCrossings);
  $$RecoveryLinksTableTableManager get recoveryLinks =>
      $$RecoveryLinksTableTableManager(_db, _db.recoveryLinks);
  $$RecoverablePersonsTableTableManager get recoverablePersons =>
      $$RecoverablePersonsTableTableManager(_db, _db.recoverablePersons);
  $$MerchantsTableTableManager get merchants =>
      $$MerchantsTableTableManager(_db, _db.merchants);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$CardTransactionTagsTableTableManager get cardTransactionTags =>
      $$CardTransactionTagsTableTableManager(_db, _db.cardTransactionTags);
  $$MerchantDefaultTagsTableTableManager get merchantDefaultTags =>
      $$MerchantDefaultTagsTableTableManager(_db, _db.merchantDefaultTags);
  $$TransactionLinksTableTableManager get transactionLinks =>
      $$TransactionLinksTableTableManager(_db, _db.transactionLinks);
  $$SmsSendersTableTableManager get smsSenders =>
      $$SmsSendersTableTableManager(_db, _db.smsSenders);
}
