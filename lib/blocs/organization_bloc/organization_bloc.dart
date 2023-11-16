import 'package:boldo/app_config.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'organization_event.dart';
part 'organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationBlocEvent, OrganizationBlocState> {
  final OrganizationRepository _organizationRepository = OrganizationRepository();
  OrganizationBloc() : super(OrganizationInitialState()) {
    on<OrganizationBlocEvent>((event, emit) async {
      if(event is GetAllOrganizations) {
        emit(Loading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.getUnsubscribedOrganizations(event.patientSelected)!)
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

          List<Organization> allOrganizations = [];
          _post.foldRight(Organization, (a, previous) => allOrganizations = a);

          allOrganizations = allOrganizations.where(
                  (element) => !organizationsPostulated.any((element2) =>
              element.id == element2.id)
          ).toList();

          PagList<Organization> _organizationsPage = PagList<Organization>(total: allOrganizations.length, items: allOrganizations);

          emit(AllOrganizationsObtained(organizationsList: _organizationsPage));
        }
      }else if(event is SubscribeToAnManyOrganizations) {
        emit(Loading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.subscribeToManyOrganizations(event.organizations, event.patientSelected)!)
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

          emit(SuccessSubscribed());
        }
      }else if(event is GetAllOrganizationsByType) {
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
          late PagList<Organization> allOrganizations;
          _post.foldRight(
              PagList<Organization>, (a, previous) => allOrganizations = a);
          emit(AllOrganizationsObtained(organizationsList: allOrganizations));


        }
      }
    }

    );
  }
}
