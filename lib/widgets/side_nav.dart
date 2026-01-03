import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:sports/providers/auth_provider.dart';

class SideNav extends StatelessWidget {
  final bool isCollapsed; // para tablet

  const SideNav({
    super.key,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProv = context.read<AuthProvider>();
    return Container(
      color: const Color(0xFF161B22), // estilo Coinbase dark
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // LOGO
          _buildLogo(),

          const SizedBox(height: 32),

          // OPCIONES PRINCIPALES
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isCollapsed: isCollapsed,
                    isActive: true,
                  ),
                  _NavItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Campeonatos',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.groups_2_outlined,
                    label: 'Equipos',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.directions_run_outlined,
                    label: 'Atletas',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.casino_outlined,
                    label: 'Apuestas',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallets',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reportes',
                    isCollapsed: isCollapsed,
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Color(0xFF21262D), height: 1),

          // OPCIONES INFERIORES
          Column(
            children: [
              _NavItem(
                icon: Icons.support_agent_outlined,
                label: 'Soporte',
                isCollapsed: isCollapsed,
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                isCollapsed: isCollapsed,
              ),

              const SizedBox(height: 24),

              _buildUserSection(isCollapsed, authProv.userEmail!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: isCollapsed
            ? const Icon(Icons.sports_soccer, color: Colors.white, size: 32)
            : const Text('SPORTS',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2,),
              ),
      ),
    );
  }

  Widget _buildUserSection(bool collapsed, String userEmail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Text(userEmail, style: TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    this.isActive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF238636) // verde Coinbase success
              : _hover
              ? Colors.white10
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: active ? Colors.white : Colors.white70,
              size: 22,
            ),
            if (!widget.isCollapsed) ...[
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}