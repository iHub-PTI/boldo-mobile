import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/dashboard/tabs/components/custom_search.dart';
import 'package:boldo/screens/filter/filter_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../constants.dart';
import '../../booking/booking_screen.dart';
import '../../doctor_profile/doctor_profile_screen.dart';
import '../../../models/Doctor.dart';
import '../../../network/http.dart';
import '../../../utils/helpers.dart';

class DoctorsTab extends StatefulWidget {
  DoctorsTab({Key key}) : super(key: key);

  @override
  _DoctorsTabState createState() => _DoctorsTabState();
}

class _DoctorsTabState extends State<DoctorsTab> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Doctor> doctors = [];
  bool _loading = true;

  @override
  void initState() {
    Provider.of<UtilsProvider>(context, listen: false).clearText();
    getDoctors();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getDoctors({int offset = 0}) async {
    try {
      if (!mounted) return;
      if (offset == 0) {
        setState(() {
          _loading = true;
        });
      }
      String text =
          Provider.of<UtilsProvider>(context, listen: false).getFilterText;
      List<String> listOfLanguages =
          Provider.of<UtilsProvider>(context, listen: false).getListOfLanguages;
      List<String> listOfSpecializations =
          Provider.of<UtilsProvider>(context, listen: false)
              .getListOfSpecializations
              .map((e) => e.description)
              .toList();

      String queryStringLanguages =
          Uri(queryParameters: {'content': listOfLanguages}).query;
      String queryStringSpecializations =
          Uri(queryParameters: {'content': listOfSpecializations}).query;
      String queryStringOther = Uri(queryParameters: {
        if (text != "") ...{"content": text},
        "offset": offset.toString(),
        "count": "20"
      }).query;

      String finalQueryString = queryStringOther;
      if (queryStringLanguages != "") {
        finalQueryString = "$finalQueryString&$queryStringLanguages";
      }
      if (queryStringSpecializations != "") {
        finalQueryString = "$finalQueryString&$queryStringSpecializations";
      }

      Response response = await dio.get("/doctors?$finalQueryString");

      if (!mounted) return;
      if (response.statusCode == 200) {
        List<Doctor> doctorsList = List<Doctor>.from(
            response.data['items'].map((i) => Doctor.fromJson(i)));
        if (!mounted) return;
        if (offset == 0) {
          doctors = doctorsList;
        } else {
          doctors = [...doctors, ...doctorsList];
        }
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

      ///FIXME: SHOW AN ERROR MESSAGE TO THE USER

    } finally {
      if (mounted) {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () async {
              final updateDoctors = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilterScreen(),
                ),
              );
              if (updateDoctors != null && updateDoctors) {
                getDoctors();
              }
            },
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SvgPicture.asset('assets/icon/filter.svg'),
                  ),
                ),
                Selector<UtilsProvider, bool>(
                  selector: (buildContext, userProvider) =>
                      userProvider.getFilterState,
                  builder: (_, data, __) {
                    if (data) {
                      return Positioned(
                        right: 13,
                        top: 13,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 9,
                            minHeight: 9,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          )
        ],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text("Médicos",
                  style: boldoHeadingTextStyle.copyWith(fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: CustomSearchBar(changeTextCallback: (text) {
                Provider.of<UtilsProvider>(context, listen: false)
                    .setFilterText(text);
                getDoctors(offset: 0);
              }),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor: Constants.primaryColor600,
                    ))
                  : doctors.isEmpty
                      ? const Center(
                          child: Text(
                          "No se encontraron doctores",
                        ))
                      : SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
                          footer: CustomFooter(
                            builder: (BuildContext context, LoadStatus mode) {
                              Widget body = Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_upward,
                                    color: Constants.extraColor300,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Sube para cargar más",
                                    style: TextStyle(
                                      color: Constants.extraColor300,
                                    ),
                                  )
                                ],
                              );
                              if (mode == LoadStatus.loading) {
                                body = const CircularProgressIndicator();
                              }
                              return Container(
                                height: 55.0,
                                child: Center(child: body),
                              );
                            },
                          ),
                          header: const MaterialClassicHeader(
                            color: Constants.primaryColor800,
                          ),
                          controller: _refreshController,
                          onLoading: () {
                            getDoctors(offset: doctors.length);
                          },
                          onRefresh: () {
                            getDoctors(offset: 0);
                          },
                          child: ListView.builder(
                            itemCount: doctors.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _DoctorCard(doctor: doctors[index]);
                            },
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    Key key,
    @required this.doctor,
  }) : super(key: key);

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    String availabilityText = "Sin disponibilidad en los próximos 30 días";
    bool isToday = false;
    if (doctor.nextAvailability != null) {
      DateTime parsedAvailability =
          DateTime.parse(doctor.nextAvailability).toLocal();
      int daysDifference = parsedAvailability.difference(DateTime.now()).inDays;

      isToday = daysDifference == 0;

      if (isToday) {
        availabilityText = "Disponible Hoy!";
      } else if (daysDifference > 0) {
        availabilityText =
            "Disponible ${DateFormat('EEEE, dd MMMM').format(parsedAvailability)}";
      }
    }

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: doctor.photoUrl == null
                        ? SvgPicture.asset(
                            doctor.gender == "female"
                                ? 'assets/images/femaleDoctor.svg'
                                : 'assets/images/maleDoctor.svg',
                            fit: BoxFit.cover)
                        : CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: doctor.photoUrl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Padding(
                              padding: const EdgeInsets.all(26.0),
                              child: LinearProgressIndicator(
                                value: downloadProgress.progress,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Constants.primaryColor400),
                                backgroundColor: Constants.primaryColor600,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            "${getDoctorPrefix(doctor.gender)}${doctor.familyName}",
                            maxLines: 1,
                            softWrap: false,
                            style: boldoHeadingTextStyle,
                          ),
                        ),
                        if (doctor.specializations != null &&
                            doctor.specializations.isNotEmpty)
                          Row(
                            children: [
                              for (int i = 0;
                                  i < doctor.specializations.length;
                                  i++)
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: i == 0 ? 0 : 3.0),
                                  child: Text(
                                    "${doctor.specializations[i].description}${doctor.specializations.length > 1 && i == 0 ? "," : ""}",
                                    style: boldoSubTextStyle,
                                  ),
                                ),
                            ],
                          ),
                        Text(availabilityText,
                            style: boldoSubTextStyle.copyWith(
                                fontSize: 12,
                                color: isToday
                                    ? Constants.primaryColor600
                                    : Constants.secondaryColor500))
                      ]),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xffE5E7EB),
          ),
          Container(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorProfileScreen(doctor: doctor),
                          ),
                        );
                      },
                      child: const Text(
                        'Ver Perfil',
                        style: boldoHeadingTextStyle,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: 1,
                  color: const Color(0xffE5E7EB),
                ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(doctor: doctor),
                          ),
                        );
                      },
                      child: const Text(
                        'Reservar',
                        style: boldoHeadingTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
