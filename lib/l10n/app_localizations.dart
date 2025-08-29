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
        return 'Flutterデモ';
      case 'en':
      default:
        return 'Flutter Demo';
    }
  }

  String get homePageTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'Flutterデモホームページ';
      case 'en':
      default:
        return 'Flutter Demo Home Page';
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
