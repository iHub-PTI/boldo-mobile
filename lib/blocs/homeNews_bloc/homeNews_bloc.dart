import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/News.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'homeNews_event.dart';
part 'homeNews_state.dart';

class HomeNewsBloc extends Bloc<HomeNewsEvent, HomeNewsState> {
  final UserRepository _patientRepository = UserRepository();
  List<News> news = [];

  HomeNewsBloc() : super(HomeNewsInitial()) {
    on<HomeNewsEvent>((event, emit) async {
      if(event is GetNews){
        emit(LoadingNews());
        news = [];
        var _post;
        var _post2;

        // get diagnostic reports
        await Task(() =>
        _patientRepository.getDiagnosticRecords()!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        }
        );

        //get appointments
        await Task(() =>
        _patientRepository.getAppointments()!)
            .attempt()
            .run()
            .then((value) {
          _post2 = value;
        }
        );
        
        var response;

        // verify is failed to get appointments
        if (_post2.isLeft()) {
          _post2.leftMap((l) => response = l.message);
          emit(FailedLoadedNews(response: response));
        }else{
          late List<Appointment> appointments = [];
          _post2.foldRight(Appointment, (a, previous) => appointments = a);
          // sort appointment by date
          appointments.sort((a, b) =>
              DateTime.parse(a.start!).compareTo(DateTime.parse(b.start!)));

          // Clear appointments where appointment is not open
          appointments = appointments
              .where((element) =>
          !["closed", "locked", "cancelled"].contains(element.status))
              .toList();

          // add appointments to news
          news = [...news, ...appointments];
        }

        // verify is failed to get diagnostic reports
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadedNews(response: response));
        }else{
          late List<DiagnosticReport> diagnosticReports = [];
          _post.foldRight(DiagnosticReport, (a, previous) => diagnosticReports = a);
          // add only diagnosticReport that were not uploaded by the patient
          diagnosticReports = diagnosticReports
              .where((element) => element.sourceID != patient.id).toList();

          // add diagnosticReport to news
          news = [...news, ...diagnosticReports];
        }

        // emit news
        emit(NewsLoaded(news: news));
      }if(event is DeleteNews){

        news = news.where((element) => element != event.news).toList();

        emit(NewsLoaded(news: news));
      }
    });
  }
}
