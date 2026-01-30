class PasskeyVerifyResponse {
  final String credentialId;
  final String publicKey;
  final int signCount;
  final String smartAccountAddress;
  final String? status;
  final String? message;

  PasskeyVerifyResponse({
    required this.credentialId,
    required this.publicKey,
    required this.signCount,
    required this.smartAccountAddress,
    this.status,
    this.message,
  });

  factory PasskeyVerifyResponse.fromJson(Map<String, dynamic> json) {
    return PasskeyVerifyResponse(
      credentialId: json['credential_id'],
      publicKey: json['public_key'],
      signCount: json['sign_count'],
      smartAccountAddress: json['smart_account_address'],
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'credential_id': credentialId,
      'public_key': publicKey,
      'sign_count': signCount,
      'smart_account_address': smartAccountAddress,
      'status': status,
      'message': message,
    };
  }
}