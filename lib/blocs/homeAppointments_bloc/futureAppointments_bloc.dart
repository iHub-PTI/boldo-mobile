import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


part 'futureAppointments_event.dart';
part 'futureAppointments_state.dart';

class FutureAppointmentsBloc extends Bloc<FutureAppointmentsEvent, FutureAppointmentsState> {
  final UserRepository _patientRepository = UserRepository();
  late List<Appointment> appointments = [];
  FutureAppointmentsBloc() : super(FutureAppointmentsInitial()) {
    on<FutureAppointmentsEvent>((event, emit) async {
      if(event is GetAppointmentsHome){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get future appointments',
          bindToScope: true,
        );
      emit(LoadingAppointments());
      late Either<Failure, List<Appointment>> _post;
      await Task(() =>
      _patientRepository.getAppointments()!)
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
        emit(FailedLoadedAppointments(response: response));
        transaction.throwable = _post.asLeft();
        transaction.finish(
          status: SpanStatus.fromString(
            _post.asLeft().message,
          ),
        );
      }else{
        appointments = _post.asRight();
        appointments.sort((a, b) =>
            DateTime.parse(a.start!).compareTo(DateTime.parse(b.start!)));
        // Clear appointments where appointment is not open
        appointments = appointments
            .where((element) =>
        ![AppointmentStatus.Closed, AppointmentStatus.Locked, AppointmentStatus.Cancelled].contains(element.status))
            .toList();
        emit(AppointmentsHomeLoaded(appointments: appointments));
        transaction.finish(
          status: const SpanStatus.ok(),
        );
      }
      }if(event is DeleteAppointmentHome){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'SELECT',
          description: 'delete local appointments',
          bindToScope: true,
        );
        appointments = appointments.where((element) => element.id != event.id).toList();
        
        emit(AppointmentsHomeLoaded(appointments: appointments));
        transaction.finish(
          status: const SpanStatus.ok(),
        );
      }
    });
  }
}
