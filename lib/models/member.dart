import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberRole { 위원장, 부위원장, 위원 }
enum Party { 국민의힘, 더불어민주당, 무소속, 기타 }

class Member {
  final String id;
  final String name;
  final String district;     // 선거구
  final MemberRole role;
  final Party party;
  final DateTime termStart;  // 임기 시작
  final DateTime termEnd;    // 임기 종료
  final bool isActive;       // 현직 여부

  Member({
    required this.id,
    required this.name,
    required this.district,
    required this.role,
    required this.party,
    required this.termStart,
    required this.termEnd,
    this.isActive = true,
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Member(
      id: doc.id,
      name: data['name'] ?? '',
      district: data['district'] ?? '',
      role: MemberRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => MemberRole.위원,
      ),
      party: Party.values.firstWhere(
        (e) => e.name == data['party'],
        orElse: () => Party.무소속,
      ),
      termStart: (data['termStart'] as Timestamp).toDate(),
      termEnd: (data['termEnd'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'district': district,
      'role': role.name,
      'party': party.name,
      'termStart': Timestamp.fromDate(termStart),
      'termEnd': Timestamp.fromDate(termEnd),
      'isActive': isActive,
    };
  }
}
