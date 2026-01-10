import 'package:package_info_plus/package_info_plus.dart';

class AppMetadata {
  static String buildName = "Unknown";
  static String buildNumber = "0";

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    buildName = packageInfo.version;    // Captura el --build-name
    buildNumber = packageInfo.buildNumber; // Captura el --build-number
  }

  static String get fullVersion => "v$buildName ($buildNumber)";
}

void log(String message) {
  // Solo imprimimos en modo debug para mantener la privacidad en producción
  assert(() {
    final now = DateTime.now();

    // Formateo manual para evitar dependencias externas como 'intl'
    // y mantener el binario ligero.
    final timestamp = "${now.year.toString()}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')}."
        "${now.millisecond.toString().padLeft(3, '0')}";

    print('🦁 [$timestamp] [${AppMetadata.fullVersion}] [Auth-Lion]: $message');
    return true;
  }());
}