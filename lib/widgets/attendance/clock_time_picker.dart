import 'package:flutter/material.dart';
import 'dart:math' as math;

class ClockTimePicker extends StatefulWidget {
  final String? initialTime;
  final ValueChanged<String> onTimeChanged;

  const ClockTimePicker({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<ClockTimePicker> createState() => _ClockTimePickerState();
}

class _ClockTimePickerState extends State<ClockTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  late bool isAM;
  ClockMode mode = ClockMode.hour;

  @override
  void initState() {
    super.initState();
    _parseInitialTime();
  }

  void _parseInitialTime() {
    if (widget.initialTime != null && widget.initialTime!.isNotEmpty) {
      final parts = widget.initialTime!.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours == 0) {
        selectedHour = 12;
        isAM = true;
      } else if (hours <= 12) {
        selectedHour = hours;
        isAM = true;
      } else {
        selectedHour = hours - 12;
        isAM = false;
      }
      selectedMinute = minutes;
    } else {
      selectedHour = 9;
      selectedMinute = 0;
      isAM = true;
    }
  }

  String get _displayTime {
    final minute = selectedMinute.toString().padLeft(2, '0');
    return '$selectedHour:$minute ${isAM ? 'AM' : 'PM'}';
  }

  void _handleHourTap(int hour) {
    setState(() {
      selectedHour = hour;
      mode = ClockMode.minute;
    });
  }

  void _handleMinuteTap(int minute) {
    setState(() {
      selectedMinute = minute;
    });
  }

  void _handleConfirm() {
    int hour24 = selectedHour;
    if (selectedHour == 12) {
      hour24 = isAM ? 0 : 12;
    } else {
      hour24 = isAM ? selectedHour : selectedHour + 12;
    }

    final timeString = '${hour24.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
    widget.onTimeChanged(timeString);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '時間選択',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            // 時間表示
            Text(
              _displayTime,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // 時/分切り替えボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => mode = ClockMode.hour),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode == ClockMode.hour
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    foregroundColor: mode == ClockMode.hour
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: const Text('時'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => mode = ClockMode.minute),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode == ClockMode.minute
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    foregroundColor: mode == ClockMode.minute
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: const Text('分'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 時計
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                children: [
                  // 時計の描画
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: ClockPainter(
                      selectedHour: selectedHour,
                      selectedMinute: selectedMinute,
                      mode: mode,
                      onHourTap: _handleHourTap,
                      onMinuteTap: _handleMinuteTap,
                    ),
                  ),
                  // タップ可能な数字ボタン
                  ...List.generate(12, (index) {
                    final numbers = mode == ClockMode.hour 
                        ? [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                        : [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
                    final value = numbers[index];
                    final angle = (index * math.pi * 2 / 12) - math.pi / 2;
                    final x = 120 + math.cos(angle) * 80; // 半径を80に調整
                    final y = 120 + math.sin(angle) * 80;
                    
                    final isSelected = mode == ClockMode.hour
                        ? value == selectedHour
                        : value == selectedMinute;
                    
                    return Positioned(
                      left: x - 20,
                      top: y - 20,
                      child: GestureDetector(
                        onTap: () {
                          print('Tapped: $value (mode: $mode)');
                          if (mode == ClockMode.hour) {
                            _handleHourTap(value);
                          } else {
                            _handleMinuteTap(value);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              value.toString().padLeft(mode == ClockMode.minute ? 2 : 1, '0'),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // AM/PM切り替え
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isAM = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isAM ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'AM',
                        style: TextStyle(
                          color: isAM ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isAM = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: !isAM ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PM',
                        style: TextStyle(
                          color: !isAM ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // アクションボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleConfirm,
                  child: const Text('確定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum ClockMode { hour, minute }

class ClockPainter extends CustomPainter {
  final int selectedHour;
  final int selectedMinute;
  final ClockMode mode;
  final Function(int) onHourTap;
  final Function(int) onMinuteTap;

  ClockPainter({
    required this.selectedHour,
    required this.selectedMinute,
    required this.mode,
    required this.onHourTap,
    required this.onMinuteTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 大きな外周円を描画（数字の外側）
    final outerPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, outerPaint);

    // 数字の位置に小さな目盛りを描画
    final numbers = mode == ClockMode.hour 
        ? [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
        : [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

    for (int i = 0; i < numbers.length; i++) {
      final angle = (i * math.pi * 2 / 12) - math.pi / 2;
      final x = center.dx + math.cos(angle) * (radius - 30);
      final y = center.dy + math.sin(angle) * (radius - 30);

      // 小さな目盛りを描画
      final tickPaint = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final tickStartX = center.dx + math.cos(angle) * (radius - 40);
      final tickStartY = center.dy + math.sin(angle) * (radius - 40);
      final tickEndX = center.dx + math.cos(angle) * (radius - 20);
      final tickEndY = center.dy + math.sin(angle) * (radius - 20);
      
      canvas.drawLine(
        Offset(tickStartX, tickStartY),
        Offset(tickEndX, tickEndY),
        tickPaint,
      );
    }

    // 中心点を描画
    final centerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);

    // 針を描画
    final selectedIndex = mode == ClockMode.hour
        ? numbers.indexOf(selectedHour)
        : numbers.indexOf(selectedMinute);

    if (selectedIndex != -1) {
      final angle = (selectedIndex * math.pi * 2 / 12) - math.pi / 2;
      final endX = center.dx + math.cos(angle) * (radius - 50);
      final endY = center.dy + math.sin(angle) * (radius - 50);

      final handPaint = Paint()
        ..color = mode == ClockMode.hour ? Colors.blue : Colors.red
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, Offset(endX, endY), handPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
