
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/family_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'dependent_family_event.dart';
part 'dependent_family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyRepository _familyRepository = FamilyRepository();
  FamilyBloc() : super(FamilyInitial()) {
    on<FamilyEvent>((event, emit) async {
      if(event is LinkFamily) {
        emit(Loading());
        var _post;
        await Task(() =>
        _familyRepository.setDependent(user.isNew)!)
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
        }else{
          emit(Success());
          await Task(() =>
          _familyRepository.getDependents()!)
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
        _familyRepository.unlinkDependent(event.id)!)
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
        }else {
          emit(DependentEliminated());
          emit(Success());
          await Task(() =>
          _familyRepository.getDependents()!)
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
            emit(Success());
          }
        }
      }
      if(event is GetFamilyList){
        emit(Loading());
        var _post;
        await Task(() =>
        _familyRepository.getDependents()!)
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
          emit(Success());
        }
      }
      if(event is GetManagersList){
        emit(Loading());
        var _post;
        await Task(() =>
        _familyRepository.getManagements()!)
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
        _familyRepository.unlinkCaretaker(event.id)!)
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
        }else {
          emit(Success());
          await Task(() =>
          _familyRepository.getManagements()!)
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
      if (event is LinkWithoutCi) {
        emit(Loading());
        var _post;
        await Task(() => _familyRepository.linkWithoutCi(event.givenName, event.familyName, event.birthDate, event.gender, event.identifier, event.relationShipCode)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          emit(Success());
        }
      }
      if (event is GetRelationShipCodes) {
        emit(RelationLoading());
        var _post;
        await Task(() => _familyRepository.getRelationships()!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(RelationFailed(response: response));
        } else {
          emit(RelationSuccess());
        }
      }
    });
  }
}
