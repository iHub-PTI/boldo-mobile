import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'studyOrder_event.dart';
part 'studyOrder_state.dart';

class StudyOrderBloc extends Bloc<StudyOrderEvent, StudyOrderState> {
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
  StudyOrderBloc() : super(StudiesOrderInitial()) {
    on<StudyOrderEvent>((event, emit) async {
      if (event is GetNews) {
        emit(LoadingOrders());
        var _post;
        await Task(() => _ordersRepository.getStudiesOrders()!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadedOrders(response: response));
        } else {
          late List<StudyOrder> studiesOrder = [];
          _post.foldRight(StudyOrder, (a, previous) => studiesOrder = a);

          emit(StudiesLoaded(studiesOrder: studiesOrder));
        }
      } else if (event is GetNewsId) {
        emit(LoadingOrders());
        var _post;
        await Task(() => _ordersRepository.getStudiesOrdersId(event.encounter)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadedOrders(response: response));
        } else {
          late StudyOrder studiesOrder;
          _post.foldRight(StudyOrder, (a, previous) => studiesOrder = a);

          emit(StudyOrderLoaded(studyOrder: studiesOrder));
        }
      } else if (event is GetAppointment) {
        emit(LoadingAppointment());
        var _post;
        await Task(() => _ordersRepository.getAppointment(event.encounter)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadAppointment(response: response));
        } else {
          late Appointment appointment;
          _post.foldRight(StudyOrder, (a, previous) => appointment = a);

          emit(AppointmentLoaded(appointment: appointment));
        }
      } else if (event is InitialEventStudyOrder) {
        emit(StudiesOrderInitial());
      }
    });
  }
}
