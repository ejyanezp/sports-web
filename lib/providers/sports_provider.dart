import 'package:flutter/widgets.dart'; // necesario para precacheImage

import 'package:sports/models/sport.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/utils/logs.dart';
import 'package:sports/config/env_config.dart';

class SportsProvider extends ChangeNotifier {
  ApiService? _api;

  SportsProvider({required ApiService? api}) : _api = api;

  bool _loading = false;
  String? _error;
  List<Sport> _sports = [];
  // estado de precarga de imágenes
  bool _logosReady = false;
  final Map<String, ImageProvider> _logos = {};

  ApiService? get api => _api;
  bool get loading => _loading;
  String? get error => _error;
  List<Sport> get sports => List.unmodifiable(_sports);
  // getters para logos
  bool get logosReady => _logosReady;
  ImageProvider? logoFor(String sportName) => _logos[sportName];

  void setApi(ApiService? api) {
    _api = api;
  }

  Future<void> loadSports() async {
    if (_api == null) return;
    _loading = true;
    _error = null;
    _logosReady = false;
    notifyListeners();

    try {
      log("SportsProvider.loadSports $api");
      _sports = await _api!.getSports();
    }
    catch (e) {
      _error = 'Error loading sports';
    }
    finally {
      _loading = false;
      notifyListeners();
    }
  }

  // precargar imágenes
  Future<void> preloadLogos(BuildContext context) async {
    _logos.clear();
    _logosReady = false;
    notifyListeners();
    String baseUrl = "${EnvConfig.cdnBaseUrl}/static-assets/sports/";
    for (final sport in _sports) {
      late final String finalUrl;
      if (sport.logoUrl == null || sport.logoUrl!.isEmpty) {
        finalUrl = baseUrl + Sport.defaultLogoUrl; // e.g. default-logo.png
      }
      else {
        finalUrl = baseUrl + sport.logoUrl!;
      }
      log("Preloading logo for ${sport.name}: $finalUrl");
      final img = NetworkImage(finalUrl);
      try {
        await precacheImage(img, context);
        _logos[sport.name] = img;
      }
      catch (e) {
        log("Error precaching ${sport.logoUrl}: $e");
      }
    }
    _logosReady = true;
    notifyListeners();
  }

  Future<void> createSport(Sport sport) async {
    if (_api == null) return;
    try {
      await _api!.createSport(sport);
      await loadSports();
    }
    catch (e) {
      _error = 'Error creating sport';
      notifyListeners();
    }
  }

  Future<void> updateSport(Sport sport) async {
    if (_api == null) return;
    try {
      await _api!.updateSport(sport);
      await loadSports();
    }
    catch (e) {
      _error = 'Error updating sport';
      notifyListeners();
    }
  }

  Future<void> deleteSport(String name) async {
    if (_api == null) return;
    try {
      await _api!.deleteSport(name);
      await loadSports();
    }
    catch (e) {
      _error = 'Error deleting sport';
      notifyListeners();
    }
  }
}