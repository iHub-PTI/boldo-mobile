import 'package:boldo/screens/Dashboard/DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

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
                  final storage = new FlutterSecureStorage();
                  String accessToken = await storage.read(key: "accessToken");
                  logger.i(accessToken);
                  try {
                    String serverAddress = DotEnv().env['SERVER_ADDRESS'];
                    print(serverAddress);
                    Dio dio = Dio();
                    dio.options.headers['Authorization'] =
                        "Bearer $accessToken";

                    Response response = await dio.get(
                      "$serverAddress/profile",
                    );
                    print(response);
                  } catch (e) {
                    logger.e(e);
                  }
                },
                child: Text("Profile with token"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final storage = new FlutterSecureStorage();
                  String value = await storage.read(key: "accessToken");
                  print(value);
                  try {
                    String serverAddress = DotEnv().env['SERVER_ADDRESS'];
                    print(serverAddress);
                    Dio dio = Dio();
                    dio.options.headers['Cookie'] = "connect.sid=$value";
                    print("poop");
                    Response response = await dio.get(
                      "$serverAddress/profile",
                    );
                    print(response);
                  } catch (e) {
                    logger.e(e);
                  }
                },
                child: Text("Profile"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Provider.of<AuthProvider>(context, listen: false)
                      .setAuthenticated(isAuthenticated: false);
                  final storage = new FlutterSecureStorage();
                  await storage.deleteAll();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(),
                    ),
                  );
                  // final storage = new FlutterSecureStorage();
                  // String value = await storage.read(key: "session");
                  // print(value);
                  // try {
                  //   String serverAddress = DotEnv().env['SERVER_ADDRESS'];
                  //   print(serverAddress);
                  //   Dio dio = Dio();
                  //   dio.options.headers['Cookie'] = "connect.sid=$value";
                  //   print("poop");
                  //   Response response = await dio.get(
                  //     "$serverAddress/logout",
                  //   );
                  //   print(response);
                  // } catch (e) {
                  //   print(e);
                  // }
                },
                child: Text("Logout"),
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
