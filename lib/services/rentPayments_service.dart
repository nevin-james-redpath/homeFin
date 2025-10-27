import 'package:supabase_flutter/supabase_flutter.dart';

class rentPaymentsService {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> getRentPayments(String propertyID) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      final response = await supabase
          .from('rentPayments')
          .select()
          .eq('propertyID', propertyID);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch rent payments: $e';
    }
  }

  Future<void> updateRentPayment(
    String tenantID,
    double amount,
    String propertyID,
    DateTime month,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      await supabase
          .from('rentPayments')
          .update({'amount': amount})
          .eq('tenantID', tenantID)
          .eq('propertyID', propertyID)
          .eq('month', month.toIso8601String())
          .select();
    } catch (e) {
      throw 'Failed to update rent payment: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getRentPaymentsByPropertyIDAndTenantID(
    String propertyID,
    String tenantID,
    DateTime month,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }
      if (propertyID.isEmpty || tenantID.isEmpty || month == null) {
        throw 'Property ID and Tenant ID are required';
      }

      final response = await supabase
          .from('rentPayments')
          .select()
          .eq('propertyID', propertyID)
          .eq('tenantID', tenantID)
          .eq('month', month.toIso8601String());

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch rent payments: $e';
    }
  }

  Future<void> addRentPayment(
    String tenantID,
    String propertyID,
    DateTime month,
    double amount,
    bool isLastMonth,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }
      if (tenantID.isEmpty ||
          propertyID.isEmpty ||
          month == null ||
          amount == null) {
        throw 'All fields are required';
      }

      await supabase.from('rentPayments').insert({
        'tenantID': tenantID,
        'propertyID': propertyID,
        'month': month.toIso8601String(),
        'amount': amount,
        'lastMonth': isLastMonth,
      });
    } catch (e) {
      throw 'Failed to add rent payment: $e';
    }
  }

  Future<void> updateRentPaymentLastMonth(
    String tenantID,
    double amount,
    String propertyID,
    DateTime month,
    bool isLastMonth,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      await supabase
          .from('rentPayments')
          .update({'amount': amount, 'lastMonth': isLastMonth})
          .eq('tenantID', tenantID)
          .eq('propertyID', propertyID)
          .eq('month', month.toIso8601String());
    } catch (e) {
      throw 'Failed to update rent payment: $e';
    }
  }
}
