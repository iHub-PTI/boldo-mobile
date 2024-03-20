
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/family_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../main.dart';


part 'dependent_family_event.dart';
part 'dependent_family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyRepository _familyRepository = FamilyRepository();
  FamilyBloc() : super(FamilyInitial()) {
    on<FamilyEvent>((event, emit) async {
      if(event is LinkFamily) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'POST',
          description: 'post a new family like dependent',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
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
            transaction.throwable = _post.asLeft();
            transaction.finish(
              status: SpanStatus.fromString(
                _post.asLeft().message,
              ),
            );
          }else{
            emit(Success());
            await Future.delayed(const Duration(seconds: 2));
            emit(RedirectNextScreen());
            transaction.finish(
              status: const SpanStatus.ok(),
            );
          }
        }
      }
      if(event is UnlinkDependent){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'PUT',
          description: 'unlink dependent of family list',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
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
      if(event is GetFamilyList){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get list of families (dependents)',
          bindToScope: true,
        );
        emit(Loading());
        Either<Failure, None<dynamic>> _post = await Task(() =>
        _familyRepository.getDependents()!)
            .attempt()
            .mapLeftToFailure()
            .run();
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
      if(event is GetManagersList){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get list of managers patient',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          List<Patient> caretakers = [];
          _post.foldRight(
              Patient, (a, previous) => caretakers = a);
          emit(CaretakersObtained(caretakers: caretakers));
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }if(event is UnlinkCaretaker){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'PUT',
          description: 'unlink manager',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
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
            transaction.throwable = _post.asLeft();
            transaction.finish(
              status: SpanStatus.fromString(
                _post.asLeft().message,
              ),
            );
          } else {
            List<Patient> caretakers = [];
            _post.foldRight(
                Patient, (a, previous) => caretakers = a);
            emit(CaretakersObtained(caretakers: caretakers));
            emit(Success());
            transaction.finish(
              status: const SpanStatus.ok(),
            );
          }
        }
      }
      if (event is LinkWithoutCi) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'POST',
          description: 'set a new family without ci',
          bindToScope: true,
        );
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
      if (event is GetRelationShipCodes) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get list of relationship available to link families',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          emit(RelationSuccess());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    });
  }
}
