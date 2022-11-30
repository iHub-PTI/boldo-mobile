import 'package:boldo/main.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import 'attach_files.dart';

class NewStudy extends StatefulWidget {
  NewStudy({Key? key}) : super(key: key);

  @override
  State<NewStudy> createState() => _NewStudyState();
}

class _NewStudyState extends State<NewStudy> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController dateTextController = TextEditingController();
  final _nameController = TextEditingController();
  String nombre = '';
  String fecha = '';
  String notas = '';
  String? type;
  bool enable = false;

  final List<StudiesCards> items = [
    StudiesCards(
      key: UniqueKey(),
      image: 'assets/icon/lab.svg',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 0,
      title: 'lab.',
      value: "LABORATORY",
    ),
    StudiesCards(
      key: UniqueKey(),
      image: 'assets/icon/image.svg',
      boxFit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      index: 1,
      title: 'img.',
      value: "IMAGE",
    ),
    StudiesCards(
      key: UniqueKey(),
      image: 'assets/icon/other.svg',
      boxFit: BoxFit.cover,
      alignment: Alignment.centerLeft,
      index: 2,
      title: 'otros',
      value: "OTHER",
    ),
  ];

  @override
  void initState() {
    // Delete studies
    BlocProvider.of<MyStudiesBloc>(context).add(DeleteFiles());
    super.initState();
  }

  @override
  void dispose() {
    dateTextController.dispose();
    _nameController.dispose();
    super.dispose();
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
        child: BlocListener<MyStudiesBloc, MyStudiesState>(
          listener: (context, state) {
            if (state is Loading) {
              print('loading');
            }
            if (state is Failed) {
              print('failed: ${state.msg}');
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.msg)));
            }
          },
          child: SingleChildScrollView(
            //  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
               const SizedBox(
                  height: 10,
                ),
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
                    'Nuevo estudio',
                    style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cargá los siguientes datos básicos sobre el resultado de tu estudio.",
                              style: boldoCorpSmallTextStyle.copyWith(
                                  color: ConstantsV2.inactiveText,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      )),
                      ProfileImageView2(
                        height: 54,
                        width: 54,
                        border: true,
                        patient: patient,
                        color: ConstantsV2.orange,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(hintText: "Nombre del estudio"),
                          onChanged: (value){
                            nombre = value;
                            setState(() {

                            });
                          },
                          validator: (value){
                            //remove unnecessary spaces
                            value = value?.trimLeft().trimRight() ?? '';
                            if(value.isEmpty){
                              return "Ingrese un nombre";
                            }
                            nombre = value;
                            _nameController.text =
                                value.trimLeft().trimRight() ?? '';
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: dateTextController,
                          inputFormatters: [DateTextFormatter()],
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            setState(() {

                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese la fecha del estudio';
                            } else {
                              try {
                                var inputFormat = DateFormat('dd/MM/yyyy');
                                var outputFormat = DateFormat('yyyy-MM-dd');
                                // use parseStrict to not accept overflow date
                                var date1 = inputFormat
                                    .parseStrict(value.toString().trim());
                                if(date1.isBefore(minDate)){
                                  throw Failure('Fecha inferior al minimo ${inputFormat.format(minDate)}');
                                }else if(date1.isAfter(DateTime.now())){
                                  throw Failure('Fecha superior a la actual');
                                }
                                var date2 = outputFormat.format(date1);
                                fecha = date2;
                              } on Failure catch (e) {
                                return e.message;
                              } catch (e) {
                                return 'El formato debe ser "dd/mm/yyyy" ';
                              }
                            }
                          },
                          decoration: InputDecoration(
                            hintText: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                            suffixIcon: Align(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: GestureDetector(
                                onTap: () async {
                                  DateTime? newDate = await showDatePicker(
                                    context: context,
                                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                                    initialDatePickerMode: DatePickerMode.year,
                                    initialDate: fecha == '' ? DateTime.now() :
                                    DateFormat('yyyy-MM-dd')
                                        .parseStrict(fecha.toString().trim()),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    locale: const Locale("es", "ES"),
                                  );
                                  if (newDate == null) {
                                    return;
                                  } else {
                                    setState(() {
                                      var outputFormat = DateFormat('yyyy-MM-dd');
                                      var inputFormat = DateFormat('dd/MM/yyyy');
                                      // use parseStrict to not accept overflow date
                                      var date1 =
                                      outputFormat.parseStrict(newDate.toString().trim());
                                      var date2 = inputFormat.format(date1);
                                      dateTextController.text = date2;
                                    });
                                  }
                                },
                                child: SvgPicture.asset(
                                  'assets/icon/calendar.svg',
                                  color: ConstantsV2.inactiveText,
                                  height: 20,
                                ),
                              ),
                            ),
                            labelText: "Fecha de estudio (dd/mm/yyyy)",
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(hintText: "Notas (opcional)"),
                          onChanged: (value){
                            notas = value;
                          },
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          height: 76,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: _buildCarousel,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 136,
                              child: ElevatedButton (
                                onPressed: enable && _formKey.currentState!.validate() ? () async {
                                  if(_formKey.currentState!.validate()){
                                    DiagnosticReport newDiagnosticReport = DiagnosticReport(
                                        description: nombre,
                                        patientNotes: notas,
                                        effectiveDate: fecha,
                                        type: type);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AttachFiles(
                                                  diagnosticReport:
                                                  newDiagnosticReport)),
                                    );
                                  }
                                }: null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('siguiente'),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.chevron_right,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  showEmptyList() {
    return Column(
      children: [
        SvgPicture.asset('assets/images/empty_studies.svg', fit: BoxFit.cover),
        Text('Aun no tenés estudios para visualizar')
      ],
    );
  }

  Widget _buildCarousel(BuildContext context, int index){
    return Container(
      child: Card(
        margin: const EdgeInsets.all(6),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap:() {
            setState(() {
              if(type == items[index].value) {
                type = "";
                enable = false;
                _formKey.currentState!.validate();
              }else{
                type = items[index].value;
                enable = true;
                _formKey.currentState!.validate();
              }
            });
          },
          child: Container(
            color: type != items[index].value ? ConstantsV2.lightest : ConstantsV2.orange,
            width: 60,
            padding: const EdgeInsets.only(
                left: 6, right: 6, bottom: 7, top: 7),
            child: Column(
              children: [
                // Container that define the image background
                Container(
                  child: SvgPicture.asset(
                    items[index].image,
                    fit: items[index].boxFit,
                    alignment: items[index].alignment,
                    color: type != items[index].value ? ConstantsV2.inactiveText : ConstantsV2.lightest,
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index].title,
                        style: boldoCorpMediumBlackTextStyle.copyWith(color: type != items[index].value ? ConstantsV2.inactiveText : ConstantsV2.lightest),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class StudiesCards extends StatelessWidget {
  final String image;
  final int index;
  final BoxFit boxFit;
  final Alignment alignment;
  final String title;
  final String value;

  const StudiesCards({
    Key? key,
    required this.image,
    required this.boxFit,
    required this.alignment,
    required this.index,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(image, fit: boxFit, alignment: alignment);
  }
}