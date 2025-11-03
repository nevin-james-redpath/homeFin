import 'package:flutter/material.dart';
import 'package:homefin/models/formFieldModel.dart';
import 'package:homefin/pages/authentication/LoginScreen.dart';
import 'package:homefin/pages/property/SharePropertyDialog.dart';
import 'package:homefin/services/auth_service.dart';
import 'package:homefin/services/property_service.dart';
import 'package:homefin/widgets/card.dart';
import 'package:go_router/go_router.dart';
import 'package:homefin/widgets/forms/DynamicForm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final supabase = Supabase.instance.client;
  final _propertyService = PropertyService();
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = true;
  String fullName = 'User';
  String email = '';

  void _handlePropertySubmit(String title) {
    print('Property Title: $title');
    // TODO: save to database or update list of cards
  }

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadUser();
  }

  Future<void> _loadProperties() async {
    try {
      final props = await _propertyService.getAllProperties();
      setState(() {
        _properties = props;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 35, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(
              fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(email, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _toRegularCase(String name) {
    if (name.trim().isEmpty) return '';
    return name
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  void _loadUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final rawName = user.userMetadata?['full_name'] ?? 'User';
      setState(() {
        fullName = _toRegularCase(rawName);
        email = user.email ?? '';
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) context.go('/login');
  }

  void _openShareDialog(BuildContext context, String propertyID) {
    showDialog(
      context: context,
      builder: (context) {
        return SharePropertyDialog(propertyID: propertyID);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final screenSize = MediaQuery.of(context).size;

    final fields = [
      // Define your form fields here using FormFieldModel
      FormFieldModel(
        label: 'Property Type',
        keyName: 'propertyType',
        type: 'dropdown',
        options: ['House', 'Apartment', 'Condo', 'Townhouse'],
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Address',
        keyName: 'address',
        type: 'text',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Bedrooms',
        keyName: 'bedrooms',
        type: 'number',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Bathrooms',
        keyName: 'bathrooms',
        type: 'number',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Parking Available',
        keyName: 'parkingAvailable',
        type: 'dropdown',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      // FormFieldModel(
      //   label: 'House Image',
      //   keyName: 'houseImage',
      //   type: 'image',
      // ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                context.go('/home'); // 👈 Navigate to Home page
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.home,
                  size: 26,
                  color: Colors.white, // ✅ white icon
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Welcome, $fullName',
              style: const TextStyle(
                color: Colors.white, // ✅ white text
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6A5ACD),
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tooltip: 'User Menu',
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF6A5ACD)),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                _showProfileDialog();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Add New Property"),
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: screenSize.width * 0.8,
                            height: screenSize.height * 0.6,
                            child: DynamicForm(
                              fields: fields,
                              onSubmit: (values) async {
                                final dataToInsert = {...values};
                                try {
                                  await _propertyService.addProperty(
                                    dataToInsert,
                                  );
                                  Navigator.pop(context); // close popup
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Property added successfully!',
                                      ),
                                    ),
                                  );
                                  _loadProperties(); // refresh property list
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  label: const Text("Add Property"),
                  icon: const Icon(Icons.add),
                ),
              ),
            ),
            SizedBox(height: 210),
            if (_properties.isEmpty)
              const Text("No properties found.", style: TextStyle(fontSize: 16))
            else
              Column(
                children: _properties.map((property) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: MyCard(
                      imagePath:
                          'assets/images/house_sample.png', // replace later with imageUrl if stored
                      title: '${property['address'] ?? 'No Address'} ',
                      onTap: () {
                        context.go('/property/?id=${property['id']}');
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.share, color: Colors.purple),
                        onPressed: () {
                          _openShareDialog(context, property['id']);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
