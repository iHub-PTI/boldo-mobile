
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



part 'prescriptionEvent.dart';
part 'prescriptionState.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final UserRepository _patientRepository = UserRepository();
  PrescriptionBloc() : super(PrescriptionBlocInitial()) {
    on<PrescriptionEvent>((event, emit) async {
      if(event is GetPrescription){
        emit(LoadingPrescription());
        var _post;
        await Task(() =>
        _patientRepository.getPrescription(event.id)!)
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
          emit(FailedLoadPrescription(response: response));
        } else {
          emit(PrescriptionLoaded(prescription: _post.value));
        }
      }else if(event is InitialEvent){
        emit(PrescriptionBlocInitial());
      }
    }

    );
  }
}
