import 'package:boldo/blocs/filter_bloc/filter_bloc.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'filter_prescription_event.dart';
part 'filter_prescription_state.dart';

class FilterPrescriptionBloc extends FilterBloc<FilterEvent, FilterState> {

  FilterPrescriptionBloc() : super(FilterInitial()) {
    on<ApplyFilter>(_filterEvent);
  }

  Future<void> _filterEvent(ApplyFilter event, Emitter<FilterState> emit) async {
    emit(Loading());

    Either<Failure, void> _post =
    await Task(() => Future(
        () => event.function(event.filter)
    ))
        .attempt()
        .mapLeftToFailure()
        .run();

    if (_post.isLeft()) {
      emit(Failed(response: _post.asLeft().message));
    } else {
      event.function(event.filter);
      Navigator.pop(event.context);
      emit(Success(result: null));
    }

  }

}
