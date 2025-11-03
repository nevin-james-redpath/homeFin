import 'package:flutter/material.dart';
import 'package:homefin/models/formFieldModel.dart';
import 'package:homefin/services/expense_service.dart';
import 'package:homefin/widgets/DynamicTable.dart';
import 'package:homefin/widgets/forms/DynamicForm.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class Propertyexpenses extends StatefulWidget {
  final String propertyID;

  const Propertyexpenses({super.key, required this.propertyID});

  @override
  State<Propertyexpenses> createState() => _propertyStateUI();
}

class _propertyStateUI extends State<Propertyexpenses> {
  List<Map<String, dynamic>> expenseList = [];
  final _expenseService = ExpenseService();
  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _expenseService.getAllExpenses(widget.propertyID);
      setState(() {
        expenseList = expenses;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading expenses: $e')));
    }
  }

  void _showEditPopup(Map<String, dynamic> expense) {
    final expenseId = expense['id'];
    final fields = [
      FormFieldModel(
        label: 'Description',
        keyName: 'description',
        type: 'text',
        isRequired: true,
        value: expense['description'],
      ),
      FormFieldModel(
        label: 'Month',
        keyName: 'month',
        type: 'date',
        isRequired: true,
        value: expense['month'],
      ),
      FormFieldModel(
        label: 'Amount',
        keyName: 'amount',
        type: 'number',
        isRequired: true,
        value: expense['amount'],
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.7,
          child: DynamicForm(
            fields: fields,
            onSubmit: (values) async {
              try {
                if (values['month'] != null &&
                    values['month'].toString().isNotEmpty) {
                  final DateTime parsedDate = DateTime.parse(values['month']);
                  final DateTime firstDayOfMonth = DateTime(
                    parsedDate.year,
                    parsedDate.month,
                    1,
                  );
                  values['month'] = DateFormat(
                    'yyyy-MM-dd',
                  ).format(firstDayOfMonth);
                }
                await _expenseService.updateExpense(
                  widget.propertyID,
                  expenseId,
                  values,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense updated successfully!'),
                  ),
                );
                _loadExpenses();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating expense: $e')),
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
    final now = DateTime.now();
    final fields = [
      // Define your form fields here using FormFieldModel
      FormFieldModel(
        label: 'Description',
        keyName: 'description',
        type: 'text',
        isRequired: true,
      ),
      FormFieldModel(
        label: 'Month',
        keyName: 'month',
        type: 'date',
        isRequired: true,
        defaultDate: DateTime(now.year, now.month, 1),
      ),
      FormFieldModel(
        label: 'Amount',
        keyName: 'amount',
        type: 'number',
        isRequired: true,
      ),
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
              'Expenses',
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
                        title: const Text("Add New Expense"),
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: screenSize.width * 0.8,
                            height: screenSize.height * 0.6,
                            child: DynamicForm(
                              fields: fields,
                              onSubmit: (values) async {
                                final dataToInsert = {
                                  ...values,
                                  'propertyID': widget.propertyID,
                                };
                                if (dataToInsert['month'] != null &&
                                    dataToInsert['month']
                                        .toString()
                                        .isNotEmpty) {
                                  final DateTime parsedDate = DateTime.parse(
                                    dataToInsert['month'],
                                  );
                                  final DateTime firstDayOfMonth = DateTime(
                                    parsedDate.year,
                                    parsedDate.month,
                                    1,
                                  );
                                  dataToInsert['month'] = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(firstDayOfMonth);
                                }
                                try {
                                  await _expenseService.addExpense(
                                    dataToInsert,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Expense added successfully!',
                                      ),
                                    ),
                                  );
                                  _loadExpenses();
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
                  label: const Text("Add Expense"),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Center(
              child: SizedBox(
                width: screenSize.width * 0.9,
                child: expenseList.isEmpty
                    ? const Center(child: Text('No Expenses found!'))
                    : DynamicTable(
                        columns: const ['description', 'month', 'amount'],
                        data: expenseList,
                        onEdit: _showEditPopup,
                        columnLabels: const ['Description', 'Month', 'Amount'],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
