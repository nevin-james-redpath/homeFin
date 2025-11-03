import 'package:homefin/services/rentPayments_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TenantService {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;
  final _rentPaymentsService = rentPaymentsService();

  Future<void> addTenant(Map<String, dynamic> tenantData) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      await supabase.from('tenants').insert(tenantData);
    } catch (e) {
      throw 'Failed to add tenant: $e';
    }
  }

  Future<void> updateTenant(
    String tenantID,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }
      final tenantDetails = await getTenantByID(tenantID); // ⬅️ await here

      if (tenantDetails != null &&
          tenantDetails['lastMonth'] == true &&
          updatedData['stopDate'] != null) {
        final stopDate = DateTime.parse(updatedData['stopDate'].toString());
        final firstDayOfMonth = DateTime(stopDate.year, stopDate.month, 1);
        await _rentPaymentsService.addRentPayment(
          tenantID,
          tenantDetails['propertyID'],
          firstDayOfMonth,
          tenantDetails['rent'],
          false,
        );
      }

      await supabase.from('tenants').update(updatedData).eq('id', tenantID);
    } catch (e) {
      throw 'Failed to update tenant: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getAllTenants(String propertyID) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      final response = await supabase
          .from('tenants')
          .select()
          .eq('propertyID', propertyID)
          .order('stopDate', ascending: true)
          .order('startDate', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch tenants: $e';
    }
  }

  Future<Map<String, dynamic>?> getTenantByID(String tenantID) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      final response = await supabase
          .from('tenants')
          .select()
          .eq('id', tenantID)
          .order('stopDate', ascending: true)
          .order('startDate', ascending: false)
          .maybeSingle();
      ;

      return response;
    } catch (e) {
      throw 'Failed to fetch tenants: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getTenantsByPropertyId(String propertyID) {
    if (propertyID.isEmpty) {
      throw 'Property ID is required';
    }
    return supabase.from('tenants').select().eq('propertyID', propertyID);
  }

  Future<void> updateLastMonth(bool isLastMonth, String propertyID) {
    if (propertyID.isEmpty || isLastMonth == null) {
      throw 'All parameters are required';
    }
    return supabase
        .from('tenants')
        .update({'lastMonth': isLastMonth})
        .eq('propertyID', propertyID);
  }
}
