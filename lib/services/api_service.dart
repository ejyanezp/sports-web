import 'package:sports/models/sport.dart';
import 'rest_driver.dart';

class ApiService {
  final RestDriver rest;

  ApiService({required this.rest});

  Future<List<Sport>> getSports() => rest.getSports();
  Future<Sport> createSport(Sport sport) => rest.createSport(sport);
  Future<Sport> updateSport(Sport sport) => rest.updateSport(sport);
  Future<void> deleteSport(String name) => rest.deleteSport(name);

// Luego agregas aquí championships, teams, etc.
}