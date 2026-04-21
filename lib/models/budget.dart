import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetType { 본예산, 추경 }
enum BudgetResult { 원안가결, 수정가결, 부결 }

class BudgetAdjustment {
  final String department;   // 부서명
  final String item;         // 항목
  final int originalAmount;  // 원안 금액
  final int adjustedAmount;  // 조정 금액
  final int difference;      // 증감액
  final String reason;       // 조정 사유

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
  final List<BudgetAdjustment> adjustments; // 계수조정 내역
  final List<String> budgetCommitteeMembers; // 예결위 위원
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
        orElse: () => BudgetType.추경,
      ),
      result: BudgetResult.values.firstWhere(
        (e) => e.name == data['result'],
        orElse: () => BudgetResult.원안가결,
      ),
      adjustments: (data['adjustments'] as List? ?? [])
          .map((e) => BudgetAdjustment.fromMap(e))
          .toList(),
      budgetCommitteeMembers:
          List<String>.from(data['budgetCommitteeMembers'] ?? []),
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
