import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/QRCode.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../main.dart';


part 'organizationApplied_event.dart';
part 'organizationApplied_state.dart';

class OrganizationAppliedBloc extends Bloc<OrganizationAppliedBlocEvent, OrganizationAppliedBlocState> {
  final OrganizationRepository _organizationRepository = OrganizationRepository();
  OrganizationAppliedBloc() : super(OrganizationInitialState()) {
    on<OrganizationAppliedBlocEvent>((event, emit) async {
      if(event is GetOrganizationsPostulated) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get organization pending to request',
          bindToScope: true,
        );
        emit(Loading());
        await Future.delayed(const Duration(seconds: 1));
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.getPostulatedOrganizations(event.patientSelected)!)
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
          late List<OrganizationRequest> organizations;
          _post.foldRight(QRCode, (a, previous) => organizations = a);

          emit(OrganizationsObtained(organizationsList: organizations));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if(event is UnPostulated) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'DELETE',
          description: 'remove a request pending to approve',
          bindToScope: true,
        );
        emit(Loading());
        var _post;

        //unsubscribed to an one organization
        await Task(() =>
        _organizationRepository.unSubscribedPostulation(event.organization, event.patientSelected)!)
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

          emit(PostulationRemoved(id: event.organization.id?? '0'));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
