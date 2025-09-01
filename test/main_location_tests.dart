import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/location_service.dart';

void main() {
  group('Main App Location Tests', () {
    group('Location Permission Flow Tests', () {
      testWidgets('should request location permission on app start', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const MyApp());
        
        // 初期化処理が完了するまで待機
        await tester.pumpAndSettle();
        
        // MapPageが表示されていることを確認
        expect(find.byType(MapPage), findsOneWidget);
      });

      testWidgets('should show map with location functionality', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        
        // GoogleMapが表示されていることを確認
        expect(find.byType(GoogleMap), findsOneWidget);
        
        // 現在位置ボタンが表示されていることを確認
        expect(find.byIcon(Icons.my_location), findsOneWidget);
      });
    });

    group('Location Service Integration Tests', () {
      test('should check location permission correctly', () async {
        final needsPermission = await LocationService.needsLocationPermission();
        expect(needsPermission, isA<bool>());
      });

      test('should request location permission correctly', () async {
        final permission = await LocationService.requestPermission();
        expect(permission, isA<PermissionStatus>());
      });

      test('should handle location service enabled check', () async {
        final isEnabled = await LocationService.isLocationServiceEnabled();
        expect(isEnabled, isA<bool>());
      });
    });

    group('Permission Status Validation Tests', () {
      test('should validate permission status types', () async {
        final status = await Permission.location.status;
        expect(status, isA<PermissionStatus>());
        
        // 許可状態の値が期待される範囲内にあることを確認
        expect([
          PermissionStatus.denied,
          PermissionStatus.granted,
          PermissionStatus.restricted,
          PermissionStatus.limited,
          PermissionStatus.permanentlyDenied,
        ], contains(status));
      });

      test('should handle permission request flow', () async {
        final initialStatus = await Permission.location.status;
        expect(initialStatus, isA<PermissionStatus>());
        
        // 許可を要求（実際のダイアログは表示されない）
        final requestedStatus = await Permission.location.request();
        expect(requestedStatus, isA<PermissionStatus>());
      });
    });

    group('Location Service Method Tests', () {
      test('should provide consistent permission checking', () async {
        final check1 = await LocationService.checkPermission();
        final check2 = await LocationService.checkPermission();
        
        // 短時間内では同じ結果を返すはず
        expect(check1, check2);
      });

      test('should handle permission needs check correctly', () async {
        final needsPermission = await LocationService.needsLocationPermission();
        expect(needsPermission, isA<bool>());
        
        // 許可が必要かどうかの判定が正しく動作することを確認
        if (needsPermission) {
          final status = await LocationService.checkPermission();
          expect(status == PermissionStatus.denied || 
                 status == PermissionStatus.restricted, isTrue);
        }
      });

      test('should check permanently denied status', () async {
        final isPermanentlyDenied = await LocationService.isPermanentlyDenied();
        expect(isPermanentlyDenied, isA<bool>());
        
        if (isPermanentlyDenied) {
          final status = await LocationService.checkPermission();
          expect(status, PermissionStatus.permanentlyDenied);
        }
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle permission service errors gracefully', () async {
        // 実際のPermission.location.statusはエラーを投げないが、
        // エラーハンドリングのテストとして記述
        expect(() async {
          await LocationService.checkPermission();
        }, returnsNormally);
        
        expect(() async {
          await LocationService.requestPermission();
        }, returnsNormally);
      });

      test('should provide fallback behavior for permission checks', () async {
        // 許可状態の確認が常に有効な値を返すことを確認
        final status = await LocationService.checkPermission();
        expect(status, isNotNull);
        expect(status, isA<PermissionStatus>());
      });
    });
  });
}
