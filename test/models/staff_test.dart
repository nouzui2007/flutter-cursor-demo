import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/staff.dart';

void main() {
  group('MasterStaff', () {
    test('should create MasterStaff with correct properties', () {
      // Arrange
      const id = '001';
      const name = '田中 太郎';
      const department = '営業部';
      const employeeId = 'EMP001';

      // Act
      final staff = MasterStaff(
        id: id,
        name: name,
        department: department,
        employeeId: employeeId,
      );

      // Assert
      expect(staff.id, equals(id));
      expect(staff.name, equals(name));
      expect(staff.department, equals(department));
      expect(staff.employeeId, equals(employeeId));
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final staff = MasterStaff(
        id: '001',
        name: '田中 太郎',
        department: '営業部',
        employeeId: 'EMP001',
      );

      // Act
      final json = staff.toJson();

      // Assert
      expect(json, equals({
        'id': '001',
        'name': '田中 太郎',
        'department': '営業部',
        'employeeId': 'EMP001',
      }));
    });

    test('should create from JSON correctly', () {
      // Arrange
      final json = {
        'id': '001',
        'name': '田中 太郎',
        'department': '営業部',
        'employeeId': 'EMP001',
      };

      // Act
      final staff = MasterStaff.fromJson(json);

      // Assert
      expect(staff.id, equals('001'));
      expect(staff.name, equals('田中 太郎'));
      expect(staff.department, equals('営業部'));
      expect(staff.employeeId, equals('EMP001'));
    });
  });

  group('WorkingStaff', () {
    test('should create WorkingStaff with correct properties', () {
      // Arrange
      const id = '001';
      const name = '田中 太郎';
      const department = '営業部';
      const employeeId = 'EMP001';
      const startTime = '09:00';
      const endTime = '18:00';
      const isSelected = true;

      // Act
      final staff = WorkingStaff(
        id: id,
        name: name,
        department: department,
        employeeId: employeeId,
        startTime: startTime,
        endTime: endTime,
        isSelected: isSelected,
      );

      // Assert
      expect(staff.id, equals(id));
      expect(staff.name, equals(name));
      expect(staff.department, equals(department));
      expect(staff.employeeId, equals(employeeId));
      expect(staff.startTime, equals(startTime));
      expect(staff.endTime, equals(endTime));
      expect(staff.isSelected, equals(isSelected));
    });

    test('should copy with new values correctly', () {
      // Arrange
      final originalStaff = WorkingStaff(
        id: '001',
        name: '田中 太郎',
        department: '営業部',
        employeeId: 'EMP001',
        startTime: '09:00',
        endTime: '18:00',
        isSelected: true,
      );

      // Act
      final copiedStaff = originalStaff.copyWith(
        startTime: '10:00',
        isSelected: false,
      );

      // Assert
      expect(copiedStaff.id, equals(originalStaff.id));
      expect(copiedStaff.name, equals(originalStaff.name));
      expect(copiedStaff.department, equals(originalStaff.department));
      expect(copiedStaff.employeeId, equals(originalStaff.employeeId));
      expect(copiedStaff.startTime, equals('10:00'));
      expect(copiedStaff.endTime, equals(originalStaff.endTime));
      expect(copiedStaff.isSelected, equals(false));
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final staff = WorkingStaff(
        id: '001',
        name: '田中 太郎',
        department: '営業部',
        employeeId: 'EMP001',
        startTime: '09:00',
        endTime: '18:00',
        isSelected: true,
      );

      // Act
      final json = staff.toJson();

      // Assert
      expect(json, equals({
        'id': '001',
        'name': '田中 太郎',
        'department': '営業部',
        'employeeId': 'EMP001',
        'startTime': '09:00',
        'endTime': '18:00',
        'isSelected': true,
      }));
    });

    test('should create from JSON correctly', () {
      // Arrange
      final json = {
        'id': '001',
        'name': '田中 太郎',
        'department': '営業部',
        'employeeId': 'EMP001',
        'startTime': '09:00',
        'endTime': '18:00',
        'isSelected': true,
      };

      // Act
      final staff = WorkingStaff.fromJson(json);

      // Assert
      expect(staff.id, equals('001'));
      expect(staff.name, equals('田中 太郎'));
      expect(staff.department, equals('営業部'));
      expect(staff.employeeId, equals('EMP001'));
      expect(staff.startTime, equals('09:00'));
      expect(staff.endTime, equals('18:00'));
      expect(staff.isSelected, equals(true));
    });

    test('should create from MasterStaff correctly', () {
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
}
