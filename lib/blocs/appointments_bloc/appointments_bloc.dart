import 'dart:async';

import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

/// Bloc Patter to get Appointments
class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  /// Bloc Patter to get Appointments
  AppointmentsBloc() : super(AppointmentsInitial()) {
    on<AppointmentsEvent>((event, emit) async {
      if (event is GetPastAppointmentsList) {
        emit(Loading());
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          bindToScope: true,
        );
        late Either<Failure, List<Appointment>> appointmentsOrError;
        await Task(
          () => _appointmentRepository.getPastAppointments(event.date)!,
        ).attempt().mapLeftToFailure().run().then((value) {
          appointmentsOrError = value;
        });
        if (appointmentsOrError.isLeft()) {
          final failure = appointmentsOrError.asLeft();
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
          late List<Appointment> appointments;
          appointments = appointmentsOrError.asRight();
          emit(AppointmentsLoadedState(appointments: appointments));
          unawaited(
            transaction.finish(
              status: const SpanStatus.ok(),
            ),
          );
        }
      } else if (event is GetPastAppointmentsBetweenDatesList) {
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          bindToScope: true,
        );
        emit(Loading());
        late Either<Failure, List<Appointment>> appointmentsOrError;
        await Task(
          () => _appointmentRepository.getPastAppointmentsBetweenDates(
            _initialDate,
            _finalDate,
          )!,
        ).attempt().mapLeftToFailure().run().then((value) {
          appointmentsOrError = value;
        });
        if (appointmentsOrError.isLeft()) {
          final failure = appointmentsOrError.asLeft();
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
          late List<Appointment> appointments;
          appointments = appointmentsOrError.asRight();

          // filter appointmentType
          appointments = appointments.where((element) {
            if (_filterVirtual && element.appointmentType == 'V') {
              return true;
            } else if (_filterInPerson && element.appointmentType == 'A') {
              return true;
            }
            return false;
          }).toList();
          emit(AppointmentsLoadedState(appointments: appointments));
          unawaited(
            transaction.finish(
              status: const SpanStatus.ok(),
            ),
          );
        }
      }
    });
  }
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  DateTime _initialDate = DateTime(
    DateTime.now().year - 1,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime? _finalDate = DateTime.now();

  // remote type
  bool _filterVirtual = true;

  // in person type
  bool _filterInPerson = true;

  /// return if is filter by virtual type
  bool getVirtualStatus() => _filterVirtual;

  /// return if is filter by inperson type
  bool getInPersonStatus() => _filterInPerson;

  /// return the initial date of filter
  DateTime getInitialDate() => _initialDate;

  /// return the final date of filter
  DateTime? getFinalDate() => _finalDate;

  ///
  void setInitialDate(DateTime initialDate) {
    _initialDate = initialDate;

    // FIXME: remove delayed and set setter and getter
    Future.delayed(Duration.zero, () {});
  }

  ///
  void setFinalDate(DateTime? finalDate) {
    _finalDate = finalDate;
    Future.delayed(Duration.zero, () {});
  }

  ///
  void setVirtualStatus({required bool virtualStatus}) {
    _filterVirtual = virtualStatus;
    Future.delayed(Duration.zero, () {});
  }

  ///
  void setInPersonStatus({required bool inPersonStatus}) {
    _filterInPerson = inPersonStatus;
    Future.delayed(Duration.zero, () {});
  }
}
