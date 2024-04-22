import 'dart:io';

import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'attach_study_order_event.dart';
part 'attach_study_order_state.dart';

/// Bloc patter to manage study order sending
class AttachStudyOrderBloc
    extends Bloc<AttachStudyOrderEvent, AttachStudyOrderState> {
  /// Consturctor of Bloc
  AttachStudyOrderBloc() : super(StudiesOrderInitial()) {
    on<AttachStudyOrderEvent>((event, emit) async {
      if (event is SendStudyToServer) {
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'POST',
          description: 'send files and diagnosticReport for a studyOrder',
          bindToScope: true,
        );
        emit(UploadingStudy());
        late Either<Failure, List<AttachmentUrl>> post;
        await Task(
          () => _ordersRepository.sendFiles(event.files)!,
        ).attempt().mapLeftToFailure().run().then((value) {
          post = value;
        });
        if (post.isLeft()) {
          final failure = post.asLeft();
          emit(FailedUploadFiles(response: failure.message));
          transaction.throwable = failure;
          await transaction.finish(
            status: SpanStatus.fromString(
              failure.message,
            ),
          );
        } else {
          late Either<Failure, None<dynamic>> post2;
          final attachmentUrls = post.asRight();

          final diagnosticReport = event.diagnosticReport
            ..attachmentUrls = attachmentUrls;
          await Task(
            () => _ordersRepository.sendDiagnosticReport(diagnosticReport)!,
          ).attempt().mapLeftToFailure().run().then((value) {
            post2 = value;
          });
          if (post2.isLeft()) {
            final failure = post2.asLeft();
            emit(FailedUploadFiles(response: failure.message));
            transaction.throwable = failure;
            await transaction.finish(
              status: SpanStatus.fromString(
                failure.message,
              ),
            );
          } else {
            emit(SendSuccess());
            await transaction.finish(
              status: const SpanStatus.ok(),
            );
          }
        }
      } else if (event is GetStudyFromServer) {
        final transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          bindToScope: true,
        );
        emit(LoadingStudies());
        late Either<Failure, ServiceRequest> post;
        await Task(
          () => _ordersRepository.getServiceRequestId(event.serviceRequestId)!,
        ).attempt().mapLeftToFailure().run().then((value) {
          post = value;
        });
        if (post.isLeft()) {
          final failure = post.asLeft();
          emit(FailedLoadedStudies(response: failure.message));
          transaction.throwable = failure;
          await transaction.finish(
            status: SpanStatus.fromString(
              failure.message,
            ),
          );
        } else {
          late ServiceRequest serviceRequest;
          serviceRequest = post.asRight();
          emit(StudyObtained(serviceRequest: serviceRequest));
          await transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    });
  }

  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
}
