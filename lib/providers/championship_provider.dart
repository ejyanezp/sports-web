import 'package:flutter/widgets.dart';

import 'package:sports/models/championship.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/utils/logs.dart';
import 'package:sports/config/env_config.dart';

class ChampionshipsProvider extends ChangeNotifier {
  ApiService? _api;

  ChampionshipsProvider({required ApiService? api}) : _api = api;

  bool _loading = false;
  String? _error;
  List<Championship> _championships = [];

  bool _logosReady = false;
  final Map<String, ImageProvider> _logos = {};

  ApiService? get api => _api;
  bool get loading => _loading;
  String? get error => _error;
  List<Championship> get championships => List.unmodifiable(_championships);

  bool get logosReady => _logosReady;
  ImageProvider? logoFor(String id) => _logos[id];

  void setApi(ApiService? api) => _api = api;

  Future<void> loadChampionships() async {
    if (_api == null) return;
    _loading = true;
    _error = null;
    _logosReady = false;
    notifyListeners();

    try {
      log("ChampionshipsProvider.loadChampionships $api");
      _championships = await _api!.getChampionships();
    } catch (e) {
      _error = 'Error loading championships';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> preloadLogos(BuildContext context) async {
    _logos.clear();
    _logosReady = false;
    notifyListeners();

    String baseUrl = "${EnvConfig.cdnBaseUrl}/assets/championships/";

    for (final ch in _championships) {
      late final String finalUrl;

      if (ch.logoUrl == null || ch.logoUrl!.isEmpty) {
        finalUrl = baseUrl + Championship.defaultLogoUrl;
      } else {
        finalUrl = baseUrl + ch.logoUrl!;
      }

      log("Preloading logo for ${ch.name}: $finalUrl");

      final img = NetworkImage(finalUrl);

      try {
        await precacheImage(img, context);
        _logos[ch.id] = img;
      } catch (e) {
        log("Error precaching ${ch.logoUrl}: $e");
      }
    }

    _logosReady = true;
    notifyListeners();
  }

  Future<void> createChampionship(Championship ch) async {
    if (_api == null) return;
    try {
      await _api!.createChampionship(ch);
      await loadChampionships();
    } catch (e) {
      _error = 'Error creating championship';
      notifyListeners();
    }
  }

  Future<void> updateChampionship(Championship ch) async {
    if (_api == null) return;
    try {
      await _api!.updateChampionship(ch);
      await loadChampionships();
    } catch (e) {
      _error = 'Error updating championship';
      notifyListeners();
    }
  }

  Future<void> deleteChampionship(String id) async {
    if (_api == null) return;
    try {
      await _api!.deleteChampionship(id);
      await loadChampionships();
    } catch (e) {
      _error = 'Error deleting championship';
      notifyListeners();
    }
  }
}