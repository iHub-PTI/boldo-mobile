import 'dart:async';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'doctors_favorite_event.dart';
part 'doctors_favorite_state.dart';

class FavoriteDoctorsBloc
    extends Bloc<FavoriteDoctorsEvent, FavoriteDoctorsState> {
  ///
  FavoriteDoctorsBloc() : super(DoctorFavoriteInitial()) {
    on<GetFavoriteDoctors>(_getFavoriteDoctors);
    on<GetMoreFavoriteDoctors>(_getMoreFavoriteDoctors);
    on<SetFavoriteLocalDoctor>(_setLocalFavoriteDoctor);
  }

  Future<void> _getFavoriteDoctors(
    GetFavoriteDoctors event,
    Emitter<FavoriteDoctorsState> emit,
  ) async {
    final transaction = Sentry.startTransaction(
      event.runtimeType.toString(),
      'GET',
      description: 'get first page of favorites doctors',
      bindToScope: true,
    );
    emit(LoadingFavoriteDoctors());
    final favoriteDoctorsOrError = await Task(
      () => _doctorRepository.getFavoriteDoctors(
        0,
        event.specializations,
        event.virtualAppointment,
        event.inPersonAppointment,
        event.organizations,
        event.names,
      ),
    ).attempt().mapLeftToFailure().run();
    if (favoriteDoctorsOrError.isLeft()) {
      final failure = favoriteDoctorsOrError.asLeft();
      emit(FailedFavoriteDoctors(response: failure.message));
      transaction.throwable = failure;
      unawaited(
        transaction.finish(
          status: SpanStatus.fromString(
            failure.message,
          ),
        ),
      );
    } else {
      final result = favoriteDoctorsOrError.asRight();

      emit(FavoriteDoctorsLoaded(doctors: result));
      unawaited(
        transaction.finish(
          status: const SpanStatus.ok(),
        ),
      );
    }
  }

  Future<void> _getMoreFavoriteDoctors(
    GetMoreFavoriteDoctors event,
    Emitter<FavoriteDoctorsState> emit,
  ) async {
    final transaction = Sentry.startTransaction(
      event.runtimeType.toString(),
      'GET',
      description: 'get another page of favorites doctors',
      bindToScope: true,
    );
    emit(LoadingMoreFavoriteDoctors());
    final favoriteDoctorsOrError = await Task(
      () => _doctorRepository.getFavoriteDoctors(
        event.offset,
        event.specializations,
        event.virtualAppointment,
        event.inPersonAppointment,
        event.organizations,
        event.names,
      ),
    ).attempt().mapLeftToFailure().run();
    if (favoriteDoctorsOrError.isLeft()) {
      final failure = favoriteDoctorsOrError.asLeft();
      emit(FailedFavoriteDoctors(response: failure.message));
      transaction.throwable = failure;
      unawaited(
        transaction.finish(
          status: SpanStatus.fromString(
            failure.message,
          ),
        ),
      );
    } else {
      final result = favoriteDoctorsOrError.asRight();

      emit(MoreFavoriteDoctorsLoaded(doctors: result));
      await transaction.finish(
        status: const SpanStatus.ok(),
      );
    }
  }

  Future<void> _setLocalFavoriteDoctor(
    SetFavoriteLocalDoctor event,
    Emitter<FavoriteDoctorsState> emit,
  ) async {
    emit(FavoriteDoctorsAdded(doctor: event.doctor));
  }

  final DoctorRepository _doctorRepository = DoctorRepository();
}
