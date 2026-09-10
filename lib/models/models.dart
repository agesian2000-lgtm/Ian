import 'dart:convert';

enum PaymentMethod {
  cash,
  gcash,
  debitCard,
  creditCard;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.gcash:
        return 'GCash';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.creditCard:
        return 'Credit Card';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.displayName == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum SourceType {
  creditCard,
  debitCard,
  bankAccount,
  cashWallet,
  eWallet;

  String get displayName {
    switch (this) {
      case SourceType.creditCard:
        return 'Credit Card';
      case SourceType.debitCard:
        return 'Debit Card';
      case SourceType.bankAccount:
        return 'Bank Account';
      case SourceType.cashWallet:
        return 'Cash';
      case SourceType.eWallet:
        return 'E-Wallet (GCash/PayMaya)';
    }
  }

  static SourceType fromString(String value) {
    return SourceType.values.firstWhere(
      (e) => e.displayName == value,
      orElse: () => SourceType.cashWallet,
    );
  }
}

enum TimeFrame {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case TimeFrame.daily:
        return 'Daily';
      case TimeFrame.weekly:
        return 'Weekly';
      case TimeFrame.monthly:
        return 'Monthly';
    }
  }
}

class Expense {
  final String id;
  final DateTime date;
  final double amount;
  final String category;
  final String paymentMethod;
  final String moneySource;
  final String notes;

  Expense({
    String? id,
    required this.date,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.moneySource,
    this.notes = '',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'amount': amount,
    'category': category,
    'paymentMethod': paymentMethod,
    'moneySource': moneySource,
    'notes': notes,
  };

  static Expense fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    date: DateTime.parse(map['date']),
    amount: (map['amount'] as num).toDouble(),
    category: map['category'],
    paymentMethod: map['paymentMethod'],
    moneySource: map['moneySource'],
    notes: map['notes'] ?? '',
  );

  String toJson() => jsonEncode(toMap());
  static Expense fromJson(String json) => fromMap(jsonDecode(json));
}

class MoneySource {
  final String id;
  final String name;
  final String type;
  double balance;

  MoneySource({
    String? id,
    required this.name,
    required this.type,
    required this.balance,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'balance': balance,
  };

  static MoneySource fromMap(Map<String, dynamic> map) => MoneySource(
    id: map['id'],
    name: map['name'],
    type: map['type'],
    balance: (map['balance'] as num).toDouble(),
  );

  String toJson() => jsonEncode(toMap());
  static MoneySource fromJson(String json) => fromMap(jsonDecode(json));
}

class Budget {
  double daily;
  double weekly;
  double monthly;

  Budget({
    this.daily = 50,
    this.weekly = 300,
    this.monthly = 1000,
  });

  Map<String, dynamic> toMap() => {
    'daily': daily,
    'weekly': weekly,
    'monthly': monthly,
  };

  static Budget fromMap(Map<String, dynamic> map) => Budget(
    daily: (map['daily'] as num?)?.toDouble() ?? 50,
    weekly: (map['weekly'] as num?)?.toDouble() ?? 300,
    monthly: (map['monthly'] as num?)?.toDouble() ?? 1000,
  );

  String toJson() => jsonEncode(toMap());
  static Budget fromJson(String json) => fromMap(jsonDecode(json));
}
