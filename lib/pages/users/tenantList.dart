import 'package:flutter/material.dart';
import 'package:homefin/models/formFieldModel.dart';
import 'package:homefin/services/tenant_service.dart';
import 'package:homefin/widgets/DynamicTable.dart';
import 'package:homefin/widgets/forms/DynamicForm.dart';
import 'package:go_router/go_router.dart';

class tenantList extends StatefulWidget {
  final String propertyID;
  const tenantList({super.key, required this.propertyID});

  @override
  State<tenantList> createState() => _tenantListState();
}

class _tenantListState extends State<tenantList> {
  final _tenantService = TenantService();
  List<Map<String, dynamic>> tenantList = [];

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    try {
      final tenants = await _tenantService.getAllTenants(widget.propertyID);
      setState(() {
        tenantList = tenants;
      });
      // Handle loaded tenants (e.g., update state)
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading tenants: $e')));
    }
  }

  bool _validateDates(BuildContext context, Map<String, dynamic> values) {
    final start = values['startDate'];
    final stop = values['stopDate'];

    if (stop != null &&
        start != null &&
        stop.toString().isNotEmpty &&
        start.toString().isNotEmpty) {
      final startDate = DateTime.tryParse(start);
      final stopDate = DateTime.tryParse(stop);

      if (stopDate != null &&
          startDate != null &&
          stopDate.isBefore(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stop Date must be after Start Date!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false; // ❌ Invalid
      }
    }

    return true; // ✅ Valid
  }

  void _showEditPopup(Map<String, dynamic> tenant) {
    final fields = [
      FormFieldModel(
        label: 'Full Name',
        keyName: 'fullName',
        type: 'text',
        isRequired: true,
        value: tenant['fullName'],
      ),
      FormFieldModel(
        label: 'Email',
        keyName: 'email',
        type: 'text',
        isRequired: true,
        value: tenant['email'],
      ),
      FormFieldModel(
        label: 'Phone',
        keyName: 'phone',
        type: 'text',
        isRequired: true,
        value: tenant['phone'],
      ),
      FormFieldModel(
        label: 'Gender',
        keyName: 'gender',
        type: 'dropdown',
        options: ['Male', 'Female'],
        isRequired: true,
        value: tenant['gender'],
      ),
      FormFieldModel(
        label: 'Rent',
        keyName: 'rent',
        type: 'number',
        isRequired: true,
        value: tenant['rent'],
      ),
      FormFieldModel(
        label: 'Start Date',
        keyName: 'startDate',
        type: 'date',
        isRequired: true,
        value: tenant['startDate'],
      ),
      FormFieldModel(
        label: 'Stop Date',
        keyName: 'stopDate',
        type: 'date',
        isRequired: false,
        value: tenant['stopDate'],
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Tenant"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.7,
          child: DynamicForm(
            fields: fields,
            onSubmit: (values) async {
              try {
                if (!_validateDates(context, values)) return;
                await _tenantService.updateTenant(tenant['id'], values);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tenant updated successfully!')),
                );
                _loadTenants();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating tenant: $e')),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final fields = [
      // Define your form fields here using FormFieldModel
      FormFieldModel(
        label: 'Full Name',
        keyName: 'fullName',
        type: 'text',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Email',
        keyName: 'email',
        type: 'text',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Phone',
        keyName: 'phone',
        type: 'text',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Gender',
        keyName: 'gender',
        type: 'dropdown',
        options: ['Male', 'Female'],
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Rent',
        keyName: 'rent',
        type: 'number',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Start Date',
        keyName: 'startDate',
        type: 'date',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Stop Date',
        keyName: 'stopDate',
        type: 'date',
        isRequired: false,
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
              'Tenants',
              style: const TextStyle(
                color: Colors.white, // ✅ white text
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6A5ACD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Add Users Button (Right aligned) ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    // optional different color
                  ),
                  onPressed: () {
                    context.go('/property/?id=${widget.propertyID}');
                  },
                  icon: const Icon(Icons.arrow_circle_left_outlined),
                  label: const Text('Back to property'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Add New Tenant"),
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: screenSize.width * 0.8,
                            height: screenSize.height * 0.6,
                            child: DynamicForm(
                              fields: fields,
                              onSubmit: (values) async {
                                if (!_validateDates(context, values)) return;
                                final dataToInsert = {
                                  ...values,
                                  'propertyID': widget.propertyID,
                                  'role': 'tenant',
                                };

                                try {
                                  await _tenantService.addTenant(dataToInsert);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tenant added successfully!',
                                      ),
                                    ),
                                  );
                                  _loadTenants();
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
                  icon: const Icon(Icons.add),
                  label: const Text('Add Users'),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // ---------- Centered Table ----------
            Center(
              child: SizedBox(
                width: screenSize.width * 0.9,
                child: tenantList.isEmpty
                    ? const Center(child: Text('No tenants found.'))
                    : DynamicTable(
                        columns: const [
                          'fullName',
                          'email',
                          'phone',
                          'gender',
                          'rent',
                          'startDate',
                          'stopDate',
                        ],
                        columnLabels: [
                          'Full Name',
                          'Email',
                          'Phone',
                          'Gender',
                          'Rent',
                          'Start Date',
                          'Stop Date',
                        ],
                        data: tenantList,
                        onEdit: _showEditPopup,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
