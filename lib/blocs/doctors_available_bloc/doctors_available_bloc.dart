import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/utils/organization_helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

part 'doctors_available_event.dart';
part 'doctors_available_state.dart';

class DoctorsAvailableBloc
    extends Bloc<DoctorsAvailableEvent, DoctorsAvailableState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  DoctorsAvailableBloc() : super(DoctorsAvailableInitial()) {
    on<DoctorsAvailableEvent>((event, emit) async {
      if (event is GetDoctorsAvailable) {
        emit(Loading());
        var _post;
        await Task(() => _doctorRepository.getAllDoctors(event.offset)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);
          emit(DoctorsLoaded(doctors: doctors));
          emit(Success());
        }
      } else if (event is GetMoreDoctorsAvailable) {
        var _post;
        await Task(() => _doctorRepository.getAllDoctors(event.offset)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);
          emit(MoreDoctorsLoaded(doctors: doctors));
        }
      } else if(event is GetMoreFilterDoctor) {
        var _post;
        await Task(() => _doctorRepository
            .getDoctorsFilter(
            0,
            event.specializations,
            event.virtualAppointment,
            event.inPersonAppointment,
            event.organizations,
            event.names
        )
        )
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);
          emit(MoreDoctorsLoaded(doctors: doctors));
        }
      }else if (event is ReloadDoctorsAvailable) {
        emit(FilterLoading());
        await Future.delayed(const Duration(seconds: 1));
        emit(FilterLoaded(doctors: Provider.of<DoctorFilterProvider>(navKey.currentState!.context, listen: false)
            .getDoctorsSaved));
        emit(FilterSucces());
      } else if (event is GetDoctorFilter) {
        emit(FilterLoading());
        var _post;
        await Task(() => _doctorRepository
            .getDoctorsFilter(
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
          emit(FilterFailed(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);

          //sort each doctor's organizations by availability
          doctors = doctors.map(
            (e) {
              e.organizations?.sort(orderByAvailability);
              return e;
            }
          ).toList();

          //sort doctors by first availability
          doctors.sort(orderByOrganizationAvailability);
          emit(DoctorsLoaded(doctors: doctors));
          emit(FilterSucces());
        }
      } else if (event is GetDoctorFilterInDoctorList) {
        emit(FilterLoadingInDoctorList());
        var _post;
        await Task(() => _doctorRepository
            .getDoctorsFilter(
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
          emit(FilterFailedInDoctorList(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);
          //sort each doctor's organizations by availability
          doctors = doctors.map(
                  (e) {
                e.organizations?.sort(orderByAvailability);
                return e;
              }
          ).toList();

          //sort doctors by first availability
          doctors.sort(orderByOrganizationAvailability);
          emit(FilterLoadedInDoctorList(doctors: doctors));
          emit(FilterSuccesInDoctorList());
        }
      }
    });
  }

}
