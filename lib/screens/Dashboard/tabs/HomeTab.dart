import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Agrega tu primera cita",
              style: TextStyle(
                  color: Colors.grey[850],
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 240,
              child: Text(
                "Consulta la lista de doctores y programá tu primera cita",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 17),
              ),
            )
          ]),
    );
  }
}
