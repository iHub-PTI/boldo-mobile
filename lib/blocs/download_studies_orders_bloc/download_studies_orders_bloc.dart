import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/files_helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
part 'download_studies_orders_event.dart';
part 'download_studies_orders_state.dart';

class DownloadStudiesOrdersBloc extends Bloc<DownloadStudiesOrdersEvent, DownloadStudiesOrdersState> {

  DownloadStudiesOrdersBloc() : super(DownloadStudiesOrdersInitial()) {
    on<DownloadStudiesOrdersEvent>((event, emit) async {
      if (event is DownloadStudiesOrders) {
        emit(Loading());
        var _post;
        await Task(() => StudiesOrdersRepository.downloadStudiesOrders(studiesOrdersId: event.listOfIds))
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(msg: response));
        } else {
          late Uint8List file;
          _post.foldRight(Uint8List, (a, previous) => file = a);

          //open the file
          FilesHelpers.openFile(file: file, extension: '.pdf');
          emit(Success(file: file));
        }
      }
    });
  }

}