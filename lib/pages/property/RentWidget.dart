import 'package:flutter/material.dart';
import 'package:homefin/services/dataRefresh_service.dart';
import 'package:homefin/services/rentPayments_service.dart';
import 'package:homefin/services/tenant_service.dart';
import 'package:homefin/themes/TableColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class propertyHomeRentWidget extends StatefulWidget {
  final String propertyID;

  const propertyHomeRentWidget({super.key, required this.propertyID});

  @override
  State<propertyHomeRentWidget> createState() => _propertyHomeRentState();
}

class _propertyHomeRentState extends State<propertyHomeRentWidget> {
  final supabase = Supabase.instance.client;
  final _tenantService = TenantService();
  final _rentPaymentService = rentPaymentsService();
  final _dataRefreshService = DataRefreshService();

  List<Map<String, dynamic>> tenants = [];
  List<DateTime> months = [];
  Map<String, dynamic> rentStatus = {};

  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  static const double _tenantColumnWidth = 140;
  static const double _cellWidth = 110;
  static const double _cellHeight = 50;
  static const double _headerHeight = 45;

  @override
  void initState() {
    super.initState();

    // Sync header and body horizontally
    _horizontalBodyController.addListener(() {
      if (_horizontalHeaderController.hasClients) {
        _horizontalHeaderController.jumpTo(_horizontalBodyController.offset);
      }
    });

    _initializeData().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));

        if (_horizontalBodyController.hasClients) {
          final maxExtent = _horizontalBodyController.position.maxScrollExtent;
          _horizontalBodyController.jumpTo(maxExtent);
          _horizontalHeaderController.jumpTo(maxExtent);
        }
      });
    });
  }

  Future<void> _initializeData() async {
    await _loadTenants();
    _generateMonths();
    await _loadRentStatus();
    setState(() {});
  }

  Future<void> _loadTenants() async {
    final response = await _tenantService.getTenantsByPropertyId(
      widget.propertyID,
    );
    tenants = List<Map<String, dynamic>>.from(
      response.map((t) {
        // Parse stopDate safely
        final stopDate = t['stopDate'] != null
            ? DateTime.parse(t['stopDate'])
            : null;
        return {...t, 'stopDate': stopDate};
      }),
    );
  }

  void _generateMonths() {
    final now = DateTime.now();
    months = List.generate(
      12,
      (i) => DateTime(now.year, now.month - 11 + i, 1),
    ); // oldest first → newest last
  }

  Future<void> _loadRentStatus() async {
    final response = await _rentPaymentService.getRentPayments(
      widget.propertyID,
    );
    for (var rent in response) {
      final key =
          "${rent['tenantID']}_${DateTime.parse(rent['month']).toIso8601String()}";
      rentStatus[key] = {
        'amount': rent['amount'] ?? 0,
        'lastMonth': rent['lastMonth'] ?? false,
      };
    }
  }

  Future<void> _toggleRent(
    String tenantId,
    DateTime month,
    double tenantRent, {
    bool isLastMonth = false,
  }) async {
    final key = "${tenantId}_${month.toIso8601String()}";
    final record = rentStatus[key] ?? {'amount': 0, 'lastMonth': false};
    final isPaid = (record['amount'] ?? 0) > 0;

    try {
      if (isPaid && !isLastMonth) {
        await _rentPaymentService.updateRentPayment(
          tenantId,
          0,
          widget.propertyID,
          month,
        );
        record['amount'] = 0;
      } else {
        final existing = await _rentPaymentService
            .getRentPaymentsByPropertyIDAndTenantID(
              widget.propertyID,
              tenantId,
              month,
            );

        if (existing.isEmpty) {
          await _rentPaymentService.addRentPayment(
            tenantId,
            widget.propertyID,
            month,
            tenantRent,
            isLastMonth,
          );
        } else {
          await _rentPaymentService.updateRentPaymentLastMonth(
            tenantId,
            tenantRent,
            widget.propertyID,
            month,
            isLastMonth,
          );
        }

        record['amount'] = tenantRent;
        record['lastMonth'] = isLastMonth;
      }

      rentStatus[key] = record;
      setState(() {});
      _dataRefreshService.notifyDataUpdated();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating rent: $e')));
    }
  }

  /// 🔹 Toggles one-time Last Month (security) payment for a tenant
  Future<void> _toggleLastMonthPayment(String tenantId, bool lastMonth) async {
    try {
      await _tenantService.updateLastMonth(lastMonth, widget.propertyID);

      setState(() {
        final tenant = tenants.firstWhere(
          (t) => t['id'] == tenantId,
          orElse: () => {},
        );
        if (tenant.isNotEmpty) {
          tenant['lastMonth'] = lastMonth;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating lastMonth: $e')));
    }
  }

  Widget _lastMonthCheckbox(Map<String, dynamic> tenant) {
    final bool isChecked = tenant['lastMonth'] ?? false;
        final tableColors = Theme.of(context).extension<TableColors>()!;


    return Container(
      width: _cellWidth,
      height: _cellHeight,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 220, 245),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Center(
        child: Checkbox(
          value: isChecked,
          onChanged: (_) => _toggleLastMonthPayment(tenant['id'], !isChecked),
          activeColor: Colors.white,
          checkColor: Colors.purple.shade400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tenants.isEmpty || months.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalGridWidth = (months.length + 1) * _cellWidth;
    final tableColors = Theme.of(context).extension<TableColors>()!;


    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // ─── Header Row ───
            Row(
              children: [
                _headerCell('Tenants', width: _tenantColumnWidth),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalHeaderController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...months.map(
                          (m) => _headerCell(
                            "${_monthName(m.month)} ${m.year}",
                            width: _cellWidth,
                          ),
                        ),
                        _headerCell("Last Month", width: _cellWidth),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ─── Scrollable Data Section ───
            Expanded(
              child: SingleChildScrollView(
                controller: _verticalController,
                scrollDirection: Axis.vertical,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: tenants
                          .map((t) => _tenantCell(t['fullName']))
                          .toList(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _horizontalBodyController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: totalGridWidth,
                          child: Column(
                            children: tenants.map((tenant) {
                              return Row(
                                children: [
                                  ...months.map((month) {
                                    final key =
                                        "${tenant['id']}_${month.toIso8601String()}";
                                    final record =
                                        rentStatus[key] ??
                                        {'amount': 0, 'lastMonth': false};
                                    final isPaid = (record['amount'] ?? 0) > 0;
                                    final tenantRent = (tenant['rent'] ?? 0)
                                        .toDouble();
                                    return _rentCell(
                                      tenant['id'],
                                      month,
                                      isPaid,
                                      tenantRent,
                                    );
                                  }),
                                  _lastMonthCheckbox(tenant),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Helper widgets ===
  Widget _headerCell(String label, {double width = 100}) {
        final tableColors = Theme.of(context).extension<TableColors>()!;

    return Container(
    width: width,
    height: _headerHeight,
    decoration: BoxDecoration(
      color: tableColors.headerBackground,
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
    ),
    alignment: Alignment.center,
    child: Text(label, style: TextStyle(fontWeight: FontWeight.bold,
    color:tableColors.headerTextColor)),
  );
  } 

  Widget _tenantCell(String name) {
    final tableColors = Theme.of(context).extension<TableColors>()!;

    return Container(
    width: _tenantColumnWidth,
    height: _cellHeight,
    decoration: BoxDecoration(
      color: tableColors.leftColumnBackground,
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
    ),
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text(name, overflow: TextOverflow.ellipsis,style: TextStyle(
                          color: tableColors.leftColumnTextColor,

    ),),
  );
  } 

  Widget _rentCell(
  String tenantId,
  DateTime month,
  bool isPaid,
  double tenantRent,
) {
  final tenant = tenants.firstWhere(
    (t) => t['id'] == tenantId,
    orElse: () => {},
  );

  final stopDateRaw = tenant['stopDate'];
  final startDateRaw = tenant['startDate'];

  // ✅ Safely parse to DateTime (handles both String and DateTime)
  DateTime? stopDate;
  DateTime? startDate;

  if (stopDateRaw != null) {
    if (stopDateRaw is String) {
      stopDate = DateTime.tryParse(stopDateRaw.split('T').first);
    } else if (stopDateRaw is DateTime) {
      stopDate = stopDateRaw;
    }
  }

  if (startDateRaw != null) {
    if (startDateRaw is String) {
      startDate = DateTime.tryParse(startDateRaw.split('T').first);
    } else if (startDateRaw is DateTime) {
      startDate = startDateRaw;
    }
  }

  // 🔹 Determine if this cell should be disabled
  bool isDisabled = false;
  final cellMonth = DateTime(month.year, month.month, 1);

  // Tenant has a stop date → disable months after or equal to that month
  if (stopDate != null) {
    final stopMonth = DateTime(stopDate.year, stopDate.month, 1);
    if (!cellMonth.isBefore(stopMonth)) {
      isDisabled = true;
    }
  }

  // Tenant has a start date → disable months before start date
  if (startDate != null) {
    final startMonth = DateTime(startDate.year, startDate.month, 1);
    if (cellMonth.isBefore(startMonth)) {
      isDisabled = true;
    }
  }

  return Container(
    width: _cellWidth,
    height: _cellHeight,
    decoration: BoxDecoration(
      color: isDisabled
          ? const Color.fromARGB(255, 214, 212, 231) // disabled look
          : const Color.fromARGB(255, 238, 234, 241),
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
    ),
    child: Center(
      child: Checkbox(
        value: isPaid,
        onChanged: isDisabled
            ? null
            : (_) => _toggleRent(tenantId, month, tenantRent),
        activeColor: Colors.white,
        checkColor: Colors.purple.shade400,
      ),
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
