import 'package:cloud_firestore/cloud_firestore.dart';

class Department {
  final String id;
  final String name;
  final String category;  // 본청/사업소 등
  final String work;      // 주요 업무
  final bool isActive;

  Department({
    required this.id,
    required this.name,
    required this.category,
    required this.work,
    this.isActive = true,
  });

  factory Department.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      work: data['work'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'work': work,
      'isActive': isActive,
    };
  }
}
