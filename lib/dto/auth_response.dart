class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String role;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
    );
  }
}