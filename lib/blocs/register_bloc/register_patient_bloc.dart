import 'dart:convert';
import 'dart:io';

import 'package:boldo/main.dart';
import 'package:boldo/models/User.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/filter/filter_screen.dart';
import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_patient_event.dart';
part 'register_patient_state.dart';

class PatientRegisterBloc extends Bloc<PatientRegisterEvent, PatientRegisterState> {
  final UserRepository _patientRepository = UserRepository();
  PatientRegisterBloc() : super(PatientRegisterInitial()) {
    on<PatientRegisterEvent>((event, emit) async {
      if(event is SendPatientPreliminaryProfilePressed) {
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.sendUserPreliminaryProfile(event.context)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        }else{
          emit(Success());
        }
      } else if(event is ValidatePatientPhonePressed){
        emit(Loading());
        final userHash = await generateHash(event.code);
        var _post;
        await Task(() =>
        _patientRepository.validateUserPhone(userHash, event.context)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        }else{
          emit(Success());
        }
      }else if(event is UploadPhoto){
        print("${event.urlUploadType} and ${event.image!.path}" );
        emit(Loading());
        String? isLogged = await storage.read(key: "access_token");
        var _post;
        _post = await getUrlFromServer(event, _post);
        var response;
        if(_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        }else {
          print("send image");
          await Task(() => _patientRepository.sendImagetoServer(
              event.urlUploadType, event.image!)!)
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            _post = value;
          });

          if (_post.isLeft()) {
            //image can't be uploaded to server or images don't match with user data
            _post.leftMap((l) => response = l.message);
            emit(Failed(response: response));
          } else {
            if (event.urlUploadType == UrlUploadType.selfie) {
              if (isLogged == null) {
                // all images was validated, send user's password to server and finish pre register
                _post = await sendPassword(_post);
                if (_post.isLeft()) {
                  //can't save user password in server
                  _post.leftMap((l) => response = l.message);
                  emit(Failed(response: response));
                } else {
                  // succefully inserted password in server, go to login screen, need access token [require webview login]
                  emit(Success());
                  // photoStage frontal again for a new patient registration
                  emit(SuccessPhotoUploaded(actualPhotoStage: UrlUploadType.frontal));

                  File(userImageSelected!.path).delete();
                  imageCache!.clearLiveImages();
                  imageCache!.clear();
                  await Future.delayed(const Duration(seconds: 2));
                  emit(NavigateNextAndDeleteUntilScreen(routeName: '/login', untilName: '/onboarding'));
                }
              } else {
                // all images was validated, and is and user logged.
                emit(Success());
                // photoStage frontal again for a new patient registration
                emit(SuccessPhotoUploaded(actualPhotoStage: UrlUploadType.frontal));

                File(userImageSelected!.path).delete();
                imageCache!.clearLiveImages();
                imageCache!.clear();
                await Future.delayed(const Duration(seconds: 2));
                emit(NavigateNextAndDeleteUntilScreen(routeName: '/familyTransition', untilName: '/methods'));
              }
            } else {
              // images was successfully sent to server proceed with take another image [dni or selfie]
              emit(Success());
              //show user screen confirmation
              await Future.delayed(const Duration(seconds: 3));
              emit(SuccessPhotoUploaded(
                  actualPhotoStage: event.urlUploadType == UrlUploadType.frontal
                      ? UrlUploadType.back
                      : UrlUploadType.selfie));
            }
          }
        }
      }
    }
    );
  }

  Future<String> generateHash(code) async {
    final String hash = code + user.phone ;
    var hashEncode = utf8.encode(hash);
    var hashGenerate = sha256.convert(hashEncode);
    await storage.write(key: "hash", value: '$hashGenerate');
    return '$hashGenerate';
  }

  Future<dynamic> getUrlFromServer(UploadPhoto event, _post) async {
    await Task(() => _patientRepository.getUrlFromServer(event.urlUploadType)!)
        .attempt()
        .mapLeftToFailure()
        .run()
        .then((value) {
      _post = value;
    });
    return _post;
  }

  Future<dynamic> sendPassword(_post) async {
    await Task(() => _patientRepository.sendUserPassword()!)
        .attempt()
        .mapLeftToFailure()
        .run()
        .then((value) {
      _post = value;
    });
    return _post;
  }

}