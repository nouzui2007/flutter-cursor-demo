import 'package:flutter/material.dart';
import '../../models/staff.dart';

class StaffSelector extends StatefulWidget {
  final List<MasterStaff> masterStaffList;
  final List<WorkingStaff> workingStaffList;
  final ValueChanged<List<WorkingStaff>> onUpdateWorkingStaff;

  const StaffSelector({
    super.key,
    required this.masterStaffList,
    required this.workingStaffList,
    required this.onUpdateWorkingStaff,
  });

  @override
  State<StaffSelector> createState() => _StaffSelectorState();
}

class _StaffSelectorState extends State<StaffSelector> {
  bool _showSelector = false;

  void _toggleStaffSelection(MasterStaff masterStaff) {
    final existingStaffIndex = widget.workingStaffList
        .indexWhere((ws) => ws.id == masterStaff.id);

    if (existingStaffIndex != -1) {
      // 既に選択済みの場合は削除
      final updatedList = List<WorkingStaff>.from(widget.workingStaffList);
      updatedList.removeAt(existingStaffIndex);
      widget.onUpdateWorkingStaff(updatedList);
    } else {
      // 新規選択の場合は追加
      final newWorkingStaff = WorkingStaff.fromMasterStaff(masterStaff);
      widget.onUpdateWorkingStaff([...widget.workingStaffList, newWorkingStaff]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.workingStaffList.length;
    final availableStaff = widget.masterStaffList
        .where((master) =>
            !widget.workingStaffList.any((working) => working.id == master.id))
        .toList();

    if (!_showSelector) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        selectedCount > 0
                            ? '出勤スタッフ ($selectedCount名)'
                            : '出勤スタッフ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _showSelector = true),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('スタッフ選択'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              if (selectedCount > 0) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.workingStaffList.map((staff) {
                    return Chip(
                      label: Text(
                        '${staff.name} (${staff.department})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[100],
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '出勤スタッフを選択',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _showSelector = false),
                  child: const Text('完了'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 選択済みスタッフ
                    ...widget.workingStaffList.map((staff) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: true,
                              onChanged: (_) => _toggleStaffSelection(staff),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${staff.department} | ID: ${staff.employeeId}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '選択中',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // 選択可能スタッフ
                    ...availableStaff.map((staff) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (_) => _toggleStaffSelection(staff),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${staff.department} | ID: ${staff.employeeId}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            if (availableStaff.isEmpty && widget.workingStaffList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '全てのスタッフが選択済みです',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
