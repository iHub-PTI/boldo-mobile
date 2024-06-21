import 'dart:async';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'favorite_action_event.dart';
part 'favorite_action_state.dart';

abstract class FavoriteDoctorBlocFactory {
  // Mapa para almacenar las instancias del Bloc según su id
  static final Map<String, FavoriteActionBloc> _instances = {};

  // Método para obtener o crear una instancia del Bloc
  static FavoriteActionBloc getBloc({required String doctorId}) {
    // Si el Bloc con el id dado ya existe, devolverlo
    if (_instances.containsKey(doctorId)) {
      return _instances[doctorId]!;
    } else {
      // Si no existe, crear una nueva instancia y almacenarla en el mapa
      final newBloc = FavoriteActionBloc._();
      _instances[doctorId] = newBloc;
      return newBloc;
    }
  }
}

/// instance with [FavoriteDoctorBlocFactory.getBloc(doctorId: id)]
class FavoriteActionBloc
    extends Bloc<FavoriteActionEvent, FavoriteActionState> {
  FavoriteActionBloc._() : super(DoctorAvailabilityInitial()) {
    on<PutFavoriteStatus>(favoriteActionEvent);
  }

  final DoctorRepository _doctorRepository = DoctorRepository();

  Future<void> favoriteActionEvent(
    PutFavoriteStatus event,
    Emitter<FavoriteActionState> emit,
  ) async {
    final transaction = Sentry.startTransaction(
      event.runtimeType.toString(),
      'PUT',
      description: 'put favorite doctor status',
      bindToScope: true,
    );
    emit(LoadingFavoriteAction());
    final result = await Task(() => _doctorRepository.putFavoriteStatus(
          event.doctor,
          event.favoriteStatus,
        )).attempt().mapLeftToFailure().run();
    if (result.isLeft()) {
      final failure = result.asLeft();
      emit(FailedFavoriteAction(response: failure.message));
      transaction.throwable = failure;
      unawaited(
        transaction.finish(
          status: SpanStatus.fromString(
            failure.message,
          ),
        ),
      );
    } else {
      emit(SuccessFavoriteAction());
      unawaited(
        transaction.finish(
          status: const SpanStatus.ok(),
        ),
      );
    }
  }
}
