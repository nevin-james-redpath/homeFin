import 'package:flutter/material.dart';
import 'package:homefin/services/expense_service.dart';
import 'package:homefin/services/tenant_service.dart';
import 'package:homefin/services/utitlity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homefin/widgets/inputs/textFormInput.dart';

class propertyFinanceGridWidget extends StatefulWidget {
  final String propertyID;

  const propertyFinanceGridWidget({super.key, required this.propertyID});

  @override
  State<propertyFinanceGridWidget> createState() =>
      _PropertyFinanceGridWidgetState();
}

class _PropertyFinanceGridWidgetState extends State<propertyFinanceGridWidget> {
  final supabase = Supabase.instance.client;
  final _utilityService = UtitlityService();
  final _expenseService = ExpenseService();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  static const double _cellWidth = 110;
  static const double _cellHeight = 50;
  static const double _headerHeight = 45;

  List<DateTime> months = [];
  final List<String> types = [
    'Gas',
    'Electricity',
    'Hydro',
    'Internet',
    'Insurance',
    'Other Expenses',
  ];

  Map<String, String> financeData = {}; // key = "type_month", value = amount

  @override
  void initState() {
    super.initState();
    _generateMonths();
    _loadFinanceData();
  }

  void _generateMonths() {
    final now = DateTime.now();
    months = List.generate(
      7,
      (i) => DateTime(now.year, now.month - i, 1),
    ).reversed.toList();
  }

  Future<void> _loadFinanceData() async {
    try {
      final financeResponse = await _utilityService.getUtilities(
        widget.propertyID,
      );

      for (final record in financeResponse) {
        final key =
            "${record['utilityType']}_${DateTime.parse(record['month']).toIso8601String()}";
        financeData[key] = record['monthly_cost']?.toString() ?? '';
      }

      // Load summarized other expenses
      final otherExpResponse = await _expenseService.otherExpenseByMonth(
        widget.propertyID,
      );
      for (final row in otherExpResponse) {
        final monthValue = row['month'];

        // ✅ Safely handle both String and DateTime types
        late DateTime monthDate;
        if (monthValue is String) {
          monthDate =
              DateTime.tryParse(monthValue.split(' ')[0]) ??
              DateTime.now(); // strip time part if present
        } else if (monthValue is DateTime) {
          monthDate = monthValue;
        } else {
          continue; // skip invalid rows
        }

        final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
        final key = "Other Expenses_${firstDayOfMonth.toIso8601String()}";

        final total = row['total_amount'] ?? 0;
        financeData[key] = total.toString();
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading finance data: $e');
    }
  }

  Future<void> _updateAmount(String type, DateTime month, String value) async {
    if (type == 'Other Expenses') return; // readonly

    final double amount = double.tryParse(value) ?? 0;
    final key = "${type}_${month.toIso8601String()}";
    financeData[key] = value;
    setState(() {});

    try {
      _utilityService.addUpdateUtility(widget.propertyID, type, month, amount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$type updated for ${_monthName(month.month)} ${month.year}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating amount: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- LEFT COLUMN (Sticky Categories) ----------
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header cell for "Category" (same height as month headers)
            Container(
              width: _cellWidth,
              height: _cellHeight,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // 🔹 Category rows (Gas, Electricity, etc.)
            ...types.map((type) {
              final isReadOnly = type == 'Other Expenses';
              final color = isReadOnly
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFF5F5F5);

              return Container(
                width: _cellWidth,
                height: _cellHeight,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: color,
                child: Text(
                  type,
                  style: TextStyle(
                    fontWeight: isReadOnly
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isReadOnly ? Colors.blueGrey[800] : Colors.black,
                  ),
                ),
              );
            }),
          ],
        ),

        // ---------- RIGHT GRID (Scrollable Months) ----------
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    ...months.map(
                      (m) => _headerCell(
                        "${_monthName(m.month)} ${m.year}",
                        width: _cellWidth,
                      ),
                    ),
                  ],
                ),
                // Data Rows
                ...types.map((type) {
                  final isReadOnly = type == 'Other Expenses';
                  final color = isReadOnly
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFF5F5F5);

                  return Row(
                    children: months.map((month) {
                      final key = "${type}_${month.toIso8601String()}";
                      final value = financeData[key] ?? '';
                      return _amountCell(type, month, value, isReadOnly);
                    }).toList(),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String label, {double width = _cellWidth}) => Container(
    width: width,
    height: _cellHeight,
    color: Colors.grey.shade200,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(8),
    child: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );

  Widget _typeCell(String label, bool readOnly) => Container(
    padding: const EdgeInsets.all(8),
    alignment: Alignment.centerLeft,
    child: Text(
      label,
      style: TextStyle(
        fontWeight: readOnly ? FontWeight.bold : FontWeight.normal,
        color: readOnly ? Colors.blueGrey[800] : Colors.black,
      ),
    ),
  );

  Widget _amountCell(String type, DateTime month, String value, bool readOnly) {
    final key = "${type}_${month.toIso8601String()}";

    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: value);
    }
    final controller = _controllers[key]!;

    if (controller.text != value) {
      controller.text = value;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }

    // ✅ Skip focus and update logic if read-only
    if (readOnly) {
      final double parsed = double.tryParse(controller.text) ?? 0;
      final color = Colors.blue[50];

      return Container(
        width: _cellWidth,
        height: _cellHeight,
        color: color,
        alignment: Alignment.center,
        child: Text(
          value.isNotEmpty ? "\$${controller.text}" : "",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );
    }

    // For editable cells only:
    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
      _focusNodes[key]!.addListener(() {
        if (!_focusNodes[key]!.hasFocus) {
          final newValue = controller.text.trim();
          _updateAmount(type, month, newValue);
        }
      });
    }

    final double parsed = double.tryParse(controller.text) ?? 0;
    final color = parsed > 0 ? Colors.green[100] : Colors.grey[100];

    return Container(
      width: _cellWidth,
      height: _cellHeight,
      color: color,
      padding: const EdgeInsets.all(2),
      child: Textforminput(
        hinttext: '',
        controller: controller,
        focusNode: _focusNodes[key],
        onChanged: null,
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month];
  }
}
