import 'dart:async';

import 'package:boldo/models/ValueEmitter.dart';
import 'package:boldo/utils/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late AppConfig appConfig ;

class AppConfig {
  final envFile;

  AppConfig({required this.envFile});

  /// Loads environment variables from the [envFile]
  Future<void> init() async {

    DotEnv envApp = DotEnv();

    await envApp.load(fileName: envFile);

    if(envApp.maybeGet("APP_URL_DOWNLOAD") == null){
      throw Exception("APP_URL_DOWNLOAD is not defined");
    }

    APP_URL_DOWNLOAD = String.fromEnvironment(
        'APP_URL_DOWNLOAD',
        defaultValue: envApp.env['APP_URL_DOWNLOAD']!
    );

    if(envApp.maybeGet("DEFAULT_APP_URL_DOWNLOAD") == null){
      throw Exception("DEFAULT_APP_URL_DOWNLOAD is not defined");
    }

    DEFAULT_APP_URL_DOWNLOAD = String.fromEnvironment(
        'DEFAULT_APP_URL_DOWNLOAD',
        defaultValue: envApp.env['DEFAULT_APP_URL_DOWNLOAD']!
    );

    if(envApp.maybeGet("LAST_STABLE_VERSION") == null){
      throw Exception("LAST_STABLE_VERSION is not defined");
    }

    LAST_STABLE_VERSION = String.fromEnvironment(
        'LAST_STABLE_VERSION',
        defaultValue: envApp.env['LAST_STABLE_VERSION']!
    );

    if(envApp.maybeGet("LAST_AVAILABLE_VERSION") == null){
      throw Exception("LAST_AVAILABLE_VERSION is not defined");
    }

    LAST_AVAILABLE_VERSION = String.fromEnvironment(
        'LAST_AVAILABLE_VERSION',
        defaultValue: envApp.env['LAST_AVAILABLE_VERSION']?? ""
    );

    if(envApp.maybeGet("ALL_DOCTORS_PAGE_COUNT") == null){
      throw Exception("ALL_DOCTORS_PAGE_COUNT is not defined");
    }

    ALL_DOCTORS_PAGE_COUNT = int.tryParse(
      String.fromEnvironment(
        'ALL_DOCTORS_PAGE_COUNT',
        defaultValue: envApp.env['ALL_DOCTORS_PAGE_COUNT']?? ""
      ),
    )?? 20;

    if(kReleaseMode){
      if(envApp.maybeGet("TRACE_RATE_ERROR") == null){
        throw Exception("TRACE_RATE_ERROR is not defined");
      }

      TRACE_RATE_ERROR = double.tryParse(
        String.fromEnvironment(
          'TRACE_RATE_ERROR',
          defaultValue: envApp.env['TRACE_RATE_ERROR']?? ""
        ),

      );
    }

    if(envApp.maybeGet("ACCESS_ADD_DEPENDENT_CI") == null){
      throw Exception("ACCESS_ADD_DEPENDENT_CI is not defined");
    }

    ACCESS_ADD_DEPENDENT_CI = bool.fromEnvironment(
        'ACCESS_ADD_DEPENDENT_CI',
        defaultValue: envApp.env['ACCESS_ADD_DEPENDENT_CI']!.parseBool()
    );

    if(envApp.maybeGet("ACCESS_ADD_DEPENDENT_QR") == null){
      throw Exception("ACCESS_ADD_DEPENDENT_QR is not defined");
    }

    ACCESS_ADD_DEPENDENT_QR = bool.fromEnvironment(
        'ACCESS_ADD_DEPENDENT_QR',
        defaultValue: envApp.env['ACCESS_ADD_DEPENDENT_QR']!.parseBool()
    );

    if(envApp.maybeGet("ACCESS_ADD_DEPENDENT_WITHOUT_CI") == null){
      throw Exception("ACCESS_ADD_DEPENDENT_WITHOUT_CI is not defined");
    }

    print(bool.fromEnvironment(
        'ACCESS_ADD_DEPENDENT_CI',
        defaultValue: envApp.env['ACCESS_ADD_DEPENDENT_CI']!.parseBool()
    ));

    ACCESS_ADD_DEPENDENT_WITHOUT_CI = bool.fromEnvironment(
        'ACCESS_ADD_DEPENDENT_WITHOUT_CI',
        defaultValue: envApp.env['ACCESS_ADD_DEPENDENT_WITHOUT_CI']!.parseBool()
    );

  }

  ValueEmitter<String> TIMEOUT_MESSAGE_DOWNLOAD_FILES = ValueEmitter(
    value: "El servicio tardó demasiado en responder, procure seleccionar menos archivos",
  );
  ValueEmitter<int> RECIVE_TIMEOUT_MILLISECONDS_DOWNLOAD_FILES = ValueEmitter(
    value: 1000,
  );

  ValueEmitter<int> ALL_PHARMACIES_PAGE_SIZE = ValueEmitter(
    value: 20,
  );

  // stream controllers to update values
  StreamController<String> _appUrlDownloadController = StreamController<String>.broadcast();
  StreamController<String> _defaultAppUrlDownloadController = StreamController<String>.broadcast();
  StreamController<String> _lastStableVersionController = StreamController<String>.broadcast();
  StreamController<String> _lastAvailableVersionController = StreamController<String>.broadcast();
  StreamController<double> _traceRateErrorController = StreamController<double>.broadcast();
  StreamController<int> _allDoctorsPageCountController = StreamController<int>.broadcast();
  StreamController<bool> _accessAddDependentCIController = StreamController<bool>.broadcast();
  StreamController<bool> _accessAddDependentQRController = StreamController<bool>.broadcast();
  StreamController<bool> _accessAddDependentWithoutCIController = StreamController<bool>.broadcast();

  // streams to emit values to listeners
  Stream<String> get streamAppUrlDownload => _appUrlDownloadController.stream;
  Stream<String> get streamDefaultAppUrlDownload => _defaultAppUrlDownloadController.stream;
  Stream<String> get streamLastStableVersion => _lastStableVersionController.stream;
  Stream<String> get streamLastAvailableVersion => _lastAvailableVersionController.stream;
  Stream<double> get streamTraceRateError => _traceRateErrorController.stream;
  Stream<int> get streamAllDoctorsPageCount => _allDoctorsPageCountController.stream;
  Stream<bool> get streamAccessAddDependentCI => _accessAddDependentCIController.stream;
  Stream<bool> get streamAccessAddDependentQR => _accessAddDependentQRController.stream;
  Stream<bool> get streamAccessAddDependentWithoutCI => _accessAddDependentWithoutCIController.stream;

  void updateAppUrlDownloadValue(String value){
    APP_URL_DOWNLOAD = value;
    _appUrlDownloadController.sink.add(value);
  }

  void updateDefaultAppUrlDownloadValue(String value){
    DEFAULT_APP_URL_DOWNLOAD = value;
    _defaultAppUrlDownloadController.sink.add(value);
  }

  void updateLastStableVersionValue(String value){
    LAST_STABLE_VERSION = value;
    _lastStableVersionController.sink.add(value);
  }

  void updateLastAvailableVersionValue(String value){
    LAST_AVAILABLE_VERSION = value;
    _lastAvailableVersionController.sink.add(value);
  }

  void updateTraceRateErrorValue(double value){
    TRACE_RATE_ERROR = value;
    _traceRateErrorController.sink.add(value);
  }

  void updateAllDoctorsPageCountValue(int value){
    ALL_DOCTORS_PAGE_COUNT = value;
    _allDoctorsPageCountController.sink.add(value);
  }

  void updateAccessAddDependentCIValue(bool value){
    ACCESS_ADD_DEPENDENT_CI = value;
    _accessAddDependentCIController.sink.add(value);
  }

  void updateAccessAddDependentQRValue(bool value){
    ACCESS_ADD_DEPENDENT_QR = value;
    _accessAddDependentQRController.sink.add(value);
  }

  void updateAccessAddDependentWithoutCIValue(bool value){
    ACCESS_ADD_DEPENDENT_WITHOUT_CI = value;
    _accessAddDependentWithoutCIController.sink.add(value);
  }

  /// This value can change remotely, you must be subscribe to [streamAppUrlDownload]
  /// to listen changes dynamically
  late String APP_URL_DOWNLOAD;

  /// This value can change remotely, you must be subscribe to [streamAppUrlDownload]
  /// to listen changes dynamically
  late String DEFAULT_APP_URL_DOWNLOAD;

  /// This value can change remotely, you must be subscribe to [streamLastStableVersion]
  /// to listen changes dynamically
  late String LAST_STABLE_VERSION;

  /// This value can change remotely, you must be subscribe to [streamLastAvailableVersion]
  /// to listen changes dynamically
  late String LAST_AVAILABLE_VERSION;

  /// This value can change remotely, you must be subscribe to [streamTraceRateError]
  /// to listen changes dynamically
  double? TRACE_RATE_ERROR;

  /// This value can change remotely, you must be subscribe to [streamAllDoctorsPageCount]
  /// to listen changes dynamically
  late int ALL_DOCTORS_PAGE_COUNT;

  late bool ACCESS_ADD_DEPENDENT_CI = true;

  late bool ACCESS_ADD_DEPENDENT_QR = true;

  late bool ACCESS_ADD_DEPENDENT_WITHOUT_CI = true;

}