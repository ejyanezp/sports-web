import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:sports/providers/auth_provider.dart';

class TopBar extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onMenuPressed;

  const TopBar({super.key,
    required this.isMobile,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final authProv = context.read<AuthProvider>();
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

          Text('Hola, ${authProv.userEmail!} 👋',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600,),
          ),

          const Spacer(),

          // Placeholder para notificaciones, avatar, etc.
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
