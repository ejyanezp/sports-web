import 'package:flutter/foundation.dart';

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;

import 'package:sports/config/env_config.dart';
import 'package:sports/utils/app_metadata.dart';

class AuthProvider extends ChangeNotifier {
  String? _userEmail;
  bool _isProcessing = false;
  String? _errorMessage;

  // Clave para el almacenamiento
  final String _storageKey = 'sports_id_token';

  final String clientId = EnvConfig.clientId;
  final String cognitoDomain = EnvConfig.cognitoDomain;
  final String redirectUri = EnvConfig.redirectUri;

  // Getters para que los widgets lean el estado
  String? get userEmail => _userEmail;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadPersistedToken();
  }

  void _loadPersistedToken() {
    log("Buscando token en sessionStorage...");
    final savedToken = web.window.sessionStorage.getItem(_storageKey);

    if (savedToken != null) {
      _userEmail = _decodeEmailFromToken(savedToken);
      if (_userEmail != null) {
        log("✅ Usuario recuperado con éxito: $_userEmail");
      }
      else {
        log("⚠️ Token encontrado pero corrupto o inválido.");
        web.window.sessionStorage.removeItem(_storageKey);
      }
    }
    else {
      log("ℹ️ No hay sesión previa. Usuario anónimo.");
    }
    // No llamamos a notifyListeners aquí porque el constructor
    // se ejecuta antes de que los widgets escuchen.
  }

  // Extraemos la lógica de decodificación para reusarla
  String? _decodeEmailFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return json.decode(payload)['email'];
    } catch (e) {
      return null;
    }
  }

  // Métodos para cambiar el estado
  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners(); // Esto avisa a todos los widgets que deben redibujarse
  }

  void setUser(String? email) {
    _userEmail = email;
    _isProcessing = false;
    notifyListeners();
  }

  void launchLogin() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    final verifier = base64UrlEncode(values).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');

    web.window.sessionStorage.setItem('pkce_verifier', verifier);

    final challenge = base64UrlEncode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');

    final authUrl = Uri.https(cognitoDomain, '/oauth2/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'scope': 'email openid phone',
      'redirect_uri': redirectUri,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    });

    // Usamos replace para que Cognito no sea un "punto de retorno" (protegernos del botón Atrás del browser)
    // web.window.location.href = authUrl.toString();   <-- Si usamos href cognito es un punto de retorno
    web.window.location.replace(authUrl.toString());
    web.document.title = "Sports App";
  }

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
        final idToken = data['id_token'] as String;
        // PERSISTENCIA: Guardamos el token crudo
        web.window.sessionStorage.setItem(_storageKey, idToken);
        _userEmail = _decodeEmailFromToken(idToken);
      }
      else {
        log("Error en Cognito: ${response.body}");
        // Capturamos el error específico de Cognito (ej: "invalid_grant")
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? "Error desconocido en el servidor";
      }
    }
    catch (e) {
      _errorMessage = "Error de conexión. Revisa tu internet.";
      log(_errorMessage!);
    }
    finally {
      setProcessing(false);
    }
  }

  void logout() {
    // 1. Limpiamos los datos locales primero
    _userEmail = null;
    _isProcessing = false;
    _errorMessage = null;
    // LIMPIEZA: Borramos el token persistido
    web.window.sessionStorage.removeItem(_storageKey);
    // 2. Limpiamos el verifier de la sesión para seguridad
    web.window.sessionStorage.removeItem('pkce_verifier');
    // 3. Notificamos a los widgets (esto mostrará el reloj de arena brevemente)
    notifyListeners();
    // 4. REDIRECCIÓN AL SERVIDOR DE COGNITO
    // Usamos el endpoint /logout oficial de AWS
    final logoutUrl = Uri.https(cognitoDomain, '/logout', {
      'client_id': clientId,
      'logout_uri': redirectUri, // DEBE estar en la lista de 'Allowed logout URLs' en la consola de AWS
    });
    // 5. El navegador viaja a AWS, AWS cierra sesión y nos devuelve a la App
    // Do not use href, do not feed the browsers history in an SPA app.
    // web.window.location.href = logoutUrl.toString();
    web.window.location.replace(logoutUrl.toString());
    web.document.title = "Sports App";
  }
}