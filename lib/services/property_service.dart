import 'package:homefin/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyService {
  final supabase = SupabaseConfig.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  Future<void> addProperty(Map<String, dynamic> propertyData) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      final response = await supabase
          .from('properties')
          .insert(propertyData)
          .select();
      if (response != null && response.isNotEmpty) {
        final insertedProperty = response.first;
        final propertyID = insertedProperty['id'];
        addUserAccess(propertyID);
      }
    } catch (e) {
      throw 'Failed to add property: $e';
    }
  }

  Future<void> addUserAccess(String propertyID) async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }
      final propertyUserData = {
        'userID': currentUser!.id,
        'propertyID': propertyID,
        'accessLevel': 'owner',
      };
      await supabase.from('propertyOwners').insert(propertyUserData);
    } catch (e) {
      throw 'Failed to add user access: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getAllProperties() async {
    try {
      if (currentUser == null) {
        throw 'User not logged in';
      }

      // Step 1: Get all property IDs owned by this user
      final ownerResponse = await supabase
          .from('propertyOwners')
          .select('propertyID')
          .eq('userID', currentUser!.id);

      if (ownerResponse.isEmpty) {
        return [];
      }

      final propertyIds = ownerResponse
          .map((row) => row['propertyID'])
          .whereType<String>()
          .toList();

      // Step 2: Fetch all property details for those IDs
      final propertiesResponse = await supabase
          .from('properties')
          .select('*')
          .inFilter('id', propertyIds);

      return propertiesResponse;
    } catch (e) {
      throw 'Failed to fetch properties: $e';
    }
  }

  Future<Map<String, dynamic>?> getPropertyById(String propertyID) async {
    try {
      final response = await supabase
          .from('properties')
          .select('*')
          .eq('id', propertyID)
          .single();
      if (response == null) {
        throw 'No property found for ID: $propertyID';
      }
      return response;
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch property: $e';
    }
  }
}
