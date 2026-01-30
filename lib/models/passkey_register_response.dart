class PasskeyRegisterResponse {
  final String challenge;
  final String mode;
  final String rpId;
  final String userId;
  final String userEmail;

  PasskeyRegisterResponse({
    required this.challenge,
    required this.mode,
    required this.rpId,
    required this.userId,
    required this.userEmail,
  });

  factory PasskeyRegisterResponse.fromJson(Map<String, dynamic> json) {
    return PasskeyRegisterResponse(
      challenge: json['challenge'],
      mode: json['mode'],
      rpId: json['rp_id'],
      userId: json['user_id'],
      userEmail: json['user_email'],
    );
  }
}