import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text('$year년 통계')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('agendas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final agendas = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          final total = agendas.length;
          final cntOriginal = agendas.where((a) => a['result'] == 'original').length;
          final cntAmended = agendas.where((a) => a['result'] == 'amended').length;
          final cntRejected = agendas.where((a) => a['result'] == 'rejected').length;
          final cntDeferred = agendas.where((a) => a['result'] == 'deferred').length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('안건 처리 현황',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      _StatRow('전체 안건', total, Colors.grey),
                      _StatRow('원안가결', cntOriginal, Colors.green),
                      _StatRow('수정가결', cntAmended, Colors.blue),
                      _StatRow('부결', cntRejected, Colors.red),
                      _StatRow('보류', cntDeferred, Colors.orange),
                    ],
                  ),
                ),
              ),
              if (total > 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('처리 비율',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              if (cntOriginal > 0)
                                Expanded(
                                  flex: cntOriginal,
                                  child: Container(
                                    height: 32, color: Colors.green,
                                    child: Center(child: Text('원안 $cntOriginal',
                                        style: const TextStyle(color: Colors.white, fontSize: 11))),
                                  ),
                                ),
                              if (cntAmended > 0)
                                Expanded(
                                  flex: cntAmended,
                                  child: Container(
                                    height: 32, color: Colors.blue,
                                    child: Center(child: Text('수정 $cntAmended',
                                        style: const TextStyle(color: Colors.white, fontSize: 11))),
                                  ),
                                ),
                              if (cntRejected > 0)
                                Expanded(
                                  flex: cntRejected,
                                  child: Container(
                                    height: 32, color: Colors.red,
                                    child: Center(child: Text('부결 $cntRejected',
                                        style: const TextStyle(color: Colors.white, fontSize: 11))),
                                  ),
                                ),
                              if (cntDeferred > 0)
                                Expanded(
                                  flex: cntDeferred,
                                  child: Container(
                                    height: 32, color: Colors.orange,
                                    child: Center(child: Text('보류 $cntDeferred',
                                        style: const TextStyle(color: Colors.white, fontSize: 11))),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$value건',
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
