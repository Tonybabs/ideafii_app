import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://oxfiaqbojcatjkzsaqxp.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94ZmlhcWJvamNhdGprenNhcXhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNTkyNTEsImV4cCI6MjA4MDkzNTI1MX0.8N5mwySVElQ6W-nf8D2VPLheoH8CsKGK_VIhtcf8vA4',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
