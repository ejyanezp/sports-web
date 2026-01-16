import 'package:sports/models/sport.dart';
import 'rest_driver.dart';
import 'package:sports/utils/logs.dart';

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
}