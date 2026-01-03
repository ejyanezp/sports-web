import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;
import 'package:provider/provider.dart';

import 'package:sports/providers/auth_provider.dart';
import 'package:sports/utils/app_metadata.dart';

class SimpleAuthPage extends StatefulWidget {
  const SimpleAuthPage({super.key});

  @override
  State<SimpleAuthPage> createState() => _SimpleAuthPageState();
}

class _SimpleAuthPageState extends State<SimpleAuthPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final authProv = context.read<AuthProvider>();
    // Si ya tenemos el email (recuperado de persistencia)
    if (authProv.userEmail != null) {
      // SEGURO DE HISTORIAL: Si ya hay sesión, limpiamos cualquier residuo en la URL
      // y detenemos cualquier ejecución posterior. (Protección contra botón Atrás del browser)
      if (web.window.location.search.contains('code=')) {
        log("Sesión activa detectada con código residual. Limpiando URL...");
        web.window.history.replaceState(null, '', '/');
      }
      return;
    }

    final uri = Uri.parse(web.window.location.href);
    final code = uri.queryParameters['code'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificamos que el widget todavía exista en pantalla antes de actuar
      if (!mounted) return;

      if (code != null && !authProv.isProcessing) {
        log("Detectado código en URL. Limpiando historial...");
        // Limpiamos la URL para que el código no se procese dos veces si el usuario da atrás/adelante
        // web.window.history.replaceState(null, '', web.window.location.pathname);
        web.window.history.replaceState(null, '', '/');
        // Limpiamos el título del Tab explícitamente
        log("✅ Intercambio exitoso. URL e Historial saneados.");
        // We have the code! Exchange it for tokens.
        authProv.exchangeCodeForTokens(code);
      }
      else if (authProv.userEmail == null && !authProv.isProcessing) {
        // SOLO REDIRIGE si no hay usuario Y no estamos procesando nada
        authProv.launchLogin();
      }
      web.document.title = "Sports App";
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();

    // 1. Si ya tenemos usuario, vamos a la App
    if (authProv.userEmail != null) {
      // Usuario autenticado → navegar a la app
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/');
      });
      return const SizedBox.shrink();
    }

    // 2. Si hay un error, podríamos mostrarlo con un botón de reintento
    if (authProv.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: ${authProv.errorMessage}", style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: () => web.window.location.reload(),
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Por defecto (mientras carga o redirige), el reloj de arena
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Cargando Sports..."),
          ],
        ),
      ),
    );
  }
}