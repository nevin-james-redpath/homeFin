import 'package:flutter/material.dart';
import 'package:homefin/services/dataRefresh_service.dart';
import 'package:homefin/services/expense_service.dart';
import 'package:homefin/services/utitlity_service.dart';
import 'package:homefin/themes/TableColors.dart';
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
  final _dataRefreshService = DataRefreshService();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final ScrollController _horizontalController = ScrollController();

  static const double _cellWidth = 110;
  static const double _cellHeight = 50;

  List<DateTime> months = [];
  final List<String> types = [
    'Gas',
    'Electricity',
    'Hydro',
    'Internet',
    'Insurance',
    'Mortgage',
    'Other Expenses',
  ];

  Map<String, String> financeData = {}; // key = "type_month", value = amount

  @override
  void initState() {
    super.initState();
    _generateMonths();
    _loadFinanceData().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        if (_horizontalController.hasClients) {
          _horizontalController.jumpTo(
            _horizontalController.position.maxScrollExtent,
          );
        }
      });
    });
  }

  void _generateMonths() {
    final now = DateTime.now();
    months = List.generate(12, (i) => DateTime(now.year, now.month - 11 + i, 1));
  }

  Future<void> _loadFinanceData() async {
    try {
      final financeResponse = await _utilityService.getUtilities(widget.propertyID);
      for (final record in financeResponse) {
        final key =
            "${record['utilityType']}_${DateTime.parse(record['month']).toIso8601String()}";
        financeData[key] = record['monthly_cost']?.toString() ?? '';
      }

      final otherExpResponse =
          await _expenseService.otherExpenseByMonth(widget.propertyID);
      for (final row in otherExpResponse) {
        final monthValue = row['month'];
        late DateTime monthDate;
        if (monthValue is String) {
          monthDate = DateTime.tryParse(monthValue.split(' ')[0]) ?? DateTime.now();
        } else if (monthValue is DateTime) {
          monthDate = monthValue;
        } else {
          continue;
        }

        final key = "Other Expenses_${DateTime(monthDate.year, monthDate.month, 1).toIso8601String()}";
        financeData[key] = (row['total_amount'] ?? 0).toString();
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading finance data: $e');
    }
  }

  Future<void> _updateAmount(String type, DateTime month, String value) async {
    final amount = double.tryParse(value.trim()) ?? 0;
    if (type == 'Other Expenses' || amount == 0) return;

    final key = "${type}_${month.toIso8601String()}";
    if (financeData[key] == value) return;

    financeData[key] = value;
    setState(() {});

    try {
      await _utilityService.addUpdateUtility(widget.propertyID, type, month, amount);
      _dataRefreshService.notifyDataUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type updated for ${_monthName(month.month)} ${month.year}'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating $type: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) return const Center(child: CircularProgressIndicator());
    final tableColors = Theme.of(context).extension<TableColors>()!;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- LEFT COLUMN ----------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Container(
                width: _cellWidth,
                height: _cellHeight,
                color: tableColors.headerBackground,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tableColors.headerTextColor,
                  ),
                ),
              ),
              // Category labels
              ...types.map((type) {
                final isReadOnly = type == 'Other Expenses';
                final isHighlighted = type == 'Other Expenses'; // example of special styling
                final color = tableColors.leftColumnBackground;
                final textColor = isHighlighted
                    ? tableColors.hoverColor
                    : tableColors.leftColumnTextColor;


                return Container(
                  width: _cellWidth,
                  height: _cellHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border(
                      bottom: BorderSide(color: tableColors.borderColor),
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontWeight: isReadOnly ? FontWeight.bold : FontWeight.normal,
                      color: tableColors.textColor,
                    ),
                  ),
                );
              }),
            ],
          ),

          // ---------- RIGHT GRID ----------
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: months.map((m) {
                      return _headerCell("${_monthName(m.month)} ${m.year}");
                    }).toList(),
                  ),
                  // Data Rows
                  ...types.map((type) {
                    final isReadOnly = type == 'Other Expenses';
                    return Row(
                      children: months
                          .map((month) =>
                              _amountCell(type, month, financeData["${type}_${month.toIso8601String()}"] ?? '', isReadOnly))
                          .toList(),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label) {
    final tableColors = Theme.of(context).extension<TableColors>()!;
    return Container(
      width: _cellWidth,
      height: _cellHeight,
      color: tableColors.headerBackground,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: tableColors.headerTextColor,
        ),
      ),
    );
  }

  Widget _amountCell(String type, DateTime month, String value, bool readOnly) {
    final key = "${type}_${month.toIso8601String()}";
    final tableColors = Theme.of(context).extension<TableColors>()!;

    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: value);
    }
    final controller = _controllers[key]!;

    if (controller.text != value) {
      controller.text = value;
      controller.selection =
          TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    }

    // Read-only display
    if (readOnly) {
      return Container(
        width: _cellWidth,
        height: _cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tableColors.rowOddBackground.withOpacity(0.8),
          border: Border.all(color: tableColors.borderColor),
        ),
        child: Text(
          value.isNotEmpty ? "\$${controller.text}" : "",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: tableColors.textColor,
          ),
        ),
      );
    }

    // Editable cells
    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
      _focusNodes[key]!.addListener(() {
        if (!_focusNodes[key]!.hasFocus) {
          _updateAmount(type, month, controller.text.trim());
        }
      });
    }

    final double parsed = double.tryParse(controller.text) ?? 0;
    final color = parsed > 0
        ? tableColors.hoverColor
        : (month.month.isEven
            ? tableColors.rowEvenBackground
            : tableColors.rowOddBackground);

    return Container(
      width: _cellWidth,
      height: _cellHeight,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: tableColors.borderColor),
      ),
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
