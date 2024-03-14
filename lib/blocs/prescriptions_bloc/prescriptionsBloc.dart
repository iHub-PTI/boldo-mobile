
import 'package:boldo/models/Encounter.dart';
import 'package:boldo/models/filters/PrescriptionFilter.dart';
import 'package:boldo/network/prescription_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';



part 'prescriptionsEvent.dart';
part 'prescriptionsState.dart';

class PrescriptionsBloc extends Bloc<PrescriptionsEvent, PrescriptionsState> {

  PrescriptionFilter _prescriptionFilter = PrescriptionFilter();

  PrescriptionFilter get prescriptionFilter => _prescriptionFilter;

  /// set the filter and call [GetPastAppointmentWithPrescriptionsList] event
  set prescriptionFilter( PrescriptionFilter newPrescriptionFilter ){

    if(newPrescriptionFilter.end != null) {
      newPrescriptionFilter.end = DateTime(
        newPrescriptionFilter.end!.year,
        newPrescriptionFilter.end!.month,
        newPrescriptionFilter.end!.day,
        23,
        59,
        59,
      );
    }

    _prescriptionFilter = newPrescriptionFilter;
    add(GetPastEncounterWithPrescriptionsList(
      prescriptionFilter: prescriptionFilter,
    ));
  }

  PrescriptionsBloc() : super(PrescriptionBlocInitial()) {
    on<PrescriptionsEvent>((event, emit) async {
      if(event is GetPastEncounterWithPrescriptionsList){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get list of prescriptions',
          bindToScope: true,
        );
        emit(Loading());
        late Either<Failure, List<Encounter>> _post;

        await Task(() =>
        PrescriptionRepository.getPrescriptions(
          prescriptionFilter: event.prescriptionFilter?? prescriptionFilter,
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
        } else {
          late List<Encounter> encounters = _post.asRight();
          emit(EncounterWithPrescriptionsLoadedState(encounters: encounters));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }

      }
    }

    );
  }
}
