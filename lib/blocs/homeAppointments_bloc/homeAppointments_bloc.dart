import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'homeAppointments_event.dart';
part 'homeAppointments_state.dart';

class HomeAppointmentsBloc extends Bloc<HomeAppointmentsEvent, HomeAppointmentsState> {
  final UserRepository _patientRepository = UserRepository();
  late List<Appointment> appointments = [];
  HomeAppointmentsBloc() : super(HomeAppointmentsInitial()) {
    on<HomeAppointmentsEvent>((event, emit) async {
      if(event is GetAppointmentsHome){
      emit(LoadingAppointments());
      var _post;
      await Task(() =>
      _patientRepository.getAppointments()!)
          .attempt()
          .run()
          .then((value) {
        _post = value;
      }
      );
      var response;
      if (_post.isLeft()) {
        _post.leftMap((l) => response = l.message);
        emit(FailedLoadedAppointments(response: response));
      }else{
        _post.foldRight(Appointment, (a, previous) => appointments = a);
        appointments.sort((a, b) =>
            DateTime.parse(a.start!).compareTo(DateTime.parse(b.start!)));
        // Clear appointments where appointment is not open
        appointments = appointments
            .where((element) =>
        !["closed", "locked", "cancelled"].contains(element.status))
            .toList();
        emit(AppointmentsHomeLoaded(appointments: appointments));
      }
      }if(event is DeleteAppointmentHome){
        
        appointments = appointments.where((element) => element.id != event.id).toList();
        
        emit(AppointmentsHomeLoaded(appointments: appointments));
      }
    });
  }
}
