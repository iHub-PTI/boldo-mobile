import 'package:boldo/blocs/filter_bloc/filter_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'filter_prescription_event.dart';
part 'filter_prescription_state.dart';

class FilterPrescriptionBloc extends FilterBloc<FilterEvent, FilterState> {

  FilterPrescriptionBloc() : super(FilterInitial()) {
    on<FilterEvent>(_filterEvent);
  }

  Future<void> _filterEvent(event, emit)async {
    emit(Loading());
  }

}
