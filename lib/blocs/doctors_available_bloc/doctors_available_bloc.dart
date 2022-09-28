import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'doctors_available_event.dart';
part 'doctors_available_state.dart';

class DoctorsAvailableBloc
    extends Bloc<DoctorsAvailableEvent, DoctorsAvailableState> {
  DoctorsAvailableBloc() : super(DoctorsAvailableInitial()) {
    on<DoctorsAvailableEvent>((event, emit) async {
      if (event is GetDoctorsAvailable) {

      } else if (event is ReloadDoctorsAvailable) {

      }
    });
  }
}
