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


part 'organizationSubscribed_event.dart';
part 'organizationSubscribed_state.dart';

class OrganizationSubscribedBloc extends Bloc<OrganizationSubscribedBlocEvent, OrganizationSubscribedBlocState> {
  final OrganizationRepository _organizationRepository = OrganizationRepository();
  OrganizationSubscribedBloc() : super(OrganizationInitialState()) {
    on<OrganizationSubscribedBlocEvent>((event, emit) async {
      if(event is GetOrganizationsSubscribed) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get all organizations unsubscribed',
          bindToScope: true,
        );
        emit(Loading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.getOrganizations(event.patientSelected)!)
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
          late List<Organization> organizations;
          _post.foldRight(QRCode, (a, previous) => organizations = a);

          emit(OrganizationsSubscribedObtained(organizationsList: organizations));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if(event is RemoveOrganization) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'DELETE',
          description: 'leave an organization',
          bindToScope: true,
        );
        emit(Loading());
        var _post;

        //unsubscribed to an one organization
        await Task(() =>
        _organizationRepository.unSubscribedOrganization(event.organization, event.patientSelected)!)
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

          emit(OrganizationRemoved(id: event.organization.id?? '0'));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if(event is ReorderByPriority) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'PUT',
          description: 'update organization order preference',
          bindToScope: true,
        );
        emit(Loading());
        var _post;

        //unsubscribed to an one organization
        await Task(() =>
        _organizationRepository.reorderByPriority(event.organizations, event.patientSelected)!)
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

          emit(PriorityEstablished());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }

    }

    );
  }
}
