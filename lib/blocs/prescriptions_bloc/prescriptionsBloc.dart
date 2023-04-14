
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



part 'prescriptionsEvent.dart';
part 'prescriptionsState.dart';

class PrescriptionsBloc extends Bloc<PrescriptionsEvent, PrescriptionsState> {
  final UserRepository _patientRepository = UserRepository();
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
      }else if(event is GetPastAppointmentWithPrescriptionsList){
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
          appointments.sort((a, b) =>
              DateTime.parse(b.start!).compareTo(DateTime.parse(a.start!)));
          await Task(() =>
          _patientRepository.getPrescriptions()!)
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
            late List<Prescription> prescriptions;
            _post.foldRight(
                Prescription, (a, previous) => prescriptions = a);
            for (Appointment appointment in appointments) {
              for (Prescription prescription in prescriptions) {
                if (prescription.encounter != null &&
                    prescription.encounter!.appointmentId == appointment.id) {
                  if (appointment.prescriptions != null) {
                    appointment.prescriptions = [
                      ...appointment.prescriptions!,
                      prescription
                    ];
                  } else {
                    appointment.prescriptions = [prescription];
                  }
                }
              }
            }
            appointments = appointments
                .where((element) => element.prescriptions != null)
                .toList();
            emit(AppointmentWithPrescriptionsLoadedState(appointments: appointments));
          }
        }

      }
    }

    );
  }
}
