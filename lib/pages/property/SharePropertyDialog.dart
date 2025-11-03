import 'package:flutter/material.dart';
import 'package:homefin/services/property_service.dart';
import 'package:homefin/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SharePropertyDialog extends StatefulWidget {
  final String propertyID;
  const SharePropertyDialog({super.key, required this.propertyID});

  @override
  State<SharePropertyDialog> createState() => _SharePropertyDialogState();
}

class _SharePropertyDialogState extends State<SharePropertyDialog> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _selectedUserId;
  final propertyService = PropertyService();
  final userService = UserService();

  Future<void> _searchUsers() async {
    setState(() => _isLoading = true);
    try {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      // 🔹 Fetch users (requires service role)
      final users = await userService.getAllUsers();
      final filtered = users.where((u) {
        final email = (u['email'] ?? '').toString().toLowerCase();
        final fullName = (u['full_name'] ?? '').toString().toLowerCase();
        return email.contains(query) || fullName.contains(query);
      }).toList();

      // 🔹 Limit to top 10 results
      final limited = filtered.take(10).toList();

      setState(() => _searchResults = limited);
    } catch (e) {
      debugPrint('Error searching users: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching users: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareProperty() async {
    if (_selectedUserId == null) return;
    try {
      await propertyService.addUserAccess(widget.propertyID, _selectedUserId);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property shared successfully!')),
      );
    } catch (e) {
      debugPrint('Error sharing property: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Property'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email or name...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
              ),
              onSubmitted: (_) => _searchUsers(),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_searchResults.isEmpty)
              const Text('No results')
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    final isSelected = _selectedUserId == user['id'];
                    return ListTile(
                      title: Text(user['email'] ?? 'Unknown'),
                      subtitle: Text(user['full_name'] ?? ''),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedUserId = user['id'];
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedUserId == null ? null : _shareProperty,
          icon: const Icon(Icons.send),
          label: const Text('Share'),
        ),
      ],
    );
  }
}
