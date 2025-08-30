import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/map_pin.dart';

class StorageService {
  static const String _pinsKey = 'map_pins';
  static const String _emailKey = 'default_email';

  // ピンデータの保存
  Future<void> savePins(List<MapPin> pins) async {
    final prefs = await SharedPreferences.getInstance();
    final pinsJson = pins.map((pin) => pin.toJson()).toList();
    await prefs.setString(_pinsKey, jsonEncode(pinsJson));
  }

  // ピンデータの読み込み
  Future<List<MapPin>> loadPins() async {
    final prefs = await SharedPreferences.getInstance();
    final pinsString = prefs.getString(_pinsKey);
    if (pinsString == null) return [];

    try {
      final pinsJson = jsonDecode(pinsString) as List;
      return pinsJson.map((json) => MapPin.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // ピンの追加
  Future<void> addPin(MapPin pin) async {
    final pins = await loadPins();
    pins.add(pin);
    await savePins(pins);
  }

  // ピンの削除
  Future<void> removePin(String pinId) async {
    final pins = await loadPins();
    pins.removeWhere((pin) => pin.id == pinId);
    await savePins(pins);
  }

  // メールアドレスの保存
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  // メールアドレスの読み込み
  Future<String?> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
}
