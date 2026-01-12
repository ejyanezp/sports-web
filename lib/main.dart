import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sports/config/env_config.dart';
import 'package:sports/providers/auth_provider.dart';
import 'package:sports/providers/sports_provider.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/services/rest_driver.dart';
import 'package:sports/utils/logs.dart';
import 'package:sports/app/app_router.dart';

/*
Execute in LOCALHOST as
flutter run -d chrome --web-port 8088 \
  --dart-define=variables... ...
  See internal documentation.
Made with Flutter 3.38.5 / Date: 12/31/2025
*/
void main() async {
  // Al usar un plugin (como package_info_plus, shared_preferences, o comunicaciones nativas)
  // antes del runApp(), se debe llama a WidgetsFlutterBinding.ensureInitialized()
  WidgetsFlutterBinding.ensureInitialized();
  // Cargar metadatos de versión
  await AppMetadata.init();
  // validación de variables de entorno
  EnvConfig.validate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. RestDriver depende del token → ProxyProvider
        ProxyProvider<AuthProvider, RestDriver>(
          update: (_, auth, _) {
            return RestDriver(
              baseUrl: EnvConfig.apiBaseUrl,
              // Se debe pasar una función al token y no el valor del token, porque el mismo podría cambiar.
              // Ejemplo: después de aplicar el refresh token.
              // Se usa el access token para implementar autorizaciones.
                getToken: () => auth.ensureValidAccessToken(),
            );
          },
        ),

        // 3. ApiService depende de RestDriver → ProxyProvider
        ProxyProvider<RestDriver, ApiService>(
          update: (_, rest, _) => ApiService(rest: rest),
        ),

        ChangeNotifierProxyProvider<ApiService, SportsProvider>(
          create: (_) => SportsProvider(api: null),
          update: (_, api, previous) {
            previous?.setApi(api);
            return previous!;
          },
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'Challengers App',
      theme: ThemeData.dark(),
    );
  }
}
