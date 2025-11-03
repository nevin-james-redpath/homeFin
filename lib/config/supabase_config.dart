import 'package:homefin/env/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static Future<void> init() async {
    final supabaseURL = Env.supabaseUrl;
    final supabaseAnnonKey = Env.supabaseAnonKey;

    await Supabase.initialize(url: supabaseURL!, anonKey: supabaseAnnonKey!);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
