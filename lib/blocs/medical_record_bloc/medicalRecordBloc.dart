
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'medicalRecordEvent.dart';
part 'medicalRecordState.dart';

class MedicalRecordBloc extends Bloc<MedicalRecordEvent, MedicalRecordState> {
  final UserRepository _patientRepository = UserRepository();
  MedicalRecordBloc() : super(MedicalRecordInitial()) {
    on<MedicalRecordEvent>((event, emit) async {
      if (event is GetMedicalRecord) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getMedicalRecordByAppointment(event.appointmentId)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late MedicalRecord medicalRecord;
          _post.foldRight(MedicalRecord, (a, previous) => medicalRecord = a);
          emit(MedicalRecordLoadedState(medicalRecord: medicalRecord));
          emit(Success());
        }
      }else if (event is GetMedicalRecordById) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getMedicalRecordById(event.id)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late MedicalRecord medicalRecord;
          _post.foldRight(MedicalRecord, (a, previous) => medicalRecord = a);
          emit(MedicalRecordLoadedState(medicalRecord: medicalRecord));
          emit(Success());
        }
      }else if(event is InitialEvent){
        emit(MedicalRecordInitial());
      }
    }

    );
  }
}
