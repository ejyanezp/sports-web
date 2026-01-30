// Este modelo cubre tanto registro (attestation) como autenticación (assertion),
// aunque al principio solo uses registro.
class PasskeyVerifyRequest {
  final String mode; // "register" o "passkey_authentication"
  final String challenge;
  final String rpId;
  final String userId;
  final String userEmail;

  // Datos comunes de la credencial
  final String id;
  final String rawId;
  final String type;

  // Registro (attestation)
  final String? attestationObject;

  // Autenticación (assertion)
  final String? authenticatorData;
  final String? signature;
  final String? userHandle;

  final String clientDataJSON;

  PasskeyVerifyRequest({
    required this.mode,
    required this.challenge,
    required this.rpId,
    required this.userId,
    required this.userEmail,
    required this.id,
    required this.rawId,
    required this.type,
    required this.clientDataJSON,
    this.attestationObject,
    this.authenticatorData,
    this.signature,
    this.userHandle,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'challenge': challenge,
      'rp_id': rpId,
      'user_id': userId,
      'user_email': userEmail,
      'id': id,
      'raw_id': rawId,
      'type': type,
      'client_data_json': clientDataJSON,
      'attestation_object': attestationObject,
      'authenticator_data': authenticatorData,
      'signature': signature,
      'user_handle': userHandle,
    };
  }

  factory PasskeyVerifyRequest.fromJson(Map<String, dynamic> json) {
    return PasskeyVerifyRequest(
      mode: json['mode'],
      challenge: json['challenge'],
      rpId: json['rp_id'],
      userId: json['user_id'],
      userEmail: json['user_email'],
      id: json['id'],
      rawId: json['raw_id'],
      type: json['type'],
      clientDataJSON: json['client_data_json'],
      attestationObject: json['attestation_object'],
      authenticatorData: json['authenticator_data'],
      signature: json['signature'],
      userHandle: json['user_handle'],
    );
  }
}