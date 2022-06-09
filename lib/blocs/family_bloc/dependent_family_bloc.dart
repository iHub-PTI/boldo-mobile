
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'dependent_family_event.dart';
part 'dependent_family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final UserRepository _patientRepository = UserRepository();
  FamilyBloc() : super(FamilyInitial()) {
    on<FamilyEvent>((event, emit) async {
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
          await Task(() =>
          _patientRepository.getDependents()!)
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
            await Future.delayed(const Duration(seconds: 2));
            emit(RedirectNextScreen());
          }
        }
      }
      if(event is UnlinkDependent){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.unlinkDependent(event.id)!)
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
        }else {
          emit(Success());
          await Task(() =>
          _patientRepository.getDependents()!)
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
          } else {
            emit(Success());
          }
        }
      }
      if(event is GetFamilyList){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getDependents()!)
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
        } else {
          emit(Success());
        }
      }
      if(event is GetManagersList){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getManagements()!)
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
        } else {
          List<Patient> caretakers = [];
          _post.foldRight(
              Patient, (a, previous) => caretakers = a);
          emit(CaretakersObtained(caretakers: caretakers));
          emit(Success());
        }
      }if(event is UnlinkCaretaker){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.unlinkCaretaker(event.id)!)
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
        }else {
          emit(Success());
          await Task(() =>
          _patientRepository.getManagements()!)
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
          } else {
            List<Patient> caretakers = [];
            _post.foldRight(
                Patient, (a, previous) => caretakers = a);
            emit(CaretakersObtained(caretakers: caretakers));
            emit(Success());
          }
        }
      }
    }

    );
  }
}
