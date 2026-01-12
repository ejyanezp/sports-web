import 'package:flutter/foundation.dart';
import 'package:sports/models/sport.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/utils/logs.dart';

class SportsProvider extends ChangeNotifier {
  ApiService? _api;

  SportsProvider({required ApiService? api}) : _api = api;

  bool _loading = false;
  String? _error;
  List<Sport> _sports = [];

  ApiService? get api => _api;
  bool get loading => _loading;
  String? get error => _error;
  List<Sport> get sports => List.unmodifiable(_sports);

  void setApi(ApiService? api) {
    _api = api;
  }

  Future<void> loadSports() async {
    if (_api == null) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      log("SportsProvider.loadSports $api");
      _sports = await _api!.getSports();
    } catch (e) {
      _error = 'Error loading sports';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createSport(Sport sport) async {
    if (_api == null) return;
    try {
      await _api!.createSport(sport);
      await loadSports();
    } catch (e) {
      _error = 'Error creating sport';
      notifyListeners();
    }
  }

  Future<void> updateSport(Sport sport) async {
    if (_api == null) return;
    try {
      await _api!.updateSport(sport);
      await loadSports();
    } catch (e) {
      _error = 'Error updating sport';
      notifyListeners();
    }
  }

  Future<void> deleteSport(String name) async {
    if (_api == null) return;
    try {
      await _api!.deleteSport(name);
      await loadSports();
    } catch (e) {
      _error = 'Error deleting sport';
      notifyListeners();
    }
  }
}