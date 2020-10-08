import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../Call/CallScreen.dart';
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

      Response response = await Dio().get("$serverAddress/api/doctors");

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
      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Doctores",
            style: TextStyle(
                color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold),
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
                      return Card(
                        margin: EdgeInsets.only(
                          bottom: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        child: InkWell(
                          splashColor: Theme.of(context).selectedRowColor,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            String roomNumber =
                                Random().nextInt(123).toString();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CallScreen(roomNumber: roomNumber),
                                ));
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 10),
                            child: Row(
                              children: <Widget>[
                                Text(doctors[index].name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .color,
                                    )),
                                Spacer(),
                                Icon(Icons.keyboard_arrow_right),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
