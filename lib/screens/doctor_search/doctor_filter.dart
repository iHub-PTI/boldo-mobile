import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DoctorFilter extends StatefulWidget {
  DoctorFilter();
  @override
  _DoctorFilterState createState() => _DoctorFilterState();
}

class _DoctorFilterState extends State<DoctorFilter> {
  bool _loading = true;
  bool? virtualAppointment;
  List<Doctor>? doctors;
  List<Specializations>? specializations;
  List<Specializations>? specializationsSelected;
  @override
  void initState() {
    specializationsSelected =
        Provider.of<DoctorFilterProvider>(context, listen: false)
            .getSpecializations;
    BlocProvider.of<DoctorsAvailableBloc>(context).add(GetSpecializations());
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
        child: BlocListener<DoctorsAvailableBloc, DoctorsAvailableState>(
          listener: (context, state) {
            if (state is Loading) {
              setState(() {
                _loading = true;
              });
            } else if (state is Success) {
              setState(() {
                _loading = false;
              });
            } else if (state is FilterLoaded) {
              setState(() {
                doctors = state.doctors;
              });
            } else if (state is SpecializationsLoaded) {
              setState(() {
                specializations = state.specializations;
              });
            }
          },
          child: Column(
            // all the possible space between the filter and button to apply the filters
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // button to go to back
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                            'Búsqueda de médicos',
                            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _loading
                      // loading
                      ? const Center(child: CircularProgressIndicator())
                      // list of specializations
                      : specializations != null
                          ? Container(
                              color: Colors.white,
                              height: 200,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: specializations!.length > 4
                                      ? 4
                                      : specializations!.length,
                                  itemBuilder: _specialization),
                            )
                          : Container(),
                  _loading
                      ? Container()
                      : Container(
                          height: 44,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  // show popup
                                  await _showSpecializations();
                                  setState(() {

                                  });
                                },
                                child: Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: ConstantsV2.rightBottonNavigaton,
                                    ),
                                    child: Center(child: Text('ver todos'))),
                              )
                            ],
                          ),
                        ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 168,
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // IN PERSON SECTION
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Provider.of<DoctorFilterProvider>(context,
                                      listen: false)
                                  .setInPersonAppointment();
                            });
                          },
                          child: Row(
                            // this for put the elements to the ends
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 14,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icon/person.svg',
                                      color: Provider.of<DoctorFilterProvider>(
                                                  context,
                                                  listen: false)
                                              .getInPersonAppointment
                                          ? ConstantsV2.green
                                          : ConstantsV2.inactiveText,
                                    ),
                                  ),
                                  // to press more easily
                                  Container(
                                    child: const Text(
                                      'Presencial',
                                      style: boldoSubTextMediumStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Provider.of<DoctorFilterProvider>(context,
                                          listen: false)
                                      .getInPersonAppointment
                                  // the circle
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        height: 36,
                                        width: 36,
                                        decoration: const BoxDecoration(
                                            color: ConstantsV2.lightGreen,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/icon/check-green.svg',
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        height: 36,
                                        width: 36,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/icon/minus.svg',
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        // VIRTUAL APPOINTMENT SECTION
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Provider.of<DoctorFilterProvider>(context,
                                      listen: false)
                                  .setVirtualAppointment();
                            });
                          },
                          child: Row(
                            // this for put the elements to the ends
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 14,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icon/videocam.svg',
                                      color: Provider.of<DoctorFilterProvider>(
                                                  context,
                                                  listen: false)
                                              .getVirtualAppointment
                                          ? ConstantsV2.buttonPrimaryColor100
                                          : ConstantsV2.inactiveText,
                                    ),
                                  ),
                                  // to press more easily
                                  Container(
                                    child: const Text(
                                      'Telemedicina',
                                      style: boldoSubTextMediumStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Provider.of<DoctorFilterProvider>(context,
                                          listen: false)
                                      .getVirtualAppointment
                                  // the circle of the right
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        height: 36,
                                        width: 36,
                                        decoration: const BoxDecoration(
                                            color: ConstantsV2.lightGreen,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/icon/check-green.svg',
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        height: 36,
                                        width: 36,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/icon/minus.svg',
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16)
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ConstantsV2.buttonPrimaryColor100,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Text(
                                'ver x coincidencia/s',
                                style: boldoCorpMediumBlackTextStyle.copyWith(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                'assets/icon/chevron-right.svg',
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specialization(BuildContext context, index) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 26.0, bottom: 26, left: 16, right: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (specializationsSelected!.contains(specializations![index])) {
              // delete item from specialization selected list
              Provider.of<DoctorFilterProvider>(context, listen: false)
                  .removeSpecialization(
                      specializationId: specializations![index].id!);
              // get the update list
              specializationsSelected =
                  Provider.of<DoctorFilterProvider>(context, listen: false)
                      .getSpecializations;
            } else {
              Provider.of<DoctorFilterProvider>(context, listen: false)
                  .addSpecializations(specialization: specializations![index]);
              // get the update list
              specializationsSelected =
                  Provider.of<DoctorFilterProvider>(
                      context,
                      listen: false)
                      .getSpecializations;
            }
          });
        },
        child: Container(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icon/filter.svg',
                height: 36,
                color:
                    specializationsSelected!.contains(specializations![index])
                        ? ConstantsV2.buttonPrimaryColor100
                        : ConstantsV2.inactiveText,
                //color: Colors.black,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                      child: Column(
                    children: [
                      Text(
                          '${specializations![index].description != null ? specializations![index].description! : 'Sin descripción'}')
                    ],
                  ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // show all specializations popup
  Future<void> _showSpecializations() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: const Text("Seleccione las especialidades"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actionsAlignment: MainAxisAlignment.end,
                actionsPadding: const EdgeInsets.only(right: 16.0, bottom: 16),
                actions: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, 'OK');
                    },
                    child: Container(
                      width: 115,
                      decoration: BoxDecoration(
                        color: ConstantsV2.buttonPrimaryColor100,
                        borderRadius: BorderRadius.circular(100)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              'aplicar',
                              style: boldoCorpMediumBlackTextStyle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              'assets/icon/check-green.svg',
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.height * 0.8,
                  child: RawScrollbar(
                    radius: const Radius.circular(8),
                    thickness: 6,
                    isAlwaysShown: true,
                    thumbColor: ConstantsV2.buttonPrimaryColor100,
                    child: ListView.builder(
                    itemCount: specializations!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8, right: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            color: specializationsSelected!
                                    .contains(specializations![index])
                                ? ConstantsV2.buttonPrimaryColor100.withOpacity(0.1)
                                : Colors.white,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (specializationsSelected!
                                    .contains(specializations![index])) {
                                  // delete item from specialization selected list
                                  Provider.of<DoctorFilterProvider>(context,
                                          listen: false)
                                      .removeSpecialization(
                                          specializationId:
                                              specializations![index].id!);
                                  // get the update list
                                  specializationsSelected =
                                      Provider.of<DoctorFilterProvider>(
                                              context,
                                              listen: false)
                                          .getSpecializations;
                                } else {
                                  Provider.of<DoctorFilterProvider>(context,
                                          listen: false)
                                      .addSpecializations(
                                          specialization:
                                              specializations![index]);
                                  // get the update list
                                  specializationsSelected =
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getSpecializations;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/filter.svg',
                                    height: 36,
                                    color: specializationsSelected!
                                            .contains(specializations![index])
                                        ? ConstantsV2.buttonPrimaryColor100
                                        : ConstantsV2.inactiveText,
                                    //color: Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.4,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          '${specializations![index].description}',
                                          style: boldoTitleBlackTextStyle
                                              .copyWith(
                                            fontSize: 16,
                                            color: specializationsSelected!
                                                    .contains(
                                                        specializations![
                                                            index])
                                                ? ConstantsV2
                                                    .buttonPrimaryColor100
                                                : ConstantsV2.inactiveText,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                  ),
                ),
              );
            },
          );
        });
  }

}