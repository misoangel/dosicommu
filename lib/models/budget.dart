import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetType { main, supplementary }
enum BudgetResult { original, amended, rejected }

extension BudgetTypeLabel on BudgetType {
  String get label {
    switch (this) {
      case BudgetType.main: return '본예산';
      case BudgetType.supplementary: return '추경';
    }
  }
}

extension BudgetResultLabel on BudgetResult {
  String get label {
    switch (this) {
      case BudgetResult.original: return '원안가결';
      case BudgetResult.amended: return '수정가결';
      case BudgetResult.rejected: return '부결';
    }
  }
}

class BudgetAdjustment {
  final String department;
  final String item;
  final int originalAmount;
  final int adjustedAmount;
  final int difference;
  final String reason;

  BudgetAdjustment({
    required this.department,
    required this.item,
    required this.originalAmount,
    required this.adjustedAmount,
    required this.difference,
    required this.reason,
  });

  factory BudgetAdjustment.fromMap(Map<String, dynamic> map) {
    return BudgetAdjustment(
      department: map['department'] ?? '',
      item: map['item'] ?? '',
      originalAmount: map['originalAmount'] ?? 0,
      adjustedAmount: map['adjustedAmount'] ?? 0,
      difference: map['difference'] ?? 0,
      reason: map['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'department': department,
      'item': item,
      'originalAmount': originalAmount,
      'adjustedAmount': adjustedAmount,
      'difference': difference,
      'reason': reason,
    };
  }
}

class Budget {
  final String id;
  final String sessionId;
  final BudgetType type;
  final BudgetResult result;
  final List<BudgetAdjustment> adjustments;
  final List<String> budgetCommitteeMembers;
  final List<String> fileUrls;
  final List<String> fileNames;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.result,
    this.adjustments = const [],
    this.budgetCommitteeMembers = const [],
    this.fileUrls = const [],
    this.fileNames = const [],
    required this.createdAt,
  });

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      type: BudgetType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BudgetType.supplementary,
      ),
      result: BudgetResult.values.firstWhere(
        (e) => e.name == data['result'],
        orElse: () => BudgetResult.original,
      ),
      adjustments: (data['adjustments'] as List? ?? [])
          .map((e) => BudgetAdjustment.fromMap(e))
          .toList(),
      budgetCommitteeMembers: List<String>.from(data['budgetCommitteeMembers'] ?? []),
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      fileNames: List<String>.from(data['fileNames'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'type': type.name,
      'result': result.name,
      'adjustments': adjustments.map((e) => e.toMap()).toList(),
      'budgetCommitteeMembers': budgetCommitteeMembers,
      'fileUrls': fileUrls,
      'fileNames': fileNames,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
