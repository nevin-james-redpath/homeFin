import 'package:flutter/material.dart';
import 'package:homefin/pages/authentication/LoginScreen.dart';
import 'package:homefin/services/auth_service.dart';
import 'package:homefin/widgets/addHouseForm.dart';
import 'package:homefin/widgets/card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handlePropertySubmit(String title) {
    print('Property Title: $title');
    // TODO: save to database or update list of cards
  }

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();
    final user = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
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
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Addhouseform(onSubmit: _handlePropertySubmit),
                      ),
                    );
                  },
                  label: const Text("Add Property"),
                  icon: const Icon(Icons.add),
                ),
              ),
            ),
            SizedBox(height: 240),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyCard(
                  imagePath: 'assets/images/house_sample.png',
                  title: '214 Dunsmore Lane, Barrie, ON',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
