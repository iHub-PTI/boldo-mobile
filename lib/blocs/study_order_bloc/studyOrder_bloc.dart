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
      if(event is GetNews){
      emit(LoadingOrders());
      var _post;
      await Task(() =>
      _ordersRepository.getStudiesOrders()!)
          .attempt()
          .run()
          .then((value) {
        _post = value;
      }
      );
      var response;
      if (_post.isLeft()) {
        _post.leftMap((l) => response = l.message);
        emit(FailedLoadedOrders(response: response));
      }else{
        late List<StudyOrder> studiesOrder = [];
        _post.foldRight(StudyOrder, (a, previous) => studiesOrder = a);

        emit(StudiesLoaded(studiesOrder: studiesOrder));
      }
    }
    });
  }
}