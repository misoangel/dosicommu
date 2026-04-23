import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/budget.dart';
import '../../models/member.dart';
import '../../models/department.dart';

// ================================================================
// 예산심사 화면
// ================================================================
class BudgetScreen extends StatelessWidget {
  final String sessionId;
  const BudgetScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('예산심사')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('budgets')
            .where('sessionId', isEqualTo: sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final budgets = snapshot.data!.docs
              .map((doc) => Budget.fromFirestore(doc))
              .toList();

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('등록된 예산심사가 없습니다',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.go('/session/$sessionId/budget/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('예산심사 등록'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(budget.type.label,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              budget.result.label,
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      if (budget.adjustments.isNotEmpty) ...[
                        const Divider(),
                        const Text('계수조정 내역',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...budget.adjustments.map((adj) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(child: Text(adj.department)),
                                  Expanded(child: Text(adj.item)),
                                  Text(
                                    '${adj.difference > 0 ? '+' : ''}${adj.difference}',
                                    style: TextStyle(
                                      color: adj.difference > 0
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                      if (budget.budgetCommitteeMembers.isNotEmpty) ...[
                        const Divider(),
                        const Text('예결위 위원',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(budget.budgetCommitteeMembers.join(', ')),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/session/$sessionId/budget/add'),
        icon: const Icon(Icons.add),
        label: const Text('예산심사 등록'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ================================================================
// 예산심사 등록
// ================================================================
class BudgetAddScreen extends StatefulWidget {
  final String sessionId;
  const BudgetAddScreen({super.key, required this.sessionId});

  @override
  State<BudgetAddScreen> createState() => _BudgetAddScreenState();
}

class _BudgetAddScreenState extends State<BudgetAddScreen> {
  BudgetType _type = BudgetType.supplementary;
  BudgetResult _result = BudgetResult.original;
  final List<BudgetAdjustment> _adjustments = [];
  final List<String> _committeeMembers = [];
  final _memberController = TextEditingController();
  bool _isLoading = false;

  void _addAdjustment() {
    final deptCtrl = TextEditingController();
    final itemCtrl = TextEditingController();
    final origCtrl = TextEditingController();
    final adjCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계수조정 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: deptCtrl,
                decoration:
                    const InputDecoration(labelText: '부서명')),
            TextField(
                controller: itemCtrl,
                decoration:
                    const InputDecoration(labelText: '항목')),
            TextField(
                controller: origCtrl,
                decoration:
                    const InputDecoration(labelText: '원안 금액'),
                keyboardType: TextInputType.number),
            TextField(
                controller: adjCtrl,
                decoration:
                    const InputDecoration(labelText: '조정 금액'),
                keyboardType: TextInputType.number),
            TextField(
                controller: reasonCtrl,
                decoration:
                    const InputDecoration(labelText: '조정 사유')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              final orig = int.tryParse(origCtrl.text) ?? 0;
              final adj = int.tryParse(adjCtrl.text) ?? 0;
              setState(() {
                _adjustments.add(BudgetAdjustment(
                  department: deptCtrl.text,
                  item: itemCtrl.text,
                  originalAmount: orig,
                  adjustedAmount: adj,
                  difference: adj - orig,
                  reason: reasonCtrl.text,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('budgets').add({
        'sessionId': widget.sessionId,
        'type': _type.label,
        'result': _result.label,
        'adjustments': _adjustments.map((e) => e.toMap()).toList(),
        'budgetCommitteeMembers': _committeeMembers,
        'fileUrls': [],
        'fileNames': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) context.go('/session/${widget.sessionId}/budget');
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
      appBar: AppBar(title: const Text('예산심사 등록')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('예산 종류',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: BudgetType.values.map((type) {
              return Expanded(
                child: RadioListTile(
                  title: Text(type.name),
                  value: type,
                  groupValue: _type,
                  onChanged: (v) => setState(() => _type = v!),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('심사 결과',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: BudgetResult.values.map((result) {
              return ChoiceChip(
                label: Text(result.name),
                selected: _result == result,
                onSelected: (v) => setState(() => _result = result),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('계수조정 내역',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: _addAdjustment,
                icon: const Icon(Icons.add),
                label: const Text('추가'),
              ),
            ],
          ),
          ..._adjustments.map((adj) => Card(
                child: ListTile(
                  title: Text('${adj.department} · ${adj.item}'),
                  subtitle: Text(adj.reason),
                  trailing: Text(
                    '${adj.difference > 0 ? '+' : ''}${adj.difference}',
                    style: TextStyle(
                      color: adj.difference > 0 ? Colors.blue : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          const Text('예결위 위원',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _memberController,
                  decoration:
                      const InputDecoration(hintText: '위원 이름 입력'),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_memberController.text.isNotEmpty) {
                    setState(() {
                      _committeeMembers.add(_memberController.text);
                      _memberController.clear();
                    });
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _committeeMembers
                .map((m) => Chip(
                      label: Text(m),
                      onDeleted: () =>
                          setState(() => _committeeMembers.remove(m)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('등록', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// 위원 목록
// ================================================================
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
                    child: Text(
                      member.name[0],
                      style:
                          const TextStyle(color: Color(0xFF1B4F8A)),
                    ),
                  ),
                  title: Text(member.name),
                  subtitle: Text('${member.district} · ${member.party.label}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF1B4F8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      member.role.label,
                      style: const TextStyle(
                          color: Color(0xFF1B4F8A), fontSize: 12),
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

// ================================================================
// 위원 등록
// ================================================================
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
  DateTime _termStart = DateTime.now();
  DateTime _termEnd = DateTime.now().add(const Duration(days: 365 * 4));
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
// 부서 목록
// ================================================================
class DepartmentListScreen extends StatelessWidget {
  const DepartmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('부서 관리')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('departments')
            .where('isActive', isEqualTo: true)
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final departments = snapshot.data!.docs
              .map((doc) => Department.fromFirestore(doc))
              .toList();

          if (departments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('등록된 부서가 없습니다',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    child:
                        const Icon(Icons.business, color: Colors.purple),
                  ),
                  title: Text(dept.name),
                  subtitle: Text(dept.category),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/departments/add'),
        icon: const Icon(Icons.add),
        label: const Text('부서 등록'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ================================================================
// 부서 등록
// ================================================================
class DepartmentAddScreen extends StatefulWidget {
  const DepartmentAddScreen({super.key});

  @override
  State<DepartmentAddScreen> createState() => _DepartmentAddScreenState();
}

class _DepartmentAddScreenState extends State<DepartmentAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _workController = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('departments').add({
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'work': _workController.text.trim(),
        'isActive': true,
      });
      if (mounted) context.go('/departments');
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
      appBar: AppBar(title: const Text('부서 등록')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: '부서명', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? '부서명을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: '구분',
                hintText: '예) 본청, 사업소',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workController,
              decoration: const InputDecoration(
                  labelText: '주요 업무', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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
// 통계
// ================================================================
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text('$year년 통계')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agendas')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final agendas = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          final total = agendas.length;
          final cntOriginal = agendas
              .where((a) => a['result'] == '원안가결')
              .length;
          final cntAmended = agendas
              .where((a) => a['result'] == '수정가결')
              .length;
          final cntRejected = agendas
              .where((a) => a['result'] == '부결')
              .length;
          final cntDeferred = agendas
              .where((a) => a['result'] == '보류')
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 전체 통계
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('안건 처리 현황',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 16),
              // 비율 바
              if (total > 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('처리 비율',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              if (cntOriginal > 0)
                                Expanded(
                                  flex: cntOriginal,
                                  child: Container(
                                    height: 32,
                                    color: Colors.green,
                                    child: Center(
                                      child: Text(
                                        '원안 $cntOriginal',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                              if (cntAmended > 0)
                                Expanded(
                                  flex: cntAmended,
                                  child: Container(
                                    height: 32,
                                    color: Colors.blue,
                                    child: Center(
                                      child: Text(
                                        '수정 $cntAmended',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                              if (cntRejected > 0)
                                Expanded(
                                  flex: cntRejected,
                                  child: Container(
                                    height: 32,
                                    color: Colors.red,
                                    child: Center(
                                      child: Text(
                                        '부결 $cntRejected',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                              if (cntDeferred > 0)
                                Expanded(
                                  flex: cntDeferred,
                                  child: Container(
                                    height: 32,
                                    color: Colors.orange,
                                    child: Center(
                                      child: Text(
                                        '보류 $cntDeferred',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11),
                                      ),
                                    ),
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
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            '$value건',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
