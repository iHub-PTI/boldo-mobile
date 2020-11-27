import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/dashboard/tabs/components/custom_search.dart';
import 'package:boldo/screens/filter/filter_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
  List<Doctor> doctors = [];
  bool loading = true;
  bool _mounted;

  @override
  void initState() {
    _mounted = true;
    getDoctors();
    super.initState();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void getDoctors({String text = ""}) async {
    try {
      setState(() {
        loading = true;
      });
      List<String> listOfLanguages =
          Provider.of<UtilsProvider>(context, listen: false).getListOfLanguages;
      List<String> listOfSpecializations =
          Provider.of<UtilsProvider>(context, listen: false)
              .getListOfSpecializations
              .map((e) => e.id)
              .toList();

      Response response = await dio.get("/doctors", queryParameters: {
        'languages': listOfLanguages ?? [],
        'specialties': listOfSpecializations ?? [],
        "text": text,
      });
      if (response.statusCode == 200) {
        List<Doctor> doctorsList =
            List<Doctor>.from(response.data.map((i) => Doctor.fromJson(i)));
        if (!_mounted) return;
        setState(() {
          loading = false;
          doctors = doctorsList;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilterScreen(),
                ),
              );
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
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: CustomSearchBar(
                  changeTextCallback: (text) => getDoctors(text: text)),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _DoctorCard(doctor: doctors[index]);
                      },
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
            height: 94,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 64,
                    width: 64,
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
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
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
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          "${getDoctorPrefix(doctor.gender)} ${doctor.familyName}",
                          style: boldoHeadingTextStyle,
                        ),
                      ),
                      const Text(
                        "Dermatología",
                        style: boldoSubTextStyle,
                      ),
                      Text("Disponible Hoy!",
                          style: boldoSubTextStyle.copyWith(
                              fontSize: 12, color: Constants.secondaryColor500))
                    ])
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
                            builder: (context) => BookingScreen(),
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
