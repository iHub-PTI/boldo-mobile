import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'homeNews_event.dart';
part 'homeNews_state.dart';

class HomeNewsBloc extends Bloc<HomeNewsEvent, HomeNewsState> {
  final UserRepository _patientRepository = UserRepository();
  HomeNewsBloc() : super(HomeNewsInitial()) {
    on<HomeNewsEvent>((event, emit) async {
      if(event is GetNews){
      emit(LoadingNews());
      var _post;
      await Task(() =>
      _patientRepository.getDiagnosticRecords()!)
          .attempt()
          .run()
          .then((value) {
        _post = value;
      }
      );
      var response;
      if (_post.isLeft()) {
        _post.leftMap((l) => response = l.message);
        emit(FailedLoadedNews(response: response));
      }else{
        late List<DiagnosticReport> diagnosticReports = [];
        _post.foldRight(DiagnosticReport, (a, previous) => diagnosticReports = a);

        diagnosticReports = diagnosticReports
            .where((element) => element.sourceID != patient.id).toList();
        emit(NewsLoaded(diagnosticReports: diagnosticReports));
      }
    }
    });
  }
}
