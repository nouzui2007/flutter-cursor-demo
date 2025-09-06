import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/attendance_data_service.dart';
import 'package:flutter_application_1/models/staff.dart';

void main() {
  group('AttendanceDataService', () {
    setUp(() {
      // テスト用のSharedPreferencesを初期化
      SharedPreferences.setMockInitialValues({});
    });

    group('getDateKey', () {
      test('should return correct date key format', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act
        final dateKey = AttendanceDataService.getDateKey(date);

        // Assert
        expect(dateKey, equals('2024-01-15'));
      });

      test('should handle different dates correctly', () {
        // Arrange
        final date1 = DateTime(2024, 12, 31);
        final date2 = DateTime(2023, 2, 28);

        // Act
        final dateKey1 = AttendanceDataService.getDateKey(date1);
        final dateKey2 = AttendanceDataService.getDateKey(date2);

        // Assert
        expect(dateKey1, equals('2024-12-31'));
        expect(dateKey2, equals('2023-02-28'));
      });
    });

    group('loadStaffData', () {
      test('should return empty map when no data exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await AttendanceDataService.loadStaffData();

        // Assert
        expect(result, isEmpty);
      });

      test('should load data correctly when data exists', () async {
        // Arrange
        final testData = <String, Object>{
          'staffTimeData': json.encode({
            '2024-01-15': [
              {
                'id': '001',
                'name': '田中 太郎',
                'department': '営業部',
                'employeeId': 'EMP001',
                'startTime': '09:00',
                'endTime': '18:00',
                'isSelected': true,
              }
            ]
          })
        };
        SharedPreferences.setMockInitialValues(testData);

        // Act
        final result = await AttendanceDataService.loadStaffData();

        // Assert
        expect(result, isNotEmpty);
        expect(result.containsKey('2024-01-15'), isTrue);
        expect(result['2024-01-15']!.length, equals(1));
        expect(result['2024-01-15']!.first.id, equals('001'));
        expect(result['2024-01-15']!.first.name, equals('田中 太郎'));
      });

      test('should handle invalid JSON gracefully', () async {
        // Arrange
        final testData = <String, Object>{
          'staffTimeData': 'invalid json'
        };
        SharedPreferences.setMockInitialValues(testData);

        // Act
        final result = await AttendanceDataService.loadStaffData();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('saveStaffData', () {
      test('should save data correctly', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
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

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('staffTimeData');
        expect(savedData, isNotNull);
        
        // データが正しく保存されているか確認
        final loadedData = await AttendanceDataService.loadStaffData();
        expect(loadedData, equals(staffData));
      });

      test('should save multiple dates correctly', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
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
          ],
          '2024-01-16': [
            WorkingStaff(
              id: '002',
              name: '佐藤 花子',
              department: '営業部',
              employeeId: 'EMP002',
              startTime: '10:00',
              endTime: '19:00',
              isSelected: true,
            )
          ]
        };

        // Act
        await AttendanceDataService.saveStaffData(staffData);

        // Assert
        final loadedData = await AttendanceDataService.loadStaffData();
        expect(loadedData.length, equals(2));
        expect(loadedData.containsKey('2024-01-15'), isTrue);
        expect(loadedData.containsKey('2024-01-16'), isTrue);
        expect(loadedData['2024-01-15']!.length, equals(1));
        expect(loadedData['2024-01-16']!.length, equals(1));
      });

      test('should overwrite existing data', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final initialData = {
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
        await AttendanceDataService.saveStaffData(initialData);

        final updatedData = {
          '2024-01-15': [
            WorkingStaff(
              id: '001',
              name: '田中 太郎',
              department: '営業部',
              employeeId: 'EMP001',
              startTime: '10:00',
              endTime: '19:00',
              isSelected: true,
            )
          ]
        };

        // Act
        await AttendanceDataService.saveStaffData(updatedData);

        // Assert
        final loadedData = await AttendanceDataService.loadStaffData();
        expect(loadedData['2024-01-15']!.first.startTime, equals('10:00'));
        expect(loadedData['2024-01-15']!.first.endTime, equals('19:00'));
      });
    });

    group('integration tests', () {
      test('should save and load data correctly in sequence', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
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
            ),
            WorkingStaff(
              id: '002',
              name: '佐藤 花子',
              department: '営業部',
              employeeId: 'EMP002',
              startTime: '10:00',
              endTime: '19:00',
              isSelected: true,
            )
          ]
        };

        // Act
        await AttendanceDataService.saveStaffData(staffData);
        final loadedData = await AttendanceDataService.loadStaffData();

        // Assert
        expect(loadedData, equals(staffData));
        expect(loadedData['2024-01-15']!.length, equals(2));
        
        final firstStaff = loadedData['2024-01-15']!.first;
        expect(firstStaff.id, equals('001'));
        expect(firstStaff.name, equals('田中 太郎'));
        expect(firstStaff.startTime, equals('09:00'));
        expect(firstStaff.endTime, equals('18:00'));
        
        final secondStaff = loadedData['2024-01-15']!.last;
        expect(secondStaff.id, equals('002'));
        expect(secondStaff.name, equals('佐藤 花子'));
        expect(secondStaff.startTime, equals('10:00'));
        expect(secondStaff.endTime, equals('19:00'));
      });
    });
  });
}
