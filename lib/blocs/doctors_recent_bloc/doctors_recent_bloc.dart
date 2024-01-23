import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'doctors_recent_event.dart';
part 'doctors_recent_state.dart';

class RecentDoctorsBloc extends Bloc<RecentDoctorsEvent, RecentDoctorsState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  RecentDoctorsBloc() : super(DoctorAvailabilityInitial()) {
    on<RecentDoctorsEvent>((event, emit) async {
      if (event is GetRecentDoctors) {
        emit(LoadingRecentDoctors());
        var _post;
        await Task(() =>
            _doctorRepository
                .getRecentDoctors(
                0,
                event.specializations,
                event.virtualAppointment,
                event.inPersonAppointment,
                event.organizations,
                event.names
            )
        ).attempt().run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedRecentDoctors(response: response));
        } else {
          late List<Doctor> doctors = [];
          _post.foldRight(Doctor, (a, previous) => doctors = a);

          // //sort each doctor's organizations by availability
          // doctors = doctors.map(
          //         (e) {
          //       e.organizations?.sort(orderByAvailability);
          //       return e;
          //     }
          // ).toList();
          //
          // //sort doctors by first availability
          // doctors.sort(orderByOrganizationAvailability);
          emit(RecentDoctorsLoaded(doctors: doctors));
        }
      }
    }
    );
  }
}
