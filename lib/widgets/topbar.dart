import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:sports/providers/auth_provider.dart';
import 'package:sports/app/app_router.dart';

class TopBar extends StatelessWidget {
  final bool isCollapsed; // para tablet
  final bool isMobile;
  final VoidCallback onMenuPressed;

  const TopBar({super.key,
    required this.isMobile,
    required this.onMenuPressed,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.matchedLocation;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(
          bottom: BorderSide(color: Color(0xFF21262D), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuPressed,
            ),

          const SizedBox(width: 8),

          Text(AppRouter.titles[location] ?? '', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600,),),

          const Spacer(),

          if (!isMobile)
            _profileMenu(context),

        ],
      ),
    );
  }
}

Widget _profileMenu(BuildContext context) {
  return PopupMenuButton<String>(
    offset: const Offset(0, 40), // baja el menú para que no tape el icono
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    onSelected: (value) {
      switch (value) {
        case 'configuration':
          context.goNamed('Configurations');
          break;
        case 'wallets':
          context.goNamed('Wallets');
          break;
        case 'logout':
          context.read<AuthProvider>().logout();
          break;
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 'configuration',
        child: Row(
          children: [
            Icon(Icons.settings, size: 20),
            const SizedBox(width: 12),
            const Text('Configuration'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'wallets',
        child: Row(
          children: [
            Icon(Icons.wallet, size: 20),
            const SizedBox(width: 12),
            const Text('eWallets'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'logout',
        child: Row(
          children: const [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ],
    child: Row(
      children: [
        const Icon(Icons.account_circle, size: 28, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          context.watch<AuthProvider>().userEmail ?? '',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}