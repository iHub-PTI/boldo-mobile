
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';



part 'appointmentsEvent.dart';
part 'appointmentsState.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  DateTime _initialDate = DateTime(DateTime.now().year-1,DateTime.now().month,DateTime.now().day);
  DateTime? _finalDate = DateTime.now();

  // remote type
  bool _filterVirtual = true;

  // in person type
  bool _filterInPerson = true;

  bool getVirtualStatus() => _filterVirtual;
  bool getInPersonStatus() => _filterInPerson;

  DateTime getInitialDate() => _initialDate;
  DateTime? getFinalDate() => _finalDate;

  void setInitialDate(DateTime initialDate) {
    _initialDate = initialDate;
  }

  void setFinalDate(DateTime? finalDate) {
    _finalDate = finalDate;
  }

  void setVirtualStatus(bool virtualStatus) {
    _filterVirtual = virtualStatus;
  }

  void setInPersonStatus(bool inPersonStatus) {
    _filterInPerson = inPersonStatus;
  }

  AppointmentsBloc() : super(AppointmentsInitial()) {
    on<AppointmentsEvent>((event, emit) async {
      if(event is GetPastAppointmentsList){
        emit(Loading());
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          bindToScope: true,
        );
        late Either<Failure, List<Appointment>> _post;
        await Task(() =>
        _appointmentRepository.getPastAppointments(event.date)!)
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
          late List<Appointment> appointments;
          appointments = _post.asRight();
          emit(AppointmentsLoadedState(appointments: appointments));
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if(event is GetPastAppointmentsBetweenDatesList){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          bindToScope: true,
        );
        emit(Loading());
        late Either<Failure, List<Appointment>> _post;
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
          late List<Appointment> appointments;
          appointments= _post.asRight();

          // filter appointmentType
          appointments = appointments
              .where(
                (element) {
                  if(_filterVirtual && element.appointmentType == "V"){
                      return true;
                  }
                  else if(_filterInPerson && element.appointmentType == "A"){
                    return true;
                  }
                  return false;
                })
              .toList();
          emit(AppointmentsLoadedState(appointments: appointments));
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
