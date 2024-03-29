import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final UserRepository _patientRepository = UserRepository();

  List<Organization> _organizations = [];

  List<Organization> getOrganizations() => _organizations;

  void setOrganizations(List<Organization> organizations) {
    _organizations = organizations;
  }

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
          await Future.delayed(const Duration(seconds: 2));
          emit(RedirectBackScreen());
        }else{
          emit(ChangeFamily());
          await Future.delayed(const Duration(seconds: 2));
          emit(RedirectNextScreen());
          emit(Success());
        }
      }
      if(event is ValidateQr) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getDependent(event.id)!)
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

          await Future.delayed(const Duration(seconds: 2));
          emit(RedirectBackScreen());
        }else{
          user.isNew = false;
          emit(Success());
          await Future.delayed(const Duration(seconds: 2));
          emit(RedirectNextScreen());
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
            emit(RedirectNextScreen());
            emit(Success());
          }
        }
      }
      if(event is ReloadHome){
        emit(Success());
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
      }if(event is EditProfile) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.editProfile(event.editingPatient)!)
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

    );
  }
}
