import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/agenda.dart';

// ================================================================
// 안건 목록
// ================================================================
class AgendaListScreen extends StatelessWidget {
  final String sessionId;
  const AgendaListScreen({super.key, required this.sessionId});

  Color _resultColor(AgendaResult result) {
    switch (result) {
      case AgendaResult.original:
        return Colors.green;
      case AgendaResult.amended:
        return Colors.blue;
      case AgendaResult.rejected:
        return Colors.red;
      case AgendaResult.deferred:
        return Colors.orange;
      case AgendaResult.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('안건심사')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agendas')
            .where('sessionId', isEqualTo: sessionId)
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final agendas = snapshot.data!.docs
              .map((doc) => Agenda.fromFirestore(doc))
              .toList();

          if (agendas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('등록된 안건이 없습니다',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.go('/session/$sessionId/agenda/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('안건 등록'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: agendas.length,
            itemBuilder: (context, index) {
              final agenda = agendas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(agenda.title),
                  subtitle: Text('${agenda.type.label} · ${agenda.proposer}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _resultColor(agenda.result).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      agenda.result.label,
                      style: TextStyle(
                        color: _resultColor(agenda.result),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => context.go(
                      '/session/$sessionId/agenda/${agenda.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/session/$sessionId/agenda/add'),
        icon: const Icon(Icons.add),
        label: const Text('안건 등록'),
        backgroundColor: const Color(0xFF1B4F8A),
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ================================================================
// 안건 등록
// ================================================================
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
            ? _amendmentController.text.trim()
            : null,
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
                labelText: '안건명',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? '안건명을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            // 안건 종류
            const Text('안건 종류',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AgendaType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name),
                  selected: _type == type,
                  onSelected: (v) => setState(() => _type = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 발의 유형
            const Text('발의 유형',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: ProposerType.values.map((type) {
                return Expanded(
                  child: RadioListTile(
                    title: Text(type.name),
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
                labelText: _proposerType == ProposerType.member
                    ? '발의 의원'
                    : '발의 부서',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? '발의자를 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            // 심사 결과
            const Text('심사 결과',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AgendaResult.values.map((result) {
                return ChoiceChip(
                  label: Text(result.name),
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
                  labelText: '수정 내용',
                  border: OutlineInputBorder(),
                ),
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

// ================================================================
// 안건 상세
// ================================================================
class AgendaDetailScreen extends StatelessWidget {
  final String sessionId;
  final String agendaId;
  const AgendaDetailScreen(
      {super.key, required this.sessionId, required this.agendaId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agendas')
          .doc(agendaId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final agenda = Agenda.fromFirestore(snapshot.data!);
        return Scaffold(
          appBar: AppBar(title: Text(agenda.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row('안건 종류', agenda.type.label),
                      _Row('발의 유형', agenda.proposerType.name),
                      _Row('발의자/부서', agenda.proposer),
                      _Row('심사 결과', agenda.result.label),
                      if (agenda.amendment != null)
                        _Row('수정 내용', agenda.amendment!),
                    ],
                  ),
                ),
              ),
              if (agenda.fileNames.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('첨부 파일',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...agenda.fileNames.asMap().entries.map((e) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf,
                          color: Colors.red),
                      title: Text(e.value),
                      trailing: const Icon(Icons.download),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
