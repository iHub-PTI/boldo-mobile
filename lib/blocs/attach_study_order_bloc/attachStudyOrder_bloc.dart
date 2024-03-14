import 'dart:io';

import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'attachStudyOrder_event.dart';
part 'attachStudyOrder_state.dart';

class AttachStudyOrderBloc extends Bloc<AttachStudyOrderEvent, AttachStudyOrderState> {
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
  AttachStudyOrderBloc() : super(StudiesOrderInitial()) {
    on<AttachStudyOrderEvent>((event, emit) async {
      if (event is SendStudyToServer) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'POST',
          description: 'send files and diagnosticReport for a studyOrder',
          bindToScope: true,
        );
        emit(UploadingStudy());
        var _post;
        await Task(() =>
        _ordersRepository.sendFiles(event.files)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedUploadFiles(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
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
              .mapLeftToFailure()
              .run()
              .then((value) {
            _post2 = value;
          });
          if (_post2.isLeft()) {
            _post2.leftMap((l) => response = l.message);
            emit(FailedUploadFiles(response: response));
            transaction.throwable = _post2.asLeft();
            transaction.finish(
              status: SpanStatus.fromString(
                _post.asLeft().message,
              ),
            );
          } else {
            emit(SendSuccess());
            transaction.finish(
              status: const SpanStatus.ok(),
            );
          }
        }
      }else if(event is GetStudyFromServer){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          bindToScope: true,
        );
        emit(LoadingStudies());
        var _post;
        await Task(() =>
        _ordersRepository.getServiceRequestId(event.serviceRequestId)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedLoadedStudies(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late ServiceRequest serviceRequest;
          _post.foldRight(ServiceRequest, (a, previous) => serviceRequest = a);
          emit(StudyObtained(serviceRequest: serviceRequest));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    });
  }
}
