import 'package:flutter/material.dart';

import 'package:sports/config/env_config.dart';
import 'package:sports/providers/auth_provider.dart';
import 'package:sports/providers/sports_provider.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/services/rest_driver.dart';
import 'package:sports/utils/logs.dart';
import 'package:sports/app/app_router.dart';

import 'package:provider/provider.dart';

/*
Execute in LOCALHOST as
flutter run -d chrome --web-port 8088 \
  --dart-define=COGNITO_CLIENT_ID=24kod6v45jbijpb2v1tnpkrsg7 \
  --dart-define=COGNITO_DOMAIN=us-east-1pemnvgmyy.auth.us-east-1.amazoncognito.com \
  --dart-define=REDIRECT_URI=http://localhost:8088/ \
  --dart-define=API_BASE_URL=https://o7l08961xb.execute-api.us-east-1.amazonaws.com/dev
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
              getToken: () => auth.idToken,
            );
          },
        ),

        // 3. ApiService depende de RestDriver → ProxyProvider
        ProxyProvider<RestDriver, ApiService>(
          update: (_, rest, _) => ApiService(rest: rest),
        ),

        ChangeNotifierProxyProvider<ApiService, SportsProvider>(
          create: (_) => SportsProvider(api: ApiService(rest: RestDriver(
            baseUrl: '',
            getToken: () => null,
          ))), // placeholder, nunca se usa
          update: (_, api, previous) {
            return previous == null
                ? SportsProvider(api: api)
                : SportsProvider(api: api);
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
      title: 'Sports App',
      theme: ThemeData.dark(),
    );
  }
}
