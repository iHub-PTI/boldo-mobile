import 'package:boldo/app_config.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../main.dart';


part 'organization_event.dart';
part 'organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationBlocEvent, OrganizationBlocState> {
  final OrganizationRepository _organizationRepository = OrganizationRepository();
  OrganizationBloc() : super(OrganizationInitialState()) {
    on<OrganizationBlocEvent>((event, emit) async {
      if(event is GetAllOrganizations) {
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
        _organizationRepository.getUnsubscribedOrganizations(event.patientSelected)!)
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

          List<Organization> allOrganizations = [];
          _post.foldRight(Organization, (a, previous) => allOrganizations = a);

          PagList<Organization> _organizationsPage = PagList<Organization>(total: allOrganizations.length, items: allOrganizations);

          emit(AllOrganizationsObtained(organizationsList: _organizationsPage));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if(event is SubscribeToAnManyOrganizations) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'POST',
          description: 'post a request to join an organization',
          bindToScope: true,
        );
        emit(Loading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.subscribeToManyOrganizations(event.organizations, event.patientSelected)!)
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

          emit(SuccessSubscribed());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if(event is GetAllOrganizationsByType) {
        ISentrySpan transaction = Sentry.startTransaction(
          "${event.runtimeType.toString()}-${event.type.codeType}",
          'GET',
          description: 'get organization by type',
          bindToScope: true,
        );
        emit(Loading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.getOrganizationsByType(
          organizationType: event.type,
          name: event.name,
          page: event.page,
          pageSize: event.pageSize?? appConfig.ALL_ORGANIZATION_PAGE_SIZE.getValue,
        )!)
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
          late PagList<Organization> allOrganizations;
          _post.foldRight(
              PagList<Organization>, (a, previous) => allOrganizations = a);
          emit(AllOrganizationsObtained(organizationsList: allOrganizations));
          transaction.finish(
            status: const SpanStatus.ok(),
          );

        }
      }
    }

    );
  }
}
