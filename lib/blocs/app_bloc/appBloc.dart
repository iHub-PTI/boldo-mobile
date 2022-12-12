
import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/network/app_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/screens/splashScreen/splashLoading.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



part 'appEvent.dart';
part 'appState.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository _patientRepository = AppRepository();

  // remote type
  bool _updateAvailable = prefs.getBool("updateAvailable")?? false;

  bool getUpdateAvailable() => _updateAvailable;

  void setUpdateAvailable(bool available) {
    _updateAvailable = available;
  }

  AppBloc() : super(AppInitial()) {
    on<AppEvent>((event, emit) async {
      if(event is GetUpdateAvailable){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.validateAppVersion()!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late bool newVersion;
          _post.foldRight(
              bool, (a, previous) => newVersion = a);

          // check is a new version is true
          if(newVersion) {
            // navigate to screen to notify a new version
            navKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => const UpdateScreen(),
              ),
            );
            // TODO: close all Bloc
            // close others Bloc individually
            BlocProvider.of<PatientBloc>(navKey.currentState!.context).close();
          }


          emit(Success());
        }
      }
    }

    );
  }
}
