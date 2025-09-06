import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateNavigator extends StatelessWidget {
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChange;

  const DateNavigator({
    super.key,
    required this.currentDate,
    required this.onDateChange,
  });

  String _formatDate(DateTime date) {
    final formatter = DateFormat('y年M月d日 (E)', 'ja_JP');
    return formatter.format(date);
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isFuture(DateTime date) {
    final today = DateTime.now();
    return date.isAfter(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                final previousDay = currentDate.subtract(const Duration(days: 1));
                onDateChange(previousDay);
              },
              icon: const Icon(Icons.chevron_left),
              iconSize: 20,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(currentDate),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (_isToday(currentDate)) ...[
                    const SizedBox(width: 8),
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
                        '今日',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isToday(currentDate))
                  TextButton(
                    onPressed: () => onDateChange(DateTime.now()),
                    child: const Text(
                      '今日',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                IconButton(
                  onPressed: _isFuture(currentDate)
                      ? null
                      : () {
                          final nextDay = currentDate.add(const Duration(days: 1));
                          onDateChange(nextDay);
                        },
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
