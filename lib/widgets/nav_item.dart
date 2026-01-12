import 'package:flutter/material.dart';

class NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isActive;
  final VoidCallback? onTap;

  const NavItem({super.key,
    required this.icon,
    required this.label,
    required this.isCollapsed,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
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