import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/budget.dart';

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

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('budgets').add({
        'sessionId': widget.sessionId,
        'type': _type.name,
        'result': _result.name,
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
          const Text('예산 종류', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: BudgetType.values.map((type) {
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
          const Text('심사 결과', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: BudgetResult.values.map((result) {
              return ChoiceChip(
                label: Text(result.label),
                selected: _result == result,
                onSelected: (v) => setState(() => _result = result),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('예결위 위원', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _memberController,
                  decoration: const InputDecoration(hintText: '위원 이름 입력'),
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
                      onDeleted: () => setState(() => _committeeMembers.remove(m)),
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
