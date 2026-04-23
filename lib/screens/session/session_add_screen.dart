import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/session.dart';

class SessionAddScreen extends StatefulWidget {
  const SessionAddScreen({super.key});

  @override
  State<SessionAddScreen> createState() => _SessionAddScreenState();
}

class _SessionAddScreenState extends State<SessionAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  SessionType _type = SessionType.temporary;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _hasAgenda = false;
  bool _hasBudget = false;
  bool _hasReport = false;
  bool _hasAudit = false;
  bool _isLoading = false;

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('sessions').add({
        'name': _nameController.text.trim(),
        'year': _startDate.year,
        'type': _type.label,
        'startDate': Timestamp.fromDate(_startDate),
        'endDate': Timestamp.fromDate(_endDate),
        'status': SessionStatus.scheduled.name,
        'hasAgenda': _hasAgenda,
        'hasBudget': _hasBudget,
        'hasReport': _hasReport,
        'hasAudit': _hasAudit,
        'detailEntered': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회기 등록')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '회기명',
                hintText: '예) 제307회 임시회',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? '회기명을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            // 회기 종류
            const Text('회기 종류', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: SessionType.values.map((type) {
                return Expanded(
                  child: RadioListTile(
                    title: Text(type.label),
                    value: type,
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 날짜
            const Text('회기 기간', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                        '${_startDate.month}.${_startDate.day} (시작)'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('~'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text('${_endDate.month}.${_endDate.day} (종료)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 포함 일정
            const Text('포함 일정 (대략)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('* 세부 날짜는 나중에 입력하세요',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            CheckboxListTile(
              title: const Text('안건심사'),
              value: _hasAgenda,
              onChanged: (v) => setState(() => _hasAgenda = v!),
            ),
            CheckboxListTile(
              title: const Text('예산심사'),
              value: _hasBudget,
              onChanged: (v) => setState(() => _hasBudget = v!),
            ),
            CheckboxListTile(
              title: const Text('업무보고'),
              value: _hasReport,
              onChanged: (v) => setState(() => _hasReport = v!),
            ),
            CheckboxListTile(
              title: const Text('행정사무감사'),
              value: _hasAudit,
              onChanged: (v) => setState(() => _hasAudit = v!),
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
