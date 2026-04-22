import 'package:tarasense_mobile/features/auth/domain/auth_models.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.isBusy = false,
    this.errorMessage,
  });

  factory AuthState.initializing() {
    return const AuthState(status: AuthStatus.initializing);
  }

  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.authenticated(AuthSession session) {
    return AuthState(
      status: AuthStatus.authenticated,
      session: session,
    );
  }

  final AuthStatus status;
  final AuthSession? session;
  final bool isBusy;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool clearSession = false,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

