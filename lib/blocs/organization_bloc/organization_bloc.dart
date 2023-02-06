import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/QRCode.dart';
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
        _organizationRepository.getAllOrganizations()!)
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

          var _post2;
          List<Organization> organizationsSubscribed = [];
          //get organizations that the patient is subscribed
          await Task(() =>
          _organizationRepository.getOrganizations()!)
              .attempt()
              .run()
              .then((value) {
            _post2 = value;
          }
          );
          if (_post2.isLeft()) {
            _post2.leftMap((l) => response = l.message);

          }else{

            _post2.foldRight(QRCode, (a, previous) => organizationsSubscribed = a);


          }
          List<Organization> allOrganizations = [];
          _post.foldRight(QRCode, (a, previous) => allOrganizations = a);

          allOrganizations = allOrganizations.where(
              (element) => !organizationsSubscribed.any((element2) =>
                  element.id == element2.id)
          ).toList();

          allOrganizations = allOrganizations.where(
                  (element) => !organizationsPostulated.any((element2) =>
              element.id == element2.id)
          ).toList();

          emit(OrganizationsObtained(organizationsList: allOrganizations));
        }
      }else if(event is SubscribeToAnManyOrganizations) {
        emit(Loading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.subscribeToManyOrganizations(event.organizations)!)
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
      }
    }

    );
  }
}
