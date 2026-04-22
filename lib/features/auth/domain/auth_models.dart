class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.organization,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final String? organization;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      organization: json['organization']?.toString(),
    );
  }
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      tokenType: (json['tokenType'] ?? 'Bearer').toString(),
    );
  }

  Map<String, String> toJson() {
    return <String, String>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
    };
  }
}

class AuthSession {
  const AuthSession({required this.user, required this.tokens});

  final UserProfile user;
  final AuthTokens tokens;

  factory AuthSession.fromAuthResponse(Map<String, dynamic> json) {
    final rawUser = json['user'];
    if (rawUser is! Map) {
      throw const FormatException(
        'Login failed: invalid response format (missing user).',
      );
    }

    final userMap = Map<String, dynamic>.from(rawUser);
    final user = UserProfile.fromJson(userMap);
    final tokens = AuthTokens.fromJson(json);

    if (user.id.trim().isEmpty || user.email.trim().isEmpty) {
      throw const FormatException(
        'Login failed: user profile data is incomplete.',
      );
    }
    if (tokens.accessToken.trim().isEmpty ||
        tokens.refreshToken.trim().isEmpty) {
      throw const FormatException(
        'Login failed: token data is missing from server response.',
      );
    }

    return AuthSession(user: user, tokens: tokens);
  }
}
