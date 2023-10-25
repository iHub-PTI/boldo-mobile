import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'studiesOrders_event.dart';
part 'studiesOrders_state.dart';

class StudiesOrdersBloc extends Bloc<StudiesOrdersEvent, StudiesOrdersState> {
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
  StudiesOrdersBloc() : super(StudiesOrdersInitial()) {
    on<StudiesOrdersEvent>((event, emit) async {
      if (event is GetStudiesOrders) {
        emit(LoadingOrders());
        var _post;
        _post = await Task(() => _ordersRepository.getStudiesOrders()!)
            .attempt()
            .run();
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadedOrders(response: response));
        } else {
          late List<StudyOrder> studiesOrder = [];
          _post.foldRight(StudyOrder, (a, previous) => studiesOrder = a);

          List<ServiceRequest> servicesRequests = [];

          studiesOrder.forEach((studyOrder) {
            List<ServiceRequest>? servicesRequestOfStudyOrder = studyOrder.serviceRequests;
            servicesRequestOfStudyOrder?.forEach((serviceRequest) {
              serviceRequest.doctor = studyOrder.doctor;
              serviceRequest.authoredDate = studyOrder.authoredDate;
            });

            servicesRequests = [...servicesRequests ,...servicesRequestOfStudyOrder?? []];
          });

          emit(StudiesOrdersLoaded( studiesOrders: servicesRequests));
        }
      }
    });
  }
}
