import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:sports/home_page.dart';
import 'package:sports/simple_auth_page.dart';
import 'package:sports/auth_provider.dart';
//import 'package:sports/features/championships/view/championships_page.dart';
//import 'package:sports/features/profiles/view/profiles_page.dart';
//import 'package:sports/features/dashboard/view/dashboard_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("DashboardPage");
  }
}

class ChampionshipsPage extends StatelessWidget {
  const ChampionshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ChampionshipsPage");
  }
}

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ProfilesPage");
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final loggedIn = authProv.userEmail != null;
      final processing = authProv.isProcessing;
      final goingToLogin = state.matchedLocation == '/login';
      if (processing) return null;
      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/';
      return null;
    },

    routes: [
      /// LOGIN FUERA DEL SHELL
      GoRoute(
        path: '/login',
        builder: (context, state) => const SimpleAuthPage(),
      ),

      /// SHELL PARA TODA LA APP AUTENTICADA
      ShellRoute(
        builder: (context, state, child) => MyHomePage(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/championships',
            builder: (context, state) => const ChampionshipsPage(),
          ),
          GoRoute(
            path: '/profiles',
            builder: (context, state) => const ProfilesPage(),
          ),
        ],
      ),
    ],
  );
}