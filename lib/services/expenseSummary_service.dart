import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseSummaryService {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> getAllExpensesSummary(
    String propertyID,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      final response = await supabase
          .from('expensebymonth')
          .select()
          .eq('propertyID', propertyID)
          .order('month', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch expenses: $e';
    }
  }
}
