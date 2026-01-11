import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

import 'package:sports/widgets/topbar.dart';
import 'package:sports/widgets/side_nav.dart';
import 'package:sports/widgets/canvas_area.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.child});
  // final GoRouterState state;
  final Widget child;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
        final bool isTablet = constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFF0D1117),

          // Drawer solo en móvil
          drawer: isMobile ? const SideNav() : null,

          body: Row(
            children: [
              // Panel izquierdo solo en desktop/tablet
              if (!isMobile)
                SizedBox(width: isTablet ? 80 : 240,
                  child: SideNav(isCollapsed: isTablet),
                ),

              // Canvas derecho
              Expanded(
                child: Column(
                  children: [
                    TopBar(isMobile: isMobile,
                      onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      isCollapsed: false,
                    ),
                    Expanded(child: CanvasArea(child: widget.child)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
