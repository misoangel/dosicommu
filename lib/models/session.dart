import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType { temporary, regular }
enum SessionStatus { scheduled, inProgress, completed }

extension SessionTypeLabel on SessionType {
  String get label {
    switch (this) {
      case SessionType.temporary:
        return '임시회';
      case SessionType.regular:
        return '정례회';
    }
  }
}

extension SessionStatusLabel on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.scheduled:
        return '예정';
      case SessionStatus.inProgress:
        return '진행중';
      case SessionStatus.completed:
        return '완료';
    }
  }
}

class Session {
  final String id;
  final String name;
  final int year;
  final SessionType type;
  final DateTime startDate;
  final DateTime endDate;
  final SessionStatus status;
  final DateTime? agendaDate;
  final DateTime? budgetDate;
  final DateTime? reportDate;
  final DateTime? auditDate;
  final bool hasAgenda;
  final bool hasBudget;
  final bool hasReport;
  final bool hasAudit;
  final bool detailEntered;

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

    static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory Session.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final startDate = _toDateTime(data['startDate']) ?? DateTime.now();
    final endDate = _toDateTime(data['endDate']) ?? startDate;

    return Session(
      id: doc.id,
      name: data['name'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      type: SessionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SessionType.temporary,
      ),
      startDate: startDate,
      endDate: endDate,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      agendaDate: _toDateTime(data['agendaDate']),
      budgetDate: _toDateTime(data['budgetDate']),
      reportDate: _toDateTime(data['reportDate']),
      auditDate: _toDateTime(data['auditDate']),
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
