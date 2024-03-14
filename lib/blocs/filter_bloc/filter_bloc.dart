import 'package:boldo/models/filters/Filter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'filter_event.dart';
part 'filter_state.dart';

abstract class FilterBloc <E extends FilterEvent, S extends FilterState> extends Bloc<E, S> {

  FilterBloc(S initialState) : super(initialState) ;
}
