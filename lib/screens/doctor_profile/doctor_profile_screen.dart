import 'package:boldo/blocs/doctor_bloc/doctor_bloc.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/booking/booking_screen.dart';
import 'package:boldo/utils/expandable_card/expandable_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

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
  List<NextAvailability> availabilities = [];

  @override
  void initState() {
    // get availabilities only if it should be displayed
    if(widget.showAvailability)
    BlocProvider.of<DoctorBloc>(context).add(GetAvailability(id: widget.doctor.id?? '', startDate: DateTime.now().toUtc().toIso8601String(), endDate: DateTime.now().add(const Duration(days: 30)).toUtc().toIso8601String()));
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
              //only first three elements
              availabilities = state.availabilities.take(3).toList();
            }
          },
          child: BlocBuilder<DoctorBloc, DoctorState>(
            builder: (context, state) {
              return ExpandableCardPage(
                page: Background(
                  doctor: widget.doctor,
                  child: Align(
                    alignment: AlignmentDirectional.topCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height*0.2,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
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
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                    Axis.horizontal,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        for (int i=0; i<widget.doctor.specializations!.length; i++)
                                                          Padding(
                                                            padding: EdgeInsets.only(bottom: 4, left: i==0 ? 0 : 3.0),
                                                            child: Text(
                                                              "${widget.doctor.specializations![i].description}${i<widget.doctor.specializations!.length-1?',':''}",
                                                              style: boldoSubTextMediumStyle.copyWith(
                                                                  color: ConstantsV2.activeText),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
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
                              ],
                            ),
                            // show Availability only if go to this page to make a reservation
                            if(widget.showAvailability)
                            BlocBuilder<DoctorBloc, DoctorState>(builder: (context, state) {
                              if(state is Success){
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BookingScreen(
                                                  doctor: widget.doctor,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            elevation: 0.0,
                                            color: ConstantsV2.lightAndClear.withOpacity(0.80),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if(availabilities.isNotEmpty)
                                                    if(DateTime(DateTime.parse(availabilities.first.availability!).year,
                                                        DateTime.parse(availabilities.first.availability!).month,
                                                        DateTime.parse(availabilities.first.availability!).day) ==
                                                        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                                      Text("Disponible hoy",
                                                        style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),)
                                                    else
                                                      Text("Disponible el ${DateFormat('dd/MM').format(DateTime.parse(availabilities.first.availability!))}",
                                                        style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),)
                                                  else
                                                    Text("No disponible en los proximos 30 dias",
                                                      style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),),
                                                  const Icon(
                                                    Icons.chevron_right,
                                                    color: ConstantsV2.orange,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(maxHeight: 45),
                                        child: Row(
                                          children: [
                                            ListView.builder(
                                                shrinkWrap: true,
                                                padding: const EdgeInsets.only(right: 16),
                                                scrollDirection: Axis.horizontal,
                                                itemCount: availabilities.length,
                                                itemBuilder: _availabilityHourCard
                                            ),
                                            Container(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => BookingScreen(
                                                          doctor: widget.doctor,
                                                        )
                                                    ),
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 0.0,
                                                  color: ConstantsV2.lightGrey.withOpacity(0.80),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(100),
                                                      side: const BorderSide(
                                                        color: ConstantsV2.orange,
                                                        width: 1.0,
                                                      )
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      children: [
                                                        Text("ver más",
                                                          style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.orange),),
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
                ),
                expandableCard: ExpandableCard(
                  handleColor: ConstantsV2.orange,
                  backgroundColor: Colors.white.withOpacity(0.85),
                  maxHeight: MediaQuery.of(context).size.height-120,
                  minHeight: MediaQuery.of(context).size.height*0.2,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.doctor.biography != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Biografía",
                                style: boldoSubTextMediumStyle.copyWith(color: Colors.black),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(widget.doctor.biography??'',
                                  style: boldoCorpMediumBlackTextStyle.copyWith(
                                      color: ConstantsV2.inactiveText)),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _availabilityHourCard(BuildContext context, int index){
    return Container(
      child: GestureDetector(
        onTapDown: (TapDownDetails details) async {
          DateTime parsedAvailability = DateTime.parse(availabilities[index].availability!);
          if (widget.doctor.nextAvailability!.appointmentType! ==
              'AV') {
            print(details.globalPosition);
            final chooseOption =
                await _showPopupMenu(details.globalPosition);
            if (chooseOption != null) {
              if (chooseOption == 'En persona') {
                handleBookingHour(
                  bookingHour: NextAvailability(
                      appointmentType: 'A',
                      availability: parsedAvailability.toString()),
                );
              } else {
                handleBookingHour(
                  bookingHour: NextAvailability(
                      appointmentType: 'V',
                      availability: parsedAvailability.toString()),
                );
              }
            }
          } else {
            handleBookingHour(bookingHour: NextAvailability(
                appointmentType:
                widget.doctor.nextAvailability!.appointmentType,
                availability: parsedAvailability.toString()));
          }
        },
        child:Card(
          elevation: 0.0,
          color: ConstantsV2.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Text("${DateFormat('HH:mm').format(DateTime.parse(availabilities[index].availability!))}",
                style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.lightGrey),),
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

  Future<void> handleBookingHour({required NextAvailability bookingHour}) async {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmScreen(
          bookingDate: bookingHour,
          doctor: widget.doctor,
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
                  : 'assets/images/maleDoctor.svg',
              fit: BoxFit.cover,)
                : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: doctor.photoUrl?? '',
              progressIndicatorBuilder:
                  (context, url, downloadProgress) =>
                  Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor:
                      Constants.primaryColor600,
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
