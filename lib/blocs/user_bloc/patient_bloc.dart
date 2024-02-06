import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get patient on change profile',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getPatient(event.id)!)
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
          await Future.delayed(const Duration(seconds: 2));
          emit(RedirectBackScreen());
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        }else{
          emit(ChangeFamily());
          await Future.delayed(const Duration(seconds: 2));
          emit(RedirectNextScreen());
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
      if(event is ReloadHome){
        emit(Success());
      }
      if(event is EditProfile) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'PUT',
          description: 'edit data of patient',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
