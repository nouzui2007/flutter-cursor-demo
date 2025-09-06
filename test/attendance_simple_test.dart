import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/staff.dart';
import 'package:flutter_application_1/services/attendance_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
    });

    group('AttendanceDataService', () {
      test('日付キーの生成', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final dateKey = AttendanceDataService.getDateKey(date);

        // Assert
        expect(dateKey, equals('2024-01-15'));
      });

      test('空のデータの読み込み', () async {
        // Act
        final data = await AttendanceDataService.loadStaffData();

        // Assert
        expect(data, isEmpty);
      });

      test('データの保存と読み込み', () async {
        // Arrange
        final staffData = {
          '2024-01-15': [
            WorkingStaff(
              id: '001',
              name: '田中 太郎',
              department: '営業部',
              employeeId: 'EMP001',
              startTime: '09:00',
              endTime: '18:00',
              isSelected: true,
            )
          ]
        };

        // Act
        await AttendanceDataService.saveStaffData(staffData);
        final loadedData = await AttendanceDataService.loadStaffData();

        // Assert
        expect(loadedData.length, equals(1));
        expect(loadedData.containsKey('2024-01-15'), isTrue);
        expect(loadedData['2024-01-15']!.length, equals(1));
        expect(loadedData['2024-01-15']!.first.name, equals('田中 太郎'));
      });
    });

    group('勤務時間計算', () {
      test('正常な勤務時間の計算', () {
        // Arrange
        final startTime = '09:00';
        final endTime = '18:00';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('9時間0分'));
      });

      test('30分の勤務時間の計算', () {
        // Arrange
        final startTime = '09:00';
        final endTime = '09:30';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('0時間30分'));
      });

      test('空の時間での計算', () {
        // Arrange
        final startTime = '';
        final endTime = '';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('--'));
      });

      test('無効な時間での計算', () {
        // Arrange
        final startTime = '18:00';
        final endTime = '09:00';

        // Act
        final workTime = _calculateWorkTime(startTime, endTime);

        // Assert
        expect(workTime, equals('--'));
      });
    });

    group('時間フォーマット', () {
      test('24時間形式から12時間形式への変換', () {
        // Arrange
        final time24 = '09:00';
        final time14 = '14:30';
        final time00 = '00:15';

        // Act
        final formatted9 = _formatTimeDisplay(time24);
        final formatted14 = _formatTimeDisplay(time14);
        final formatted0 = _formatTimeDisplay(time00);

        // Assert
        expect(formatted9, equals('9:00 AM'));
        expect(formatted14, equals('2:30 PM'));
        expect(formatted0, equals('12:15 AM'));
      });

      test('空の時間のフォーマット', () {
        // Arrange
        final emptyTime = '';

        // Act
        final formatted = _formatTimeDisplay(emptyTime);

        // Assert
        expect(formatted, equals('時間を選択'));
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
    
    return '${hours}時間${minutes}分';
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
