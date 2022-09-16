import 'dart:convert';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Specialization.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'auth_provider.dart';

class UtilsProvider with ChangeNotifier {
  List<Specialization> _selectedSpecializations = [];
  List<String> _selectedLanguages = [];
  String _filterText = "";
  int _selectedPageIndex = 0;
  bool isAppoinmentOnline = false;
  bool isAppoinmentInPerson = false;
  int get getSelectedPageIndex => _selectedPageIndex;
  List<Specialization> get getListOfSpecializations => _selectedSpecializations;
  List<String> get getListOfLanguages => _selectedLanguages;
  int _filterCounter = -1;
  bool get getFilterState =>
      _selectedLanguages.isNotEmpty ||
      _selectedSpecializations.isNotEmpty ||
      isAppoinmentOnline ||
      isAppoinmentInPerson;
  String get getFilterText => _filterText;
  int get getFilterCounter => _filterCounter;

  void setFilterText(String filterText) {
    _filterText = filterText;
  }

  void setSelectedPageIndex({required int pageIndex}) {
    _selectedPageIndex = pageIndex;

    notifyListeners();
  }

  void clearText() {
    _filterText = "";
  }

  void setListOfSpecializations(
      {required List<Specialization> selectedFilters}) {
    _selectedSpecializations = selectedFilters;
    getDoctors();
    notifyListeners();
  }

  void removeSpecialization({required String specializationId}) {
    _selectedSpecializations = _selectedSpecializations
        .where((element) => element.id != specializationId)
        .toList();
    getDoctors();
    notifyListeners();
  }

  void addLanguageValue(String languageValue) {
    _selectedLanguages = [..._selectedLanguages, languageValue];
    getDoctors();
    notifyListeners();
  }

  void setVirtualRemoteStatus(bool isInPerson, bool isOnline) {
    isAppoinmentOnline = isOnline;
    isAppoinmentInPerson = isInPerson;
    getDoctors();
    notifyListeners();
  }

  void removeLanguageValue(String languageValue) {
    _selectedLanguages =
        _selectedLanguages.where((e) => e != languageValue).toList();
    getDoctors();
    notifyListeners();
  }

  void clearFilters() {
    _selectedLanguages = [];
    _selectedSpecializations = [];
    isAppoinmentOnline = false;
    isAppoinmentInPerson = false;
    _filterCounter = -1;
    notifyListeners();
  }

  void getDoctors({int offset = 0}) async {
    try {
      List<String>? listOfSpecializations =
          getListOfSpecializations.map((e) => e.id!).toList();
      String queryStringLanguages =
          Uri(queryParameters: {'languageCodes': _selectedLanguages}).query;
      String queryStringSpecializations =
          Uri(queryParameters: {'specialtyIds': listOfSpecializations}).query;

      String finalQueryString = "";

      if (queryStringLanguages != "") {
        finalQueryString = "$finalQueryString&$queryStringLanguages";
      }
      if (queryStringSpecializations != "") {
        finalQueryString = "$finalQueryString&$queryStringSpecializations";
      }

      String appointmentType = "";
      if (isAppoinmentOnline == true && isAppoinmentInPerson == true) {
        appointmentType = Uri(queryParameters: {"appointmentType": "AV"}).query;
      } else if (isAppoinmentOnline) {
        appointmentType = Uri(queryParameters: {"appointmentType": "V"}).query;
      } else if (isAppoinmentInPerson) {
        appointmentType =
            "${Uri(queryParameters: {"appointmentType": "A"}).query}";
      }

      if (appointmentType != "") {
        finalQueryString = "$finalQueryString&$appointmentType";
      }
      String queryStringOther =
          Uri(queryParameters: {"offset": offset.toString(), "count": "20"})
              .query;
      finalQueryString = "$finalQueryString&$queryStringOther";
      Response response = await dio.get("/doctors?$finalQueryString");
      if (response.statusCode == 200) {
        List<Doctor> doctorsList = List<Doctor>.from(
            response.data['items'].map((i) => Doctor.fromJson(i)));
        _filterCounter = doctorsList.length;
      }
    } on DioError catch (exception, stackTrace) {
      print(exception);
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
    notifyListeners();
  }

  void logout(BuildContext context) async {
    try {
      String baseUrlKeyCloack = String.fromEnvironment(
          'KEYCLOAK_REALM_ADDRESS',
          defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);

      const storage = FlutterSecureStorage();
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();
      String? refreshToken =
      await storage.read(key: "refresh_token");
      Map<String, dynamic> body = {
        "refresh_token": refreshToken??'',
        "client_id": "boldo-patient"
      };
      var url = Uri.parse(
          "$baseUrlKeyCloack/protocol/openid-connect/logout");
      await http.post(url,
          body: body,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded"
          },
          encoding: Encoding.getByName("utf-8"));
      Provider.of<AuthProvider>(context, listen: false)
          .setIsFamily(isFamily: false);
      Provider.of<AuthProvider>(context, listen: false)
          .setAuthenticated(isAuthenticated: false);
      Provider.of<UserProvider>(context, listen: false)
          .clearProvider();
      await prefs.setBool("onboardingCompleted", false);
      await storage.deleteAll();
      await prefs.clear();

      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (Route<dynamic> route) => false);
    } on DioError catch (exception, stackTrace) {
      print(exception);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

}
