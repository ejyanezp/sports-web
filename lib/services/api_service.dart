import 'package:sports/models/sport.dart';
import 'rest_driver.dart';
import 'package:sports/utils/logs.dart';
import 'package:sports/models/championship.dart';

class ApiService {
  static ApiService? instance;
  final RestDriver rest;

  ApiService({required this.rest}) {
    instance = this;
  }

  Future<List<Sport>> getSports() {
    log("ApiService.getSports $rest");
    return rest.getSports();
  }
  Future<Sport> createSport(Sport sport) {
    return rest.createSport(sport);
  }
  Future<Sport> updateSport(Sport sport) {
    return rest.updateSport(sport);
  }
  Future<void> deleteSport(String name) {
    return rest.deleteSport(name);
  }

  Future<Map<String, bool>> getEntitlements() {
    log("ApiService.getEntitlements");
    return rest.getEntitlements();
  }

  // CHAMPIONSHIPS
  Future<List<Championship>> getChampionships() {
    log("ApiService.getChampionships");
    return rest.getChampionships();
  }

  Future<List<Championship>> getChampionshipsBySport(String sportName) {
    log("ApiService.getChampionshipsBySport $sportName");
    return rest.getChampionshipsBySport(sportName);
  }

  Future<Championship> createChampionship(Championship ch) {
    return rest.createChampionship(ch);
  }

  Future<Championship> updateChampionship(Championship ch) {
    return rest.updateChampionship(ch);
  }

  Future<void> deleteChampionship(String id) {
    return rest.deleteChampionship(id);
  }

}