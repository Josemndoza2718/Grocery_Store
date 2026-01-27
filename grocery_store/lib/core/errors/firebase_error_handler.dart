import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/core/errors/result.dart';

/// Utility class to handle Firebase exceptions and convert them to [Failure] objects.
class FirebaseErrorHandler {
  /// Handles a Firestore [FirebaseException] and returns an appropriate [Failure].
  static Failure handleFirestoreException(FirebaseException exception) {
    return FirestoreFailure.fromCode(exception.code);
  }

  /// Handles a Firebase Auth exception and returns an appropriate [Failure].
  static Failure handleAuthException(FirebaseAuthException exception) {
    return AuthFailure.fromCode(exception.code);
  }

  /// Executes [operation] and wraps the result in a [Result].
  /// 
  /// Catches Firebase and general exceptions, converting them to appropriate [Failure] types.
  /// 
  /// Example:
  /// ```dart
  /// final result = await FirebaseErrorHandler.guard(() async {
  ///   await firestore.collection('carts').doc(id).set(data);
  /// });
  /// ```
  static Future<Result<T>> guard<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } on FirebaseAuthException catch (e) {
      return Error(handleAuthException(e));
    } on FirebaseException catch (e) {
      return Error(handleFirestoreException(e));
    } catch (e) {
      return Error(UnknownFailure.fromException(e));
    }
  }

  /// Executes [operation] synchronously and wraps the result in a [Result].
  static Result<T> guardSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Success(result);
    } on FirebaseAuthException catch (e) {
      return Error(handleAuthException(e));
    } on FirebaseException catch (e) {
      return Error(handleFirestoreException(e));
    } catch (e) {
      return Error(UnknownFailure.fromException(e));
    }
  }
}
