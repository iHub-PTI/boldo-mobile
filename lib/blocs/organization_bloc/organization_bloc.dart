import 'package:boldo/app_config.dart';
import 'package:boldo/blocs/homeOrganization_bloc/homeOrganization_bloc.dart' as home_organization_bloc;
import 'package:boldo/constants.dart';
import 'package:boldo/blocs/organizationSubscribed_bloc/organizationSubscribed_bloc.dart' as subscribed;
import 'package:boldo/blocs/organizationApplied_bloc/organizationApplied_bloc.dart' as applied;
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/organization_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/screens/organizations/request_subscription/RequestRequirementPostulation.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


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

        Either<Failure, List<MapEntry<Organization, bool?>>>
        postulationEvaluation = await Task(() =>
          checkOrganizationsRequirements(
            organizations: event.organizations,
            context: event.context,
          )
        )
          .attempt()
          .mapLeftToFailure()
          .run();

        if(postulationEvaluation.isLeft()){

          Failure _failure = postulationEvaluation.asLeft();

          if(_failure.message == cancelActionMessage) {
            transaction.finish(
              status: SpanStatus.fromString(
                _failure.message,
              ),
            );
            emit(Success());
          }else {
            emit(Failed(response: _failure.message));
            transaction.throwable = _failure;
            transaction.finish(
              status: SpanStatus.fromString(
                _failure.message,
              ),
            );
          }
        }else{

          List<MapEntry<Organization, bool?>> listPostulation = postulationEvaluation.asRight();

          List<Organization> _organizationsChecked = listPostulation.where(
                  (organizationWithResponse) => organizationWithResponse.value == true
          ).map(
                  (organizationWithResponse) => organizationWithResponse.key
          ).toList();

          if(_organizationsChecked.isNotEmpty){

            // get organizations that the patient is subscribed
            Either<Failure, None<dynamic>> _post2 =
             await Task(() =>
            _organizationRepository.subscribeToManyOrganizations(
              _organizationsChecked,
              event.patientSelected,
            )!)
                .attempt()
                .mapLeftToFailure()
                .run();
            if (_post2.isLeft()) {

              Failure failure = _post2.asLeft();

              emit(Failed(response: failure.message));
              transaction.throwable = failure;
              transaction.finish(
                status: SpanStatus.fromString(
                  failure.message,
                ),
              );

              emit(SuccessSubscribed(
                organizationSubscribed: [],
              ));


            }else{
              // send signal to get news with latest organizations list
              BlocProvider.of<home_organization_bloc.HomeOrganizationBloc>(event.context).add(home_organization_bloc.GetOrganizationsSubscribed());

              String text = _organizationsChecked.length == 1
                  ? "Una solicitud enviada correctamente":
              "${_organizationsChecked.length} solicitudes enviadas correctamente"
              ;

              await emitSnackBar(
                  context: event.context,
                  text: text,
                  status: ActionStatus.Success
              ).then((value) {

                GetIt.I.get<subscribed.OrganizationSubscribedBloc>().add(subscribed.GetOrganizationsSubscribed(patientSelected: event.patientSelected));
                GetIt.I.get<applied.OrganizationAppliedBloc>().add(applied.GetOrganizationsPostulated(patientSelected: event.patientSelected));

                if (_organizationsChecked.length == event.organizations.length) {
                  Navigator.of(event.context).pop(true);
                }
              });

              emit(SuccessSubscribed(
                organizationSubscribed: _organizationsChecked,
              ));

              transaction.finish(
                status: const SpanStatus.ok(),
              );
            }

          }else{

            String message = listPostulation.length == 1 ?
                "No se pudo enviar la solicitud" : "No se pudo enviar las solicitudes";

            message = message + " debido a los requisitos de suscripción no cumplidos";

            emitSnackBar(
              context: event.context,
              text: message,
              status: ActionStatus.Warning,
            );
            transaction.finish(
              status: SpanStatus.fromString(
                'failed some form to postulate',
              ),
            );
            emit(Success());
          }
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

  Future<List<MapEntry<Organization, bool?>>> checkOrganizationsRequirements ({
    required List<Organization> organizations,
    required BuildContext context,
  }) async {
    
    List<MapEntry<Organization, bool?>> _answers = [];

    await Future.forEach(organizations, (element) async {
      
      if(element.organizationSettings?.automaticPatientSubscription?? false) {
        bool? _answer = await evaluateRequirements(
            organization: element, context: context);

        if(_answer == null){
          throw Failure(cancelActionMessage);
        }else {
          _answers.add(
            MapEntry(
              element,
              _answer,
            ),
          );
        }
      }else {
        _answers.add(MapEntry(element, true));
      }

        
    });

    return _answers;
  }

  Future<bool?> evaluateRequirements({
    required Organization organization,
    required BuildContext context,
  }) async {

    bool? expectedValue = await Navigator.of(context).push(
      MaterialPageRoute (
        builder: (BuildContext context) => RequestRequirementPostulation(
          organization: organization,
          cancelAction: () async {
            return await showDialog<bool>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext contextDialog) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  scrollable: true,
                  titleTextStyle: boldoCardHeadingTextStyle.copyWith(
                    color: ConstantsV2.blueDark,
                  ),
                  title: Container(
                    child: const Center(
                      child: Text(
                        "¿Estás seguro que deseas cancelar las solicitudes?",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            left: 24.0,
                            top: 20.0,
                            right: 24.0,
                            bottom: 24.0,
                          ),
                          child: const Center(
                            child: Text(
                              "Si cancelas ahora, perderás todo el proceso realizado hasta el momento.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.black87,
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Cerrar',
                        style: boldoCardHeadingTextStyle.copyWith(
                          color: ConstantsV2.secondaryRegular,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(contextDialog).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Si, cancelar',
                        style: boldoCardHeadingTextStyle.copyWith(
                          color: ConstantsV2.blueDark,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(contextDialog).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );

    return expectedValue;
  }

}
