import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import '../../Booking/BookingScreen.dart';
import '../../DoctorProfile/DoctorProfileScreen.dart';
import '../../../models/Doctor.dart';
import '../../../network/http.dart';

class DoctorsTab extends StatefulWidget {
  DoctorsTab({Key key}) : super(key: key);

  @override
  _DoctorsTabState createState() => _DoctorsTabState();
}

class _DoctorsTabState extends State<DoctorsTab> {
  List<Doctor> doctors = [];
  bool loading = true;
  @override
  void initState() {
    getDoctors();
    super.initState();
  }

  void getDoctors() async {
    try {
      Response response = await dio.get("/doctors");
      if (response.statusCode == 200) {
        List<Doctor> doctorsList = List<Doctor>.from(
            response.data["doctors"].map((i) => Doctor.fromJson(i)));

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
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
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
            const SizedBox(
              height: 20,
            ),
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
                SvgPicture.asset(
                  'assets/images/ProfileImage.svg',
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
                          "${doctor.givenName} ${doctor.familyName}",
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
                            builder: (context) => DoctorProfileScreen(),
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
