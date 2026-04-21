import 'package:cloud_firestore/cloud_firestore.dart';

enum AgendaType { 조례안, 동의안, 의견제시, 공유재산, 기타 }
enum AgendaResult { 원안가결, 수정가결, 부결, 보류, 미심사 }
enum ProposerType { 의원발의, 부서발의 }

class Agenda {
  final String id;
  final String sessionId;
  final String title;
  final AgendaType type;
  final ProposerType proposerType;
  final String proposer;       // 발의자 또는 발의부서
  final AgendaResult result;
  final String? amendment;     // 수정내용 (수정가결인 경우)
  final List<String> fileUrls; // 첨부파일 URL 목록
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
        orElse: () => AgendaType.기타,
      ),
      proposerType: ProposerType.values.firstWhere(
        (e) => e.name == data['proposerType'],
        orElse: () => ProposerType.부서발의,
      ),
      proposer: data['proposer'] ?? '',
      result: AgendaResult.values.firstWhere(
        (e) => e.name == data['result'],
        orElse: () => AgendaResult.미심사,
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
