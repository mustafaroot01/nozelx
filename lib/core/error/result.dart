/// Result wrapper class for handling success and failure cases
/// Provides a clean way to handle operations that can either succeed or fail
class Result<T> {
  final T? _value;
  final String? _error;

  // Private constructor
  Result._(this._value, this._error);

  /// Creates a successful result with a value
  factory Result.success(T value) {
    return Result._(value, null);
  }

  /// Creates a failed result with an error message
  factory Result.failure(String error) {
    return Result._(null, error);
  }

  /// Returns true if this is a success
  bool get isSuccess => _error == null;

  /// Returns true if this is a failure
  bool get isFailure => _error != null;

  /// Returns the value if success, throws error if failure
  T get value {
    if (_value == null) {
      throw StateError('Cannot get value from a failure result: $_error');
    }
    return _value;
  }

  /// Returns the error message if failure, throws if success
  String get error {
    if (_error == null) {
      throw StateError('Cannot get error from a success result');
    }
    return _error;
  }

  /// Returns the value if success, or the provided default value if failure
  T getOrElse(T defaultValue) {
    return _value ?? defaultValue;
  }

  /// Returns the value if success, or null if failure
  T? getOrNull() {
    return _value;
  }

  /// Returns the error if failure, or null if success
  String? get errorOrNull => _error;

  /// Maps the success value to a new type
  Result<R> map<R>(R Function(T value) mapper) {
    if (isSuccess) {
      return Result.success(mapper(_value as T));
    } else {
      return Result.failure(_error as String);
    }
  }

  /// Maps the success value or returns the same error
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) {
    if (isSuccess) {
      return mapper(_value as T);
    } else {
      return Result.failure(_error as String);
    }
  }

  /// Executes the callback if this is a success
  Result<T> onSuccess(void Function(T value) callback) {
    if (isSuccess) {
      callback(_value as T);
    }
    return this;
  }

  /// Executes the callback if this is a failure
  Result<T> onFailure(void Function(String error) callback) {
    if (isFailure) {
      callback(_error as String);
    }
    return this;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Result<T>) {
      return _value == other._value && _error == other._error;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(_value, _error);

  @override
  String toString() {
    return isSuccess ? 'Result.success($_value)' : 'Result.failure($_error)';
  }
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Convert to a nullable type
  T? toNullable() => getOrNull();

  /// Get or throw custom exception
  T getOrThrow([String Function()? onError]) {
    if (isSuccess) return _value as T;
    throw Exception(onError?.call() ?? error);
  }
}
