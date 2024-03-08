import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
part 'download_event.dart';
part 'download_state.dart';

abstract class DownloadBloc<E extends DownloadEvent, S extends DownloadState> extends Bloc<E, S> {

  DownloadBloc(S initialState) : super(initialState);

}
