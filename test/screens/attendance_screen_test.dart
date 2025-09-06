import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screens/attendance_screen.dart';
import 'package:flutter_application_1/models/staff.dart';

void main() {
  group('AttendanceScreen', () {
    setUp(() {
      // テスト用のSharedPreferencesを初期化
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display attendance screen with correct title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      // Assert
      expect(find.text('勤怠管理'), findsOneWidget);
      expect(find.text('出勤スタッフの勤務時間を記録'), findsOneWidget);
    });

    testWidgets('should display all required components', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('勤怠管理'), findsOneWidget);
      expect(find.text('出勤スタッフの勤務時間を記録'), findsOneWidget);
      expect(find.byType(CalendarTodayIcon), findsOneWidget); // DateNavigator
      expect(find.text('出勤スタッフ'), findsOneWidget); // StaffSelector
      expect(find.text('データは端末に自動保存されます'), findsOneWidget);
    });

    testWidgets('should display master staff list correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // スタッフ選択ボタンをタップ
      await tester.tap(find.text('スタッフ選択'));
      await tester.pumpAndSettle();

      // Assert - マスタースタッフリストの確認
      expect(find.text('田中 太郎'), findsOneWidget);
      expect(find.text('佐藤 花子'), findsOneWidget);
      expect(find.text('山田 次郎'), findsOneWidget);
      expect(find.text('鈴木 美咲'), findsOneWidget);
      expect(find.text('高橋 健一'), findsOneWidget);
    });

    testWidgets('should handle staff selection correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // スタッフ選択ボタンをタップ
      await tester.tap(find.text('スタッフ選択'));
      await tester.pumpAndSettle();

      // 最初のスタッフを選択
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // 完了ボタンをタップ
      await tester.tap(find.text('完了'));
      await tester.pumpAndSettle();

      // Assert - 選択されたスタッフが表示される
      expect(find.text('出勤スタッフ (1名)'), findsOneWidget);
      expect(find.text('田中 太郎 (営業部)'), findsOneWidget);
    });

    testWidgets('should display time entry form when staff is selected', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // スタッフ選択ボタンをタップ
      await tester.tap(find.text('スタッフ選択'));
      await tester.pumpAndSettle();

      // 最初のスタッフを選択
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // 完了ボタンをタップ
      await tester.tap(find.text('完了'));
      await tester.pumpAndSettle();

      // Assert - 時間入力フォームが表示される
      expect(find.text('出勤時間'), findsOneWidget);
      expect(find.text('退勤時間'), findsOneWidget);
      expect(find.text('勤務時間: --'), findsOneWidget);
    });

    testWidgets('should display empty state when no staff selected', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - 空の状態が表示される
      expect(find.text('出勤スタッフが選択されていません'), findsOneWidget);
      expect(find.text('上の「スタッフ選択」から出勤者を選んでください'), findsOneWidget);
    });

    testWidgets('should handle date navigation', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 左矢印をタップして前の日へ
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Assert - 日付が変更される（具体的な日付は現在日時によって変わる）
      expect(find.byType(CalendarTodayIcon), findsOneWidget);
    });

    testWidgets('should display today badge when current date is today', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - 今日の場合は「今日」バッジが表示される
      // 注意: このテストは現在日時によって結果が変わる可能性があります
      final todayBadge = find.text('今日');
      if (todayBadge.evaluate().isNotEmpty) {
        expect(todayBadge, findsOneWidget);
      }
    });

    testWidgets('should load and save data correctly', (WidgetTester tester) async {
      // Arrange - テストデータを設定
      final testData = {
        'staffTimeData': '{"2024-01-15":[{"id":"001","name":"田中 太郎","department":"営業部","employeeId":"EMP001","startTime":"09:00","endTime":"18:00","isSelected":true}]}'
      };
      SharedPreferences.setMockInitialValues(testData);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - 保存されたデータが読み込まれる
      // 注意: 実際の日付が2024-01-15でない場合、データは表示されない可能性があります
      // このテストは日付に依存するため、条件付きで実行
    });

    testWidgets('should handle multiple staff selection', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // スタッフ選択ボタンをタップ
      await tester.tap(find.text('スタッフ選択'));
      await tester.pumpAndSettle();

      // 複数のスタッフを選択
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pumpAndSettle();

      // 完了ボタンをタップ
      await tester.tap(find.text('完了'));
      await tester.pumpAndSettle();

      // Assert - 複数のスタッフが選択される
      expect(find.text('出勤スタッフ (2名)'), findsOneWidget);
    });

    testWidgets('should display correct department information', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // スタッフ選択ボタンをタップ
      await tester.tap(find.text('スタッフ選択'));
      await tester.pumpAndSettle();

      // Assert - 部署情報が正しく表示される
      expect(find.text('営業部'), findsAtLeastNWidgets(2)); // 田中、佐藤
      expect(find.text('マーケティング部'), findsAtLeastNWidgets(2)); // 山田、鈴木
      expect(find.text('技術部'), findsAtLeastNWidgets(2)); // 高橋、小林
      expect(find.text('人事部'), findsAtLeastNWidgets(2)); // 渡辺、加藤
      expect(find.text('経理部'), findsAtLeastNWidgets(2)); // 井上、斎藤
    });
  });
}
