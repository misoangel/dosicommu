import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/member.dart';

class MemberAddScreen extends StatefulWidget {
  const MemberAddScreen({super.key});

  @override
  State<MemberAddScreen> createState() => _MemberAddScreenState();
}

class _MemberAddScreenState extends State<MemberAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  MemberRole _role = MemberRole.member;
  Party _party = Party.ppp;
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('members').add({
        'name': _nameController.text.trim(),
        'district': _districtController.text.trim(),
        'role': _role.name,
        'party': _party.name,
        'termStart': Timestamp.fromDate(DateTime.now()),
        'termEnd': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 365 * 4))),
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
              decoration: const InputDecoration(
                  labelText: '이름', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '이름을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                  labelText: '선거구', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '선거구를 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            const Text('직책',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: MemberRole.values.map((role) {
                return ChoiceChip(
                  label: Text(role.label),
                  selected: _role == role,
                  onSelected: (v) => setState(() => _role = role),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('정당',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: Party.values.map((party) {
                return ChoiceChip(
                  label: Text(party.label),
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
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('등록', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
