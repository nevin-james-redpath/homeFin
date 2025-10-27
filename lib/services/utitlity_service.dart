import 'package:supabase_flutter/supabase_flutter.dart';

class UtitlityService {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> getUtilities(String propertyID) {
    if (propertyID.isEmpty) {
      throw 'Property ID is required';
    }
    return supabase.from('utilities').select().eq('property_id', propertyID);
  }

  Future<void> addUpdateUtility(
    String propertyID,
    String utilityType,
    DateTime month,
    final amount,
  ) async {
    try {
      if (propertyID.isEmpty &&
          utilityType.isEmpty &&
          month == null &&
          amount == null) {
        throw 'Property ID is required';
      }
      final existing = await supabase
          .from('utilities')
          .select('id')
          .eq('property_id', propertyID)
          .eq('utilityType', utilityType)
          .eq('month', month.toIso8601String());
      if (existing.isEmpty) {
        // ✅ Insert new
        await supabase.from('utilities').insert({
          'property_id': propertyID,
          'utilityType': utilityType,
          'month': month.toIso8601String(),
          'monthly_cost': amount,
        });
      } else {
        // ✅ Update existing
        final id = existing.first['id'];
        await supabase
            .from('utilities')
            .update({'monthly_cost': amount})
            .eq('id', id);
      }
    } catch (e) {
      print('Error in addUpdateUtility: $e');
    }
  }
}
