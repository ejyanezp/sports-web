import 'package:flutter/widgets.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/utils/logs.dart';

class Entitlements extends ChangeNotifier {
  bool _loaded = false;
  ApiService? _api;
  Map<String, bool> _permissions = {};

  Entitlements() : _loaded = false;

  void setApi(ApiService api) {
    _api = api;
  }

  bool get isLoaded => _loaded;

  void clean() {
    _loaded = false;
    _permissions = {};
  }

  Future<void> load() async {
    if (_api == null) {
      log("ApiService.instance == null");
      return;
    }
    if (_loaded) {
      log("Permisos ya cargados");
      return;
    }
    log("ApiService.instance != null, cargar permisos");
    final response = await ApiService.instance!.getEntitlements();
    _permissions = Map<String, bool>.from(response);
    log("Permisos = $_permissions");
    _loaded = true;
    notifyListeners();
  }

  bool can(String permission) {
    String key = "urn:challengers:api/$permission";
    log("key=$key");
    return _permissions[key] == true;
  }
}