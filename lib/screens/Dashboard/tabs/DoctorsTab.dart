import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constant.dart';
import '../../Booking/BookingScreen.dart';
import '../../DoctorProfile/DoctorProfileScreen.dart';
import '../../../models/Doctor.dart';

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

  getDoctors() async {
    try {
      String serverAddress = DotEnv().env['SERVER_ADDRESS'];

      Response response = await Dio().get("$serverAddress/doctors");

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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text("Médicos",
                style: boldoHeadingTextStyle.copyWith(fontSize: 20)),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _DoctorCard(doctor: doctors[index]);
                    },
                  ),
          )
        ],
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
                SizedBox(
                  width: 16,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          doctor.name,
                          style: boldoHeadingTextStyle,
                        ),
                      ),
                      Text(
                        "Dermatología",
                        style: boldoSubTextStyle,
                      ),
                      Text("Disponible Hoy!",
                          style: boldoSubTextStyle.copyWith(
                              fontSize: 12, color: boldoDarkPrimaryColor))
                    ])
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Color(0xffE5E7EB),
          ),
          Container(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorProfileScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Ver Perfil',
                        style: boldoHeadingTextStyle,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: 1,
                  color: Color(0xffE5E7EB),
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
                      child: Text(
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
