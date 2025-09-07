import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/staff.dart';

void main() {
  group('勤怠管理 - 基本機能テスト', () {
    group('Staffモデル', () {
      test('MasterStaffの作成とJSON変換', () {
        // Arrange
        final staff = MasterStaff(
          id: '001',
          name: '田中 太郎',
          department: '営業部',
          employeeId: 'EMP001',
        );

        // Act
        final json = staff.toJson();
        final restored = MasterStaff.fromJson(json);

        // Assert
        expect(staff, equals(restored));
        expect(json['id'], equals('001'));
        expect(json['name'], equals('田中 太郎'));
        expect(json['department'], equals('営業部'));
        expect(json['employeeId'], equals('EMP001'));
      });

      test('WorkingStaffの作成とコピー', () {
        // Arrange
        final workingStaff = WorkingStaff(
          id: '001',
          name: '田中 太郎',
          department: '営業部',
          employeeId: 'EMP001',
          startTime: '09:00',
          endTime: '18:00',
          isSelected: true,
        );

        // Act
        final copied = workingStaff.copyWith(
          startTime: '10:00',
          isSelected: false,
        );

        // Assert
        expect(copied.id, equals(workingStaff.id));
        expect(copied.name, equals(workingStaff.name));
        expect(copied.department, equals(workingStaff.department));
        expect(copied.employeeId, equals(workingStaff.employeeId));
        expect(copied.startTime, equals('10:00'));
        expect(copied.endTime, equals(workingStaff.endTime));
        expect(copied.isSelected, equals(false));
      });

      test('MasterStaffからWorkingStaffへの変換', () {
        // Arrange
        final masterStaff = MasterStaff(
          id: '001',
          name: '田中 太郎',
          department: '営業部',
          employeeId: 'EMP001',
        );

        // Act
        final workingStaff = WorkingStaff.fromMasterStaff(masterStaff);

        // Assert
        expect(workingStaff.id, equals(masterStaff.id));
        expect(workingStaff.name, equals(masterStaff.name));
        expect(workingStaff.department, equals(masterStaff.department));
        expect(workingStaff.employeeId, equals(masterStaff.employeeId));
        expect(workingStaff.startTime, equals(''));
        expect(workingStaff.endTime, equals(''));
        expect(workingStaff.isSelected, equals(true));
      });

      test('WorkingStaffのJSON変換', () {
        // Arrange
        final workingStaff = WorkingStaff(
          id: '001',
          name: '田中 太郎',
          department: '営業部',
          employeeId: 'EMP001',
          startTime: '09:00',
          endTime: '18:00',
          isSelected: true,
        );

        // Act
        final json = workingStaff.toJson();
        final restored = WorkingStaff.fromJson(json);

        // Assert
        expect(workingStaff, equals(restored));
        expect(json['startTime'], equals('09:00'));
        expect(json['endTime'], equals('18:00'));
        expect(json['isSelected'], equals(true));
      });
    });

    group('勤務時間計算', () {
      test('正常な勤務時間の計算', () {
        // Arrange
        const startTime = '09:00';
        const endTime = '18:00';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('9時間0分'));
      });

      test('30分の勤務時間の計算', () {
        // Arrange
        const startTime = '09:00';
        const endTime = '09:30';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('0時間30分'));
      });

      test('1時間30分の勤務時間の計算', () {
        // Arrange
        const startTime = '09:00';
        const endTime = '10:30';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('1時間30分'));
      });

      test('空の時間での計算', () {
        // Arrange
        const startTime = '';
        const endTime = '';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('--'));
      });

      test('無効な時間での計算（終了時間が開始時間より前）', () {
        // Arrange
        const startTime = '18:00';
        const endTime = '09:00';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('--'));
      });

      test('同じ時間での計算', () {
        // Arrange
        const startTime = '09:00';
        const endTime = '09:00';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('--'));
      });
    });

    group('時間フォーマット', () {
      test('24時間形式から12時間形式への変換（AM）', () {
        // Arrange
        const time9 = '09:00';
        const time11 = '11:30';

        // Act
        final formatted9 = _formatTimeDisplay(time9);
        final formatted11 = _formatTimeDisplay(time11);

        // Assert
        expect(formatted9, equals('9:00 AM'));
        expect(formatted11, equals('11:30 AM'));
      });

      test('24時間形式から12時間形式への変換（PM）', () {
        // Arrange
        const time14 = '14:30';
        const time18 = '18:00';

        // Act
        final formatted14 = _formatTimeDisplay(time14);
        final formatted18 = _formatTimeDisplay(time18);

        // Assert
        expect(formatted14, equals('2:30 PM'));
        expect(formatted18, equals('6:00 PM'));
      });

      test('深夜時間の変換', () {
        // Arrange
        const time0 = '00:15';
        const time12 = '12:00';

        // Act
        final formatted0 = _formatTimeDisplay(time0);
        final formatted12 = _formatTimeDisplay(time12);

        // Assert
        expect(formatted0, equals('12:15 AM'));
        expect(formatted12, equals('12:00 PM'));
      });

      test('空の時間のフォーマット', () {
        // Arrange
        const emptyTime = '';

        // Act
        final formatted = _formatTimeDisplay(emptyTime);

        // Assert
        expect(formatted, equals('時間を選択'));
      });

      test('無効な時間のフォーマット', () {
        // Arrange
        const invalidTime = 'invalid';

        // Act
        final formatted = _formatTimeDisplay(invalidTime);

        // Assert
        expect(formatted, equals('時間を選択'));
      });
    });

    group('日付キー生成', () {
      test('日付キーの生成', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final dateKey = _getDateKey(date);

        // Assert
        expect(dateKey, equals('2024-01-15'));
      });

      test('異なる日付でのキー生成', () {
        // Arrange
        final date1 = DateTime(2024, 12, 31);
        final date2 = DateTime(2023, 2, 28);

        // Act
        final dateKey1 = _getDateKey(date1);
        final dateKey2 = _getDateKey(date2);

        // Assert
        expect(dateKey1, equals('2024-12-31'));
        expect(dateKey2, equals('2023-02-28'));
      });
    });

    group('合計勤務時間計算', () {
      test('複数スタッフの合計勤務時間', () {
        // Arrange
        final staffList = [
          WorkingStaff(
            id: '001',
            name: '田中 太郎',
            department: '営業部',
            employeeId: 'EMP001',
            startTime: '09:00',
            endTime: '18:00',
            isSelected: true,
          ),
          WorkingStaff(
            id: '002',
            name: '佐藤 花子',
            department: '営業部',
            employeeId: 'EMP002',
            startTime: '10:00',
            endTime: '19:00',
            isSelected: true,
          ),
        ];

        // Act
        final totalTime = _getTotalWorkTime(staffList);

        // Assert
        expect(totalTime, equals('18時間0分'));
      });

      test('空のスタッフリストでの合計時間', () {
        // Arrange
        final staffList = <WorkingStaff>[];

        // Act
        final totalTime = _getTotalWorkTime(staffList);

        // Assert
        expect(totalTime, equals('--'));
      });

      test('時間が設定されていないスタッフでの合計時間', () {
        // Arrange
        final staffList = [
          WorkingStaff(
            id: '001',
            name: '田中 太郎',
            department: '営業部',
            employeeId: 'EMP001',
            startTime: '',
            endTime: '',
            isSelected: true,
          ),
        ];

        // Act
        final totalTime = _getTotalWorkTime(staffList);

        // Assert
        expect(totalTime, equals('--'));
      });
    });
  });
}

// ヘルパー関数
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

String _getDateKey(DateTime date) {
  return date.toIso8601String().split('T')[0];
}

String _getTotalWorkTime(List<WorkingStaff> staffList) {
  int totalMinutes = 0;
  
  for (final staff in staffList) {
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
