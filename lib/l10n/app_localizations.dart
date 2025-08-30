import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get appTitle {
    switch (locale.languageCode) {
      case 'ja':
        return '地図ピン管理';
      case 'en':
      default:
        return 'Map Pin Manager';
    }
  }

  String get homePageTitle {
    switch (locale.languageCode) {
      case 'ja':
        return '地図ピン管理ホームページ';
      case 'en':
      default:
        return 'Map Pin Manager Home Page';
    }
  }

  String get counterMessage {
    switch (locale.languageCode) {
      case 'ja':
        return 'ボタンを押した回数:';
      case 'en':
      default:
        return 'You have pushed the button this many times:';
    }
  }

  String get incrementTooltip {
    switch (locale.languageCode) {
      case 'ja':
        return '増加';
      case 'en':
      default:
        return 'Increment';
    }
  }

  // 地図機能用の翻訳
  String get mapTypeToggle {
    switch (locale.languageCode) {
      case 'ja':
        return '地図タイプ切り替え';
      case 'en':
      default:
        return 'Toggle Map Type';
    }
  }

  String get emailSend {
    switch (locale.languageCode) {
      case 'ja':
        return 'メール送信';
      case 'en':
      default:
        return 'Send Email';
    }
  }

  String get pinAdded {
    switch (locale.languageCode) {
      case 'ja':
        return 'ピンを追加しました';
      case 'en':
      default:
        return 'Pin added';
    }
  }

  String get pinAddFailed {
    switch (locale.languageCode) {
      case 'ja':
        return 'ピンの追加に失敗しました';
      case 'en':
      default:
        return 'Failed to add pin';
    }
  }

  String get pinDeleted {
    switch (locale.languageCode) {
      case 'ja':
        return 'ピンを削除しました';
      case 'en':
      default:
        return 'Pin deleted';
    }
  }

  String get pinDeleteFailed {
    switch (locale.languageCode) {
      case 'ja':
        return 'ピンの削除に失敗しました';
      case 'en':
      default:
        return 'Failed to delete pin';
    }
  }

  String get returnToInitialPosition {
    switch (locale.languageCode) {
      case 'ja':
        return '初期位置に戻る';
      case 'en':
      default:
        return 'Return to initial position';
    }
  }

  // ピンリスト機能用の翻訳
  String get pinList {
    switch (locale.languageCode) {
      case 'ja':
        return 'ピンリスト';
      case 'en':
      default:
        return 'Pin List';
    }
  }

  String get noPins {
    switch (locale.languageCode) {
      case 'ja':
        return 'ピンがありません';
      case 'en':
      default:
        return 'No pins';
    }
  }

  String get addPinInstruction {
    switch (locale.languageCode) {
      case 'ja':
        return '地図をタップしてピンを追加してください';
      case 'en':
      default:
        return 'Tap on the map to add pins';
    }
  }

  String get deleteAllPins {
    switch (locale.languageCode) {
      case 'ja':
        return 'すべて削除';
      case 'en':
      default:
        return 'Delete All';
    }
  }

  String get deleteAllPinsConfirm {
    switch (locale.languageCode) {
      case 'ja':
        return 'すべてのピンを削除しますか？\nこの操作は取り消せません。';
      case 'en':
      default:
        return 'Delete all pins?\nThis action cannot be undone.';
    }
  }

  String get allPinsDeleted {
    switch (locale.languageCode) {
      case 'ja':
        return 'すべてのピンを削除しました';
      case 'en':
      default:
        return 'All pins deleted';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ja'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
