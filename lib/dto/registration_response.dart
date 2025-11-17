class RegistrationResponse {
  final String userId;
  final String role;

  RegistrationResponse({
    required this.userId,
    required this.role,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      userId: json['userId'] as String,
      role: json['role'] as String,
    );
  }
}