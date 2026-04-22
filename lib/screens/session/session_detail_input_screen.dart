import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/session.dart';

class SessionDetailInputScreen extends StatefulWidget {
  final String sessionId;
  const SessionDetailInputScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailInputScreen> createState() =>
      _SessionDetailInputScreenState();
}

class _SessionDetailInputScreenState extends State<SessionDetailInputScreen> {
  DateTime? _agendaDate;
  DateTime? _budgetDate;
  DateTime? _reportDate;
  DateTime? _auditDate;
  bool _isLoading = false;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final doc = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .get();
    setState(() {
      _session = Session.fromFirestore(doc);
      _agendaDate = _session!.agendaDate;
      _budgetDate = _session!.budgetDate;
      _reportDate = _session!.reportDate;
      _auditDate = _session!.auditDate;
    });
  }

  Future<void> _pickDate(String type) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        switch (type) {
          case 'agenda':
            _agendaDate = picked;
            break;
          case 'budget':
            _budgetDate = picked;
            break;
          case 'report':
            _reportDate = picked;
            break;
          case 'audit':
            _auditDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .update({
        'agendaDate':
            _agendaDate != null ? Timestamp.fromDate(_agendaDate!) : null,
        'budgetDate':
            _budgetDate != null ? Timestamp.fromDate(_budgetDate!) : null,
        'reportDate':
            _reportDate != null ? Timestamp.fromDate(_reportDate!) : null,
        'auditDate':
            _auditDate != null ? Timestamp.fromDate(_auditDate!) : null,
        'detailEntered': true,
      });
      if (mounted) context.go('/session/${widget.sessionId}');
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
    if (_session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('세부 일정 입력')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('각 일정의 날짜를 입력해주세요',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          if (_session!.hasAgenda)
            _DateTile(
              label: '안건심사일',
              date: _agendaDate,
              onTap: () => _pickDate('agenda'),
            ),
          if (_session!.hasBudget)
            _DateTile(
              label: '예산심사일',
              date: _budgetDate,
              onTap: () => _pickDate('budget'),
            ),
          if (_session!.hasReport)
            _DateTile(
              label: '업무보고일',
              date: _reportDate,
              onTap: () => _pickDate('report'),
            ),
          if (_session!.hasAudit)
            _DateTile(
              label: '행감일',
              date: _auditDate,
              onTap: () => _pickDate('audit'),
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
                : const Text('저장', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateTile({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        subtitle: Text(
          date != null
              ? '${date!.year}.${date!.month}.${date!.day}'
              : '날짜를 선택해주세요',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: onTap,
      ),
    );
  }
}
