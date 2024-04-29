import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/organization_helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../main.dart';


part 'doctor_event.dart';
part 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  DoctorBloc() : super(DoctorInitial()) {
    on<DoctorEvent>((event, emit) async {
      if(event is GetAvailability) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get doctor availability for booking an appointment in profile',
          bindToScope: true,
        );
        emit(Loading());
        late Either<Failure,List<OrganizationWithAvailabilities>> _post;
        await Task(() =>
        _doctorRepository.getAvailabilities(
            id: event.id,
            startDate: event.startDate,
            endDate: event.endDate,
            organizations: event.organizations,
        )!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        }
        );
        if (_post.isLeft()) {
          final failure = _post.asLeft();
          emit(Failed(response: failure.message));
          transaction.throwable = failure;
          transaction.finish(
            status: SpanStatus.fromString(
              failure.message,
            ),
          );
        }else{
          late List<OrganizationWithAvailabilities> nextAvailability = [];
          nextAvailability = _post.asRight();

          nextAvailability.sort(orderByAvailabilities);

          emit(AvailabilitiesObtained(availabilities: nextAvailability));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
