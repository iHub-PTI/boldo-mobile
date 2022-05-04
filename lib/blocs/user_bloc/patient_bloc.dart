import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final UserRepository _patientRepository = UserRepository();
  PatientBloc() : super(PatientInitial()) {
    on<PatientEvent>((event, emit) async {
      if(event is ChangeUser) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getPatient(event.id)!)
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
          //patient = _post;
          emit(Success());
        }
      }
    }
    );
  }
}