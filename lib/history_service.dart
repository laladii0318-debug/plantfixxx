import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _historyKey = 'scan_history';

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(_historyKey) ?? [];

    return data
        .map(
          (item) => Map<String, dynamic>.from(
        jsonDecode(item) as Map,
      ),
    )
        .toList();
  }

  static Future<void> addHistory({
    required String crop,
    required String disease,
    required double confidence,
    required String symptoms,
    required String causes,
    required String treatment,
    required String prevention,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final history = await getHistory();

    history.insert(
      0,
      {
        'crop': crop,
        'disease': disease,
        'confidence': confidence,
        'symptoms': symptoms,
        'causes': causes,
        'treatment': treatment,
        'prevention': prevention,
        'date': DateTime.now().toIso8601String(),
      },
    );

    final encodedHistory = history
        .map((item) => jsonEncode(item))
        .toList();

    await prefs.setStringList(
      _historyKey,
      encodedHistory,
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_historyKey);
  }
}