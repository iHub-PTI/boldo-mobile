import 'package:boldo/blocs/appointmet_bloc/appointmentBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/screens/appointments/medicalRecordScreen.dart';

import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PastAppointmentsScreen extends StatefulWidget {

  const PastAppointmentsScreen() : super();

  @override
  _PastAppointmentsScreenState createState() => _PastAppointmentsScreenState();
}

class _PastAppointmentsScreenState extends State<PastAppointmentsScreen> {
  bool _dataLoading = true;
  bool _dataLoaded =false;
  late List<Appointment> allAppointments = [];
  DateTime dateOffset = DateTime.now().subtract(const Duration(days: 30));
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AppointmentBloc>(context).add(GetPastAppointmentList(date: DateTime(dateOffset.year, dateOffset.month, dateOffset.day).toUtc().toIso8601String()));
  }

  void _onRefresh() async {
    setState(() {
      dateOffset = DateTime.now().subtract(const Duration(days: 30));
    });
    // monitor network fetch
    BlocProvider.of<AppointmentBloc>(context).add(GetPastAppointmentList(date: DateTime(dateOffset.year, dateOffset.month, dateOffset.day).toUtc().toIso8601String()));
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state){
        if(state is Success) {
          setState(() {
            _dataLoading = false;
            _dataLoaded = true;
          });
        }else if(state is Failed){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response!),
              backgroundColor: Colors.redAccent,
            ),
          );
          _dataLoading = false;
          _dataLoaded = false;
        }else if(state is AppointmentLoadedState){
          allAppointments = state.appointments;
        }
      },
      child: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leadingWidth: 200,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child:
                SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
              ),
            ),
            body: _dataLoading == true
                ? Text('Mis consultas',
                style: boldoHeadingTextStyle.copyWith(fontSize: 20)
            )
                : Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Mis Consultas',
                      textAlign: TextAlign.start,
                      style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                    ),
                  ),
                  if (!_dataLoading && !_dataLoaded)
                    const Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Center(
                        child: Text(
                          "Algo salió mal. Por favor, inténtalo de nuevo más tarde.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Constants.otherColor100,
                          ),
                        ),
                      ),
                    ),
                  if (!_dataLoading && _dataLoaded)
                    allAppointments.isEmpty
                        ? const EmptyStateV2(
                      picture: "feed_empty.svg",
                      textTop: "Nada para mostrar",
                    )
                        : Expanded(
                      child: ListView.separated(
                        itemCount: allAppointments.length,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.transparent,
                        ),
                        itemBuilder: (context, index) {
                          int daysDifference = DateTime.now().difference(DateTime.parse(allAppointments[index].start!)
                              .toLocal())
                              .inDays;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MedicalRecordsScreen(
                                        encounterId: allAppointments[index].id)),
                              );
                            },
                            child: Container(
                              child: Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Consultaste con",
                                          style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.darkBlue),
                                        ),
                                        Text(
                                          daysDifference == 0 ? "hoy" : "hace $daysDifference dias",
                                          style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.veryLightBlue),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: SizedBox(
                                            width: 54,
                                            height: 54,
                                            child: allAppointments[index].doctor?.photoUrl == null
                                                ? SvgPicture.asset(
                                                allAppointments[index].doctor!.gender == "female"
                                                    ? 'assets/images/femaleDoctor.svg'
                                                    : 'assets/images/maleDoctor.svg',
                                                fit: BoxFit.cover)
                                                : CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: allAppointments[index].doctor!.photoUrl??'',
                                              progressIndicatorBuilder:
                                                  (context, url, downloadProgress) =>
                                                  Padding(
                                                    padding: const EdgeInsets.all(26.0),
                                                    child: LinearProgressIndicator(
                                                      value: downloadProgress.progress,
                                                      valueColor:
                                                      const AlwaysStoppedAnimation<
                                                          Color>(
                                                          Constants.primaryColor400),
                                                      backgroundColor:
                                                      Constants.primaryColor600,
                                                    ),
                                                  ),
                                              errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "${getDoctorPrefix(allAppointments[index].doctor!.gender!)}${allAppointments[index].doctor!.familyName}",
                                                      style: boldoSubTextMediumStyle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            if (allAppointments[index].doctor!.specializations !=
                                                null &&
                                                allAppointments[index].doctor!.specializations!
                                                    .isNotEmpty)
                                              SizedBox(
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      for (int i = 0;
                                                      i <
                                                          allAppointments[index].doctor!
                                                              .specializations!.length;
                                                      i++)
                                                      Text(
                                                          "${toLowerCase(allAppointments[index].doctor!.specializations![i].description?? '')}${allAppointments[index].doctor!.specializations!.length > 1 && i == 0 ? "," : ""}",
                                                          style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.inactiveText),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
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
            ),
          );
        }
      )
    );
  }
}

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileScreenTopDecoration.svg',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileBottomDecoration.svg',
            ),
          ),
          child,
        ],
      ),
    );
  }
}
