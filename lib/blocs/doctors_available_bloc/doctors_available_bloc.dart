import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        await Task(() =>
        _doctorRepository.getAllDoctors()!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        }else{
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);
          emit(DoctorsLoaded(doctors: doctors));
          emit(Success());
        }
      } else if (event is ReloadDoctorsAvailable) {}
    });
  }
}
