import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/Doctor.dart';


part 'doctor_more_availability_event.dart';
part 'doctor_more_availability_state.dart';

class DoctorMoreAvailabilityBloc extends Bloc<DoctorMoreAvailabilityEvent, DoctorMoreAvailabilityState> {
  final UserRepository _patientRepository = UserRepository();
  final DoctorRepository _doctorRepository = DoctorRepository();
  DoctorMoreAvailabilityBloc() : super(DoctorAvailabilityInitial()) {
    on<DoctorMoreAvailabilityEvent>((event, emit) async {
      if(event is GetAvailability) {
        emit(Loading());
        var _post;
        await Task(() =>
        _doctorRepository.getAvailabilities(
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
          appointments?.removeWhere((element) => element.status != AppointmentStatus.Upcoming);

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
        }
      }
    }

    );
  }
}
