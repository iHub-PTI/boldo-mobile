import 'dart:io';

import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'attachStudyOrder_event.dart';
part 'attachStudyOrder_state.dart';

class AttachStudyOrderBloc extends Bloc<AttachStudyOrderEvent, AttachStudyOrderState> {
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
  AttachStudyOrderBloc() : super(StudiesOrderInitial()) {
    on<AttachStudyOrderEvent>((event, emit) async {
      if (event is SendStudyToServer) {
        emit(UploadingStudy());
        var _post;
        await Task(() =>
        _ordersRepository.sendFiles(event.files)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedUploadFiles(response: response));
        } else {
          var _post2;
          late List<AttachmentUrl> attachmentUrls;
          _post.foldRight(AttachmentUrl, (a, previous) => attachmentUrls = a);
          DiagnosticReport diagnosticReport = event.diagnosticReport;
          diagnosticReport.attachmentUrls = attachmentUrls;
          await Task(() =>
          _ordersRepository.sendDiagnosticReport(
              diagnosticReport)!)
              .attempt()
              .run()
              .then((value) {
            _post2 = value;
          });
          if (_post2.isLeft()) {
            _post.leftMap((l) => response = l.message);
            emit(FailedUploadFiles(response: response));
          } else {
            emit(SendSuccess());
          }
        }
      }else if(event is GetStudyFromServer){
        emit(UploadingStudy());
        var _post;
        await Task(() =>
        _ordersRepository.getServiceRequestId(event.serviceRequestId)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedUploadFiles(response: response));
        } else {
          late ServiceRequest serviceRequest;
          _post.foldRight(ServiceRequest, (a, previous) => serviceRequest = a);
          emit(StudyObtained(serviceRequest: serviceRequest));
        }
      }
    });
  }
}
