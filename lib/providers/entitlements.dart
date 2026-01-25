import 'package:flutter/widgets.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/utils/logs.dart';

class Entitlements extends ChangeNotifier {
  bool _loaded = false;
  ApiService? _api;
  // Nuevo modelo: módulo -> lista de acciones
  Map<String, List<String>> _permissions = {};

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
    // Convertimos dinámico → Map<String, List<String>>
    _permissions = response.map((key, value) => MapEntry(key, List<String>.from(value),),);
    log("Permisos = $_permissions");
    _loaded = true;
    notifyListeners();
  }

  // método can() we do an action in a given module?
  bool can(String module, String action) {
    final actions = _permissions[module];
    if (actions == null) return false;
    return actions.contains(action);
  }
}