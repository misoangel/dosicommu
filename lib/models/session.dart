import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType { 임시회, 정례회 }
enum SessionStatus { 예정, 진행중, 완료 }

class Session {
  final String id;
  final String name;
  final int year;
  final SessionType type;
  final DateTime startDate;
  final DateTime endDate;
  final SessionStatus status;
  // 세부 일정 (나중에 입력)
  final DateTime? agendaDate;      // 안건심사일
  final DateTime? budgetDate;      // 예산심사일
  final DateTime? reportDate;      // 업무보고일
  final DateTime? auditDate;       // 행감일
  final bool hasAgenda;
  final bool hasBudget;
  final bool hasReport;
  final bool hasAudit;
  final bool detailEntered;        // 세부일정 입력 여부

  Session({
    required this.id,
    required this.name,
    required this.year,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.agendaDate,
    this.budgetDate,
    this.reportDate,
    this.auditDate,
    this.hasAgenda = false,
    this.hasBudget = false,
    this.hasReport = false,
    this.hasAudit = false,
    this.detailEntered = false,
  });

  factory Session.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Session(
      id: doc.id,
      name: data['name'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      type: SessionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SessionType.임시회,
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SessionStatus.예정,
      ),
      agendaDate: data['agendaDate'] != null
          ? (data['agendaDate'] as Timestamp).toDate()
          : null,
      budgetDate: data['budgetDate'] != null
          ? (data['budgetDate'] as Timestamp).toDate()
          : null,
      reportDate: data['reportDate'] != null
          ? (data['reportDate'] as Timestamp).toDate()
          : null,
      auditDate: data['auditDate'] != null
          ? (data['auditDate'] as Timestamp).toDate()
          : null,
      hasAgenda: data['hasAgenda'] ?? false,
      hasBudget: data['hasBudget'] ?? false,
      hasReport: data['hasReport'] ?? false,
      hasAudit: data['hasAudit'] ?? false,
      detailEntered: data['detailEntered'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'year': year,
      'type': type.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'agendaDate': agendaDate != null ? Timestamp.fromDate(agendaDate!) : null,
      'budgetDate': budgetDate != null ? Timestamp.fromDate(budgetDate!) : null,
      'reportDate': reportDate != null ? Timestamp.fromDate(reportDate!) : null,
      'auditDate': auditDate != null ? Timestamp.fromDate(auditDate!) : null,
      'hasAgenda': hasAgenda,
      'hasBudget': hasBudget,
      'hasReport': hasReport,
      'hasAudit': hasAudit,
      'detailEntered': detailEntered,
    };
  }
}
