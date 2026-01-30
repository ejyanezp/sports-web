import 'package:flutter/foundation.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:convert';

import 'package:sports/services/api_service.dart';
import 'package:sports/models/passkey_register_response.dart';
import 'package:sports/models/passkey_verify_request.dart';
import 'package:sports/models/passkey_verify_response.dart';
import 'package:sports/utils/logs.dart';

enum PasskeyFlowState {
  idle,
  requestingChallenge,
  waitingForWebAuthn,
  verifying,
  completed,
  error,
}

@JS('passkeys.create')
external JSPromise createPasskeyJs(
    String userId,
    String userEmail,
    );

@JS('passkeys.sign')
external JSPromise signWithPasskeyJs(
    JSAny publicKeyOptions, // lo definiremos bien cuando armemos el flujo de login
    );

Future<Map<String, dynamic>> createPasskeyDart({required String userId, required String userEmail}) async {
  final jsResult = await createPasskeyJs(userId, userEmail).toDart;
  // jsResult es un String JSON
  final jsonString = jsResult as String;
  // Convertimos el String JSON a Map
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

// placeholder para más adelante, cuando definamos el flujo de sign
Future<Map<String, dynamic>> signWithPasskeyDart(JSAny publicKeyOptions) async {
  final jsResult = await signWithPasskeyJs(publicKeyOptions).toDart;
  return jsonDecode(jsonEncode(jsResult)) as Map<String, dynamic>;
}

class SmartAccountProvider extends ChangeNotifier {
  final ApiService api;

  SmartAccountProvider({required this.api});

  PasskeyFlowState _state = PasskeyFlowState.idle;
  PasskeyFlowState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _smartAccountAddress;
  String? get smartAccountAddress => _smartAccountAddress;

  // Datos temporales del challenge
  late PasskeyRegisterResponse _registerData;

  void _setState(PasskeyFlowState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _setState(PasskeyFlowState.error);
  }

  Future<void> startPasskeyRegistration({required String userId, required String userEmail}) async {
    try {
      _setState(PasskeyFlowState.requestingChallenge);
      _registerData = await api.passkeyRegister(userId, userEmail);
      _setState(PasskeyFlowState.waitingForWebAuthn);
    }
    catch (e) {
      log("startPasskeyRegistration exception: $e");
      _setError("No se pudo obtener el challenge");
    }
  }

  Future<Map<String, dynamic>> _executeWebAuthnCreate() async {
    try {
      final result = await createPasskeyDart(userId: _registerData.userId, userEmail: _registerData.userEmail);
      if (result.containsKey('error')) {
        throw Exception("WebAuthn error: ${result['error']}");
      }
      return result;
    }
    catch (e) {
      log("executeWebAuthn exception: $e");
      _setError("El usuario canceló o WebAuthn falló");
      rethrow;
    }
  }

  PasskeyVerifyRequest _buildVerifyRequest(Map<String, dynamic> webauthnJson) {
    return PasskeyVerifyRequest(
      mode: _registerData.mode,
      challenge: _registerData.challenge,
      rpId: _registerData.rpId,
      userId: _registerData.userId,
      userEmail: _registerData.userEmail,
      id: webauthnJson['id'],
      rawId: webauthnJson['rawId'],
      type: webauthnJson['type'],
      clientDataJSON: webauthnJson['clientDataJSON'],
      attestationObject: webauthnJson['attestationObject'],
      authenticatorData: webauthnJson['authenticatorData'],
      signature: webauthnJson['signature'],
      userHandle: webauthnJson['userHandle'],
    );
  }

  Future<void> verifyPasskey(Map<String, dynamic> webauthnJson) async {
    try {
      _setState(PasskeyFlowState.verifying);
      final request = _buildVerifyRequest(webauthnJson);
      final response = await api.verifyPasskey(request);
      _smartAccountAddress = response.smartAccountAddress;
      _setState(PasskeyFlowState.completed);
    }
    catch (e) {
      log("verifyPasskey exception: $e");
      _setError("No se pudo verificar la passkey");
    }
  }

  void _reset() {
    _errorMessage = null;
    _smartAccountAddress = null;
    _state = PasskeyFlowState.idle;
  }

  Future<void> createSmartAccount({required String userId, required String userEmail}) async {
    _reset();
    await startPasskeyRegistration(userId: userId, userEmail: userEmail);
    final webauthnJson = await _executeWebAuthnCreate();
    await verifyPasskey(webauthnJson);
  }
}
