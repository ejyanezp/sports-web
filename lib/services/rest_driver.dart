import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sports/models/sport.dart';
import 'package:sports/models/championship.dart';
import 'package:sports/models/passkey_verify_request.dart';
import 'package:sports/utils/logs.dart';

// Se debe pasar una función al token y no el valor del token, porque el mismo podría cambiar.
// Ejemplo: después de aplicar el refresh token.
typedef TokenProvider = Future<String?> Function();

class RestDriver {
  final String baseUrl;
  final http.Client client;
  final TokenProvider getToken;

  RestDriver({
    required this.baseUrl,
    required this.getToken,
    http.Client? client
  }) : client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    // log("Authorization: ${headers['Authorization']}");
    return headers;
  }

  // -------------------------
  // SPORTS
  // -------------------------
  Future<List<Sport>> getSports() async {
    log("RestDriver.getSports URL=$baseUrl");
    try {
      final resp = await client.get(_uri('/sports'), headers: await _headers());
      log("resp = ${resp.statusCode}");
      if (resp.statusCode != 200) {
        throw Exception('Error getting sports: ${resp.statusCode}');
      }

      final List<dynamic> data = json.decode(resp.body);
      return data.map((e) => Sport.fromJson(e as Map<String, dynamic>)).toList();
    }
    catch (e) {
      log("exception = ${e.toString()}");
    }
    finally {
      log("RestDriver.getSports finalizado");
    }
    return [];
  }

  Future<Sport> createSport(Sport sport) async {
    final resp = await client.post(
      _uri('/sports'),
      headers: await _headers(),
      body: json.encode(sport.toJson()),
    );

    if (resp.statusCode != 201) {
      throw Exception('Error creating sport: ${resp.statusCode}');
    }

    return Sport.fromJson(json.decode(resp.body));
  }

  Future<Sport> updateSport(Sport sport) async {
    final resp = await client.put(
      _uri('/sports/${sport.name}'),
      headers: await _headers(),
      body: json.encode(sport.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error updating sport: ${resp.statusCode}');
    }

    return Sport.fromJson(json.decode(resp.body));
  }

  Future<void> deleteSport(String name) async {
    final resp = await client.delete(
      _uri('/sports/$name'),
      headers: await _headers(),
    );

    if (resp.statusCode != 204) {
      throw Exception('Error deleting sport: ${resp.statusCode}');
    }
  }

  // -------------------------
  // ENTITLEMENTS
  // -------------------------
  Future<Map<String, List<String>>> getEntitlements() async {
    log("RestDriver.getEntitlements");
    try {
      final resp = await client.get(_uri('/entitlements'), headers: await _headers(),);
      log("getEntitlements resp = ${resp.statusCode}");
      if (resp.statusCode != 200) {
        throw Exception('Error getting entitlements: ${resp.statusCode}');
      }
      final Map<String, dynamic> data = json.decode(resp.body);
      // Convertimos dinámico → Map<String, List<String>>
      final entitlements = data.map((key, value) => MapEntry(key, List<String>.from(value),),);
      return entitlements;
    }
    catch (e) {
      log("exception = ${e.toString()}");
    }
    finally {
      log("RestDriver.getEntitlements finalizado");
    }
    return {};
  }
  // -------------------------
  // CHAMPIONSHIPS
  // -------------------------
  Future<List<Championship>> getChampionships() async {
    log("RestDriver.getChampionships");
    try {
      final resp = await client.get(_uri('/championships'), headers: await _headers());
      log("resp = ${resp.statusCode}");
      if (resp.statusCode != 200) {
        throw Exception('Error getting championships: ${resp.statusCode}');
      }

      final List<dynamic> data = json.decode(resp.body);
      return data.map((e) => Championship.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      log("exception = ${e.toString()}");
    } finally {
      log("RestDriver.getChampionships finalizado");
    }
    return [];
  }

  Future<List<Championship>> getChampionshipsBySport(String sportName) async {
    log("RestDriver.getChampionshipsBySport sport=$sportName");
    try {
      final resp = await client.get(
        _uri('/sports/$sportName/championships'),
        headers: await _headers(),
      );
      log("resp = ${resp.statusCode}");
      if (resp.statusCode != 200) {
        throw Exception('Error getting championships by sport: ${resp.statusCode}');
      }

      final List<dynamic> data = json.decode(resp.body);
      return data.map((e) => Championship.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      log("exception = ${e.toString()}");
    } finally {
      log("RestDriver.getChampionshipsBySport finalizado");
    }
    return [];
  }

  Future<Championship> createChampionship(Championship ch) async {
    // IMPORTANT: backend generates ID → do NOT send id
    final body = {
      'name': ch.name,
      'sport': ch.sport,
      'scope': ch.scope,
      'logoUrl': ch.logoUrl,
    };

    final resp = await client.post(
      _uri('/championships'),
      headers: await _headers(),
      body: json.encode(body),
    );

    if (resp.statusCode != 201) {
      throw Exception('Error creating championship: ${resp.statusCode}');
    }

    return Championship.fromJson(json.decode(resp.body));
  }

  Future<Championship> updateChampionship(Championship ch) async {
    final resp = await client.put(
      _uri('/championships/${ch.id}'),
      headers: await _headers(),
      body: json.encode(ch.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error updating championship: ${resp.statusCode}');
    }

    return Championship.fromJson(json.decode(resp.body));
  }

  Future<void> deleteChampionship(String id) async {
    final resp = await client.delete(
      _uri('/championships/$id'),
      headers: await _headers(),
    );

    if (resp.statusCode != 204) {
      throw Exception('Error deleting championship: ${resp.statusCode}');
    }
  }

  // Smart account management
  // 1) Register passkey
  Future<Map<String, dynamic>> postPasskeyRegister({required String userId, required String userEmail}) async {
    log("RestDriver.postPasskeyRegister userId=$userId");
    try {
      final resp = await client.post(_uri('/webauthn/passkey/register'),
        headers: await _headers(),
        body: json.encode({
          'user_id': userId,
          'user_email': userEmail,
        }),
      );
      log("postPasskeyRegister resp = ${resp.statusCode}");
      if (resp.statusCode != 200) {
        throw Exception('Error in /webauthn/passkey/register: ${resp.statusCode}');
      }
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    catch (e) {
      log("exception = ${e.toString()}");
    }
    finally {
      log("RestDriver.postPasskeyRegister finalizado");
    }
    return {};
  }

  Future<Map<String, dynamic>> postPasskeyVerify(PasskeyVerifyRequest request) async {
    log("RestDriver.postPasskeyVerify mode=${request.mode} userId=${request.userId}");
    log("** postPasskeyVerify challenge: ${request.challenge}");
    try {
      final resp = await client.post(
        _uri('/webauthn/passkey/verify'),
        headers: await _headers(),
        body: json.encode(request.toJson()),
      );
      log("postPasskeyVerify resp = ${resp.statusCode}");
      if (resp.statusCode != 200) {
        throw Exception('Error in /webauthn/passkey/verify: ${resp.statusCode}');
      }
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    catch (e) {
      log("exception = ${e.toString()}");
    }
    finally {
      log("RestDriver.postPasskeyVerify finalizado");
    }
    return {};
  }
}