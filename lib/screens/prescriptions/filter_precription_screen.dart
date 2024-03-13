

import 'package:boldo/blocs/filter_bloc/filter_bloc.dart';
import 'package:boldo/blocs/filter_prescription_bloc/filter_prescription_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/filters/PrescriptionFilter.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/header_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class FilterPrescriptionsScreen extends StatefulWidget {

  final PrescriptionFilter initialFilter;
  final Function(PrescriptionFilter filter) filterCallback;

  const FilterPrescriptionsScreen({
    super.key,
    required this.initialFilter,
    required this.filterCallback,
  }) : super();

  @override
  _FilterPrescriptionsScreenState createState() => _FilterPrescriptionsScreenState();
}

class _FilterPrescriptionsScreenState extends State<FilterPrescriptionsScreen> {

  PrescriptionFilter prescriptionFilter = PrescriptionFilter();
  TextEditingController dateTextController = TextEditingController();
  TextEditingController date2TextController = TextEditingController();
  var inputFormat = DateFormat('dd/MM/yyyy');
  var outputFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();

    prescriptionFilter = widget.initialFilter.copyWith();
    if( prescriptionFilter.start != null) {
      dateTextController.text =
          inputFormat.format(prescriptionFilter.start!);
    }

    if( prescriptionFilter.end != null) {
      date2TextController.text =
          inputFormat.format(prescriptionFilter.end!);
    }

  }

  Widget datePicker({
    required BuildContext context,
    required DateTime firstDate,
    required DateTime initialDate,
    required DateTime lastDate,
    required Function(DateTime selectedDate) callback,
    String? hintText,
    Function? cancelCallback,
    DateTime? selectedDate,
  }){
    return Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              DateTime? newDate = await showDatePicker(
                  context: context,
                  initialEntryMode: DatePickerEntryMode
                      .calendarOnly,
                  initialDatePickerMode: DatePickerMode.day,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
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
                callback.call(newDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: selectedDate != null? const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(16)
                  ),
                  side: BorderSide(
                    width: 0.5,
                    color: ConstantsV2.gray,
                  ),
                ),
              ) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: SvgPicture.asset(
                          'assets/icon/calendar.svg',
                          color: ConstantsV2.orange,
                          height: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('$hintText: ${selectedDate != null
                            ? inputFormat.format(
                            selectedDate
                        ): ''}',
                          style: boldoCorpSmallSTextStyle.copyWith(
                              color: ConstantsV2.activeText
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: selectedDate != null,
                    child: InkWell(
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: ConstantsV2.gray,
                        size: 18,
                      ),
                      onTap: ()=> cancelCallback?.call(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dateFilter(){
    return Container(
      decoration: ShapeDecoration(
        color: ConstantsV2.lightest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        shadows: [
          shadowRegular,
        ],
      ),
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
            datePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: prescriptionFilter.start ?? DateTime.now(),
              lastDate: prescriptionFilter.end ?? DateTime.now(),
              callback: (DateTime newDate){
                setState(() {
                  var _date1 =
                  outputFormat.parse(newDate.toString().trim());
                  var _date2 = inputFormat.format(_date1);
                  dateTextController.text = _date2;
                  prescriptionFilter.start = _date1;
                });
              },
              cancelCallback: (){
                setState(() {
                  dateTextController.text = '';
                  prescriptionFilter.start = null;
                });
              },
              hintText: "Desde",
              selectedDate: prescriptionFilter.start,
            ),
            const SizedBox(
              height: 4,
            ),
            datePicker(
              context: context,
              firstDate: prescriptionFilter.start?? DateTime.now(),
              initialDate: prescriptionFilter.end ?? prescriptionFilter.start?? DateTime.now(),
              lastDate: DateTime.now(),
              callback: (DateTime newDate){
                setState(() {
                  var _date1 =
                  outputFormat.parse(newDate.toString().trim());
                  var _date2 = inputFormat.format(_date1);
                  date2TextController.text = _date2;
                  prescriptionFilter.end = _date1;
                });
              },
              cancelCallback: (){
                setState(() {
                  date2TextController.text = '';
                  prescriptionFilter.end = null;
                });
              },
              hintText: "Hasta",
              selectedDate: prescriptionFilter.end,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FilterPrescriptionBloc>(
      create: (BuildContext context) => FilterPrescriptionBloc(),
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
        body: SafeArea(
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
                              "Filtrar",
                              "Filtrar",
                              showPatientPicture: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: ShapeDecoration(
                                      color: ConstantsV2.lightest,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      shadows: [
                                        shadowRegular,
                                      ]
                                  ),
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
                                        datePicker(
                                          context: context,
                                          firstDate: DateTime(1900),
                                          initialDate: prescriptionFilter.start ?? DateTime.now(),
                                          lastDate: prescriptionFilter.end ?? DateTime.now(),
                                          callback: (DateTime newDate){
                                            setState(() {
                                              var _date1 =
                                              outputFormat.parse(newDate.toString().trim());
                                              var _date2 = inputFormat.format(_date1);
                                              dateTextController.text = _date2;
                                              prescriptionFilter.start = _date1;
                                            });
                                          },
                                          cancelCallback: (){
                                            setState(() {
                                              dateTextController.text = '';
                                              prescriptionFilter.start = null;
                                            });
                                          },
                                          hintText: "Desde",
                                          selectedDate: prescriptionFilter.start,
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        datePicker(
                                          context: context,
                                          firstDate: prescriptionFilter.start?? DateTime.now(),
                                          initialDate: prescriptionFilter.end ?? prescriptionFilter.start?? DateTime.now(),
                                          lastDate: DateTime.now(),
                                          callback: (DateTime newDate){
                                            setState(() {
                                              var _date1 =
                                              outputFormat.parse(newDate.toString().trim());
                                              var _date2 = inputFormat.format(_date1);
                                              date2TextController.text = _date2;
                                              prescriptionFilter.end = _date1;
                                            });
                                          },
                                          cancelCallback: (){
                                            setState(() {
                                              date2TextController.text = '';
                                              prescriptionFilter.end = null;
                                            });
                                          },
                                          hintText: "Hasta",
                                          selectedDate: prescriptionFilter.end,
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
                      actions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actions(){
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            shadowRegular,
          ],
          color: ConstantsV2.grayLightest
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: prescriptionFilter.ifFiltered? () {
              prescriptionFilter.clearFilter();
              BlocProvider.of<FilterPrescriptionBloc>(context).add(
                  ApplyFilter<PrescriptionFilter>(
                      filter: prescriptionFilter,
                      function:
                          (filter)=> widget.filterCallback(filter),
                      context: context
                  )
              );
            }: null,
            child: const Row(
              children: [
                Text('Limpiar filtros',
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: prescriptionFilter != widget.initialFilter? () {
              BlocProvider.of<FilterPrescriptionBloc>(context).add(
                  ApplyFilter<PrescriptionFilter>(
                      filter: prescriptionFilter,
                      function:
                          (filter)=> widget.filterCallback(filter),
                      context: context
                  )
              );
            }: null,
            child: const Row(
              children: [
                const Text('Ver resultados',
                ),
                Icon(Icons.arrow_forward_rounded)
              ],
            ),
          ),
        ],
      ),
    );
  }

}
