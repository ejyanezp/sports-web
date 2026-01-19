import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sports/config/env_config.dart';
import 'package:sports/providers/auth_provider.dart';
import 'package:sports/providers/sports_provider.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/services/rest_driver.dart';
import 'package:sports/utils/logs.dart';
import 'package:sports/app/app_router.dart';
import 'package:sports/providers/entitlements.dart';

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

  final auth = AuthProvider();
  final rest = RestDriver(
    baseUrl: EnvConfig.apiBaseUrl,
    getToken: () => auth.ensureValidAccessToken(),
  );
  final api = ApiService(rest: rest);
  final entitlements = Entitlements()..setApi(api);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        Provider.value(value: rest),
        Provider.value(value: api),
        ChangeNotifierProvider.value(value: entitlements),
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
