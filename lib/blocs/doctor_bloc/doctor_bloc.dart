import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'doctor_event.dart';
part 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final UserRepository _patientRepository = UserRepository();
  DoctorBloc() : super(DoctorInitial()) {
    on<DoctorEvent>((event, emit) async {
      if(event is GetAvailability) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getAvailabilities(id: event.id, startDate: event.startDate, endDate: event.endDate)!)
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
          late List<NextAvailability> nextAvailability = [];
          _post.foldRight(NextAvailability, (a, previous) => nextAvailability = a);
          emit(AvailabilitiesObtained(availabilities: nextAvailability));
          emit(Success());
        }
      }
      if(event is GetDoctor) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getDoctor(id: event.id)!)
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
          emit(Success());
        }
      }
      if(event is LinkFamily) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.setDependent(user.isNew)!)
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
          emit(Success());
          await UserRepository().getDependents();
          await Future.delayed(const Duration(seconds: 2));
          emit(RedirectNextScreen());
        }
      }
      if(event is ReloadHome){
        emit(Success());
      }
    }

    );
  }
}
