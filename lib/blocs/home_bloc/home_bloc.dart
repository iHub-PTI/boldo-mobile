import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _patientRepository = UserRepository();
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      if(event is ReloadHome){
        emit(Success());
      }else if(event is GetAppointments){
        emit(Loading());
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
          emit(Failed(response: response));
        }else{
          late List<Appointment> appointments = [];
          _post.foldRight(Appointment, (a, previous) => appointments = a);
          appointments.sort((a, b) =>
              DateTime.parse(a.start!).compareTo(DateTime.parse(b.start!)));
          // Clear appointments where appointment is not open
          appointments = appointments
              .where((element) =>
          !["closed", "locked", "cancelled"].contains(element.status))
              .toList();
          emit(AppointmentsLoaded(appointments: appointments));
          emit(Success());
        }
      }else if(event is GetDiagnosticReports){
      emit(Loading());
      var _post;
      await Task(() =>
      _patientRepository.getDiagnosticRecords()!)
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
        late List<DiagnosticReport> diagnosticReports = [];
        _post.foldRight(DiagnosticReport, (a, previous) => diagnosticReports = a);

        // Clear appointments where appointment is not open
        diagnosticReports = diagnosticReports
            .where((element) => element.sourceID != patient.id).toList();
        emit(DiagnosticReportsLoaded(diagnosticReports: diagnosticReports));
        emit(Success());
      }
    }
    });
  }
}
