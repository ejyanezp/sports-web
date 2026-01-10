import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import 'package:sports/providers/auth_provider.dart';
import 'package:sports/providers/sports_provider.dart';

class SideNav extends StatelessWidget {
  final bool isCollapsed; // para tablet

  const SideNav({
    super.key,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProv = context.read<AuthProvider>();
    final location = GoRouterState.of(context).uri.toString();

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
                    isActive: location == '/home',
                    onTap: () {
                      context.go('/home');
                    },
                  ),
                  _NavItem(
                    icon: Icons.group,
                    label: 'Directory',
                    isCollapsed: isCollapsed,
                    isActive: location == '/directory',
                    onTap: () {
                      context.go('/directory');
                    },
                  ),
                  _NavItem(
                    icon: Icons.sports_soccer,
                    label: 'Sports',
                    isCollapsed: isCollapsed,
                    isActive: location == '/sports',
                    onTap: () {
                      context.go('/sports');
                      context.read<SportsProvider>().loadSports();
                    },
                  ),
                  _NavItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Championships',
                    isCollapsed: isCollapsed,
                    isActive: location == '/championships',
                    onTap: () {
                      context.go('/championships');
                    },
                  ),
                  _NavItem(
                    icon: Icons.groups_2_outlined,
                    label: 'Teams',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.directions_run_outlined,
                    label: 'Athletes',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.casino_outlined,
                    label: 'Challenges',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallets',
                    isCollapsed: isCollapsed,
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reports',
                    isCollapsed: isCollapsed,
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Color(0xFFFFFFFF), height: 2),

          // OPCIONES INFERIORES
          Column(
            children: [
              _NavItem(
                icon: Icons.support_agent_outlined,
                label: 'Support',
                isCollapsed: isCollapsed,
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Configuration',
                isCollapsed: isCollapsed,
              ),

              // const SizedBox(height: 24),

              // _buildUserSection(isCollapsed, authProv.userEmail!),
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
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    this.isActive = false,
    this.onTap,
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
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF238636)
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
      ),
    );
  }
}