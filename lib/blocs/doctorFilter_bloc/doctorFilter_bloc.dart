import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'doctorFilter_event.dart';
part 'doctorFilter_state.dart';

class DoctorFilterBloc extends Bloc<DoctorFilterEvent, DoctorFilterState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  DoctorFilterBloc() : super(DoctorFilterInitial()) {
    on<DoctorFilterEvent>((event, emit) async {
      if(event is GetDoctorsPreview) {
        emit(LoadingDoctorFilter());
        //prevent get from server if any filter was selected
        if(event.organizations.isNotEmpty || event.specializations.isNotEmpty
        || event.inPersonAppointment || event.virtualAppointment) {
          var _post;
          await Task(() =>
              _doctorRepository
                  .getDoctorsFilter(
                  0,
                  event.specializations,
                  event.virtualAppointment,
                  event.inPersonAppointment,
                  event.organizations))
              .attempt()
              .run()
              .then((value) {
            _post = value;
          }
          );
          var response;
          if (_post.isLeft()) {
            _post.leftMap((l) => response = l.message);
            emit(FailedDoctorFilter(response: response));
          } else {
            late List<Doctor> _doctorsList = [];
            _post.foldRight(
                NextAvailability, (a, previous) => _doctorsList = a);
            emit(SuccessDoctorFilter(doctorList: _doctorsList));
          }
        }else{
          emit(SuccessDoctorFilter(doctorList: []));
        }
      }
    }

    );
  }
}
