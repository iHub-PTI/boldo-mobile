import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/specialization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


part 'specializationFilter_event.dart';
part 'specializationFilter_state.dart';

class SpecializationFilterBloc extends Bloc<SpecializationsFilterEvent, SpecializationFilterState> {
  final SpecializationRepository _specializationRepository = SpecializationRepository();
  SpecializationFilterBloc() : super(SpecializationFilterInitial()) {
    on<SpecializationsFilterEvent>((event, emit) async {
      if (event is GetSpecializations) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get list of specializations available',
          bindToScope: true,
        );
        emit(LoadingSpecializationFilter());
        var _post;
        await Task(() => _specializationRepository.getAllSpecializations()!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedSpecializationFilter(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late List<Specializations> specializations = [];
          _post.foldRight(
              Specializations, (a, previous) => specializations = a);
          emit(SuccessSpecializationFilter(specializationsList: specializations));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
