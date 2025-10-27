import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> getAllExpenses(String propertyID) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      final response = await supabase
          .from('expenses')
          .select()
          .eq('propertyID', propertyID)
          .order('month', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch expenses: $e';
    }
  }

  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    try {
      if (currentUser == null) {
        throw 'Use not logged in';
      }

      await supabase.from('expenses').insert(expenseData);
    } catch (e) {
      throw 'Failed to add expense: $e';
    }
  }

  Future<void> updateExpense(
    String propertyID,
    int expenseID,
    Map<String, dynamic> updatedExpense,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }
      await supabase
          .from('expenses')
          .update(updatedExpense)
          .eq('propertyID', propertyID)
          .eq('id', expenseID);
    } catch (e) {
      throw 'Failed to update expense: $e';
    }
  }

  Future<List<Map<String, dynamic>>> otherExpenseByMonth(
    String propertyID,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }
      final response = await supabase
          .from('otherexpensebymonth')
          .select()
          .eq('propertyID', propertyID);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to get expense: $e';
    }
  }
}
