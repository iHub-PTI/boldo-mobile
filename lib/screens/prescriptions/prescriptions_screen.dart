import 'package:boldo/blocs/download_prescriptions_bloc/download_prescriptions_bloc.dart' as download_prescriptions_bloc;
import 'package:boldo/blocs/prescriptions_bloc/prescriptionsBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Encounter.dart';
import 'package:boldo/models/Organization.dart';

import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/header_page.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:boldo/widgets/selectable/selectable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'components/prescription_card.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen() : super();

  @override
  _PrescriptionsScreenState createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  late List<Encounter> allEncounters = [];
  @override
  void initState() {
    super.initState();
  }

  void _onRefresh() async {
    // monitor network fetch
    BlocProvider.of<PrescriptionsBloc>(context).add(GetPastAppointmentWithPrescriptionsList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PrescriptionsBloc>(
      create: (BuildContext context) => PrescriptionsBloc()..add(GetPastAppointmentWithPrescriptionsList()),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child:
                SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
            ),
          ),
          body: BlocListener<PrescriptionsBloc, PrescriptionsState>(
            listener: (context, state) {
              if(state is EncounterWithPrescriptionsLoadedState){
                allEncounters = state.encounters;
              }
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            BackButtonLabel(),
                            Expanded(
                              child: header(
                                "Mis Recetas",
                                "Recetas",
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<PrescriptionsBloc, PrescriptionsState>(
                        builder: (context, state) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                await _filterBox(context);
                              },
                              child: SvgPicture.asset(
                                'assets/icon/filter-list.svg',
                              ),
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OrganizationType.pharmacy.page?? Container(),
                            ),
                          ),
                          icon: SvgPicture.asset(
                            OrganizationType.pharmacy.svgPath,
                            color: ConstantsV2.blueDark,
                          ),
                          label: Text(
                            'Ver Farmacias',
                            style: label.copyWith(
                              color: ConstantsV2.blueDark,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  BlocBuilder<PrescriptionsBloc, PrescriptionsState>(builder: (context, state){
                    if(state is EncounterWithPrescriptionsLoadedState){
                      if(allEncounters.isEmpty){
                        return const Expanded(
                          child:  EmptyStateV2(
                            picture: "empty_prescriptions.svg",
                            titleBottom: "Aún no tenés recetas",
                            textBottom:
                            "A medida en que uses la aplicación podrás ir viendo tus recetas",
                          ),
                        );
                      }else{
                        return Expanded(
                          child: SelectableWidgets<Encounter, download_prescriptions_bloc.Loading>(
                            enableSelectAll: false,
                            downloadEvent: (ids){
                              return download_prescriptions_bloc.DownloadPrescriptions(
                                listOfIds: ids,
                                context: context,
                              );
                            },
                            bloc: download_prescriptions_bloc.DownloadPrescriptionsBloc(),
                            items: (allEncounters).map((e) {
                              return SelectableWidgetItem<Encounter>(
                                child: PrescriptionCard(
                                  encounter: e,
                                ),
                                item: e,
                                id: e.prescriptions?.first.encounterId,
                              );
                            }).toList(),
                          ),
                        );
                      }
                    }else if(state is Loading){
                      return loadingStatus();
                    }else if(state is Failed){
                      return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<PrescriptionsBloc>(context).add(GetPastAppointmentWithPrescriptionsList()) ) ;
                    }else{
                      return Container();
                    }
                  }),
                ],
              ),
            ),
          )
      ),
    );
  }

  Future _filterBox(BuildContext prescriptionBlocContext){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController dateTextController = TextEditingController();
        TextEditingController date2TextController = TextEditingController();
        var inputFormat = DateFormat('dd/MM/yyyy');
        var outputFormat = DateFormat('yyyy-MM-dd');
        DateTime date1 = BlocProvider.of<PrescriptionsBloc>(prescriptionBlocContext).getInitialDate();
        DateTime? date2 = BlocProvider.of<PrescriptionsBloc>(prescriptionBlocContext).getFinalDate();
        dateTextController.text = inputFormat.format(date1);
        date2TextController.text = date2 != null? inputFormat.format(date2) :'';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsetsDirectional.all(0),
              scrollable: true,
              backgroundColor: ConstantsV2.lightGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filtrar recetas',
                            style: boldoTitleBlackTextStyle.copyWith(
                                color: ConstantsV2.activeText
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              'assets/icon/close.svg',
                              color: ConstantsV2.inactiveText,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                color: ConstantsV2.lightest,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text('Filtrar por fecha',
                                          style: boldoCorpSmallSTextStyle.copyWith(
                                              color: ConstantsV2.activeText
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                DateTime? newDate = await showDatePicker(
                                                    context: context,
                                                    initialEntryMode: DatePickerEntryMode
                                                        .calendarOnly,
                                                    initialDatePickerMode: DatePickerMode.day,
                                                    initialDate: date1 ?? DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: date2?? DateTime.now(),
                                                    locale: const Locale("es", "ES"),
                                                    builder: (context, child){
                                                      return Theme(
                                                        data: Theme.of(context).copyWith(
                                                            colorScheme: const ColorScheme.light(
                                                                primary: ConstantsV2.orange
                                                            )
                                                        ),
                                                        child: child!,
                                                      );
                                                    }
                                                );
                                                if (newDate == null) {
                                                  return;
                                                } else {
                                                  setState(() {
                                                    var outputFormat = DateFormat('yyyy-MM-dd');
                                                    var inputFormat = DateFormat('dd/MM/yyyy');
                                                    var _date1 =
                                                    outputFormat.parse(newDate.toString().trim());
                                                    var _date2 = inputFormat.format(_date1);
                                                    dateTextController.text = _date2;
                                                    date1 = _date1;
                                                  });
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icon/calendar.svg',
                                                    color: ConstantsV2.orange,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 6,),
                                                  Text('Desde: ${inputFormat.format(date1)}',
                                                    style: boldoCorpSmallSTextStyle.copyWith(
                                                        color: ConstantsV2.activeText
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                DateTime? newDate = await showDatePicker(
                                                    context: context,
                                                    initialEntryMode: DatePickerEntryMode
                                                        .calendarOnly,
                                                    initialDatePickerMode: DatePickerMode.day,
                                                    initialDate: date2 ?? date1,
                                                    firstDate: date1,
                                                    lastDate: DateTime.now(),
                                                    locale: const Locale("es", "ES"),
                                                    builder: (context, child){
                                                      return Theme(
                                                        data: Theme.of(context).copyWith(
                                                            colorScheme: const ColorScheme.light(
                                                                primary: ConstantsV2.orange
                                                            )
                                                        ),
                                                        child: child!,
                                                      );
                                                    }
                                                );
                                                if (newDate == null) {
                                                  return;
                                                } else {
                                                  setState(() {
                                                    var outputFormat = DateFormat('yyyy-MM-dd');
                                                    var inputFormat = DateFormat('dd/MM/yyyy');
                                                    var _date1 =
                                                    outputFormat.parse(newDate.toString().trim());
                                                    var _date2 = inputFormat.format(_date1);
                                                    date2TextController.text = _date2;
                                                    date2 = _date1;
                                                  });
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icon/calendar.svg',
                                                    color: ConstantsV2.orange,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(width: 6,),
                                                  Text('Hasta: ${date2 != null ? inputFormat.format(
                                                      date2!) : 'indefinido'}',
                                                    style: boldoCorpSmallSTextStyle.copyWith(
                                                        color: ConstantsV2.activeText
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
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed:() {
                              BlocProvider.of<PrescriptionsBloc>(prescriptionBlocContext).setInitialDate(date1);
                              BlocProvider.of<PrescriptionsBloc>(prescriptionBlocContext).setFinalDate(date2);
                              BlocProvider.of<PrescriptionsBloc>(prescriptionBlocContext).add(GetPastAppointmentWithPrescriptionsList());
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                Text('Aplicar',
                                  style: boldoCorpSmallSTextStyle.copyWith(
                                      color: ConstantsV2.lightGrey
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/icon/done.svg',
                                  color: ConstantsV2.lightGrey,
                                  height: 20,
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
            );
          }
        );
      },
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
