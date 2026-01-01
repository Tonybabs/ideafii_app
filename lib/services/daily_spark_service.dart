import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'entitlements_service.dart';
import 'profile_store.dart';

class DailySparkService {
  static const _dateKey = 'daily_spark_date';
  static const _sparkKey = 'daily_spark_text';

  static Future<String> getDailySpark() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);

    final cachedDate = prefs.getString(_dateKey);
    final cachedSpark = prefs.getString(_sparkKey);
    if (cachedDate == today && cachedSpark != null && cachedSpark.isNotEmpty) {
      return cachedSpark;
    }

    final canUse = await EntitlementsService.canUseDailySpark();
    if (!canUse) {
      throw Exception('Daily Spark limit reached');
    }

    final profile = await ProfileStore.load();
    final sparkMode = await EntitlementsService.modeForBlueprint();
    final response = await Supabase.instance.client.functions.invoke(
      'daily-spark',
      body: {
        'day': today,
        'user_profile': profile?.toJson(),
        'spark_mode': sparkMode,
      },
    );

    final data = response.data;
    if (data is Map) {
      final raw = (data['spark'] ??
              data['oneLiner'] ??
              data['title'])
          ?.toString()
          .trim() ??
          '';
      final spark = raw;
      if (spark.isNotEmpty) {
        await prefs.setString(_dateKey, today);
        await prefs.setString(_sparkKey, spark);
        await EntitlementsService.recordDailySparkUse();
        return spark;
      }
    }

    throw Exception('AI returned empty response');
  }
}
