import 'dart:ui';

import 'package:boldo/blocs/user_bloc/patient_bloc.dart'as patient;
import 'package:boldo/blocs/doctor_bloc/doctor_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/booking/booking_screen.dart';
import 'package:boldo/screens/booking/booking_screen2.dart';
import 'package:boldo/utils/expandable_card/expandable_card.dart';
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
        child: BlocProvider<DoctorBloc>(
          create: (BuildContext context) => DoctorBloc()..add(GetAvailability(
            id: widget.doctor.id ?? '',
            startDate: DateTime.now().toUtc().toIso8601String(),
            endDate: DateTime.now().add(const Duration(days: 30))
                .toUtc()
                .toIso8601String(),
            organizations: Provider
                .of<DoctorFilterProvider>(context, listen: false)
                .getOrganizationsApplied
                .isNotEmpty ? Provider
                .of<DoctorFilterProvider>(context, listen: false)
                .getOrganizationsApplied : BlocProvider.of<patient.PatientBloc>(context)
                .getOrganizations(),
          )),
          child: BlocListener<DoctorBloc, DoctorState>(
            listener: (context, state){
              if(state is Success) {
              }else if(state is Failed){
                emitSnackBar(
                    context: context,
                    text: state.response,
                    status: ActionStatus.Fail
                );
              }else if(state is Loading){
              }else if(state is AvailabilitiesObtained){
                organizationsWithAvailabilites = state.availabilities;
              }
            },
            child: BlocBuilder<DoctorBloc, DoctorState>(
                builder: (context, state) {
                  return Background(
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
                                                  Align(
                                                    alignment: Alignment.center,
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
                                                              "${widget.doctor.specializations![i].description}${widget.doctor.specializations!.length-1 != i  ? "," : ""}",
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
                                              child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: SvgPicture.asset(
                                                    'assets/icon/close_black.svg',
                                                    height: 17,)
                                              ),)
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            if(widget.showAvailability)
                              BlocBuilder<DoctorBloc, DoctorState>(builder: (context, state) {
                                if(state is Success){
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
                                        child: _organizationAvailabilities(context, 0),
                                      ),
                                    ),
                                  );
                                }else if(state is Loading){
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
                  );
                }
            ),
          ),
        ),
      ),
    );
  }

  Widget _organizationAvailabilities(BuildContext context, int index){

    List<Organization> _organizationsSelected = Provider
        .of<DoctorFilterProvider>(context, listen: false)
        .getOrganizationsApplied
        .isNotEmpty ? Provider
        .of<DoctorFilterProvider>(context, listen: false)
        .getOrganizationsApplied : BlocProvider.of<patient.PatientBloc>(context)
        .getOrganizations();

    List<Organization>? _organizations = _organizationsSelected.where(
            (element) => element.id == organizationsWithAvailabilites[index].idOrganization
    ).toList();

    String organizationName = _organizations.first.name?? "Desconocido";

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
                        Flexible(
                          child: Text(
                            "Hoy - $organizationName",
                            style: boldoScreenSubtitleTextStyle.copyWith(color: ConstantsV2.grayLightest),
                          ),
                        )
                      else
                        Flexible(
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
                      Flexible(
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
          constraints: BoxConstraints(maxHeight: 45),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: organizationsWithAvailabilites[index].availabilities.length > 3
                        ? 3: organizationsWithAvailabilites[index].availabilities.length,
                    itemBuilder: (BuildContext context, int indexAvailable){
                      return _availabilityHourCard(index, indexAvailable);
                    }
                ),
              ),
              Container(
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
                  child: Card(
                    elevation: 0.0,
                    margin: EdgeInsets.zero,
                    color: ConstantsV2.grayLightAndClear,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _availabilityHourCard(int indexOrganization, int index){

    List<Organization> _organizationsSelected = Provider
        .of<DoctorFilterProvider>(context, listen: false)
        .getOrganizationsApplied
        .isNotEmpty ? Provider
        .of<DoctorFilterProvider>(context, listen: false)
        .getOrganizationsApplied : BlocProvider.of<patient.PatientBloc>(context)
        .getOrganizations();

    Organization organization = _organizationsSelected.where(
            (element) => element.id == organizationsWithAvailabilites[indexOrganization].idOrganization
    ).first;

    return Container(
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
        child:Card(
          elevation: 0.0,
          color: ConstantsV2.grayLightAndClear,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: ConstantsV2.grayLightAndClear, width: 1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text("${DateFormat('HH:mm').format(DateTime.parse(organizationsWithAvailabilites[indexOrganization].availabilities[index]?.availability?? DateTime.now().toString()))}",
                style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.secondaryRegular),),
              ],
            ),
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
    required Organization organization}) async {

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

}

class Background extends StatelessWidget {
  final Widget child;
  final Doctor doctor;
  const Background({
    Key? key,
    required this.child,
    required this.doctor,
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
          child,
        ],
      ),
    );
  }
}
