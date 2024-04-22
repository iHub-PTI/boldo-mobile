import 'dart:async';

import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

/// Bloc Pattern to get [Appointment] from encounter id
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  /// Bloc Pattern constructor to get [Appointment] from encounter id
  AppointmentBloc() : super(AppointmentInitial()) {
    on<GetAppointmentByEcounterId>(_getAppointmentByEcounterId);
  }

  /// list of Pair of [AppointmentStatus] transition valid for [Appointment]
  static List<MapEntry<AppointmentStatus, AppointmentStatus>>
      statusChangeValidatorList = [
    const MapEntry(AppointmentStatus.Upcoming, AppointmentStatus.Upcoming),
    const MapEntry(AppointmentStatus.Upcoming, AppointmentStatus.Open),
    const MapEntry(AppointmentStatus.Upcoming, AppointmentStatus.Cancelled),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Open),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Cancelled),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Closed),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Locked),
    const MapEntry(AppointmentStatus.Closed, AppointmentStatus.Locked),
    const MapEntry(AppointmentStatus.Closed, AppointmentStatus.Open),
    const MapEntry(AppointmentStatus.Closed, AppointmentStatus.Closed),
    const MapEntry(AppointmentStatus.Locked, AppointmentStatus.Locked),
    const MapEntry(AppointmentStatus.Cancelled, AppointmentStatus.Cancelled),
  ];

  Future<void> _getAppointmentByEcounterId(
    GetAppointmentByEcounterId event,
    Emitter<AppointmentState> emit,
  ) async {
    final transaction = Sentry.startTransaction(
      event.runtimeType.toString(),
      'GET',
      description: 'To redirect to Appointment detail, ',
      bindToScope: true,
    );
    emit(Loading());
    late Either<Failure, Appointment> appointmentOrError;
    await Task(
      () => AppointmentRepository.getAppointmentByEncounterId(
        encounterId: event.encounterId,
      )!,
    ).attempt().mapLeftToFailure().run().then((value) {
      appointmentOrError = value;
    });
    if (appointmentOrError.isLeft()) {
      final failure = appointmentOrError.asLeft();
      emit(Failed(response: failure.message));
      transaction.throwable = failure;
      unawaited(
        transaction.finish(
          status: SpanStatus.fromString(
            failure.message,
          ),
        ),
      );
    } else {
      late Appointment appointment;
      appointment = appointmentOrError.asRight();

      unawaited(
        transaction.finish(
          status: const SpanStatus.ok(),
        ),
      );
      emit(AppointmentLoadedState(appointment: appointment));
    }
  }

  /// Validate if the [actualState] can change to [newState] and will
  ///  return the [newState], if can't change this will
  /// throw the [InvalidAppointmentStatusChange] Exception
  ///
  /// The list of valid states change will be compared
  /// with [statusChangeValidatorList]
  static AppointmentStatus? validChangeStatus({
    AppointmentStatus? actualState,
    AppointmentStatus? newState,
  }) {
    if (statusChangeValidatorList.any(
      (element) => element.key == actualState && element.value == newState,
    )) {
      return newState;
    }
    throw InvalidAppointmentStatusChange(
      'Invalid status from $actualState to $newState',
    );
  }
}

/// Exception class that represent an error on [AppointmentStatus] transition
/// not is valid
class InvalidAppointmentStatusChange implements Exception {
  /// Exception class that represent an error on [AppointmentStatus] transition
  /// not is valid
  const InvalidAppointmentStatusChange([
    this.message = 'Invalid status change',
  ]);

  /// Message of the exception
  final String message;

  @override
  String toString() {
    return message;
  }
}
