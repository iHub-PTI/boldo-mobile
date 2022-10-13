import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
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
      } else if (event is ReloadDoctorsAvailable) {
        emit(FilterLoading());
        await Future.delayed(const Duration(seconds: 1));
        emit(FilterLoaded(doctors: Provider.of<DoctorFilterProvider>(navKey.currentState!.context, listen: false)
            .getDoctorsSaved));
        emit(FilterSucces());
      } else if (event is GetSpecializations) {
        emit(Loading());
        var _post;
        await Task(() => _doctorRepository.getAllSpecializations()!)
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
          late List<Specializations> specializations = [];
          _post.foldRight(
              Specializations, (a, previous) => specializations = a);
          emit(SpecializationsLoaded(specializations: specializations));
          emit(Success());
        }
      } else if (event is GetDoctorFilter) {
        emit(FilterLoading());
        var _post;
        await Task(() => _doctorRepository.getDoctorsFilter(
            event.specializations,
            event.virtualAppointment,
            event.inPersonAppointment)).attempt().run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FilterFailed(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);
          emit(FilterLoaded(doctors: doctors));
          emit(FilterSucces());
        }
      }
    });
  }
}
