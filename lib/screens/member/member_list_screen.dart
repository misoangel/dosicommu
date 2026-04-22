import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/member.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위원 관리')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('members')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final members = snapshot.data!.docs
              .map((doc) => Member.fromFirestore(doc))
              .toList();
          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('등록된 위원이 없습니다',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF1B4F8A).withOpacity(0.1),
                    child: Text(member.name[0],
                        style:
                            const TextStyle(color: Color(0xFF1B4F8A))),
                  ),
                  title: Text(member.name),
                  subtitle:
                      Text('${member.district} · ${member.party.label}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF1B4F8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(member.role.label,
                        style: const TextStyle(
                            color: Color(0xFF1B4F8A), fontSize: 12)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/members/add'),
        icon: const Icon(Icons.add),
        label: const Text('위원 등록'),
        backgroundColor: const Color(0xFF1B4F8A),
        foregroundColor: Colors.white,
      ),
    );
  }
}
