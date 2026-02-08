import 'package:sports/models/sport.dart';
import 'package:sports/models/championship.dart';
import 'package:sports/models/passkey_register_response.dart';
import 'package:sports/models/passkey_verify_request.dart';
import 'package:sports/models/passkey_verify_response.dart';
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

  Future<Map<String, List<String>>> getEntitlements() {
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

  // Smart Accounts
  Future<PasskeyRegisterResponse> passkeyRegister(String userId, String userEmail) async {
    try {
      // Llamada al RestDriver
      final json = await rest.postPasskeyRegister(userId: userId, userEmail: userEmail);
      // Conversión a modelo tipado
      return PasskeyRegisterResponse.fromJson(json);
    }
    catch (e) {
      // Puedes mejorar este log según tu estilo
      log("ApiService.passkeyRegister exception: ${e.toString()}");
      rethrow; // Deja que el provider decida cómo manejarlo
    }
  }

  Future<PasskeyVerifyResponse> verifyPasskey(PasskeyVerifyRequest request) async {
    try {
      final json = await rest.postPasskeyVerify(request);
      log("### postPasskeyVerify = $json");
      return PasskeyVerifyResponse.fromJson(json);
    }
    catch (e) {
      log("ApiService.verifyPasskey exception: ${e.toString()}");
      rethrow;
    }
  }
}