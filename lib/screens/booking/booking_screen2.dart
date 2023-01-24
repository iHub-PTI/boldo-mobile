import 'package:boldo/blocs/user_bloc/patient_bloc.dart'as patient;
import 'package:boldo/blocs/doctor_availability_bloc/doctor_availability_bloc.dart';
import 'package:boldo/blocs/doctor_more_availability_bloc/doctor_more_availability_bloc.dart' as more_availabilities;
import 'package:boldo/main.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/booking/booking_screen.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/expandable_card/expandable_card.dart';
import 'package:boldo/widgets/in-person-virtual-switch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/Doctor.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';

class BookingScreen2 extends StatefulWidget{
  const BookingScreen2({Key? key, required this.doctor}) : super(key: key);
  final Doctor doctor;

  @override
  State<StatefulWidget> createState() =>
      _BookingScreenScreenState();

}

class _BookingScreenScreenState extends State<BookingScreen2> {

  final List<String> popupRoutes = <String>["Remoto (on line)", "En persona"];
  List<OrganizationWithAvailabilities> organizationsWithAvailabilites = [];
  List<OrganizationWithAvailabilities> calendarOrganizationsWithAvailabilites = [];
  DateTime date = DateTime.now();
  AppointmentType selectedType = AppointmentType.InPerson;
  NextAvailability? _selectedBookingHour;
  Organization? _selectedOrganization;
  bool _hideCalendar = true;
  bool _expandCalendar = false;
  // height of calendar
  double _height = 0.8;

  List<Organization?>? _organizations;

  @override
  void initState() {
    _organizations = Provider
        .of<DoctorFilterProvider>(context, listen: false)
        .getOrganizationsApplied
        .isNotEmpty ? Provider
        .of<DoctorFilterProvider>(context, listen: false)
        .getOrganizationsApplied : BlocProvider.of<patient.PatientBloc>(context)
        .getOrganizations();
    BlocProvider.of<DoctorAvailabilityBloc>(context).add(GetAvailability(
      id: widget.doctor.id?? '',
      startDate: DateTime.now().toUtc().toIso8601String(),
      endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 1).toLocal().toIso8601String(),
      organizations: _organizations,
    ));
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
        child: MultiBlocListener(
          listeners: [
            BlocListener<DoctorAvailabilityBloc, DoctorAvailabilityState>(
              listener: (context, state){
                if(state is Failed){
                  emitSnackBar(
                      context: context,
                      text: state.response,
                      status: ActionStatus.Fail
                  );
                }else if(state is AvailabilitiesObtained){
                  organizationsWithAvailabilites = state.availabilities;
                }
              },
            ),
            BlocListener<more_availabilities.DoctorMoreAvailabilityBloc, more_availabilities.DoctorMoreAvailabilityState>(
              listener: (context, state){
                if(state is more_availabilities.Failed){
                  emitSnackBar(
                      context: context,
                      text: state.response,
                      status: ActionStatus.Fail
                  );
                }else if(state is more_availabilities.AvailabilitiesObtained){
                  calendarOrganizationsWithAvailabilites = state.availabilities;
                }
              },
            )
          ],
          child: BlocBuilder<DoctorAvailabilityBloc, DoctorAvailabilityState>(
              builder: (context, state) {
                return ExpandableCardPage(
                  page: GestureDetector(
                    onTap: () {
                      setState(() {
                        _hideCalendar = true;
                        _selectedOrganization = null;
                        _selectedBookingHour = null;
                      });
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 2),
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    elevation: 0.0,
                                    color: ConstantsV2.grayLightest,
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                        color: ConstantsV2.lightGrey,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          ImageViewTypeForm(
                                            height: 60,
                                            width: 60,
                                            border: true,
                                            url: widget.doctor.photoUrl,
                                            gender: widget.doctor.gender,
                                          ),
                                          Flexible(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        "${getDoctorPrefix(widget.doctor.gender!)} ${widget.doctor.givenName?.split(" ")[0]} ${widget.doctor.familyName?.split(" ")[0]}",
                                                        style: boldoHeadingTextStyle.copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (widget.doctor.specializations != null)
                                                  SingleChildScrollView(
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
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                Flexible(child: BlocBuilder<DoctorAvailabilityBloc, DoctorAvailabilityState>(builder: (context, state) {
                                  if(state is Success){
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          VirtualInPersonSwitch(
                                            switchCallbackResponse: (AppointmentType type) {
                                              setState(() {
                                                selectedType = type;
                                                _selectedBookingHour = null;
                                                _selectedOrganization = null;
                                              });
                                            },
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.only(right: 16),
                                            scrollDirection: Axis.vertical,
                                            itemCount: organizationsWithAvailabilites.length,
                                            itemBuilder: _organizationAvailabilities,
                                            physics: const ClampingScrollPhysics(),
                                          ),
                                        ],
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
                                }),)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  expandableCard: ExpandableCard(
                    onHide: (){
                      setState((){
                        _expandCalendar = false;
                      });
                    },
                    onShow: (){
                      setState((){
                        _expandCalendar = true;
                      });
                    },
                    handleColor: ConstantsV2.orange,
                    backgroundGradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                      colors: <Color> [
                        ConstantsV2.grayLightest,
                        ConstantsV2.grayLightest
                      ],
                    ),
                    maxHeight: MediaQuery.of(context).size.height,
                    isExpanded: _expandCalendar,
                    minHeight: _hideCalendar ? 0: MediaQuery.of(context).size.height*_height,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            "Horarios disponibles",
                            style: boldoScreenTitleTextStyle.copyWith(
                                color: ConstantsV2.activeText
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "${getDoctorPrefix(widget.doctor.gender!)} ${widget.doctor.givenName?.split(" ")[0]} ${widget.doctor.familyName?.split(" ")[0]}",
                                  style: boldoCardSubtitleTextStyle.copyWith(color: ConstantsV2.inactiveText),
                                ),
                              ),
                            ],
                          ),
                          if (widget.doctor.specializations != null)
                            SingleChildScrollView(
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
                                        style: boldoCardSubtitleTextStyle.copyWith(
                                            color: ConstantsV2.blueLight),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _selectedOrganization?.name?? "Sin Organización",
                              style: boldoCardSubtitleTextStyle.copyWith(
                                  color: ConstantsV2.orange
                              ),
                            ),
                          ),
                          // TODO: expanded card not refresh values
                          /*InkWell(
                            onTap: (){
                              setState((){
                                _expandCalendar = !_expandCalendar;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                'assets/icon/zoom_out.svg',
                                color: ConstantsV2.secondaryRegular,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                      TableCalendar(
                        rowHeight: 35,
                        locale: const Locale("es", 'ES').languageCode,
                        headerStyle: HeaderStyle(
                            titleTextStyle: boldoSubTextMediumStyle.copyWith(
                                color: ConstantsV2.activeText
                            ),
                            formatButtonVisible: false,
                            leftChevronIcon: const Icon(
                              Icons.chevron_left,
                              color: ConstantsV2.orange,
                            ),
                            rightChevronIcon: const Icon(
                              Icons.chevron_right,
                              color: ConstantsV2.orange,
                            )
                        ),
                        calendarStyle: CalendarStyle(
                            selectedDecoration: const BoxDecoration(color: ConstantsV2.orange, shape: BoxShape.circle),
                            todayDecoration: BoxDecoration(color: ConstantsV2.secondaryLightAndClear, shape: BoxShape.circle),
                            todayTextStyle: const TextStyle(color: Color(0xFF263238), fontSize: 14.0)
                        ),
                        availableGestures: AvailableGestures.all,
                        onDaySelected: (DateTime day, DateTime focusedDay){
                          setState(() {
                            date = day;
                            BlocProvider.of<more_availabilities.DoctorMoreAvailabilityBloc>(context).add(more_availabilities.GetAvailability(
                              id: widget.doctor.id?? '',
                              startDate: date.toUtc().toIso8601String(),
                              endDate: DateTime(date.year, date.month, date.day+1).toLocal().toIso8601String(),
                              organizations: [_selectedOrganization],
                            ));
                          });
                        },
                        onPageChanged: (newDate){
                          setState(() {
                            date = newDate;
                            BlocProvider.of<more_availabilities.DoctorMoreAvailabilityBloc>(context).add(more_availabilities.GetAvailability(
                              id: widget.doctor.id?? '',
                              startDate: date.toUtc().toIso8601String(),
                              endDate: DateTime(date.year, date.month, date.day+1).toLocal().toIso8601String(),
                              organizations: [_selectedOrganization],
                            ));
                          });
                        },
                        selectedDayPredicate: (day) => isSameDay(day, date),
                        calendarFormat: _expandCalendar? CalendarFormat.month : CalendarFormat.week,
                        firstDay: DateTime.now(),
                        lastDay: DateTime(date.year, date.month + 1, 1),
                        currentDay: DateTime.now(),
                        focusedDay: date,
                      ),
                      BlocBuilder<more_availabilities.DoctorMoreAvailabilityBloc, more_availabilities.DoctorMoreAvailabilityState>(
                          builder: (context, state){
                            if(state is more_availabilities.AvailabilitiesObtained){
                              return Container(
                                height: MediaQuery.of(context).size.height*0.15,
                                child: Container(
                                  child: SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    child: Wrap(
                                      clipBehavior: Clip.antiAlias,
                                      alignment: WrapAlignment.center,
                                      spacing: 14,
                                      runSpacing: 14,
                                      children: [
                                        if(calendarOrganizationsWithAvailabilites.isNotEmpty)
                                        if(calendarOrganizationsWithAvailabilites.first.availabilities.isNotEmpty)
                                          for(NextAvailability? availability in calendarOrganizationsWithAvailabilites.first.availabilities.map((e) => e))
                                            if(availability != null)
                                              _calendarAvailabilityHourCard(
                                                  widget.doctor.organizations?.
                                                  map((e) => e.organization)
                                                      .toList()
                                                      .firstWhere(
                                                          (element) => element?.id == calendarOrganizationsWithAvailabilites.first.idOrganization
                                                  ), availability),
                                        if(calendarOrganizationsWithAvailabilites.isNotEmpty)
                                        if(calendarOrganizationsWithAvailabilites.first.availabilities.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 20.0),
                                            child: Text(
                                              "No hay disponibilidad en esta fecha",
                                              style:
                                              boldoHeadingTextStyle.copyWith(fontSize: 13),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }else if(state is more_availabilities.Loading){
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
                          }
                      ),
                    ],
                  ),
                );
              }
          ),
        ),
      ),
      bottomNavigationBar: Card(
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        elevation: 0.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed:
                  _selectedBookingHour == null ||  _selectedOrganization == null
                      ? null:
                      (){
                    handleBookingHour(
                        bookingHour: _selectedBookingHour!,
                        organization: _selectedOrganization!
                    );
                  },
                  child: Text("confirmar")
              ),
            ],
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
        Card(
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
                if(organizationsWithAvailabilites[index].availabilities.isNotEmpty)
                  if(DateTime(DateTime.parse(organizationsWithAvailabilites[index].nextAvailability?.availability?? DateTime.now().toString()).year,
                      DateTime.parse(organizationsWithAvailabilites[index].nextAvailability?.availability?? DateTime.now().toString()).month,
                      DateTime.parse(organizationsWithAvailabilites[index].nextAvailability?.availability?? DateTime.now().toString()).day) ==
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                    Flexible(
                      child: Text(
                        "Disponible hoy vía $organizationName",
                        style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),
                      ),
                    )
                  else
                    Flexible(
                        child: Text("Disponible el ${DateFormat('dd/MM')
                            .format(DateTime.parse(
                            organizationsWithAvailabilites[index]
                                .nextAvailability?.availability??
                                DateTime.now().toString()))}"
                            " vía $organizationName",
                          style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),
                        )
                    )
                else
                  Flexible(
                    child: Text(
                      "No disponible en los proximos 30 dias vía $organizationName",
                      style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(maxHeight: 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(right: 16),
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
                    setState(() {
                      _selectedOrganization = widget.doctor.organizations?.where(
                              (element) => element.organization?.id == organizationsWithAvailabilites[index].idOrganization
                      ).first.organization;
                      _selectedBookingHour = null;
                      _hideCalendar = false;
                      date = DateTime.now();
                      BlocProvider.of<more_availabilities.DoctorMoreAvailabilityBloc>(context).add(more_availabilities.GetAvailability(
                        id: widget.doctor.id?? '',
                        startDate: date.toUtc().toIso8601String(),
                        endDate: DateTime(date.year, date.month, date.day+1).toLocal().toIso8601String(),
                        organizations: [_selectedOrganization],
                      ));
                    });
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
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 10),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/icon/more-horiz.svg',
                          color: ConstantsV2.secondaryRegular,),
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

    bool _selected = _selectedBookingHour == organizationsWithAvailabilites[indexOrganization].availabilities[index];
    String? appointmentType = organizationsWithAvailabilites[indexOrganization].availabilities[index]?.appointmentType;

    return Container(
        child: GestureDetector(
          onTap: appointmentType?.contains(selectedType == AppointmentType.Virtual ? "V" : "A")?? false ?() {
            setState(() {
              _selectedBookingHour = organizationsWithAvailabilites[indexOrganization].availabilities[index];
              _selectedOrganization = widget.doctor.organizations?.map((e) => e.organization).toList().firstWhere((element) => element?.id == organizationsWithAvailabilites[indexOrganization].idOrganization);
            });

          }: null,
          child:Card(
            elevation: 0.0,
            color: appointmentType?.contains(
                selectedType == AppointmentType.Virtual ? "V" : "A"
            ) ?? false
                ? _selected? ConstantsV2.orange : ConstantsV2.secondaryLightAndClear
                : ConstantsV2.gray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text("${DateFormat('HH:mm').format(DateTime.parse(organizationsWithAvailabilites[indexOrganization].availabilities[index]?.availability?? DateTime.now().toString()))}",
                    style: boldoCorpMediumBlackTextStyle.copyWith(
                        color: appointmentType?.contains(
                            selectedType == AppointmentType.Virtual ? "V" : "A"
                        ) ?? false
                            ?_selected? ConstantsV2.lightGrey.withOpacity(0.80) : ConstantsV2.secondaryRegular
                            : ConstantsV2.inactiveText
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Future<void> handleBookingHour({
    required NextAvailability bookingHour,
    required Organization organization}) async {
    NextAvailability _bookingHour = NextAvailability.fromJson(bookingHour.toJson());
    _bookingHour.appointmentType = selectedType == AppointmentType.InPerson? "A"
        : selectedType == AppointmentType.Virtual? "V" : "none";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmScreen(
          bookingDate: _bookingHour,
          doctor: widget.doctor,
          organization: organization,
        ),
      ),
    );
  }

  Widget _calendarAvailabilityHourCard(Organization? organization, NextAvailability availability){

    bool _selected = _selectedBookingHour == availability;
    String? appointmentType = availability.appointmentType;

    return Container(
        child: GestureDetector(
          onTap: appointmentType?.contains(selectedType == AppointmentType.Virtual ? "V" : "A")?? false ?() {
            setState(() {
              _selectedBookingHour = availability;
              _selectedOrganization = organization;
            });

          }: null,
          child:Card(
            elevation: 0.0,
            color: appointmentType?.contains(
                selectedType == AppointmentType.Virtual ? "V" : "A"
            ) ?? false
                ? _selected? ConstantsV2.orange : ConstantsV2.secondaryLightAndClear
                : ConstantsV2.gray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${DateFormat('HH:mm').format(DateTime.parse(availability.availability?? DateTime.now().toString()))}",
                    style: boldoCorpMediumBlackTextStyle.copyWith(
                        color: appointmentType?.contains(
                            selectedType == AppointmentType.Virtual ? "V" : "A"
                        ) ?? false
                            ?_selected? ConstantsV2.lightGrey.withOpacity(0.80) : ConstantsV2.secondaryRegular
                            : ConstantsV2.inactiveText
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

}
