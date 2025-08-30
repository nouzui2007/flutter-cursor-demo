import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('should return Japanese text for Japanese locale', () {
      final l10n = AppLocalizations(const Locale('ja'));
      
      expect(l10n.appTitle, '地図ピン管理');
      expect(l10n.pinList, 'ピンリスト');
      expect(l10n.noPins, 'ピンがありません');
      expect(l10n.addPinInstruction, '地図をタップしてピンを追加してください');
      expect(l10n.deleteAllPins, 'すべて削除');
      expect(l10n.deleteAllPinsConfirm, 'すべてのピンを削除しますか？\nこの操作は取り消せません。');
      expect(l10n.allPinsDeleted, 'すべてのピンを削除しました');
      expect(l10n.mapTypeToggle, '地図タイプ切り替え');
      expect(l10n.emailSend, 'メール送信');
      expect(l10n.pinAdded, 'ピンを追加しました');
      expect(l10n.pinAddFailed, 'ピンの追加に失敗しました');
      expect(l10n.pinDeleted, 'ピンを削除しました');
      expect(l10n.pinDeleteFailed, 'ピンの削除に失敗しました');
      expect(l10n.returnToInitialPosition, '初期位置に戻る');
    });

    test('should return English text for English locale', () {
      final l10n = AppLocalizations(const Locale('en'));
      
      expect(l10n.appTitle, 'Map Pin Manager');
      expect(l10n.pinList, 'Pin List');
      expect(l10n.noPins, 'No pins');
      expect(l10n.addPinInstruction, 'Tap on the map to add pins');
      expect(l10n.deleteAllPins, 'Delete All');
      expect(l10n.deleteAllPinsConfirm, 'Delete all pins?\nThis action cannot be undone.');
      expect(l10n.allPinsDeleted, 'All pins deleted');
      expect(l10n.mapTypeToggle, 'Toggle Map Type');
      expect(l10n.emailSend, 'Send Email');
      expect(l10n.pinAdded, 'Pin added');
      expect(l10n.pinAddFailed, 'Failed to add pin');
      expect(l10n.pinDeleted, 'Pin deleted');
      expect(l10n.pinDeleteFailed, 'Failed to delete pin');
      expect(l10n.returnToInitialPosition, 'Return to initial position');
    });

    test('should return English text for unsupported locale', () {
      final l10n = AppLocalizations(const Locale('fr')); // フランス語
      
      expect(l10n.appTitle, 'Map Pin Manager');
      expect(l10n.pinList, 'Pin List');
      expect(l10n.noPins, 'No pins');
      expect(l10n.addPinInstruction, 'Tap on the map to add pins');
    });

    test('should return English text for unknown locale', () {
      final l10n = AppLocalizations(const Locale('unknown'));
      
      expect(l10n.appTitle, 'Map Pin Manager');
      expect(l10n.pinList, 'Pin List');
    });

    test('should handle different locale formats', () {
      final l10n1 = AppLocalizations(const Locale('ja', 'JP'));
      final l10n2 = AppLocalizations(const Locale('en', 'US'));
      
      expect(l10n1.appTitle, '地図ピン管理');
      expect(l10n2.appTitle, 'Map Pin Manager');
    });
  });
}
