import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:sports/widgets/nav_item.dart';
import 'package:sports/providers/entitlements.dart';

class SideNav extends StatelessWidget {
  final bool isCollapsed; // para tablet

  const SideNav({
    super.key,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final entitlements = context.watch<Entitlements>();

    if (!entitlements.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  NavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isCollapsed: isCollapsed,
                    isActive: location == '/',
                    onTap: () {
                      context.goNamed('Home');
                    },
                  ),
                  NavItem(
                    icon: Icons.group,
                    label: 'Directory',
                    isCollapsed: isCollapsed,
                    isActive: location.startsWith('/directory'),
                    onTap: () {
                      context.goNamed('Directory');
                    },
                  ),
                  NavItem(
                    icon: Icons.sports_soccer,
                    label: 'Sports',
                    isCollapsed: isCollapsed,
                    isActive: location.startsWith('/sports'),
                    onTap: () {
                      context.goNamed('Sports');
                      // context.read<SportsProvider>().loadSports();
                    },
                  ),
                  NavItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Championships',
                    isCollapsed: isCollapsed,
                    isActive: location.startsWith('/championships'),
                    onTap: () {
                      context.goNamed('Championships');
                    },
                  ),
                  NavItem(
                    icon: Icons.groups_2_outlined,
                    label: 'Teams',
                    isCollapsed: isCollapsed,
                    isActive: location.startsWith('/teams'),
                    onTap: () {
                      context.goNamed('Teams');
                    },
                  ),
                  NavItem(
                    icon: Icons.directions_run_outlined,
                    label: 'Athletes',
                    isCollapsed: isCollapsed,
                    isActive: location.startsWith('/athletes'),
                    onTap: () {
                      context.goNamed('Athletes');
                    },
                  ),
                  NavItem(
                    icon: Icons.casino_outlined,
                    label: 'Challenges',
                    isCollapsed: isCollapsed,
                    isActive: location.startsWith('/challenges'),
                    onTap: () {
                      context.goNamed('Challenges');
                    },
                  ),
                  NavItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reports',
                    isCollapsed: isCollapsed,
                    isActive: location.startsWith('/reports'),
                    onTap: () {
                      context.goNamed('Reports');
                    },
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Color(0xFFFFFFFF), height: 2),

          // OPCIONES INFERIORES
          Column(
            children: [
              NavItem(
                icon: Icons.support_agent_outlined,
                label: 'Support',
                isCollapsed: isCollapsed,
                isActive: location.startsWith('/support'),
                onTap: () {
                  context.goNamed('Support');
                },
              ),
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
            ? const Icon(Icons.sports, color: Colors.white, size: 32)
            : const Text('Challengers',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2,),
              ),
      ),
    );
  }

}
