import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'studyOrder_event.dart';
part 'studyOrder_state.dart';

class StudyOrderBloc extends Bloc<StudyOrderEvent, StudyOrderState> {
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
  StudyOrderBloc() : super(StudiesOrderInitial()) {
    on<StudyOrderEvent>((event, emit) async {
      if (event is GetNews) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get list of studies orders',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late List<StudyOrder> studiesOrder = [];
          _post.foldRight(StudyOrder, (a, previous) => studiesOrder = a);

          emit(StudiesLoaded(studiesOrder: studiesOrder));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      } else if (event is GetNewsId) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get study order from a encounter',
          bindToScope: true,
        );
        emit(LoadingOrders());
        var _post;
        await Task(() => _ordersRepository.getStudiesOrdersId(event.encounter)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadedOrders(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late StudyOrder studiesOrder;
          _post.foldRight(StudyOrder, (a, previous) => studiesOrder = a);

          emit(StudyOrderLoaded(studyOrder: studiesOrder));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      } else if (event is InitialEventStudyOrder) {
        emit(StudiesOrderInitial());
      }
    });
  }
}
