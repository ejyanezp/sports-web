import 'package:flutter/foundation.dart';
import '../models/sport.dart';
import '../services/api_service.dart';

class SportsProvider extends ChangeNotifier {
  final ApiService api;

  SportsProvider({required this.api});

  List<Sport> _sports = [];
  bool _loading = false;
  String? _error;

  List<Sport> get sports => _sports;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadSports() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _sports = await api.getSports();
    }
    catch (e) {
      _error = 'Error loading sports';
    }
    finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addSport(Sport sport) async {
    try {
      final created = await api.createSport(sport);
      _sports.add(created);
      notifyListeners();
    }
    catch (e) {
      _error = 'Error creating sport';
      notifyListeners();
    }
  }

  Future<void> updateSport(Sport sport) async {
    try {
      final updated = await api.updateSport(sport);
      final index = _sports.indexWhere((s) => s.name == sport.name);
      if (index != -1) {
        _sports[index] = updated;
        notifyListeners();
      }
    }
    catch (e) {
      _error = 'Error updating sport';
      notifyListeners();
    }
  }

  Future<void> deleteSport(String name) async {
    try {
      await api.deleteSport(name);
      _sports.removeWhere((s) => s.name == name);
      notifyListeners();
    }
    catch (e) {
      _error = 'Error deleting sport';
      notifyListeners();
    }
  }
}