import 'package:boldo/main.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'homeOrganization_event.dart';
part 'homeOrganization_state.dart';

class HomeOrganizationBloc extends Bloc<HomeOrganizationBlocEvent, HomeOrganizationBlocState> {
  final OrganizationRepository _organizationRepository = OrganizationRepository();
  HomeOrganizationBloc() : super(HomeOrganizationInitialState()) {
    on<HomeOrganizationBlocEvent>((event, emit) async {
      if(event is GetOrganizationsSubscribed) {
        emit(HomeOrganizationLoading());
        var _post;

        //get organizations that the patient is subscribed
        await Task(() =>
        _organizationRepository.getOrganizations(patient)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(HomeOrganizationFailed(response: response));

        }else{
          late List<Organization> organizations;
          _post.foldRight(Organization, (a, previous) => organizations = a);

          emit(OrganizationsObtained(organizationsList: organizations));
        }
      }
    }

    );
  }
}
