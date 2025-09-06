import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/staff.dart';

class AttendanceDataService {
  static const String _staffDataKey = 'staffTimeData';

  static Future<Map<String, List<WorkingStaff>>> loadStaffData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_staffDataKey);
    
    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final Map<String, List<WorkingStaff>> result = {};

      jsonData.forEach((dateKey, staffListJson) {
        final List<dynamic> staffList = staffListJson;
        result[dateKey] = staffList
            .map((staffJson) => WorkingStaff.fromJson(staffJson))
            .toList();
      });

      return result;
    } catch (e) {
      print('データの復元に失敗しました: $e');
      return {};
    }
  }

  static Future<void> saveStaffData(Map<String, List<WorkingStaff>> staffData) async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, dynamic> jsonData = {};
    staffData.forEach((dateKey, staffList) {
      jsonData[dateKey] = staffList.map((staff) => staff.toJson()).toList();
    });

    await prefs.setString(_staffDataKey, json.encode(jsonData));
  }

  static String getDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }
}
