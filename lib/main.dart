import 'package:flutter/material.dart';
import 'package:homefin/config/supabase_config.dart';
import 'package:homefin/goRouterRefreshStream.dart';
import 'package:homefin/pages/authentication/LoginScreen.dart';
import 'package:homefin/pages/authentication/SignUpScreen.dart';
import 'package:homefin/pages/dashboard/homeScreen.dart';
import 'package:homefin/pages/expenses/propertyExpenses.dart';
import 'package:homefin/pages/property/propertyHome.dart';
import 'package:homefin/pages/users/tenantList.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // ✅ Build router that listens for auth state changes
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(
        Supabase.instance.client.auth.onAuthStateChange,
      ),
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final loggedIn = session != null;

        // Protect routes
        final loggingIn =
            state.uri.toString() == '/login' ||
            state.uri.toString() == '/register';

        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/property',
          builder: (context, state) {
            final propertyId = state.uri.queryParameters['id'];
            return propertyHome(propertyID: propertyId!);
          },
        ),
        GoRoute(
          path: '/property/tenants',
          builder: (context, state) {
            final propertyId = state.uri.queryParameters['id'];
            return tenantList(propertyID: propertyId!);
          },
        ),
        GoRoute(
          path: '/property/expenses',
          builder: (context, state) {
            final propertyId = state.uri.queryParameters['id'];
            return Propertyexpenses(propertyID: propertyId!);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
