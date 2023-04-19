import 'dart:convert';

import 'package:boldo/main.dart';
import 'package:boldo/network/passport_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


part 'passportEvent.dart';
part 'passportState.dart';

class PassportBloc extends Bloc<PassportEvent, PassportState> {
  final PassportRepository _passportRepository = PassportRepository();

  PassportBloc(): super(PassportInitial()) {
    on<PassportEvent>((event, emit) async{
      if (event is GetUserDiseaseList) {
        emit(Loading());
        var _post;
        await Task(() => _passportRepository.getUserDiseaseList(false)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          emit(Success());
        }
      } else if (event is GetUserDiseaseListSync) {
          emit(Loading());
          var _post;
          await Task(() => _passportRepository.getUserDiseaseList(true)!)
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            _post = value;
          });
          var response;
          if (_post.isLeft()) {
            _post.leftMap((l) => response = l.message);
            emit(Failed(response: response));
          } else {
            emit(Success());
          }
      } else if (event is GetUserVaccinationPdfPressed) {
        emit(Loading());
        var _post;
        await Task(() => _passportRepository.downloadVacinnationPdf(event.pdfFromHome)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          emit(Success());
        }
      } else if(event is GetUserQrCode) {
        try {
          final url = await generateHash();
          emit(QrUrlLoaded(url));
        } catch (e) {
          emit(Failed(response: 'No fue posible generar el código qr'));
        }
      }
    });
  }
  Future<String> generateHash() async {
    String urlQrFinal = "";
    String userIdentifier = "";
    String diseaseCode = "";
    String version = "";
    String baseUrl = String.fromEnvironment('SERVER_ADDRESS_PASSPORT',
        defaultValue: dotenv.env['SERVER_ADDRESS_PASSPORT']!);
    if (vaccineListQR!.length == 1) {
      diseaseCode = vaccineListQR![0].diseaseCode;
      version = vaccineListQR![0].version.toString();
      userIdentifier = patient.identifier!;

      final String hash =
          version + userIdentifier + diseaseCode + 'banana'.trim();
      var hashEncode = utf8.encode(hash);
      var hashGenerate = sha256.convert(hashEncode);
      urlQrFinal = "${baseUrl}healthPassport/vaccinationRegistry/$hashGenerate".trim();
    } // in this case we have to generate the QR for all vaccine
    else if (vaccineListQR!.length == diseaseUserList!.length) {
      // empty array to send
      //List<String> hash = [];
      // in this case we need all vaccine
      bool all = true;
      var verificationCode = await _passportRepository.postVerificationCode(all, []);
      urlQrFinal = "${baseUrl}healthPassport/vaccinationRegistry/$verificationCode".trim();
    } // in this case we have to generate the QR for some vaccines
    else if (vaccineListQR!.length > 1 &&
        vaccineListQR!.length < diseaseUserList!.length) {
      // string that will contain each hash
      String hash = "";
      // this will be contain the list of hashes for each vaccine
      List<String> listHashes = [];
      // we need to generate hash for each vaccine
      for (var i = 0; i < vaccineListQR!.length; i++) {
        diseaseCode = vaccineListQR![i].diseaseCode;
        version = vaccineListQR![i].version.toString();
        userIdentifier = patient.identifier!;
        hash = version + userIdentifier + diseaseCode + 'banana'.trim();
        // the next two lines change for each instance
        var hashEncode = utf8.encode(hash);
        var hashGenerate = sha256.convert(hashEncode).toString();
        // add new hash to the list
        listHashes.add(hashGenerate);
      }
      // in this case we don't need all vaccine
      bool all = false;
      var verificationCode = await _passportRepository.postVerificationCode(all, listHashes);
      urlQrFinal = "${baseUrl}healthPassport/vaccinationRegistry/$verificationCode".trim();
    }
    return urlQrFinal;
  }
}
