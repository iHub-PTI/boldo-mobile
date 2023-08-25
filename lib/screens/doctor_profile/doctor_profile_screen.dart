import 'dart:ui';

import 'package:boldo/blocs/lastAppointment_bloc/lastAppointmentBloc.dart' as last_appointment_bloc;
import 'package:boldo/blocs/doctor_bloc/doctor_bloc.dart' as doctor_bloc;
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/booking/booking_screen2.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/Doctor.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';

class DoctorProfileScreen extends StatefulWidget{
  /// make [showAvailability] true if go to this page to make a reservation
  const DoctorProfileScreen({Key? key, required this.doctor, this.showAvailability= false}) : super(key: key);
  final Doctor doctor;
  final bool showAvailability;

  @override
  State<StatefulWidget> createState() =>
    _DoctorProfileScreenState();

}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {

  final List<String> popupRoutes = <String>["Remoto (on line)", "En persona"];
  List<OrganizationWithAvailabilities> organizationsWithAvailabilites = [];
  bool hasFilter = false;
  Appointment? lastAppointment;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
          SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: SafeArea(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<last_appointment_bloc.LastAppointmentBloc>(
              create: (BuildContext context) => last_appointment_bloc.LastAppointmentBloc()..add(
                last_appointment_bloc.GetLastAppointment(doctor: widget.doctor),
              ),
            ),
            BlocProvider<doctor_bloc.DoctorBloc>(
              create: (BuildContext context) => doctor_bloc.DoctorBloc()..add(
                doctor_bloc.GetAvailability(
                  id: widget.doctor.id ?? '',
                  startDate: DateTime.now().toUtc(),
                  endDate: DateTime.now().add(const Duration(days: 30))
                      .toUtc(),
                  organizations: Provider
                      .of<DoctorFilterProvider>(context, listen: false)
                      .getOrganizationsApplied
                      .isNotEmpty ? Provider
                      .of<DoctorFilterProvider>(context, listen: false)
                      .getOrganizationsApplied : null,
                ),
              ),
            ),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<doctor_bloc.DoctorBloc, doctor_bloc.DoctorState>(
                listener: (context, state){
                  if(state is doctor_bloc.Failed){
                    emitSnackBar(
                      context: context,
                      text: state.response,
                      status: ActionStatus.Fail
                    );
                  }else if(state is doctor_bloc.AvailabilitiesObtained){
                    organizationsWithAvailabilites = state.availabilities;
                    if(organizationsWithAvailabilites.isEmpty)
                      hasFilter = true;
                  }
                },
              ),
              BlocListener<last_appointment_bloc.LastAppointmentBloc, last_appointment_bloc.LastAppointmentState>(
                listener: (context, state){
                  if(state is last_appointment_bloc.LastAppointmentLoadedState){
                    lastAppointment = state.appointment;
                  }
                }
              )
            ],
            child: BlocBuilder<doctor_bloc.DoctorBloc, doctor_bloc.DoctorState>(
                builder: (context, state) {
                  return Background(
                    hasFilter: hasFilter,
                    doctor: widget.doctor,
                    child: Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.75,
                                        child: Card(
                                          elevation: 0.0,
                                          color: ConstantsV2.lightGrey.withOpacity(0.80),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: const BorderSide(
                                              color: ConstantsV2.lightGrey,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${getDoctorPrefix(widget.doctor.gender!)}",
                                                      style: boldoHeadingTextStyle.copyWith(color: ConstantsV2.orange),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${widget.doctor.givenName?.split(" ")[0]} ${widget.doctor.familyName?.split(" ")[0]}",
                                                        style: boldoHeadingTextStyle.copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (widget.doctor.specializations != null)
                                                  Container(
                                                    child: Wrap(
                                                      children: [
                                                        for (int i = 0;
                                                        i <
                                                            widget.doctor
                                                                .specializations!.length;
                                                        i++)
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                right: i == 0 ? 0 : 3.0, bottom: 5),
                                                            child: Text(
                                                              "${widget.doctor.specializations![i].description}${widget.doctor.specializations!.length-1 != i  ? ", " : ""}",
                                                              style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.inactiveText),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        elevation: 0.0,
                                        color: ConstantsV2.lightGrey.withOpacity(0.80),
                                        shape: const CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: Align(
                                              widthFactor: 1.0,
                                              heightFactor: 1.0,
                                              child: BackButtonLabel(
                                                padding: null,
                                                iconType: BackIcon.backClose,
                                                iconSize: 24,
                                              ),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BlocBuilder<last_appointment_bloc.LastAppointmentBloc, last_appointment_bloc.LastAppointmentState>(
                                        builder: (context, state){
                                          return AnimatedOpacity(
                                            duration: const Duration(milliseconds: 1000),
                                            opacity: state is last_appointment_bloc.LastAppointmentLoadedState && lastAppointment != null? 1.0: 0.0, // 1 is to get visible
                                            child: Visibility(
                                              visible: lastAppointment != null,
                                              child: Card(
                                                color: ConstantsV2.grayLightAndClear,
                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(color: ConstantsV2.grayLightest, width: 1),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ImageViewTypeForm(
                                                        height: 44,
                                                        width: 44,
                                                        border: true,
                                                        borderColor: ConstantsV2.secondaryRegular,
                                                        gender: lastAppointment?.patient?.gender,
                                                        url: lastAppointment?.patient?.photoUrl,
                                                      ),
                                                      if(lastAppointment?.patient?.id == prefs.getString("userId"))
                                                        Text(
                                                          "consultaste",
                                                          style: bodyLargeBlack.copyWith(color: ConstantsV2.activeText),
                                                        )
                                                      else
                                                        RichText(
                                                          text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                    text: lastAppointment?.patient?.givenName?.split(" ")[0]?? "Desconocido",
                                                                    style: bodyLargeBlack.copyWith(color: ConstantsV2.activeText)
                                                                ),
                                                                TextSpan(
                                                                    text: " consultó",
                                                                    style: bodyLargeBlack.copyWith(color: ConstantsV2.activeText)
                                                                ),
                                                              ]
                                                          ),
                                                        ),
                                                      Text(
                                                          passedDays(daysBetween(DateTime.parse(
                                                              lastAppointment?.start?? DateTime.now()
                                                                  .toString()),
                                                              DateTime.now()
                                                          )),
                                                          style: bodyP.copyWith(color: ConstantsV2.activeText)
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                    ),
                                    if(widget.showAvailability)
                                      BlocBuilder<doctor_bloc.DoctorBloc, doctor_bloc.DoctorState>(builder: (context, state) {
                                        if(state is doctor_bloc.AvailabilitiesObtained){
                                          if(organizationsWithAvailabilites.isNotEmpty)
                                            return ClipRect(
                                              child: Container(
                                                padding: const EdgeInsets.only(bottom: 16),
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(15.0),
                                                    topRight: Radius.circular(15.0),
                                                  ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomCenter,
                                                    colors: <Color> [
                                                      Colors.black.withOpacity(0),
                                                      const Color(0xA7A7A7).withOpacity(1),
                                                    ],
                                                  ),
                                                ),
                                                child: BackdropFilter(
                                                    blendMode: BlendMode.src,
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 5,
                                                        sigmaY: 5
                                                    ),
                                                    child: organizationsWithAvailabilites.isNotEmpty ?
                                                    _organizationAvailabilities(context, 0) :
                                                    null
                                                ),
                                              ),
                                            );
                                          else
                                            return familyListWithAccess();
                                        }else if(state is doctor_bloc.Loading){
                                          return Container(
                                              child: const Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor:
                                                    AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                                                    backgroundColor: Constants.primaryColor600,
                                                  )
                                              )
                                          );
                                        }else{
                                          return Container();
                                        }
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            ),
          ),
        ),
      ),
    );
  }

  Widget _organizationAvailabilities(BuildContext context, int index){

    String organizationName = organizationsWithAvailabilites[index].nameOrganization?? "Desconocido";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen2(
                    doctor: widget.doctor,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 0.0,
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(organizationsWithAvailabilites[index].availabilities.isNotEmpty)
                      if(DateTime(DateTime.parse(organizationsWithAvailabilites[index].nextAvailability?.availability?? DateTime.now().toString()).year,
                          DateTime.parse(organizationsWithAvailabilites[index].nextAvailability?.availability?? DateTime.now().toString()).month,
                          DateTime.parse(organizationsWithAvailabilites[index].nextAvailability?.availability?? DateTime.now().toString()).day) ==
                          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                        Expanded(
                          child: Text(
                            "Hoy - $organizationName",
                            style: boldoScreenSubtitleTextStyle.copyWith(
                              color: ConstantsV2.grayLightest,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Text("Disponible el ${DateFormat('dd/MM')
                              .format(DateTime.parse(
                              organizationsWithAvailabilites[index]
                                  .nextAvailability?.availability??
                                  DateTime.now().toString()))}"
                              " - $organizationName",
                            style: boldoScreenSubtitleTextStyle.copyWith(color: ConstantsV2.grayLightest),
                          )
                        )
                    else
                      Expanded(
                        child: Text(
                          "No disponible en los proximos 30 dias - $organizationName",
                        style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),
                        ),
                      ),
                  ],
                ),
              ),
            ),),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(
                      int indexAvailable=0;
                      indexAvailable<organizationsWithAvailabilites[index]
                          .availabilities.length && indexAvailable<3;
                      indexAvailable++)
                        _availabilityHourCard(index, indexAvailable)
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingScreen2(
                            doctor: widget.doctor,
                          )
                      ),
                    );
                  },
                  child:  Container(
                    decoration: ShapeDecoration(
                      color: ConstantsV2.grayLightAndClear,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Más opciones",
                          style: GoogleFonts.inter().copyWith(
                              color: ConstantsV2.secondaryRegular,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _availabilityHourCard(int indexOrganization, int index){


    OrganizationWithAvailabilities organization = organizationsWithAvailabilites[indexOrganization];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: GestureDetector(
        onTapDown: (TapDownDetails details) async {
          DateTime parsedAvailability = DateTime.parse(organizationsWithAvailabilites[indexOrganization].availabilities[index]?.availability?? DateTime.now().toString());
          if (organizationsWithAvailabilites[indexOrganization].availabilities[index]?.appointmentType! ==
              'AV') {
            print(details.globalPosition);
            final chooseOption =
                await _showPopupMenu(details.globalPosition);
            if (chooseOption != null) {
              if (chooseOption == 'En persona') {
                handleBookingHour(
                  organization: organization,
                  bookingHour: NextAvailability(
                      appointmentType: 'A',
                      availability: parsedAvailability.toString()),
                );
              } else {
                handleBookingHour(
                  organization: organization,
                  bookingHour: NextAvailability(
                      appointmentType: 'V',
                      availability: parsedAvailability.toString()),
                );
              }
            }
          } else {
            handleBookingHour(
                organization: organization,
                bookingHour: NextAvailability(
                appointmentType:
                organizationsWithAvailabilites[indexOrganization].availabilities[index]?.appointmentType!,
                availability: parsedAvailability.toString()));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: ConstantsV2.grayLightAndClear,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: ConstantsV2.grayLightAndClear, width: 1),
              borderRadius: BorderRadius.circular(100),
            ),
            shadows: [
              shadowHourAvailable,
            ]
          ),
          child: Row(
            children: [
              Text("${DateFormat('HH:mm').format(DateTime.parse(organizationsWithAvailabilites[indexOrganization].availabilities[index]?.availability?? DateTime.now().toString()))}",
                style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.secondaryRegular),),
            ],
          ),
        ),
      )
    );
  }

  Future<String?>? _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top , MediaQuery.of(context).size.width- left, 0),
      items: popupRoutes.map((String popupRoute) {
        return PopupMenuItem<String>(
          child: Container(
              decoration: const BoxDecoration(color: Constants.accordionbg),
              child: Container(
                height: 50,
                child: ListTile(
                  leading: popupRoute == 'En persona'
                      ? const Icon(
                    Icons.person,
                    color: Colors.black,
                  )
                      : SvgPicture.asset('assets/icon/video.svg'),
                  title: Text(popupRoute),
                ),
              )),
          value: popupRoute,
          padding:
          const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
        );
      }).toList(),
      elevation: 8.0,
    );
  }

  Future<void> handleBookingHour({
    required NextAvailability bookingHour,
    required OrganizationWithAvailabilities organization}) async {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmScreen(
          bookingDate: bookingHour,
          doctor: widget.doctor,
          organization: organization,
        ),
      ),
    );
  }

  Widget familyListWithAccess(){

    Widget patientBox = Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ImageViewTypeForm(
            height: 44,
            width: 44,
            border: true,
            borderColor: ConstantsV2.grayLightAndClear,
            color: ConstantsV2.grayLightAndClear,
            opacity: .8,
            gender: patient.gender,
          ),
          const SizedBox(width: 16,),
          Expanded(
            child: Container(
              child: Text(
                "No tenés acceso a este médico. Agregá una organización",
                style: boldoCardSubtitleTextStyle.copyWith(color: ConstantsV2.inactiveText),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        patientBox,
      ],
    );
  }

}

class Background extends StatelessWidget {
  final Widget child;
  final Doctor doctor;
  final bool hasFilter;
  const Background({
    Key? key,
    required this.child,
    required this.doctor,
    this.hasFilter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: doctor.photoUrl == null
                ? SvgPicture.asset(
              doctor.gender == "female"
                  ? 'assets/images/femaleDoctor.svg'
                  : doctor.gender == "male"? 'assets/images/maleDoctor.svg':
              'assets/images/persona.svg',
              fit: BoxFit.cover,)
                : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: doctor.photoUrl?? '',
              progressIndicatorBuilder:
                  (context, url, downloadProgress) =>
                  Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                            Constants.primaryColor400),
                        backgroundColor:
                        Constants.primaryColor600,
                      ),
                    ),
                  ),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: hasFilter== true ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Container(
                color: const Color(0xF5F5F5).withOpacity(.8),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
