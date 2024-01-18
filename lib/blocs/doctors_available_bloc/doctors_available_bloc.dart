import 'dart:async';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/utils/organization_helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'doctors_available_event.dart';
part 'doctors_available_state.dart';

class DoctorsAvailableBloc
    extends Bloc<DoctorsAvailableEvent, DoctorsAvailableState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  DoctorsAvailableBloc() : super(DoctorsAvailableInitial()) {
    on<DoctorsAvailableEvent>((event, emit) async {
      if(event is GetMoreFilterDoctor) {
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
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          //sort each doctor's organizations by availability
          result.items = result.items?.map(
                  (e) {
                e.organizations?.sort(orderByAvailability);
                return e;
              }
          ).toList();

          //sort doctors by first availability
          result.items?.sort(orderByOrganizationAvailability);
          emit(MoreDoctorsLoaded(doctors: result));
        }
      }else if (event is ReloadDoctorsAvailable) {
        emit(FilterLoading());
        await Future.delayed(const Duration(seconds: 1));
        // emit(FilterLoaded(doctors: Provider.of<DoctorFilterProvider>(navKey.currentState!.context, listen: false)
        //     .getDoctorsSaved));
        emit(FilterSucces());
      } else if (event is GetDoctorFilter) {
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
        ).attempt().run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FilterFailed(response: response));
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          //sort each doctor's organizations by availability
          result.items = result.items?.map(
                  (e) {
                e.organizations?.sort(orderByAvailability);
                return e;
              }
          ).toList();

          //sort doctors by first availability
          result.items?.sort(orderByOrganizationAvailability);

          emit(DoctorsLoaded(doctors: result));
          emit(FilterSucces());
        }
      } else if (event is GetDoctorFilterInDoctorList) {
        emit(FilterLoadingInDoctorList());
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
        ).attempt().run().then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FilterFailedInDoctorList(response: response));
        } else {
          late PagList<Doctor> result;
          _post.foldRight(Doctor, (a, previous) => result = a);

          //sort each doctor's organizations by availability
          result.items = result.items?.map(
                  (e) {
                e.organizations?.sort(orderByAvailability);
                return e;
              }
          ).toList();

          //sort doctors by first availability
          result.items?.sort(orderByOrganizationAvailability);
          emit(FilterLoadedInDoctorList(doctors: result));
          emit(FilterSuccesInDoctorList());
        }
      }
    });
  }

}
