import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';


part 'favorite_action_event.dart';
part 'favorite_action_state.dart';

class FavoriteActionBloc extends Bloc<FavoriteActionEvent, FavoriteActionState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  FavoriteActionBloc() : super(DoctorAvailabilityInitial()) {
    on<FavoriteActionEvent>((event, emit) async {
      if (event is PutFavoriteStatus) {
        emit(LoadingFavoriteAction());
        var _post;
        await Task(() =>
            _doctorRepository
                .putFavoriteStatus(
                event.doctor,
                event.favoriteStatus,
            )
        ).attempt()
            .mapLeftToFailure()
            .run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedFavoriteAction(response: response));
        } else {

          emit(SuccessFavoriteAction());
        }
      }
    });
  }
}
