import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:homefin/services/dataRefresh_service.dart';
import 'package:homefin/services/expenseSummary_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyExpensesWidget extends StatefulWidget {
  final String propertyID;

  const PropertyExpensesWidget({super.key, required this.propertyID});

  @override
  State<PropertyExpensesWidget> createState() => _PropertyExpensesWidgetUI();
}

class _PropertyExpensesWidgetUI extends State<PropertyExpensesWidget> {
  final supabase = Supabase.instance.client;
  final _expenseSummaryService = ExpenseSummaryService();
  final _dataRefreshService = DataRefreshService();

  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // 🔹 New filter state
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadExpenseSummary();
    _dataRefreshService.addListener(() {
      _loadExpenseSummary();
    });
  }

  Future<void> _loadExpenseSummary() async {
    try {
      final response = await _expenseSummaryService.getAllExpensesSummary(
        widget.propertyID,
      );

      final expenses = response
          .map<Map<String, dynamic>>(
            (row) => {
              'month': row['month'],
              'amount': (row['total_amount'] as num?)?.toDouble() ?? 0.0,
              'type': row['ExpenseType'] ?? 'Unknown',
            },
          )
          .toList();

      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });

      // 🔹 Auto-scroll to latest
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } catch (e) {
      debugPrint('Error loading Expense Summary data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<String> _generateLast12Months() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final date = DateTime(now.year, now.month - 11 + i, 1);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}"; // YYYY-MM
    });
  }

  double _getMaxY(Map<String, Map<String, double>> groupedData) {
    double maxY = 0;
    for (final month in groupedData.values) {
      for (final value in month.values) {
        if (value > maxY) maxY = value;
      }
    }
    return maxY;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return const Center(child: Text('No expense data found'));
    }

    // 🔹 Apply filter
    final filteredExpenses = _selectedFilter == 'All'
        ? _expenses
        : _expenses.where((e) => e['type'] == _selectedFilter).toList();

    // 🔹 Ensure all last 12 months exist (even if no data)
    final allMonths = _generateLast12Months();

    // 🔹 Group and fill defaults
    final Map<String, Map<String, double>> groupedData = {
      for (final m in allMonths) m: {},
    };

    for (final row in filteredExpenses) {
      final monthStr = row['month'].toString().substring(0, 7); // YYYY-MM
      if (!groupedData.containsKey(monthStr)) continue;

      final type = row['type'];
      final amount = row['amount'];
      groupedData[monthStr]![type] =
          (groupedData[monthStr]![type] ?? 0) + amount;
    }

    // 🔹 Sort months oldest → newest
    final months = groupedData.keys.toList()
      ..sort(
        (a, b) => DateTime.parse("$a-01").compareTo(DateTime.parse("$b-01")),
      );
    final expenseTypes = groupedData.values
        .expand((m) => m.keys)
        .toSet()
        .toList();

    final maxY = _getMaxY(groupedData) * 1.2;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          // 🔹 Filter dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                value: _selectedFilter,
                items: [
                  const DropdownMenuItem(value: 'All', child: Text('All')),
                  ..._expenses
                      .map((e) => e['type'])
                      .toSet()
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Sticky Left Y-Axis
                SizedBox(
                  width: 55,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      final maxY = _getMaxY(groupedData) * 1.2;
                      final value = maxY - (maxY / 5) * index;
                      String label;
                      if (value >= 1000) {
                        label = "\$${(value / 1000).toStringAsFixed(1)}k";
                      } else {
                        label = "\$${value.toStringAsFixed(0)}";
                      }
                      return Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      );
                    }),
                  ),
                ),

                // 🔹 Scrollable Chart Area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: months.length * (expenseTypes.length * 25 + 40),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          minY: 0,
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= months.length)
                                    return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[i],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(months.length, (i) {
                            final month = months[i];
                            final values = groupedData[month]!;
                            return BarChartGroupData(
                              x: i,
                              barsSpace: 6,
                              barRods: List.generate(expenseTypes.length, (j) {
                                final type = expenseTypes[j];
                                final amount = values[type] ?? 0.0;
                                return BarChartRodData(
                                  toY: amount,
                                  width: 12,
                                  color: Colors
                                      .primaries[j % Colors.primaries.length],
                                  borderRadius: BorderRadius.circular(3),
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔹 Sticky Right Y-Axis (duplicate of left)
                SizedBox(
                  width: 55,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      final maxY = _getMaxY(groupedData) * 1.2;
                      final value = maxY - (maxY / 5) * index;
                      String label;
                      if (value >= 1000) {
                        label = "\$${(value / 1000).toStringAsFixed(1)}k";
                      } else {
                        label = "\$${value.toStringAsFixed(0)}";
                      }
                      return Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // 🔹 Legend
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: expenseTypes.map((type) {
              final color =
                  Colors.primaries[expenseTypes.indexOf(type) %
                      Colors.primaries.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, color: color),
                  const SizedBox(width: 5),
                  Text(type, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
