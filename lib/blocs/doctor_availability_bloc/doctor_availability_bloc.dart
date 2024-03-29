import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/Doctor.dart';


part 'doctor_availability_event.dart';
part 'doctor_availability_state.dart';

class DoctorAvailabilityBloc extends Bloc<DoctorAvailabilityEvent, DoctorAvailabilityState> {
  final UserRepository _patientRepository = UserRepository();
  DoctorAvailabilityBloc() : super(DoctorAvailabilityInitial()) {
    on<DoctorAvailabilityEvent>((event, emit) async {
      if(event is GetAvailability) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getAvailabilities(
          id: event.id,
          startDate: event.startDate,
          endDate: event.endDate,
          organizations: event.organizations,
          appointmentType: event.appointmentType,
        )!)
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

          List<Appointment>? appointments =
          await _patientRepository.getAppointments();

          // canceled or blocked appointments are not necessary
          appointments?.removeWhere((element) => element.status != 'upcoming');

          late List<OrganizationWithAvailabilities> nextAvailability = [];
          _post.foldRight(NextAvailability, (a, previous) => nextAvailability = a);

          if (appointments != null) {
            if (appointments.isNotEmpty) {
              for(OrganizationWithAvailabilities organizationWithAvailabilities in nextAvailability){
                for (int i = 0; i < appointments.length; i++) {
                  organizationWithAvailabilities.availabilities.removeWhere((element) {
                    return element == null || DateTime.parse(element.availability!).toLocal().compareTo(
                        DateTime.parse(appointments[i].start!).toLocal()) ==
                        0;
                    }
                  );
                }
              }
            }
          }

          emit(AvailabilitiesObtained(availabilities: nextAvailability));
          emit(Success());
        }
      }
    }

    );
  }
}
