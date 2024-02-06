import 'dart:async';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'doctors_available_event.dart';
part 'doctors_available_state.dart';

class DoctorsAvailableBloc
    extends Bloc<DoctorsAvailableEvent, DoctorsAvailableState> {
  final DoctorRepository _doctorRepository = DoctorRepository();

  StreamController<List<Doctor>> _allDoctorsController = StreamController<List<Doctor>>.broadcast();

  Stream<List<Doctor>> get streamAllDoctors => _allDoctorsController.stream;

  DoctorsAvailableBloc() : super(DoctorsAvailableInitial()) {
    on<DoctorsAvailableEvent>((event, emit) async {
      if(event is GetMoreFilterDoctor) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get another page of doctors available',
          bindToScope: true,
        );
        var _post;
        await Task(() => _doctorRepository
            .getDoctorsFilter(
            event.offset,
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
        });
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
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          // //sort each doctor's organizations by availability
          // result.items = result.items?.map(
          //         (e) {
          //       e.organizations?.sort(orderByAvailability);
          //       return e;
          //     }
          // ).toList();

          //sort doctors by first availability
          // result.items?.sort(orderByOrganizationAvailability);
          emit(MoreDoctorsLoaded(doctors: result));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      } else if (event is GetDoctorFilter) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get first page of doctors available',
          bindToScope: true,
        );
        emit(FilterLoading());
        var _post;
        await Task(() => _doctorRepository
            .getDoctorsFilter(
            0,
            event.specializations,
            event.virtualAppointment,
            event.inPersonAppointment,
            event.organizations,
            event.names
        )
        ).attempt()
            .mapLeftToFailure()
            .run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FilterFailed(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          //sort each doctor's organizations by availability
          // result.items = result.items?.map(
          //         (e) {
          //       e.organizations?.sort(orderByAvailability);
          //       return e;
          //     }
          // ).toList();

          //sort doctors by first availability
          // result.items?.sort(orderByOrganizationAvailability);

          emit(DoctorsLoaded(doctors: result));
          emit(FilterSucces());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    });
  }

}
