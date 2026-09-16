enum TransactionType { income, expense }

enum TransactionCategory {
  comida,
  transporte,
  lazer,
  saude,
  contas,
  salario,
  investimentos,
  beneficios,
  outros,
}

class Transaction {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: _parseDate(map['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => TransactionCategory.outros,
      ),
    );
  }

  // Aceita String ISO 8601 (formato atual) ou Timestamp do Firestore
  // (dados legados gravados diretamente como DateTime em versões antigas).
  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'category': category.toString(),
    };
  }

  // Aliases para compatibilidade com Firestore
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      Transaction.fromMap(json);

  Map<String, dynamic> toJson() => toMap();
}
