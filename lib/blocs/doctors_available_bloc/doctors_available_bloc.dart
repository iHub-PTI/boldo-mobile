import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
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
        await Task(() => _doctorRepository.getDoctorsFilter(
          event.offset,
          event.specializations,
          event.virtualAppointment,
          event.inPersonAppointment,
          event.organizations))
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
        await Task(() => _doctorRepository.getDoctorsFilter(
            0,
            event.specializations,
            event.virtualAppointment,
            event.inPersonAppointment,
            event.organizations)).attempt().run().then((value) {
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
        await Task(() => _doctorRepository.getDoctorsFilter(
            0,
            event.specializations,
            event.virtualAppointment,
            event.inPersonAppointment,
            event.organizations)).attempt().run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FilterFailedInDoctorList(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);
          emit(FilterLoadedInDoctorList(doctors: doctors));
          emit(FilterSuccesInDoctorList());
        }
      }
    });
  }

  int orderByAvailability(OrganizationWithAvailability a, OrganizationWithAvailability b){
    if (b.nextAvailability == null && a.nextAvailability == null) {
      return 0;
    }
    if (a.nextAvailability == null) {
      return 1;
    }
    if (b.nextAvailability == null) {
      return -1;
    }
    return DateTime.parse(a.nextAvailability!.availability!)
        .compareTo(DateTime.parse(b.nextAvailability!.availability!));
  }

  int orderByOrganizationAvailability(Doctor a, Doctor b){
    if (b.organizations?.first.nextAvailability == null && a.organizations?.first.nextAvailability == null) {
      return 0;
    }
    if (a.organizations?.first.nextAvailability == null) {
      return 1;
    }
    if (b.organizations?.first.nextAvailability == null) {
      return -1;
    }
    return DateTime.parse(a.organizations!.first.nextAvailability!.availability!)
        .compareTo(DateTime.parse(b.organizations!.first.nextAvailability!.availability!));
  }
}
