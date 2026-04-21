import 'package:cloud_firestore/cloud_firestore.dart';

enum AgendaType { ordinance, consent, opinion, property, other }
enum AgendaResult { original, amended, rejected, deferred, pending }
enum ProposerType { member, department }

extension AgendaTypeLabel on AgendaType {
  String get label {
    switch (this) {
      case AgendaType.ordinance: return '조례안';
      case AgendaType.consent: return '동의안';
      case AgendaType.opinion: return '의견제시';
      case AgendaType.property: return '공유재산';
      case AgendaType.other: return '기타';
    }
  }
}

extension AgendaResultLabel on AgendaResult {
  String get label {
    switch (this) {
      case AgendaResult.original: return '원안가결';
      case AgendaResult.amended: return '수정가결';
      case AgendaResult.rejected: return '부결';
      case AgendaResult.deferred: return '보류';
      case AgendaResult.pending: return '미심사';
    }
  }
}

extension ProposerTypeLabel on ProposerType {
  String get label {
    switch (this) {
      case ProposerType.member: return '의원발의';
      case ProposerType.department: return '부서발의';
    }
  }
}

class Agenda {
  final String id;
  final String sessionId;
  final String title;
  final AgendaType type;
  final ProposerType proposerType;
  final String proposer;
  final AgendaResult result;
  final String? amendment;
  final List<String> fileUrls;
  final List<String> fileNames;
  final DateTime createdAt;

  Agenda({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.type,
    required this.proposerType,
    required this.proposer,
    required this.result,
    this.amendment,
    this.fileUrls = const [],
    this.fileNames = const [],
    required this.createdAt,
  });

  factory Agenda.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Agenda(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      title: data['title'] ?? '',
      type: AgendaType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AgendaType.other,
      ),
      proposerType: ProposerType.values.firstWhere(
        (e) => e.name == data['proposerType'],
        orElse: () => ProposerType.department,
      ),
      proposer: data['proposer'] ?? '',
      result: AgendaResult.values.firstWhere(
        (e) => e.name == data['result'],
        orElse: () => AgendaResult.pending,
      ),
      amendment: data['amendment'],
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      fileNames: List<String>.from(data['fileNames'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'title': title,
      'type': type.name,
      'proposerType': proposerType.name,
      'proposer': proposer,
      'result': result.name,
      'amendment': amendment,
      'fileUrls': fileUrls,
      'fileNames': fileNames,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
