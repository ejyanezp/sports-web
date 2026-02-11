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
    String challenge, // challenge comming from the registration
    String rpId       // rpId coming from the registration
    );

@JS('passkeys.sign')
external JSPromise signWithPasskeyJs(
    JSAny publicKeyOptions, // lo definiremos bien cuando armemos el flujo de login
    );

Future<Map<String, dynamic>> createPasskeyDart({
  required String userId,
  required String userEmail,
  required String challenge,
  required String rpId}) async {
  final jsResult = await createPasskeyJs(userId, userEmail, challenge, rpId).toDart;
  log(">> createPasskeyDart: $jsResult");
  return jsonDecode(jsResult.dartify() as String);
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
  late PasskeyVerifyResponse _verifyResponse;

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
      log("** startPasskeyRegistration challenge: ${_registerData.challenge}");
      _setState(PasskeyFlowState.waitingForWebAuthn);
    }
    catch (e) {
      log("startPasskeyRegistration exception: $e");
      _setError("No se pudo obtener el challenge");
    }
  }

  Future<Map<String, dynamic>> _executeWebAuthnCreate() async {
    log("** _executeWebAuthnCreate challenge: ${_registerData.challenge}");
    try {
      final result = await createPasskeyDart(
          userId: _registerData.userId,
          userEmail: _registerData.userEmail,
          challenge: _registerData.challenge,
          rpId: _registerData.rpId
      );
      log("executeWebAuthnCreate result: $result");
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
    log("buildVerifyRequest webauthnJson: $webauthnJson");
    log("** _buildVerifyRequest challenge: ${_registerData.challenge}");
    final response = webauthnJson["response"] as Map<String, dynamic>;
    return PasskeyVerifyRequest(
      mode: _registerData.mode,
      challenge: _registerData.challenge,
      rpId: _registerData.rpId,
      userId: _registerData.userId,
      userEmail: _registerData.userEmail,
      credential: {
        // identificador de la passkey en Base64URL encoding
        "id": webauthnJson["id"],
        // identificador binario de la passkey
        "rawId": webauthnJson["rawId"],
        // Siempre vale "public-key"
        "type": webauthnJson["type"],
        "response": {
          "clientDataJSON": response["clientDataJSON"],
          "attestationObject": response["attestationObject"],
          "authenticatorData": response["authenticatorData"],
          "signature": response["signature"],
          "userHandle": response["userHandle"],
        }
      },
    );
  }

  Future<void> verifyPasskey(Map<String, dynamic> webauthnJson) async {
    try {
      _setState(PasskeyFlowState.verifying);
      log("verifyPasskey webauthnJson: $webauthnJson");
      final request = _buildVerifyRequest(webauthnJson);
      log("** verifyPasskey request challenge: ${request.challenge}");
      _verifyResponse = await api.verifyPasskey(request);
      log("verifyPasskey response: $_verifyResponse");
      _smartAccountAddress = _verifyResponse.smartAccountAddress;
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
