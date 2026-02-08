// Este modelo cubre tanto registro (attestation) como autenticación (assertion),
// aunque al principio solo uses registro.
class PasskeyVerifyRequest {
  final String mode;
  final String challenge;
  final String rpId;
  final String userId;
  final String userEmail;

  // The entire WebAuthn credential object
  final Map<String, dynamic> credential;

  PasskeyVerifyRequest({
    required this.mode,
    required this.challenge,
    required this.rpId,
    required this.userId,
    required this.userEmail,
    required this.credential,
  });

  Map<String, dynamic> toJson() {
    return {
      "mode": mode,
      "challenge": challenge,
      "rp_id": rpId,
      "user_id": userId,
      "user_email": userEmail,
      "credential": credential,
    };
  }

  factory PasskeyVerifyRequest.fromJson(Map<String, dynamic> json) {
    return PasskeyVerifyRequest(
      mode: json["mode"],
      challenge: json["challenge"],
      rpId: json["rp_id"],
      userId: json["user_id"],
      userEmail: json["user_email"],
      credential: json["credential"],
    );
  }
}