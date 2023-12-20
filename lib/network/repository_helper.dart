import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../constants.dart';

class Failure extends Error {
  final String message;
  final Response? response;

  Failure(this.message, {this.response});

  @override
  String toString() => message;
}

extension TaskX<U> on Task<Either<Object, U>> {
  Task<Either<Failure, U>> mapLeftToFailure() {
    return map(
          (either) => either.leftMap((obj) {
        try {
          return obj as Failure;
        } catch (e) {
          return Failure(genericError);
        }
      }),
    );
  }
}