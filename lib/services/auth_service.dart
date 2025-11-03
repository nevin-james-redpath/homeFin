import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = SupabaseConfig.client;

  Future<AppUser?> register(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AppUser(
          id: response.user!.id,
          email: response.user!.email ?? '',
        );
      }

      if (response.session == null && response.user == null) {
        throw 'Signup failed. Please try again.';
      }
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Unexpected error: $e';
    }

    return null;
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email);
    } catch (e) {
      throw 'Failed to resend verification: $e';
    }
  }

  Future<AppUser?> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) return null;
    return AppUser(id: response.user!.id, email: response.user!.email ?? '');
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  AppUser? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AppUser(id: user.id, email: user.email ?? '');
  }

  Future<void> signInWithGoogle() async {
    try {
      final redirectUrl = kIsWeb
          ? 'http://localhost:57606/' // must exactly match what’s in the browser + Supabase
          : 'io.supabase.homefin://login-callback/';
      print(redirectUrl);
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // redirectTo: 'io.supabase.homefin://login-callback/',
        redirectTo: redirectUrl,
      );
    } catch (e) {
      print('Error during Google sign-in: $e');
      rethrow;
    }
  }
}
