import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/agenda.dart';

class AgendaDetailScreen extends StatelessWidget {
  final String sessionId;
  final String agendaId;
  const AgendaDetailScreen({super.key, required this.sessionId, required this.agendaId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('agendas').doc(agendaId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                      _Row('발의 유형', agenda.proposerType.label),
                      _Row('발의자/부서', agenda.proposer),
                      _Row('심사 결과', agenda.result.label),
                      if (agenda.amendment != null)
                        _Row('수정 내용', agenda.amendment!),
                    ],
                  ),
                ),
              ),
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
          SizedBox(width: 90,
              child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
