import 'package:flutter/material.dart';
import 'package:homefin/pages/property/propertyExpensesWidget.dart';
import 'package:homefin/pages/property/propertyFinanceGridWidget.dart';
import 'package:homefin/pages/property/propertyFinanceSummaryWidget.dart';
import 'package:homefin/pages/property/propertyHomeRentWidget.dart';
import 'package:homefin/services/property_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class propertyHome extends StatefulWidget {
  final String propertyID;
  const propertyHome({super.key, required this.propertyID});

  @override
  State<propertyHome> createState() => _PropertyHomeState();
}

class _PropertyHomeState extends State<propertyHome> {
  Map<String, dynamic>? propertyDetails;
  final _propertyService = PropertyService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final details = await _propertyService.getPropertyById(widget.propertyID);
      setState(() {
        propertyDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading property: $e')));
    }
  }

  Widget _dashboardCard({
    required String title,
    required Widget child,
    required Color color,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 16,
      height: MediaQuery.of(context).size.height / 2 - 59,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟣 Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          // 🧩 Content section
          Expanded(
            child: Padding(padding: const EdgeInsets.all(8.0), child: child),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (propertyDetails == null) {
      return const Scaffold(body: Center(child: Text('Property not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(propertyDetails?['address'] ?? 'Property Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    context.go('/property/tenants?id=${widget.propertyID}');
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Manage Users'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    context.go('/property/expenses?id=${widget.propertyID}');
                  },
                  icon: const Icon(Icons.money),
                  label: const Text('Manage Expenses'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 12, // horizontal gap
              runSpacing: 12, // vertical gap
              children: [
                _dashboardCard(
                  title: "Finance Summary",
                  color: Colors.white,
                  child: PropertyFinanceSummaryWidget(
                    propertyID: widget.propertyID,
                  ),
                ),
                _dashboardCard(
                  title: "Rent Payments",
                  color: Colors.white,
                  child: propertyHomeRentWidget(propertyID: widget.propertyID),
                ),
                _dashboardCard(
                  title: "Expenses & Utilities",
                  color: Colors.white,
                  child: PropertyExpensesWidget(propertyID: widget.propertyID),
                ),
                _dashboardCard(
                  title: "Utilities & Expenses",
                  color: Colors.white,
                  child: propertyFinanceGridWidget(
                    propertyID: widget.propertyID,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
