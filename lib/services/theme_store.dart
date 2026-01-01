import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStore {
  static const _key = 'ideafii_theme_mode'; // 'dark' | 'light' | 'system'

  static Future<ThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key) ?? 'dark';
    if (v == 'light') return ThemeMode.light;
    if (v == 'system') return ThemeMode.system;
    return ThemeMode.dark;
  }

  static Future<void> save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final v = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.system
            ? 'system'
            : 'dark';
    await prefs.setString(_key, v);
  }
}
