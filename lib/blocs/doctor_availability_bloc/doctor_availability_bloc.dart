import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../models/Doctor.dart';


part 'doctor_availability_event.dart';
part 'doctor_availability_state.dart';

class DoctorAvailabilityBloc extends Bloc<DoctorAvailabilityEvent, DoctorAvailabilityState> {
  final UserRepository _patientRepository = UserRepository();
  final DoctorRepository _doctorRepository = DoctorRepository();
  DoctorAvailabilityBloc() : super(DoctorAvailabilityInitial()) {
    on<DoctorAvailabilityEvent>((event, emit) async {
      if(event is GetAvailability) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get doctor availability for booking an appointment',
          bindToScope: true,
        );
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
