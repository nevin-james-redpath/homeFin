import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://hjxajicdxbydpsqmzpef.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhqeGFqaWNkeGJ5ZHBzcW16cGVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MDUzOTUsImV4cCI6MjA2OTk4MTM5NX0.ik8g04PBOJ_PrT7mnjPdaGuiZgFVnup6SH6sZGXjjPE',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
