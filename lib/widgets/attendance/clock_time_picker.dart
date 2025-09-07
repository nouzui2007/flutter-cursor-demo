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
  ClockMode mode = ClockMode.hour;

  @override
  void initState() {
    super.initState();
    _parseInitialTime();
  }

  void _parseInitialTime() {
    if (widget.initialTime != null && widget.initialTime!.isNotEmpty) {
      final parts = widget.initialTime!.split(':');
      selectedHour = int.parse(parts[0]);
      selectedMinute = int.parse(parts[1]);
    } else {
      selectedHour = 9;
      selectedMinute = 0;
    }
  }

  String get _displayTime {
    final hour = selectedHour.toString().padLeft(2, '0');
    final minute = selectedMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    final timeString = '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
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
            const SizedBox(height: 6),
            // 時計
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(160), // 円形
              ),
              child: Stack(
                children: [
                  // 時計の描画
                  CustomPaint(
                    size: const Size(320, 320),
                    painter: ClockPainter(
                      selectedHour: selectedHour,
                      selectedMinute: selectedMinute,
                      mode: mode,
                      onHourTap: _handleHourTap,
                      onMinuteTap: _handleMinuteTap,
                    ),
                  ),
                  // 内側の数字ボタン（1-12）
                  ...List.generate(12, (index) {
                    final numbers = mode == ClockMode.hour 
                        ? [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                        : [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
                    final value = numbers[index];
                    // 12時の位置から時計回りに配置
                    final angle = (index * math.pi * 2 / 12) - math.pi / 2;
                    // 時間は内側半径70、分は半径100
                    final radius = mode == ClockMode.hour ? 70 : 100;
                    final x = 160 + math.cos(angle) * radius; // 中心を160に調整
                    final y = 160 + math.sin(angle) * radius; // 中心を160に調整
                    
                    // 数字ボタンを右にずらして、12と6が直線で結ばれるようにする
                    // 12と6の位置を調整して、時計の中心を通る垂直線に配置
                    const offsetX = -30; // 右に20ピクセルずらす（針の付け根と12と6を直線に）
                    final adjustedX = x + offsetX;
                    
                    final isSelected = mode == ClockMode.hour
                        ? value == selectedHour
                        : value == selectedMinute;
                    
                    return Positioned(
                      left: adjustedX - 20,
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
                            border: isSelected ? Border.all(
                              color: Colors.blue,
                              width: 2,
                            ) : null,
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
                  // 外側の数字ボタン（13-24）- 時間選択時のみ表示
                  if (mode == ClockMode.hour)
                    ...List.generate(12, (index) {
                      final numbers = [24, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
                      final value = numbers[index];
                      // 12時の位置から時計回りに配置
                      final angle = (index * math.pi * 2 / 12) - math.pi / 2;
                      final x = 160 + math.cos(angle) * 100; // 中心160, 半径100（外側の数字）
                      final y = 160 + math.sin(angle) * 100; // 中心160
                      
                      // 数字ボタンを右にずらして、12と6が直線で結ばれるようにする
                      // 24と18の位置を調整して、時計の中心を通る垂直線に配置
                      const offsetX = -30; // 右に20ピクセルずらす（針の付け根と24と18を直線に）
                      final adjustedX = x + offsetX;
                      
                      final isSelected = value == selectedHour;
                      
                      return Positioned(
                        left: adjustedX - 20,
                        top: y - 20,
                        child: GestureDetector(
                          onTap: () {
                            print('Tapped: $value (mode: $mode)');
                            _handleHourTap(value);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(
                                color: Colors.blue,
                                width: 2,
                              ) : null,
                            ),
                            child: Center(
                              child: Text(
                                value.toString(),
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
            const SizedBox(height: 6),
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
    final center = Offset(size.width / 2 - 3, size.height / 2);
    final radius = size.width / 2 - 10;

    // 時計の外枠を描画
    final outerPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, outerPaint);

    // 目盛り線は削除（数字ボタンと重なるため）

    // 中心点を描画
    final centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);

    // 針を描画
    if (mode == ClockMode.hour) {
      // 時間の針（半径70）
      final hour12 = selectedHour == 0 ? 12 : (selectedHour > 12 ? selectedHour - 12 : selectedHour);
      final hourAngle = hour12 * math.pi * 2 / 12 - math.pi / 2;
      final hourEndX = center.dx + math.cos(hourAngle) * 50; // 内側の数字の位置（半径70）
      final hourEndY = center.dy + math.sin(hourAngle) * 50;
      
      final hourPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(center, Offset(hourEndX, hourEndY), hourPaint);
    } else {
      // 分の針（半径100）
      final minuteAngle = (selectedMinute / 5) * math.pi * 2 / 12 - math.pi / 2;
      final minuteEndX = center.dx + math.cos(minuteAngle) * 70; // 分の数字の位置（半径100）
      final minuteEndY = center.dy + math.sin(minuteAngle) * 70;
      
      final minutePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(center, Offset(minuteEndX, minuteEndY), minutePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
