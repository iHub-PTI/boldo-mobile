import 'dart:convert';

import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../models/Doctor.dart';


part 'doctor_availability_event.dart';
part 'doctor_availability_state.dart';

class DoctorAvailabilityBloc extends Bloc<DoctorAvailabilityEvent, DoctorAvailabilityState> {
  final UserRepository _patientRepository = UserRepository();
  DoctorAvailabilityBloc() : super(DoctorAvailabilityInitial()) {
    on<DoctorAvailabilityEvent>((event, emit) async {
      if(event is GetDoctorAvailability) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getDoctorAvailability(event.doctor, event.start)!)
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
          late List<NextAvailability> nextAvailability;
          _post.foldRight(
              NextAvailability, (a, previous) => nextAvailability = a);

          emit(DoctorNextAvailabilityLoaded(nextAvailability: nextAvailability));
          emit(Success());
        }
      }
      if(event is ReloadHome){
        emit(Success());
      }
    }

    );
  }
}
