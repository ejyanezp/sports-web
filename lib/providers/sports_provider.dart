import 'package:flutter/foundation.dart';
import 'package:sports/models/sport.dart';
import 'package:sports/services/api_service.dart';
import 'package:sports/utils/logs.dart';

class SportsProvider extends ChangeNotifier {
  final ApiService api;

  SportsProvider({required this.api});

  bool _loading = false;
  String? _error;
  List<Sport> _sports = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Sport> get sports => List.unmodifiable(_sports);

  Future<void> loadSports() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      log("SportsProvider.loadSports $api");
      _sports = await api.getSports();
    } catch (e) {
      _error = 'Error loading sports';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createSport(Sport sport) async {
    try {
      await api.createSport(sport);
      await loadSports();
    } catch (e) {
      _error = 'Error creating sport';
      notifyListeners();
    }
  }

  Future<void> updateSport(Sport sport) async {
    try {
      await api.updateSport(sport);
      await loadSports();
    } catch (e) {
      _error = 'Error updating sport';
      notifyListeners();
    }
  }

  Future<void> deleteSport(String name) async {
    try {
      await api.deleteSport(name);
      await loadSports();
    } catch (e) {
      _error = 'Error deleting sport';
      notifyListeners();
    }
  }
}