import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/session.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = Session.fromFirestore(snapshot.data!);
        return Scaffold(
          appBar: AppBar(
            title: Text(session.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.go('/session/$sessionId/detail-input'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 세부 일정 미입력 경고
              if (!session.detailEntered)
                Card(
                  color: Colors.orange[50],
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: const Text('세부 일정을 입력해주세요'),
                    subtitle: const Text('날짜별 상세 일정을 입력하면 할일 알림이 시작됩니다'),
                    trailing: TextButton(
                      onPressed: () =>
                          context.go('/session/$sessionId/detail-input'),
                      child: const Text('입력'),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // 회기 정보
              _InfoCard(session: session),
              const SizedBox(height: 16),
              // 메뉴 카드들
              if (session.hasAgenda)
                _MenuCard(
                  icon: Icons.gavel,
                  title: '안건심사',
                  subtitle: '조례안, 동의안 등 심사 결과',
                  color: const Color(0xFF1B4F8A),
                  onTap: () => context.go('/session/$sessionId/agenda'),
                ),
              if (session.hasBudget)
                _MenuCard(
                  icon: Icons.account_balance_wallet,
                  title: '예산심사',
                  subtitle: '본예산 / 추경 심사 결과',
                  color: Colors.green[700]!,
                  onTap: () => context.go('/session/$sessionId/budget'),
                ),
              if (session.hasReport)
                _MenuCard(
                  icon: Icons.assignment,
                  title: '업무보고',
                  subtitle: '부서별 업무보고 현황',
                  color: Colors.purple[700]!,
                  onTap: () {},
                ),
              if (session.hasAudit)
                _MenuCard(
                  icon: Icons.search,
                  title: '행정사무감사',
                  subtitle: '행감 결과',
                  color: Colors.red[700]!,
                  onTap: () {},
                ),
              const SizedBox(height: 16),
              // 단톡방 안내문
              _DanTalkCard(session: session),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Session session;
  const _InfoCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy. M. d.');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('회기 정보',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.type.label,
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),
            _InfoRow('회기 기간',
                '${fmt.format(session.startDate)} ~ ${fmt.format(session.endDate)}'),
            if (session.agendaDate != null)
              _InfoRow('안건심사일', fmt.format(session.agendaDate!)),
            if (session.budgetDate != null)
              _InfoRow('예산심사일', fmt.format(session.budgetDate!)),
            if (session.reportDate != null)
              _InfoRow('업무보고일', fmt.format(session.reportDate!)),
            if (session.auditDate != null)
              _InfoRow('행감일', fmt.format(session.auditDate!)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _DanTalkCard extends StatelessWidget {
  final Session session;
  const _DanTalkCard({required this.session});

  String _generateMessage(String type) {
    final date = type == 'agenda' ? session.agendaDate : session.budgetDate;
    if (date == null) return '';
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    final fmt = DateFormat('yyyy. M. d.');
    final dayStr = days[date.weekday % 7];
    return '''안녕하십니까, 도시위원회 전문위원입니다.

오는 ${fmt.format(date)}($dayStr) ${session.name} 도시위원회가 개최될 예정입니다.

📅 일시 : ${fmt.format(date)}($dayStr) 10:00
📍 장소 : 도시위원회 회의실

검토보고서 및 오늘의 의사일정을 함께 송부드리오니 참고하시기 바랍니다.

감사합니다.''';
  }

  @override
  Widget build(BuildContext context) {
    if (!session.detailEntered) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💬 단톡방 안내문',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            if (session.hasAgenda && session.agendaDate != null)
              _MessageButton(
                label: '안건심사 안내문',
                message: _generateMessage('agenda'),
              ),
            if (session.hasBudget && session.budgetDate != null)
              _MessageButton(
                label: '예산심사 안내문',
                message: _generateMessage('budget'),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  final String label;
  final String message;
  const _MessageButton({required this.label, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(label),
              content: SelectableText(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ],
            ),
          );
        },
        child: const Text('보기'),
      ),
    );
  }
}
