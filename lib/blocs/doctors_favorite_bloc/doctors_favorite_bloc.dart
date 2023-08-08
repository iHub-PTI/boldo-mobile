import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/utils/organization_helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'doctors_favorite_event.dart';
part 'doctors_favorite_state.dart';

class FavoriteDoctorsBloc extends Bloc<FavoriteDoctorsEvent, FavoriteDoctorsState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  FavoriteDoctorsBloc() : super(DoctorFavoriteInitial()) {
    on<FavoriteDoctorsEvent>((event, emit) async {
      if (event is GetFavoriteDoctors) {
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
        ).attempt().run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedFavoriteDoctors(response: response));
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          //sort each doctor's organizations by availability
          result.items = result.items?.map(
                  (e) {
                e.organizations?.sort(orderByAvailability);
                return e;
              }
          ).toList();

          //sort doctors by first availability
          result.items?.sort(orderByOrganizationAvailability);
          emit(FavoriteDoctorsLoaded(doctors: result));
          emit(SuccessFavoriteDoctors());
        }
      }
      else if (event is GetMoreFavoriteDoctors) {
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
        ).attempt().run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedFavoriteDoctors(response: response));
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          //sort each doctor's organizations by availability
          result.items = result.items?.map(
                  (e) {
                e.organizations?.sort(orderByAvailability);
                return e;
              }
          ).toList();

          //sort doctors by first availability
          result.items?.sort(orderByOrganizationAvailability);
          emit(MoreFavoriteDoctorsLoaded(doctors: result));
          emit(SuccessFavoriteDoctors());
        }
      }
    }
    );
  }
}
