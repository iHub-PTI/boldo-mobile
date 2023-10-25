import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'goToTop_event.dart';
part 'goToTop_state.dart';

class GoToTopBloc extends Bloc<GoToTopEvent, GoToTopState> {
  GoToTopBloc() : super(GoToTopInitial()) {
    on<GoToTopEvent>((event, emit) async {
      if (event is GoToTopVisibility) {
        emit(GoToTopShow(show: event.show));
      }
    });
  }
}
