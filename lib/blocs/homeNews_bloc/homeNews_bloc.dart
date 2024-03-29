import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/News.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'homeNews_event.dart';
part 'homeNews_state.dart';

class HomeNewsBloc extends Bloc<HomeNewsEvent, HomeNewsState> {
  final UserRepository _patientRepository = UserRepository();
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
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
        _ordersRepository.getStudiesOrders()!)
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

          // date limit to show Appointment before this date
          // day + 1 in applied for appointments with startDate dd/mm/aaaa hh:nn
          // and the filter is dd/mm/aaaa 00:00, the limit date is under startDate
          // by a few hours, but is at the same date, in this case the limit must
          // be dd+1/mm/aaaa 00:00 to filter before or equal to dd/mm/aaaa
          DateTime timeLimitSup = DateTime(
            DateTime.now().year,
            DateTime.now().month + timeToShowAppointmentsOnHoldInMonth,
            DateTime.now().day + 1,
          );

          // Clear appointments where appointment before the timeLimitSup
          appointments = appointments
              .where((element) {

                DateTime appointmentDate = DateTime(
                  DateTime.parse(element.start!).toLocal().year,
                  DateTime.parse(element.start!).toLocal().month,
                  DateTime.parse(element.start!).toLocal().day,
                );

                return appointmentDate.isBefore(timeLimitSup);

          }
          ).toList();

          // add appointments to news
          news = [...news, ...appointments];
        }

        // verify is failed to get diagnostic reports
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadedNews(response: response));
        }else{
          late List<StudyOrder> studiesOrders = [];
          _post.foldRight(StudyOrder, (a, previous) => studiesOrders = a);

          // sort studiesOrders by descending date
          studiesOrders.sort((a, b) =>
              DateTime.parse(b.authoredDate?? DateTime.now().toString())
                  .compareTo(DateTime.parse(a.authoredDate?? DateTime.now().toString())));

          // date limit to show StudyOrder after this date
          DateTime timeLimitInf = DateTime(
            DateTime.now().year,
            DateTime.now().month - timeToShowStudyOrderInMonth,
            DateTime.now().day,
          );

          // Clear appointments where appointment after the timeLimitInf
          studiesOrders = studiesOrders
              .where((element)
          => DateTime.parse(element.authoredDate!).toLocal().isAfter(timeLimitInf)
          ).toList();

          // add diagnosticReport to news
          news = [...news, ...studiesOrders];
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
