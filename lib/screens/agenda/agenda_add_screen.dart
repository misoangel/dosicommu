import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/agenda.dart';

class AgendaAddScreen extends StatefulWidget {
  final String sessionId;
  const AgendaAddScreen({super.key, required this.sessionId});

  @override
  State<AgendaAddScreen> createState() => _AgendaAddScreenState();
}

class _AgendaAddScreenState extends State<AgendaAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _proposerController = TextEditingController();
  final _amendmentController = TextEditingController();
  AgendaType _type = AgendaType.ordinance;
  ProposerType _proposerType = ProposerType.department;
  AgendaResult _result = AgendaResult.original;
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('agendas').add({
        'sessionId': widget.sessionId,
        'title': _titleController.text.trim(),
        'type': _type.name,
        'proposerType': _proposerType.name,
        'proposer': _proposerController.text.trim(),
        'result': _result.name,
        'amendment': _result == AgendaResult.amended
            ? _amendmentController.text.trim() : null,
        'fileUrls': [],
        'fileNames': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) context.go('/session/${widget.sessionId}/agenda');
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
      appBar: AppBar(title: const Text('안건 등록')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: '안건명', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '안건명을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            const Text('안건 종류', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AgendaType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (v) => setState(() => _type = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('발의 유형', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: ProposerType.values.map((type) {
                return Expanded(
                  child: RadioListTile(
                    title: Text(type.label),
                    value: type,
                    groupValue: _proposerType,
                    onChanged: (v) => setState(() => _proposerType = v!),
                  ),
                );
              }).toList(),
            ),
            TextFormField(
              controller: _proposerController,
              decoration: InputDecoration(
                labelText: _proposerType == ProposerType.member ? '발의 의원' : '발의 부서',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? '발의자를 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            const Text('심사 결과', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AgendaResult.values.map((result) {
                return ChoiceChip(
                  label: Text(result.label),
                  selected: _result == result,
                  onSelected: (v) => setState(() => _result = result),
                );
              }).toList(),
            ),
            if (_result == AgendaResult.amended) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _amendmentController,
                decoration: const InputDecoration(
                    labelText: '수정 내용', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
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
