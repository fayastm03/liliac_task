
class CreditModel {
  final int? id;
  final String creditType;
  final String recipient;
  final double amount;
  final DateTime dueDate;
  final String planType;
  final DateTime createdAt;

  const CreditModel({
    this.id,
    this.creditType = 'credit',
    required this.recipient,
    required this.amount,
    required this.dueDate,
    required this.planType,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'credit_type': creditType,
      'recipient': recipient,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'plan_type': planType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CreditModel.fromMap(Map<String, Object?> map) {
    return CreditModel(
      id: map['id'] as int?,
      creditType: map['credit_type'] as String,
      recipient: map['recipient'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      planType: map['plan_type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  CreditModel copyWith({
    int? id,
    String? creditType,
    String? recipient,
    double? amount,
    DateTime? dueDate,
    String? planType,
    DateTime? createdAt,
  }) {
    return CreditModel(
      id: id ?? this.id,
      creditType: creditType ?? this.creditType,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      planType: planType ?? this.planType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
