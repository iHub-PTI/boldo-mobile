
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



part 'appointmentEvent.dart';
part 'appointmentState.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final UserRepository _patientRepository = UserRepository();
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

  AppointmentBloc() : super(AppointmentInitial()) {
    on<AppointmentEvent>((event, emit) async {
      if(event is GetPastAppointmentList){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getPastAppointments(event.date)!)
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
        } else {
          late List<Appointment> appointments;
          _post.foldRight(
              Appointment, (a, previous) => appointments = a);
          emit(AppointmentLoadedState(appointments: appointments));
          emit(Success());
        }
      }else if(event is GetPastAppointmentBetweenDatesList){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getPastAppointmentsBetweenDates(_initialDate, _finalDate)!)
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
        } else {
          late List<Appointment> appointments;
          _post.foldRight(
              Appointment, (a, previous) => appointments = a);

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
          emit(AppointmentLoadedState(appointments: appointments));
          emit(Success());
        }
      }
    }

    );
  }
}
