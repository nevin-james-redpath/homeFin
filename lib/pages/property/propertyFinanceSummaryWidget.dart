import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:homefin/services/financeSummary_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyFinanceSummaryWidget extends StatefulWidget {
  final String propertyID;

  const PropertyFinanceSummaryWidget({super.key, required this.propertyID});

  @override
  State<PropertyFinanceSummaryWidget> createState() =>
      _FinanceSummaryChartState();
}

class _FinanceSummaryChartState extends State<PropertyFinanceSummaryWidget> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _summary = [];
  final ScrollController _scrollController = ScrollController();
  final _financeSummaryService = FinancesummaryService();

  @override
  void initState() {
    super.initState();
    _loadFinanceSummary();
  }

  Future<void> _loadFinanceSummary() async {
    try {
      final response = await _financeSummaryService.getFinanceSummary(
        widget.propertyID,
      );

      final List<Map<String, dynamic>> data = response
          .map<Map<String, dynamic>>((row) {
            return {
              'month': row['month'],
              'amount': (row['total_amount'] as num?)?.toDouble() ?? 0.0,
              'outcome': row['Outcome'] ?? 'Unknown',
            };
          })
          .toList();

      setState(() {
        _summary = data;
        _isLoading = false;
      });

      // 🔹 Automatically scroll to latest month after load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } catch (e) {
      debugPrint('Error loading finance summary: $e');
      setState(() => _isLoading = false);
    }
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

    if (_summary.isEmpty) {
      return const Center(child: Text('No finance data available'));
    }

    // 🔹 Group data by month (Income & Expenses)
    final Map<String, Map<String, double>> grouped = {};
    for (final row in _summary) {
      final monthStr = row['month'].toString().substring(0, 7); // YYYY-MM
      final outcome = row['outcome'];
      final amount = row['amount'];

      grouped.putIfAbsent(monthStr, () => {'Income': 0, 'Expenses': 0});
      grouped[monthStr]![outcome] = (grouped[monthStr]![outcome] ?? 0) + amount;
    }

    // 🔹 Sort months oldest → newest
    final months = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    final maxY = _getMaxY(grouped) * 1.2; // 20% padding above max

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 🔹 Scrollable bar chart
          SizedBox(
            height: 285,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: months.length * 100, // adjust width per month
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0');
                            if (value >= 1000) {
                              return Text(
                                '\$${(value / 1000).toStringAsFixed(1)}k',
                              );
                            }
                            return Text('\$${value.toStringAsFixed(0)}');
                          },
                        ),
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
                      final data = grouped[months[i]]!;
                      final income = data['Income'] ?? 0;
                      final expenses = data['Expenses'] ?? 0;

                      return BarChartGroupData(
                        x: i,
                        barsSpace: 8,
                        barRods: [
                          // Income bar
                          BarChartRodData(
                            toY: income,
                            width: 14,
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(3),
                          ),
                          // Expense bar
                          BarChartRodData(
                            toY: expenses,
                            width: 14,
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 🔹 Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.green[400]!, 'Income'),
              const SizedBox(width: 20),
              _legendItem(Colors.red[400]!, 'Expenses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(
    children: [
      Container(width: 12, height: 12, color: color),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
