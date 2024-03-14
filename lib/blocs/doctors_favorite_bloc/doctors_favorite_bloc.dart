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

class FavoriteDoctorsBloc extends Bloc<FavoriteDoctorsEvent, FavoriteDoctorsState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  FavoriteDoctorsBloc() : super(DoctorFavoriteInitial()) {
    on<FavoriteDoctorsEvent>((event, emit) async {
      if (event is GetFavoriteDoctors) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get first page of favorites doctors',
          bindToScope: true,
        );
        emit(LoadingFavoriteDoctors());
        var _post;
        await Task(() =>
            _doctorRepository
                .getFavoriteDoctors(
                0,
                event.specializations,
                event.virtualAppointment,
                event.inPersonAppointment,
                event.organizations,
                event.names
            )
        ).attempt()
            .mapLeftToFailure()
            .run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedFavoriteDoctors(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          // //sort each doctor's organizations by availability
          // result.items = result.items?.map(
          //         (e) {
          //       e.organizations?.sort(orderByAvailability);
          //       return e;
          //     }
          // ).toList();
          //
          // //sort doctors by first availability
          // result.items?.sort(orderByOrganizationAvailability);
          emit(FavoriteDoctorsLoaded(doctors: result));
          emit(SuccessFavoriteDoctors());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
      else if (event is GetMoreFavoriteDoctors) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get another page of favorites doctors',
          bindToScope: true,
        );
        emit(LoadingMoreFavoriteDoctors());
        var _post;
        await Task(() =>
            _doctorRepository
                .getFavoriteDoctors(
                event.offset,
                event.specializations,
                event.virtualAppointment,
                event.inPersonAppointment,
                event.organizations,
                event.names
            )
        ).attempt()
            .mapLeftToFailure()
            .run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedFavoriteDoctors(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          // //sort each doctor's organizations by availability
          // result.items = result.items?.map(
          //         (e) {
          //       e.organizations?.sort(orderByAvailability);
          //       return e;
          //     }
          // ).toList();
          //
          // //sort doctors by first availability
          // result.items?.sort(orderByOrganizationAvailability);
          emit(MoreFavoriteDoctorsLoaded(doctors: result));
          emit(SuccessFavoriteDoctors());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }
    );
  }
}
