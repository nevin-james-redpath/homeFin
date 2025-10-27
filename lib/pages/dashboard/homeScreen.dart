import 'package:flutter/material.dart';
import 'package:homefin/models/formFieldModel.dart';
import 'package:homefin/pages/authentication/LoginScreen.dart';
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

  void _handlePropertySubmit(String title) {
    print('Property Title: $title');
    // TODO: save to database or update list of cards
  }

  @override
  void initState() {
    super.initState();
    _loadProperties();
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
        title: Text('Welcome User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
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
            SizedBox(height: 240),
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
