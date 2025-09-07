import 'package:flutter/material.dart';
import '../../models/staff.dart';
import 'clock_time_picker.dart';

class TimeEntryForm extends StatelessWidget {
  final List<WorkingStaff> workingStaffList;
  final ValueChanged<List<WorkingStaff>> onUpdateStaff;

  const TimeEntryForm({
    super.key,
    required this.workingStaffList,
    required this.onUpdateStaff,
  });

  void _updateStaffTime(String id, String field, String value) {
    final updatedList = workingStaffList.map((staff) {
      if (staff.id == id) {
        if (field == 'startTime') {
          return staff.copyWith(startTime: value);
        } else {
          return staff.copyWith(endTime: value);
        }
      }
      return staff;
    }).toList();
    
    onUpdateStaff(updatedList);
  }

  String _calculateWorkTime(String startTime, String endTime) {
    if (startTime.isEmpty || endTime.isEmpty) return '--';

    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      if (endMinutes <= startMinutes) return '--';
      
      final diffMinutes = endMinutes - startMinutes;
      final hours = diffMinutes ~/ 60;
      final minutes = diffMinutes % 60;
      
      return '$hours時間$minutes分';
    } catch (e) {
      return '--';
    }
  }

  String _getTotalWorkTime() {
    int totalMinutes = 0;
    
    for (final staff in workingStaffList) {
      if (staff.startTime.isNotEmpty && staff.endTime.isNotEmpty) {
        try {
          final startParts = staff.startTime.split(':');
          final endParts = staff.endTime.split(':');
          
          final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
          final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
          
          if (endMin > startMin) {
            totalMinutes += endMin - startMin;
          }
        } catch (e) {
          // エラーの場合は無視
        }
      }
    }
    
    if (totalMinutes == 0) return '--';
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    return '$hours時間$minutes分';
  }

  String _formatTimeDisplay(String time) {
    if (time.isEmpty) return '時間を選択';
    
    try {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final period = hours >= 12 ? 'PM' : 'AM';
      final displayHour = hours == 0 ? 12 : hours > 12 ? hours - 12 : hours;
      
      return '$displayHour:${minutes.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '時間を選択';
    }
  }

  void _showTimePicker(BuildContext context, String staffId, String field, String currentTime) {
    showDialog(
      context: context,
      builder: (context) => ClockTimePicker(
        initialTime: currentTime.isEmpty ? null : currentTime,
        onTimeChanged: (time) => _updateStaffTime(staffId, field, time),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (workingStaffList.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.access_time,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text('出勤スタッフが選択されていません'),
              const SizedBox(height: 8),
              Text(
                '上の「スタッフ選択」から出勤者を選んでください',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // 出勤スタッフの時間入力
        ...workingStaffList.map((staff) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // スタッフ情報
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
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
                  const SizedBox(height: 12),
                  // 時間入力
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '出勤時間',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showTimePicker(
                                  context,
                                  staff.id,
                                  'startTime',
                                  staff.startTime,
                                ),
                                icon: Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                label: Text(
                                  _formatTimeDisplay(staff.startTime),
                                  style: TextStyle(
                                    color: staff.startTime.isEmpty
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '退勤時間',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showTimePicker(
                                  context,
                                  staff.id,
                                  'endTime',
                                  staff.endTime,
                                ),
                                icon: Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                label: Text(
                                  _formatTimeDisplay(staff.endTime),
                                  style: TextStyle(
                                    color: staff.endTime.isEmpty
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 勤務時間表示
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '勤務時間: ${_calculateWorkTime(staff.startTime, staff.endTime)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        // 合計時間
        Card(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '合計勤務時間',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTotalWorkTime(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
