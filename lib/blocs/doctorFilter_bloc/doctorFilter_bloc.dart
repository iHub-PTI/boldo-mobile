import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


part 'doctorFilter_event.dart';
part 'doctorFilter_state.dart';

class DoctorFilterBloc extends Bloc<DoctorFilterEvent, DoctorFilterState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  DoctorFilterBloc() : super(DoctorFilterInitial()) {
    on<DoctorFilterEvent>((event, emit) async {
      if(event is GetDoctorsPreview) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get preview of count of doctor in filter',
          bindToScope: true,
        );
        emit(LoadingDoctorFilter());
        //prevent get from server if any filter was selected
        if(event.organizations.isNotEmpty || event.specializations.isNotEmpty
        || event.inPersonAppointment || event.virtualAppointment || event.names.isNotEmpty) {
          var _post;
          await Task(() =>
              _doctorRepository
                  .getDoctorsFilter(
                  0,
                  event.specializations,
                  event.virtualAppointment,
                  event.inPersonAppointment,
                  event.organizations,
                  event.names
                )
              )
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
            emit(FailedDoctorFilter(response: response));
            transaction.throwable = _post.asLeft();
            transaction.finish(
              status: SpanStatus.fromString(
                _post.asLeft().message,
              ),
            );
          } else {
            late PagList<Doctor> _doctorsList;
            _post.foldRight(
                NextAvailability, (a, previous) => _doctorsList = a);
            emit(SuccessDoctorFilter(doctorList: _doctorsList));
            transaction.finish(
              status: const SpanStatus.ok(),
            );
          }
        }else{
          PagList<Doctor> doctors = PagList<Doctor>(total: 0, items: []);
          emit(SuccessDoctorFilter(doctorList: doctors));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
