import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/QRCode.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'organizationSubscribed_event.dart';
part 'organizationSubscribed_state.dart';

class OrganizationSubscribedBloc extends Bloc<OrganizationSubscribedBlocEvent, OrganizationSubscribedBlocState> {
  final OrganizationRepository _organizationRepository = OrganizationRepository();
  OrganizationSubscribedBloc() : super(OrganizationInitialState()) {
    on<OrganizationSubscribedBlocEvent>((event, emit) async {
      if(event is GetOrganizationsSubscribed) {
        emit(Loading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.getOrganizations()!)
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
          late List<Organization> organizations;
          _post.foldRight(QRCode, (a, previous) => organizations = a);

          emit(OrganizationsSubscribedObtained(organizationsList: organizations));
        }
      }else if(event is RemoveOrganization) {
        emit(Loading());
        var _post;

        //unsubscribed to an one organization
        await Task(() =>
        _organizationRepository.unSubscribedOrganization(event.id)!)
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

          emit(OrganizationRemoved(id: event.id));
        }
      }

    }

    );
  }
}
