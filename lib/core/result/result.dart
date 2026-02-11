/// Functional Result type for error handling without exceptions.
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(String message, {String? code}) = Failure<T>;

  /// Map the success value.
  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success(value: final v) => Result.success(transform(v)),
      Failure(message: final m, code: final c) => Result.failure(m, code: c),
    };
  }

  /// FlatMap.
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return switch (this) {
      Success(value: final v) => transform(v),
      Failure(message: final m, code: final c) => Result.failure(m, code: c),
    };
  }

  /// Get value or default.
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => defaultValue,
    };
  }

  /// Get value or null.
  T? getOrNull() {
    return switch (this) {
      Success(value: final v) => v,
      Failure() => null,
    };
  }

  /// Execute side effects.
  Result<T> onSuccess(void Function(T) action) {
    if (this is Success<T>) action((this as Success<T>).value);
    return this;
  }

  Result<T> onFailure(void Function(String message, String? code) action) {
    if (this is Failure<T>) {
      final f = this as Failure<T>;
      action(f.message, f.code);
    }
    return this;
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}
