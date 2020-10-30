import 'package:boldo/screens/Dashboard/DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../network/http.dart';
import '../../../provider/auth_provider.dart';

class SettingsTab extends StatefulWidget {
  SettingsTab({Key key}) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  Logger logger = Logger();
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
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Provider.of<AuthProvider>(context, listen: false)
                      .setAuthenticated(isAuthenticated: false);
                  const storage = FlutterSecureStorage();
                  await storage.deleteAll();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(),
                    ),
                  );
                },
                child: const Text("Logout"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    Response response = await dio.get("/me");
                    logger.i(response);
                  } catch (e) {
                    logger.e(e);
                  }
                },
                child: const Text("GET AUTH DATA"),
              ),
              Text(
                "Coming Soon!",
                style: TextStyle(
                    color: Colors.grey[850],
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ]),
      ),
    );
  }
}
