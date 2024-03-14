
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';



part 'lastAppointmentEvent.dart';
part 'lastAppointmentState.dart';

class LastAppointmentBloc extends Bloc<LastAppointmentEvent, LastAppointmentState> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  LastAppointmentBloc() : super(LastAppointmentInitial()) {
    on<LastAppointmentEvent>((event, emit) async {
      if(event is GetLastAppointment){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get last appointment with the doctor',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() =>
        _appointmentRepository.getLastAppointment(event.doctor)!)
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
          late Appointment? appointment;
          _post.foldRight(
              Appointment, (a, previous) => appointment = a);
          emit(LastAppointmentLoadedState(appointment: appointment));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
