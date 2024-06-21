import 'dart:async';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'doctors_result_event.dart';
part 'doctors_result_state.dart';

/// Bloc to manage result of doctors search
class DoctorsResultBloc extends Bloc<DoctorsResultEvent, DoctorsResultState> {
  /// Constructor
  DoctorsResultBloc() : super(DoctorsResultInitial()) {
    on<SetInitialDoctors>(_setInitialDoctors);
    on<DoctorsResultEvent>((event, emit) async {
      if (event is GetMoreDoctorsResult) {
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get another page of doctors available',
          bindToScope: true,
        );
        final doctorsOrError = await Task(
          () => _doctorRepository.getDoctorsFilter(
            event.offset,
            event.specializations,
            event.virtualAppointment,
            event.inPersonAppointment,
            event.organizations,
            event.names,
          ),
        ).attempt().mapLeftToFailure().run();
        if (doctorsOrError.isLeft()) {
          final error = doctorsOrError.asLeft();
          emit(FailedResult(response: error.message));
          transaction.throwable = error;
          unawaited(
            transaction.finish(
              status: SpanStatus.fromString(
                error.message,
              ),
            ),
          );
        } else {
          final doctorsPaged = doctorsOrError.asRight();
          emit(MoreDoctorsResultLoaded(doctors: doctorsPaged));
          unawaited(
            transaction.finish(
              status: const SpanStatus.ok(),
            ),
          );
        }
      } else if (event is GetDoctorsResult) {
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get first page of doctors available',
          bindToScope: true,
        );
        emit(LoadingResults());
        final doctorsOrError = await Task(
          () => _doctorRepository.getDoctorsFilter(
            0,
            event.specializations,
            event.virtualAppointment,
            event.inPersonAppointment,
            event.organizations,
            event.names,
          ),
        ).attempt().mapLeftToFailure().run();
        if (doctorsOrError.isLeft()) {
          final error = doctorsOrError.asLeft();
          emit(FailedResult(response: error.message));
          transaction.throwable = doctorsOrError;
          unawaited(
            transaction.finish(
              status: SpanStatus.fromString(
                error.message,
              ),
            ),
          );
        } else {
          final doctorsPaged = doctorsOrError.asRight();

          emit(DoctorsResultLoaded(doctors: doctorsPaged));
          unawaited(
            transaction.finish(
              status: const SpanStatus.ok(),
            ),
          );
        }
      }
    });
  }
  final DoctorRepository _doctorRepository = DoctorRepository();

  void _setInitialDoctors(
    SetInitialDoctors event,
    Emitter<DoctorsResultState> emit,
  ) {
    emit(DoctorsResultLoaded(doctors: event.doctors));
  }
}
