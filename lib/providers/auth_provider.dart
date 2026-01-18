import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;

import 'package:sports/config/env_config.dart';
import 'package:sports/utils/logs.dart';

class AuthProvider extends ChangeNotifier {
  // Estado interno
  Map<String, dynamic> _tokens = {};

  String? _userEmail;
  bool _isProcessing = false;
  String? _errorMessage;

  // Clave única para todo el objeto
  final String _storageKey = 'auth_tokens';

  // Configuración Cognito
  final String clientId = EnvConfig.clientId;
  final String cognitoDomain = EnvConfig.cognitoDomain;
  final String redirectUri = EnvConfig.redirectUri;

  // ------------------------------------------------------------
  // Getters públicos
  // ------------------------------------------------------------
  String? get idToken => _tokens["id_token"];
  String? get accessToken => _tokens["access_token"];
  String? get refreshToken => _tokens["refresh_token"];
  int? get expiresIn => _tokens["expires_in"];
  int? get issuedAt => _tokens["issued_at"];

  String? get userEmail => _userEmail;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  String get groupName {
    final raw = _tokens["cognito:groups"];

    if (raw == null) return "";

    // Caso 1: ya es lista
    if (raw is List) {
      return raw.isNotEmpty ? raw.first : "";
    }

    // Caso 2: es string tipo "[admin]"
    if (raw is String) {
      final clean = raw.replaceAll("[", "").replaceAll("]", "").trim();
      final parts = clean.split(",");
      return parts.isNotEmpty ? parts.first.trim() : "";
    }

    return "";
  }

  AuthProvider() {
    _loadPersistedTokens();
  }

  // ------------------------------------------------------------
  // Cargar sesión desde sessionStorage
  // ------------------------------------------------------------
  void _loadPersistedTokens() {
    log("Buscando auth_tokens en sessionStorage...");

    final raw = web.window.sessionStorage.getItem(_storageKey);
    if (raw == null) {
      log("ℹ️ No hay sesión previa.");
      return;
    }

    _tokens = jsonDecode(raw);

    if (idToken == null) {
      log("⚠️ auth_tokens encontrado pero sin id_token. Limpiando...");
      logout();
      return;
    }

    final payload = _decodePayload(idToken!);
    _userEmail = payload?["email"];

    if (_userEmail == null) {
      log("⚠️ id_token corrupto o inválido. Limpiando...");
      logout();
      return;
    }

    if (isExpired()) {
      log("⚠️ Token expirado al iniciar. Cerrando sesión.");
      logout();
      return;
    }

    log("✅ Sesión restaurada: $_userEmail");
  }

  // ------------------------------------------------------------
  // Decodificar JWT
  // ------------------------------------------------------------
  Map<String, dynamic>? _decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );

      return json.decode(payload);
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // Validar expiración usando issued_at + expires_in
  // ------------------------------------------------------------
  bool isExpired() {
    log("⚠️ Verificando si el token expiró...");
    if (expiresIn == null || issuedAt == null) {
      log("Token no adquirido aun!");
      return true;
    }
    log("Token obtenido!");
    final expiresAtMs = (issuedAt! + expiresIn!) * 1000;
    final now = DateTime.now().millisecondsSinceEpoch;
    bool expired = now >= expiresAtMs;
    if (expired) {
      log("Token expirado!");
    }
    else {
      log("Token vigente!");
    }
    return expired;
  }

  // ------------------------------------------------------------
  // Login con PKCE
  // ------------------------------------------------------------
  void launchLogin() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    final verifier = base64UrlEncode(values)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');

    web.window.sessionStorage.setItem('pkce_verifier', verifier);

    final challenge = base64UrlEncode(
      sha256.convert(utf8.encode(verifier)).bytes,
    ).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');

    final authUrl = Uri.https(cognitoDomain, '/oauth2/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'scope': 'openid email'
          ' urn:challengers:api/sports.read'
          ' urn:challengers:api/sports.write'
          ' urn:challengers:api/championships.read'
          ' urn:challengers:api/championships.write',
      'redirect_uri': redirectUri,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    });

    setProcessing(true);
    web.window.location.replace(authUrl.toString());
    web.document.title = "Challengers App";
  }

  // ------------------------------------------------------------
  // Intercambiar code por tokens
  // ------------------------------------------------------------
  Future<void> exchangeCodeForTokens(String code) async {
    _errorMessage = null;

    final verifier = web.window.sessionStorage.getItem('pkce_verifier');
    if (verifier == null) {
      setProcessing(false);
      return;
    }

    try {
      final response = await http.post(
        Uri.https(cognitoDomain, '/oauth2/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'code': code,
          'redirect_uri': redirectUri,
          'code_verifier': verifier,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Guardamos TODO el objeto
        data["issued_at"] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        _tokens = data;

        web.window.sessionStorage.setItem(_storageKey, jsonEncode(_tokens));
        log("Access token ${_tokens["access_token"]}");

        final payload = _decodePayload(idToken!);
        log("Payload = $payload");
        _userEmail = payload?["email"];

        log("✅ Sesión iniciada: $_userEmail");

        notifyListeners();
      }
      else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? "Error desconocido";
      }
    }
    catch (e) {
      _errorMessage = "Error de conexión.";
    }
     finally {
      setProcessing(false);
    }
  }

  Future<bool> refreshTokens() async {
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.https(cognitoDomain, '/oauth2/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'refresh_token': refreshToken!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cognito NO devuelve refresh_token en este flujo
        data["refresh_token"] = refreshToken;

        data["issued_at"] = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        _tokens = data;
        web.window.sessionStorage.setItem(_storageKey, jsonEncode(_tokens));

        notifyListeners();
        return true;
      }
    }
    catch (_) {}

    return false;
  }

  Future<String?> ensureValidAccessToken() async {
    if (!isExpired()) return accessToken;

    final ok = await refreshTokens();
    if (ok) return accessToken;

    logout();
    return null;
  }

  // ------------------------------------------------------------
  // Logout
  // ------------------------------------------------------------
  void logout() {
    _tokens = {};
    _userEmail = null;
    _isProcessing = false;
    _errorMessage = null;

    web.window.sessionStorage.removeItem(_storageKey);
    web.window.sessionStorage.removeItem('pkce_verifier');

    notifyListeners();

    if (kIsWeb) {
      web.window.history.replaceState(null, '', '/login');
      web.document.title = "Challengers App";
    }

    final logoutUrl = Uri.https(cognitoDomain, '/logout', {
      'client_id': clientId,
      'logout_uri': redirectUri,
    });

    Future.microtask(() {
      web.window.location.replace(logoutUrl.toString());
    });
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------
  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }
}