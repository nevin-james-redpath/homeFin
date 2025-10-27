import 'package:supabase_flutter/supabase_flutter.dart';

class FinancesummaryService {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> getFinanceSummary(
    String propertyID,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }
      final response = await supabase
          .from('vw_financesummary')
          .select()
          .eq('propertyID', propertyID)
          .order('month', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Error loading finance summary: $e';
    }
  }
}
