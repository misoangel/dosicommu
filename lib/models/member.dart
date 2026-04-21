import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberRole { chair, viceChair, member }
enum Party { ppp, dp, independent, other }

extension MemberRoleLabel on MemberRole {
  String get label {
    switch (this) {
      case MemberRole.chair: return '위원장';
      case MemberRole.viceChair: return '부위원장';
      case MemberRole.member: return '위원';
    }
  }
}

extension PartyLabel on Party {
  String get label {
    switch (this) {
      case Party.ppp: return '국민의힘';
      case Party.dp: return '더불어민주당';
      case Party.independent: return '무소속';
      case Party.other: return '기타';
    }
  }
}

class Member {
  final String id;
  final String name;
  final String district;
  final MemberRole role;
  final Party party;
  final DateTime termStart;
  final DateTime termEnd;
  final bool isActive;

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
        orElse: () => MemberRole.member,
      ),
      party: Party.values.firstWhere(
        (e) => e.name == data['party'],
        orElse: () => Party.independent,
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
