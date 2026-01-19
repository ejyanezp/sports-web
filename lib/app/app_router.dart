import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:sports/home_page.dart';
import 'package:sports/pages/championship_page.dart';
import 'package:sports/simple_auth_page.dart';
import 'package:sports/providers/auth_provider.dart';

import '../pages/sport_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("DashboardPage");
  }
}

class DirectoryPage extends StatelessWidget {
  const DirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("DirectoryPage");
  }
}

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("TeamsPage");
  }
}

class AthletesPage extends StatelessWidget {
  const AthletesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("AthletesPage");
  }
}

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ChallengesPage");
  }
}

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("WalletsPage");
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ReportsPage");
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("SupportPage");
  }
}

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ConfigurationPage");
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("ProfilePage");
  }
}

class AppRouter {
  static final Map<String, String> titles = {
    '/': 'Dashboard',
    '/directory': 'Directory',
    '/sports': 'Sports',
    '/championships': 'Championships',
    '/teams': 'Teams',
    '/athletes': 'Athletes',
    '/challenges': 'Challenges',
    '/wallets': 'Wallets',
    '/reports': 'Reports',
    '/support': 'Support',
    '/configuration': 'Preferences',
  };

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      // 1. Mientras AuthProvider está inicializando → no redirigir
      if (auth.status == AuthStatus.initializing) {
        return null;
      }
      // 2. Mientras está procesando login (intercambio de code) → no redirigir
      if (auth.isProcessing) {
        return null;
      }
      final loggedIn = auth.status == AuthStatus.authenticated;
      // final goingToLogin = state.matchedLocation == '/login';    // <- old version, no usar, no funciona bien con F5
      final goingToLogin = state.uri.path == '/login';
      // 2. Si NO está autenticado → forzar /login
      if (!loggedIn && !goingToLogin) {
        return '/login';
      }
      // 3. Si está autenticado y va a /login → mandarlo al home
      if (loggedIn && goingToLogin) {
        return '/';
      }
      // 4. En cualquier otro caso → no redirigir
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
          GoRoute(name: 'Home',
            path: '/',
            builder: (context, state) => const DashboardPage(),
            routes: [
              GoRoute(name: 'Directory',
                path: 'directory',
                builder: (context, state) => const DirectoryPage(),
              ),
              GoRoute(name: 'Sports',
                path: 'sports',
                builder: (context, state) => const SportsPage(),
              ),
              GoRoute(name: 'Championships',
                path: 'championships',
                builder: (context, state) => const ChampionshipsPage(),
              ),
              GoRoute(name: 'Teams',
                path: 'teams',
                builder: (context, state) => const TeamsPage(),
              ),
              GoRoute(name: 'Athletes',
                path: 'athletes',
                builder: (context, state) => const AthletesPage(),
              ),
              GoRoute(name: 'Challenges',
                path: 'challenges',
                builder: (context, state) => const ChallengesPage(),
              ),
              GoRoute(name: 'Wallets',
                path: 'wallets',
                builder: (context, state) => const WalletsPage(),
              ),
              GoRoute(name: 'Reports',
                path: 'reports',
                builder: (context, state) => const ReportsPage(),
              ),

              GoRoute(name: 'Support',
                path: 'support',
                builder: (context, state) => const SupportPage(),
              ),
              GoRoute(name: 'Preferences',
                path: 'configuration',
                builder: (context, state) => const ConfigurationPage(),
              ),
            ]
          ),
        ],
      ),
    ],
  );
}