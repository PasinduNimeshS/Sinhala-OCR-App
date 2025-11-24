import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sin_ocr/screens/home/home.dart';

class LocalStorageService {
  static const String _historyKey = 'ocr_history';
  static const String _savedKey = 'ocr_saved';

  // Save History
  static Future<void> saveHistory(List<OcrItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // Load History
  static Future<List<OcrItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => OcrItem.fromJson(json)).toList();
  }

  // Save Saved Items
  static Future<void> saveSaved(List<OcrItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_savedKey, jsonEncode(jsonList));
  }

  // Load Saved Items
  static Future<List<OcrItem>> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => OcrItem.fromJson(json)).toList();
  }

  // Optional: Clear all data (for logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_savedKey);
  }
}