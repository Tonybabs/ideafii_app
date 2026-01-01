import 'package:shared_preferences/shared_preferences.dart';

enum PlanTier { free, premium, premiumX }

class EntitlementsService {
  static const _tierKey = 'ideafii_plan_tier';
  static const _liteBlueprintsKey = 'lite_blueprints_count';
  static const _ideasTodayPrefix = 'ideas_count';
  static const _dailySparkPrefix = 'daily_spark_used';

  static Future<PlanTier> getTier() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tierKey) ?? 'free';
    switch (raw) {
      case 'premium':
        return PlanTier.premium;
      case 'premium_x':
        return PlanTier.premiumX;
      default:
        return PlanTier.free;
    }
  }

  static Future<void> setTier(PlanTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    final value = tier == PlanTier.premiumX
        ? 'premium_x'
        : tier == PlanTier.premium
            ? 'premium'
            : 'free';
    await prefs.setString(_tierKey, value);
  }

  static Future<bool> isPremium() async {
    final tier = await getTier();
    return tier == PlanTier.premium || tier == PlanTier.premiumX;
  }

  static Future<String> modeForBlueprint() async {
    return (await isPremium()) ? 'full' : 'lite';
  }

  static Future<bool> canGenerateBlueprint() async {
    final tier = await getTier();
    if (tier != PlanTier.free) return true;

    final prefs = await SharedPreferences.getInstance();
    final ideasToday = prefs.getInt(_todayKey(_ideasTodayPrefix)) ?? 0;
    final liteCount = prefs.getInt(_liteBlueprintsKey) ?? 0;

    return ideasToday < 5 && liteCount < 3;
  }

  static Future<void> recordBlueprintGeneration(String mode) async {
    final tier = await getTier();
    if (tier != PlanTier.free) return;

    final prefs = await SharedPreferences.getInstance();
    final ideasTodayKey = _todayKey(_ideasTodayPrefix);
    final ideasToday = prefs.getInt(ideasTodayKey) ?? 0;
    await prefs.setInt(ideasTodayKey, ideasToday + 1);

    if (mode == 'lite') {
      final liteCount = prefs.getInt(_liteBlueprintsKey) ?? 0;
      await prefs.setInt(_liteBlueprintsKey, liteCount + 1);
    }
  }

  static Future<bool> canSaveMore(int currentCount) async {
    final tier = await getTier();
    if (tier != PlanTier.free) return true;
    return currentCount < 5;
  }

  static Future<bool> canExport() async {
    return isPremium();
  }

  static Future<bool> canUseDailySpark() async {
    final tier = await getTier();
    if (tier != PlanTier.free) return true;

    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getBool(_todayKey(_dailySparkPrefix)) ?? false;
    return !used;
  }

  static Future<void> recordDailySparkUse() async {
    final tier = await getTier();
    if (tier != PlanTier.free) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_todayKey(_dailySparkPrefix), true);
  }

  static String _todayKey(String prefix) {
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    return '${prefix}_$today';
  }
}
