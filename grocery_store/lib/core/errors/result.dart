import 'package:grocery_store/core/errors/failure.dart';

/// A sealed class representing the result of an operation.
/// 
/// This implements the Either/Result pattern for functional error handling.
/// Use [Success] for successful operations and [Error] for failures.
sealed class Result<T> {
  const Result();

  /// Returns true if this is a successful result.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is an error result.
  bool get isError => this is Error<T>;

  /// Pattern matches on this result.
  /// 
  /// Example:
  /// ```dart
  /// result.fold(
  ///   onSuccess: (data) => print('Got: $data'),
  ///   onError: (failure) => print('Error: ${failure.message}'),
  /// );
  /// ```
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onError(failure),
    };
  }

  /// Returns the success value or [defaultValue] if this is an error.
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(:final data) => data,
      Error<T>() => defaultValue,
    };
  }

  /// Returns the success value or null if this is an error.
  T? getOrNull() {
    return switch (this) {
      Success<T>(:final data) => data,
      Error<T>() => null,
    };
  }

  /// Transforms the success value using [transform].
  /// If this is an error, returns the same error.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Success(transform(data)),
      Error<T>(:final failure) => Error(failure),
    };
  }

  /// Chains another Result-returning operation.
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => transform(data),
      Error<T>(:final failure) => Error(failure),
    };
  }
}

/// Represents a successful result containing [data].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result containing a [failure].
final class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  String toString() => 'Error(${failure.message})';
}
