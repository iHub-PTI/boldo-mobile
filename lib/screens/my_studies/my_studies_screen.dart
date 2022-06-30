import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';

class MyStudies extends StatefulWidget {
  MyStudies({Key? key}) : super(key: key);

  @override
  State<MyStudies> createState() => _MyStudiesState();
}

class _MyStudiesState extends State<MyStudies> {
  @override
  void initState() {
    BlocProvider.of<MyStudiesBloc>(context).add(GetPatientStudiesFromServer());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 200,
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 16.0),
        //   child:
        //       SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.chevron_left_rounded,
                size: 25,
                color: Constants.extraColor400,
              ),
              label: Text(
                'Estudios',
                style: boldoHeadingTextStyle.copyWith(fontSize: 20),
              ),
            ),
            Text(
              'Subí y consultá resultados de estudios provenientes de varias fuentes.',
              style: boldoHeadingTextStyle.copyWith(fontSize: 12),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Mis estudios',
              style: boldoHeadingTextStyle.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
