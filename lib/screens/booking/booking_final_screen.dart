import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import '../../constants.dart';

class BookingFinalScreen extends StatefulWidget {
  BookingFinalScreen({
    Key? key,
  }) : super(key: key);

  @override
  _BookingFinalScreenState createState() => _BookingFinalScreenState();
}

class _BookingFinalScreenState extends State<BookingFinalScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SvgPicture.asset('assets/Logo.svg',
                  semanticsLabel: 'BOLDO Logo'),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/booking.svg',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "¡Su consulta ha sido agendada!",
                      style: boldoSubTextStyle,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(left: 16, right: 16),
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       primary: Constants.primaryColor500,
                    //     ),
                    //     onPressed: null,
                    //     child: const Text("Ver reserva"),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 16,
                    // ),
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      width: double.infinity,
                      child: OutlinedButton(
                        //  style: style1,
                        onPressed: () {
                          Provider.of<UtilsProvider>(context, listen: false)
                              .setSelectedPageIndex(pageIndex: 0);
                          BlocProvider.of<PatientBloc>(context).add(ReloadHome());
                          Navigator.of(context).popUntil(ModalRoute.withName("/home"));

                        },

                        child: Text(
                          'Ir a Inicio',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
