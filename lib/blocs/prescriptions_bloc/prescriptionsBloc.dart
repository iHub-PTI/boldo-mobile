
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:boldo/network/prescription_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';



part 'prescriptionsEvent.dart';
part 'prescriptionsState.dart';

class PrescriptionsBloc extends Bloc<PrescriptionsEvent, PrescriptionsState> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  final PrescriptionRepository _prescriptionRepository = PrescriptionRepository();
  DateTime _initialDate = DateTime(DateTime.now().year-1,DateTime.now().month,DateTime.now().day);
  DateTime? _finalDate = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day, 23, 59, 59);

  DateTime getInitialDate() => _initialDate;
  DateTime? getFinalDate() => _finalDate;

  void setInitialDate(DateTime initialDate) {
    _initialDate = initialDate;
  }

  void setFinalDate(DateTime? finalDate) {
    _finalDate = finalDate;
  }

  PrescriptionsBloc() : super(PrescriptionBlocInitial()) {
    on<PrescriptionsEvent>((event, emit) async {
      if(event is GetPastAppointmentWithPrescriptionsList){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get list of prescriptions',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() =>
        _appointmentRepository.getPastAppointmentsBetweenDates(_initialDate, _finalDate)!)
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
