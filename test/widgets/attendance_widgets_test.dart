import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/widgets/attendance/date_navigator.dart';
import 'package:flutter_application_1/widgets/attendance/staff_selector.dart';
import 'package:flutter_application_1/widgets/attendance/time_entry_form.dart';
import 'package:flutter_application_1/models/staff.dart';

void main() {
  group('DateNavigator', () {
    testWidgets('should display current date correctly', (WidgetTester tester) async {
      // Arrange
      final currentDate = DateTime(2024, 1, 15);
      bool dateChanged = false;
      DateTime? newDate;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateNavigator(
              currentDate: currentDate,
              onDateChange: (date) {
                dateChanged = true;
                newDate = date;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('2024年1月15日 (月)'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should show today badge when current date is today', (WidgetTester tester) async {
      // Arrange
      final today = DateTime.now();
      bool dateChanged = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateNavigator(
              currentDate: today,
              onDateChange: (date) {
                dateChanged = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('今日'), findsOneWidget);
    });

    testWidgets('should navigate to previous day when left arrow is tapped', (WidgetTester tester) async {
      // Arrange
      final currentDate = DateTime(2024, 1, 15);
      bool dateChanged = false;
      DateTime? newDate;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateNavigator(
              currentDate: currentDate,
              onDateChange: (date) {
                dateChanged = true;
                newDate = date;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Assert
      expect(dateChanged, isTrue);
      expect(newDate, equals(DateTime(2024, 1, 14)));
    });

    testWidgets('should navigate to next day when right arrow is tapped', (WidgetTester tester) async {
      // Arrange
      final currentDate = DateTime(2024, 1, 14);
      bool dateChanged = false;
      DateTime? newDate;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateNavigator(
              currentDate: currentDate,
              onDateChange: (date) {
                dateChanged = true;
                newDate = date;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Assert
      expect(dateChanged, isTrue);
      expect(newDate, equals(DateTime(2024, 1, 15)));
    });

    testWidgets('should navigate to today when today button is tapped', (WidgetTester tester) async {
      // Arrange
      final currentDate = DateTime(2024, 1, 10);
      bool dateChanged = false;
      DateTime? newDate;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateNavigator(
              currentDate: currentDate,
              onDateChange: (date) {
                dateChanged = true;
                newDate = date;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('今日'));
      await tester.pumpAndSettle();

      // Assert
      expect(dateChanged, isTrue);
      expect(newDate!.day, equals(DateTime.now().day));
    });
  });

  group('StaffSelector', () {
    testWidgets('should display staff selection button when not showing selector', (WidgetTester tester) async {
      // Arrange
      final masterStaffList = [
        MasterStaff(id: '001', name: '田中 太郎', department: '営業部', employeeId: 'EMP001'),
        MasterStaff(id: '002', name: '佐藤 花子', department: '営業部', employeeId: 'EMP002'),
      ];
      final workingStaffList = <WorkingStaff>[];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffSelector(
              masterStaffList: masterStaffList,
              workingStaffList: workingStaffList,
              onUpdateWorkingStaff: (staff) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('出勤スタッフ'), findsOneWidget);
      expect(find.text('スタッフ選択'), findsOneWidget);
    });

    testWidgets('should display selected staff count', (WidgetTester tester) async {
      // Arrange
      final masterStaffList = [
        MasterStaff(id: '001', name: '田中 太郎', department: '営業部', employeeId: 'EMP001'),
      ];
      final workingStaffList = [
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffSelector(
              masterStaffList: masterStaffList,
              workingStaffList: workingStaffList,
              onUpdateWorkingStaff: (staff) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('出勤スタッフ (1名)'), findsOneWidget);
    });

    testWidgets('should show selector when staff selection button is tapped', (WidgetTester tester) async {
      // Arrange
      final masterStaffList = [
        MasterStaff(id: '001', name: '田中 太郎', department: '営業部', employeeId: 'EMP001'),
      ];
      final workingStaffList = <WorkingStaff>[];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffSelector(
              masterStaffList: masterStaffList,
              workingStaffList: workingStaffList,
              onUpdateWorkingStaff: (staff) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('スタッフ選択'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('出勤スタッフを選択'), findsOneWidget);
      expect(find.text('完了'), findsOneWidget);
    });

    testWidgets('should call onUpdateWorkingStaff when staff is selected', (WidgetTester tester) async {
      // Arrange
      final masterStaffList = [
        MasterStaff(id: '001', name: '田中 太郎', department: '営業部', employeeId: 'EMP001'),
      ];
      final workingStaffList = <WorkingStaff>[];
      List<WorkingStaff>? updatedStaff;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffSelector(
              masterStaffList: masterStaffList,
              workingStaffList: workingStaffList,
              onUpdateWorkingStaff: (staff) {
                updatedStaff = staff;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('スタッフ選択'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // Assert
      expect(updatedStaff, isNotNull);
      expect(updatedStaff!.length, equals(1));
      expect(updatedStaff!.first.id, equals('001'));
    });
  });

  group('TimeEntryForm', () {
    testWidgets('should display empty state when no working staff', (WidgetTester tester) async {
      // Arrange
      final workingStaffList = <WorkingStaff>[];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeEntryForm(
              workingStaffList: workingStaffList,
              onUpdateStaff: (staff) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('出勤スタッフが選択されていません'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('should display working staff information', (WidgetTester tester) async {
      // Arrange
      final workingStaffList = [
        WorkingStaff(
          id: '001',
          name: '田中 太郎',
          department: '営業部',
          employeeId: 'EMP001',
          startTime: '09:00',
          endTime: '18:00',
          isSelected: true,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeEntryForm(
              workingStaffList: workingStaffList,
              onUpdateStaff: (staff) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('田中 太郎'), findsOneWidget);
      expect(find.text('営業部 | ID: EMP001'), findsOneWidget);
      expect(find.text('出勤時間'), findsOneWidget);
      expect(find.text('退勤時間'), findsOneWidget);
    });

    testWidgets('should display time buttons with correct labels', (WidgetTester tester) async {
      // Arrange
      final workingStaffList = [
        WorkingStaff(
          id: '001',
          name: '田中 太郎',
          department: '営業部',
          employeeId: 'EMP001',
          startTime: '09:00',
          endTime: '18:00',
          isSelected: true,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeEntryForm(
              workingStaffList: workingStaffList,
              onUpdateStaff: (staff) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('6:00 PM'), findsOneWidget);
    });

    testWidgets('should display work time calculation', (WidgetTester tester) async {
      // Arrange
      final workingStaffList = [
        WorkingStaff(
          id: '001',
          name: '田中 太郎',
          department: '営業部',
          employeeId: 'EMP001',
          startTime: '09:00',
          endTime: '18:00',
          isSelected: true,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeEntryForm(
              workingStaffList: workingStaffList,
              onUpdateStaff: (staff) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('勤務時間: 9時間0分'), findsOneWidget);
      expect(find.text('合計勤務時間'), findsOneWidget);
      expect(find.text('9時間0分'), findsNWidgets(2)); // 個人と合計
    });

    testWidgets('should display empty time labels when no time set', (WidgetTester tester) async {
      // Arrange
      final workingStaffList = [
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeEntryForm(
              workingStaffList: workingStaffList,
              onUpdateStaff: (staff) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('時間を選択'), findsNWidgets(2)); // 出勤時間と退勤時間
      expect(find.text('勤務時間: --'), findsOneWidget);
    });
  });
}
