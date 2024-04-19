import 'dart:async';
import 'dart:math';

import 'package:boldo/app_config.dart';
import 'package:boldo/blocs/homeOrganization_bloc/homeOrganization_bloc.dart'
    as home_organization_bloc;
import 'package:boldo/blocs/organizationApplied_bloc/organizationApplied_bloc.dart'
    as applied;
import 'package:boldo/blocs/organizationSubscribed_bloc/organizationSubscribed_bloc.dart'
    as subscribed;
import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/PositionEntity.dart';
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

/// Bloc for get organizations
class OrganizationBloc
    extends Bloc<OrganizationBlocEvent, OrganizationBlocState> {
  /// Bloc constructor
  OrganizationBloc() : super(OrganizationInitialState()) {
    pharmaciesListViewController.addListener(() {
      if (pharmaciesListViewController.position.pixels ==
          pharmaciesListViewController.position.maxScrollExtent) {
        if ((organizationList.items?.length ?? 0) <
            (organizationList.total ?? 0)) {
          pharmaciesListPage++;
          add(GetAllOrganizationsByType(type: OrganizationType.pharmacy));
        }
      }
    });

    on<OrganizationBlocEvent>((event, emit) async {
      if (event is GetAllOrganizations) {
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get all organizations unsubscribed',
          bindToScope: true,
        );
        emit(Loading());
        late Either<Failure, List<Organization>> organizationsOrError;

        //get organizations that the patient is subscribed
        await Task(
          () => _organizationRepository
              .getUnsubscribedOrganizations(event.patientSelected)!,
        ).attempt().mapLeftToFailure().run().then((value) {
          organizationsOrError = value;
        });
        if (organizationsOrError.isLeft()) {
          final failure = organizationsOrError.asLeft();
          emit(Failed(response: failure.message));
          transaction.throwable = failure;
          unawaited(
            transaction.finish(
              status: SpanStatus.fromString(
                failure.message,
              ),
            ),
          );
        } else {
          final allOrganizations = organizationsOrError.asRight();

          final organizationsPage = PagList<Organization>(
            total: allOrganizations.length,
            items: allOrganizations,
          );

          emit(AllOrganizationsObtained(organizationsList: organizationsPage));
          unawaited(
            transaction.finish(
              status: const SpanStatus.ok(),
            ),
          );
        }
      } else if (event is SubscribeToAnManyOrganizations) {
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'POST',
          description: 'post a request to join an organization',
          bindToScope: true,
        );
        emit(Loading());

        final context = event.context;

        final postulationEvaluationOrError = await Task(
          () => _checkOrganizationsRequirements(
            organizations: event.organizations,
            context: event.context,
          ),
        ).attempt().mapLeftToFailure().run();

        if (postulationEvaluationOrError.isLeft()) {
          final failure = postulationEvaluationOrError.asLeft();

          if (failure.message == cancelActionMessage) {
            unawaited(
              transaction.finish(
                status: SpanStatus.fromString(
                  failure.message,
                ),
              ),
            );
            emit(Success());
          } else {
            emit(Failed(response: failure.message));
            transaction.throwable = failure;
            unawaited(
              transaction.finish(
                status: SpanStatus.fromString(
                  failure.message,
                ),
              ),
            );
          }
        } else {
          final listPostulation = postulationEvaluationOrError.asRight();

          final organizationsChecked = listPostulation
              .where(
                (organizationWithResponse) =>
                    organizationWithResponse.value ?? false,
              )
              .map((organizationWithResponse) => organizationWithResponse.key)
              .toList();

          if (organizationsChecked.isNotEmpty) {
            // get organizations that the patient is subscribed
            final subscribedSuccessOrError = await Task(
              () => _organizationRepository.subscribeToManyOrganizations(
                organizationsChecked,
                event.patientSelected,
              )!,
            ).attempt().mapLeftToFailure().run();
            if (subscribedSuccessOrError.isLeft()) {
              final failure = subscribedSuccessOrError.asLeft();

              emit(Failed(response: failure.message));
              transaction.throwable = failure;
              unawaited(
                transaction.finish(
                  status: SpanStatus.fromString(
                    failure.message,
                  ),
                ),
              );

              emit(
                SuccessSubscribed(
                  organizationSubscribed: const [],
                ),
              );
            } else {
              if (!context.mounted) return;
              // send signal to get news with latest organizations list
              BlocProvider.of<home_organization_bloc.HomeOrganizationBloc>(
                event.context,
              ).add(home_organization_bloc.GetOrganizationsSubscribed());

              final text = organizationsChecked.length == 1
                  ? 'Una solicitud enviada correctamente'
                  : '${organizationsChecked.length} '
                      'solicitudes enviadas correctamente';

              if (!context.mounted) return;
              await emitSnackBar(
                context: event.context,
                text: text,
                status: ActionStatus.Success,
              ).then((value) {
                GetIt.I.get<subscribed.OrganizationSubscribedBloc>().add(
                      subscribed.GetOrganizationsSubscribed(
                        patientSelected: event.patientSelected,
                      ),
                    );
                GetIt.I.get<applied.OrganizationAppliedBloc>().add(
                      applied.GetOrganizationsPostulated(
                        patientSelected: event.patientSelected,
                      ),
                    );

                if (organizationsChecked.length == event.organizations.length) {
                  Navigator.of(event.context).pop(true);
                }
              });

              emit(
                SuccessSubscribed(
                  organizationSubscribed: organizationsChecked,
                ),
              );

              unawaited(
                transaction.finish(
                  status: const SpanStatus.ok(),
                ),
              );
            }
          } else {
            var message = listPostulation.length == 1
                ? 'No se pudo enviar la solicitud'
                : 'No se pudo enviar las solicitudes';

            message = '$message debido a los requisitos de '
                'suscripción no cumplidos';

            if (!context.mounted) return;
            unawaited(
              emitSnackBar(
                context: context,
                text: message,
                status: ActionStatus.Warning,
              ),
            );
            unawaited(
              transaction.finish(
                status: SpanStatus.fromString(
                  'failed some form to postulate',
                ),
              ),
            );
            emit(Success());
          }
        }
      } else if (event is GetAllOrganizationsByType) {
        final transaction = Sentry.startTransaction(
          '${event.runtimeType}-${event.type.codeType}',
          'GET',
          description: 'get organization by type',
          bindToScope: true,
        );

        // emit loading status on first page
        if (pharmaciesListPage <= 1) emit(Loading());
        late Either<Failure, PagList<Organization>> organizationPageOrError;

        //get organizations that the patient is subscribed
        await Task(
          () => _organizationRepository.getOrganizationsByType(
            organizationType: event.type,
            name: pharmacyNameFilter,
            page: pharmaciesListPage,
            pageSize:
                event.pageSize ?? appConfig.ALL_ORGANIZATION_PAGE_SIZE.getValue,
          )!,
        ).attempt().mapLeftToFailure().run().then((value) {
          organizationPageOrError = value;
        });
        if (organizationPageOrError.isLeft()) {
          final failure = organizationPageOrError.asLeft();
          emit(Failed(response: failure.message));
          transaction.throwable = failure;
          unawaited(
            transaction.finish(
              status: SpanStatus.fromString(
                failure.message,
              ),
            ),
          );
        } else {
          final currentList = state is AllOrganizationsObtained
              ? (state as AllOrganizationsObtained).organizationsList
              : PagList<Organization>(items: []);
          var allOrganizationsPage = organizationPageOrError.asRight();

          allOrganizationsPage = PagList<Organization>(
            total: currentList.total ?? allOrganizationsPage.total,
            items: [...?currentList.items, ...?allOrganizationsPage.items],
          );

          allOrganizationsPage.items?.forEach((organization) {
            organization.position = PositionEntity(
              latitude: -25.30066 +
                  (Random().nextBool() ? 1 : -1) * Random().nextDouble() / 50,
              longitude: -57.63591 +
                  (Random().nextBool() ? 1 : -1) * Random().nextDouble() / 50,
              title: "Surcursal: ${organization.name ?? 'unwknown'}",
              subtitle: organization.name,
            );
          });

          emit(
            AllOrganizationsObtained(
              organizationsList: allOrganizationsPage,
            ),
          );
          unawaited(
            transaction.finish(
              status: const SpanStatus.ok(),
            ),
          );
        }
      }
    });
  }

  final OrganizationRepository _organizationRepository =
      OrganizationRepository();

  /// used to listen the value of scroll and call event on maxScroll
  ScrollController pharmaciesListViewController = ScrollController();

  /// containt the name that was filter the list of [Organization]
  String? pharmacyNameFilter;

  /// contain the actual page
  int pharmaciesListPage = 1;

  /// get list of organizations in a page
  PagList<Organization> get organizationList {
    if (state is AllOrganizationsObtained) {
      return (state as AllOrganizationsObtained).organizationsList;
    } else {
      return PagList();
    }
  }

  Future<List<MapEntry<Organization, bool?>>> _checkOrganizationsRequirements({
    required List<Organization> organizations,
    required BuildContext context,
  }) async {
    final answers = <MapEntry<Organization, bool?>>[];

    await Future.forEach(organizations, (element) async {
      if (element.organizationSettings?.automaticPatientSubscription ?? false) {
        final answer = await _evaluateRequirements(
          organization: element,
          context: context,
        );

        if (answer == null) {
          throw Failure(cancelActionMessage);
        } else {
          answers.add(
            MapEntry(
              element,
              answer,
            ),
          );
        }
      } else {
        answers.add(MapEntry(element, true));
      }
    });

    return answers;
  }

  Future<bool?> _evaluateRequirements({
    required Organization organization,
    required BuildContext context,
  }) async {
    final expectedValue = await Navigator.of(context).push(
      MaterialPageRoute<bool?>(
        builder: (BuildContext context) => RequestRequirementPostulation(
          organization: organization,
          cancelAction: () async {
            return showDialog<bool>(
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
                  title: const Center(
                    child: Text(
                      '¿Estás seguro que deseas cancelar las solicitudes?',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  content: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 24,
                          top: 20,
                          right: 24,
                          bottom: 24,
                        ),
                        child: const Center(
                          child: Text(
                            'Si cancelas ahora, perderás todo el proceso '
                            'realizado hasta el momento.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.black87,
                        height: 10,
                      ),
                    ],
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
