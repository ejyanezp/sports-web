import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sports/models/sport.dart';
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
}