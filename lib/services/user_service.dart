import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class UserService {
  final _supabase = SupabaseConfig.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      final response = await _supabase.from('user_profiles').select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch tenants: $e';
    }
  }
}
