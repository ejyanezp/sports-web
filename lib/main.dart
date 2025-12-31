import 'package:flutter/material.dart';
import 'package:sports/config/env_config.dart';

import 'package:sports/home_page.dart';
import 'package:sports/auth_provider.dart';

import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

/*
Execute in LOCALHOST as
flutter run -d chrome --web-port 8088
Made with Flutter 3.38.5 / Date: 12/31/2025
*/
void main() {
  EnvConfig.validate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider())
      ],
      child: const MaterialApp(home: SimpleAuthPage())
    )
  );
}

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
    final uri = Uri.parse(web.window.location.href);
    final code = uri.queryParameters['code'];
    final authProv = context.read<AuthProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificamos que el widget todavía exista en pantalla antes de actuar
      if (!mounted) return;

      if (code != null && !authProv.isProcessing) {
        // 1. BLOQUEO: Evita que cualquier otro proceso inicie un redirect
        authProv.setProcessing(true);
        // Step 2: We have the code! Exchange it for tokens.
        authProv.exchangeCodeForTokens(code);
      }
      else if (authProv.userEmail == null && !authProv.isProcessing) {
        // 2. SOLO REDIRIGE si no hay usuario Y no estamos procesando nada
        authProv.launchLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();

    // 1. Si ya tenemos usuario, vamos a la App
    if (authProv.userEmail != null) {
      return MyHomePage(title: "Sports");
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