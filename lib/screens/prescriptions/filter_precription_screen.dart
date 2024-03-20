

import 'package:boldo/blocs/filter_bloc/filter_bloc.dart';
import 'package:boldo/blocs/filter_prescription_bloc/filter_prescription_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/filters/PrescriptionFilter.dart';
import 'package:boldo/network/doctor_repository.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/widgets/dropdownSearch.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var inputFormat = DateFormat('dd/MM/yyyy');
  var outputFormat = DateFormat('yyyy-MM-dd');

  bool formValidate = false;

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
                          style: boldoBodyLRegularTextStyle.copyWith(
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

  Widget doctorBoxFilter(){
    return FormField<Doctor>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<Doctor> state){
        return boxFilter(
          name: 'Doctor',
          child: DropdownSearch<Doctor>(
            listObjects: (String name) async {
              var result = DoctorRepository().getDoctorsFilter(
                0,
                [],
                true,
                true,
                [],
                [name],
              );

              PagList<Doctor> pageDoctors = await result;

              List<Doctor> doctors = pageDoctors.items?? [];

              return doctors;
            },
            emptyBuilder: (context, text){
              return const EmptyStateV2(
                titleBottom: 'No hay resultados',
                textBottom: 'No hay información disponible para los criterios de búsqueda especificados',
              );
            },
            toStringItem: (Doctor? doctor){
              return doctor?.givenName?? '';
            },
            onSelectItem: (Doctor? doctor){
              setState(() {
                prescriptionFilter.doctors = [doctor];
                state.didChange(doctor);
              });
            },
            selected: (prescriptionFilter.doctors?.isEmpty?? true)? null : prescriptionFilter.doctors?.first,
            onRemoveElement: (Doctor? doctor){
              prescriptionFilter.doctors?.removeWhere((element) => element == doctor);
              if(prescriptionFilter.doctors?.isEmpty?? true){
                prescriptionFilter.doctors= null;
              }
              setState(() {
                state.didChange(null);
              });
            },
          ),
        );
      }
    );
  }

  Widget boxFilter({required String name, Widget? child}){
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
              child: Text(name,
                style: boldoCorpSmallSTextStyle.copyWith(
                    color: ConstantsV2.activeText
                ),
              ),
            ),
            if(child != null)
              child,
          ],
        ),
      ),
    );
  }

  Widget dateFilter(){

    return FormField<MapEntry<DateTime?, DateTime?>>(
      autovalidateMode: AutovalidateMode.onUserInteraction,

      validator: (value){
        if(prescriptionFilter.start == null && prescriptionFilter.end != null){
          return 'Por favor, coloca la fecha "Desde" para definir un rango válido';
        } else if(prescriptionFilter.start != null && prescriptionFilter.end == null) {
          return 'Por favor, coloca la fecha "Hasta" para definir un rango válido';
        }
        return null;
      },
      builder: (FormFieldState<MapEntry<DateTime?, DateTime?>> state){

        InputBorder? shape = InputBorder.none;

        if(state.hasError){
          shape = OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).inputDecorationTheme.errorBorder?.borderSide.color
                  ?? ConstantsV2.systemFail,
            )
          );
        }

        return Container(
          decoration: BoxDecoration(
            boxShadow: state.hasError? null: [
              shadowRegular,
            ],
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              fillColor: ConstantsV2.lightest,
              filled: true,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: shape,
              errorText: state.errorText,
            ),
            child: Container(
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
                        state.didChange(MapEntry(prescriptionFilter.start, prescriptionFilter.end,));
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
                        state.didChange(MapEntry(prescriptionFilter.start, prescriptionFilter.end,));
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
        );
      },
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
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder?.copyWith(
                                    borderSide: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.copyWith(
                                      color: ConstantsV2.secondaryRegular,
                                      width: 1.32,
                                    ),
                                  ),
                                  focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder?.copyWith(
                                    borderSide: Theme.of(context).inputDecorationTheme.focusedBorder?.borderSide.copyWith(
                                      color: ConstantsV2.secondaryRegular,
                                      width: 1.32,
                                    ),
                                  ),
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                onChanged: (){
                                  formValidate = _formKey.currentState?.validate()?? false;
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    dateFilter(),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    doctorBoxFilter(),
                                  ],
                                ),
                              ),
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
    return BlocBuilder<FilterPrescriptionBloc, FilterState>(
      builder: (context, state){
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
                    ApplyFilter(
                      filter: prescriptionFilter,
                      function:
                          (filter)=> widget.filterCallback(filter as PrescriptionFilter),
                      context: context,
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
              onPressed: prescriptionFilter != widget.initialFilter && formValidate? () {
                BlocProvider.of<FilterPrescriptionBloc>(context).add(
                    ApplyFilter(
                        filter: prescriptionFilter,
                        function:
                            (filter) =>
                            widget.filterCallback(
                                filter as PrescriptionFilter),
                        context: context
                    )
                );
              }: null,
              child: const Row(
                children: [
                  Text(
                    'Ver resultados',
                  ),
                  Icon(Icons.arrow_forward_rounded)
                ],
              ),
            ),
          ],
        ),
      );
      },
    );
  }

}
