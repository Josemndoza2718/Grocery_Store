/// Base class for all failures in the application.
/// 
/// All specific failure types extend this class to maintain consistency
/// across the application's error handling.
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Failure related to network/server issues.
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error de conexión con el servidor',
    super.code,
  });
}

/// Failure related to Firestore operations.
class FirestoreFailure extends Failure {
  const FirestoreFailure({
    required super.message,
    super.code,
  });

  factory FirestoreFailure.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const FirestoreFailure(
          message: 'No tienes permisos para realizar esta operación',
          code: 'permission-denied',
        );
      case 'not-found':
        return const FirestoreFailure(
          message: 'El documento solicitado no existe',
          code: 'not-found',
        );
      case 'already-exists':
        return const FirestoreFailure(
          message: 'El documento ya existe',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const FirestoreFailure(
          message: 'Se excedió el límite de recursos. Intenta más tarde',
          code: 'resource-exhausted',
        );
      case 'unavailable':
        return const FirestoreFailure(
          message: 'Servicio no disponible. Verifica tu conexión',
          code: 'unavailable',
        );
      case 'cancelled':
        return const FirestoreFailure(
          message: 'La operación fue cancelada',
          code: 'cancelled',
        );
      case 'deadline-exceeded':
        return const FirestoreFailure(
          message: 'La operación tardó demasiado. Intenta de nuevo',
          code: 'deadline-exceeded',
        );
      default:
        return FirestoreFailure(
          message: 'Error en la base de datos: $code',
          code: code,
        );
    }
  }
}

/// Failure related to Firebase Authentication.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'No existe un usuario con ese correo electrónico',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Contraseña incorrecta',
          code: 'wrong-password',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'El formato del correo electrónico es inválido',
          code: 'invalid-email',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'Ya existe una cuenta con ese correo electrónico',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'La contraseña es demasiado débil',
          code: 'weak-password',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'Esta cuenta ha sido deshabilitada',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Demasiados intentos. Intenta más tarde',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const AuthFailure(
          message: 'Error de red. Verifica tu conexión a internet',
          code: 'network-request-failed',
        );
      default:
        return AuthFailure(
          message: 'Error de autenticación: $code',
          code: code,
        );
    }
  }
}

/// Failure related to local cache/storage (Sembast).
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder al almacenamiento local',
    super.code,
  });
}

/// Failure for unexpected/unknown errors.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Ocurrió un error inesperado',
    super.code,
  });

  factory UnknownFailure.fromException(Object exception) {
    return UnknownFailure(
      message: 'Error inesperado: ${exception.toString()}',
    );
  }
}
