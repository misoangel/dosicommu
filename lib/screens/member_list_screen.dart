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
                  Text('등록된 위원이 없습니다', style: TextStyle(color: Colors.grey[500])),
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
                    backgroundColor: const Color(0xFF1B4F8A).withOpacity(0.1),
                    child: Text(
                      member.name[0], style: const TextStyle(color: Color(0xFF1B4F8A)),
                    ),
                  ),
                  title: Text(member.name),
                  subtitle: Text('${member.district} · ${member.party.label}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4F8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      member.role.label, style: const TextStyle(color: Color(0xFF1B4F8A), fontSize: 12),
                    ),
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

class MemberAddScreen extends StatefulWidget {
  const MemberAddScreen({super.key});

  @override
  State<MemberAddScreen> createState() => _MemberAddScreenState();
}

class _MemberAddScreenState extends State<MemberAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  late MemberRole _role;
  late Party _party;
  DateTime _termStart = DateTime.now();
  DateTime _termEnd = DateTime.now().add(const Duration(days: 365 * 4));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _role = MemberRole.member;
    _party = Party.ppp;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('members').add({
        'name': _nameController.text.trim(),
        'district': _districtController.text.trim(),
        'role': _role.name,
        'party': _party.name,
        'termStart': Timestamp.fromDate(_termStart),
        'termEnd': Timestamp.fromDate(_termEnd),
        'isActive': true,
      });
      if (mounted) context.go('/members');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위원 등록')),  
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '이름을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: '선거구', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '선거구를 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            const Text('직책', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: MemberRole.values.map((role) {
                return ChoiceChip(
                  label: Text(role.name),
                  selected: _role == role,
                  onSelected: (v) => setState(() => _role = role),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('정당', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: Party.values.map((party) {
                return ChoiceChip(
                  label: Text(party.name),
                  selected: _party == party,
                  onSelected: (v) => setState(() => _party = party),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4F8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('등록', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}