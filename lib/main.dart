import 'package:flutter/material.dart';

import 'package:sports/config/env_config.dart';
import 'package:sports/auth_provider.dart';
import 'package:sports/utils/app_metadata.dart';
import 'package:sports/app/app_router.dart';

import 'package:provider/provider.dart';

/*
Execute in LOCALHOST as
flutter run -d chrome --web-port 8088 \
  --dart-define=COGNITO_CLIENT_ID=24kod6v45jbijpb2v1tnpkrsg7 \
  --dart-define=COGNITO_DOMAIN=us-east-1pemnvgmyy.auth.us-east-1.amazoncognito.com \
  --dart-define=REDIRECT_URI=http://localhost:8088/
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
        ChangeNotifierProvider(create: (_) => AuthProvider())
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
