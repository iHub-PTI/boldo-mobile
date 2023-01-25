import 'package:boldo/blocs/doctorFilter_bloc/doctorFilter_bloc.dart';
import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/blocs/homeOrganization_bloc/homeOrganization_bloc.dart';
import 'package:boldo/blocs/specializationFilter_bloc/specializationFilter_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
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
  bool _loadingFilter = false;
  bool _specializationsFailed = false;
  String _filterFailed = "Hubo un fallo durante la aplicación del filtro.";
  bool virtualAppointment = false;
  bool inPersonAppointment = false;

  List<Organization> organizations = [];
  List<Organization> organizationsSelected = [];
  List<Doctor>? doctors;
  List<Specializations> specializations = [];
  List<Specializations> specializationsSelected = [];
  List<Specializations>? specializationsSelectedCopy;
  @override
  void initState() {
    specializationsSelected =
        Provider.of<DoctorFilterProvider>(context, listen: false)
            .getSpecializations;
    virtualAppointment =
        Provider.of<DoctorFilterProvider>(context, listen: false)
            .getVirtualAppointment;
    inPersonAppointment =
        Provider.of<DoctorFilterProvider>(context, listen: false)
            .getInPersonAppointment;
    organizationsSelected = Provider.of<DoctorFilterProvider>(context, listen: false)
        .getOrganizations;
    if(Provider.of<DoctorFilterProvider>(context, listen: false)
        .getFilterState)
      BlocProvider.of<DoctorFilterBloc>(context).add(GetDoctorsPreview(
          specializations: specializationsSelected,
          virtualAppointment: virtualAppointment,
          inPersonAppointment: inPersonAppointment,
          organizations: organizationsSelected));
    BlocProvider.of<SpecializationFilterBloc>(context).add(GetSpecializations());
    BlocProvider.of<HomeOrganizationBloc>(context).add(GetOrganizationsSubscribed());
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
        child: MultiBlocListener(
          listeners: [
            BlocListener<DoctorFilterBloc, DoctorFilterState>(
              listener: (context, state) {
                if (state is SuccessDoctorFilter) {
                  setState(() {
                    virtualAppointment =
                        Provider.of<DoctorFilterProvider>(context, listen: false)
                            .getVirtualAppointment;
                    inPersonAppointment =
                        Provider.of<DoctorFilterProvider>(context, listen: false)
                            .getInPersonAppointment;
                    doctors = state.doctorList;
                  });
                } else if (state is FilterFailed) {
                  setState(() {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(_filterFailed)));
                  });
                }
              }
            ),
            BlocListener<SpecializationFilterBloc, SpecializationFilterState>(
                listener: (context, state) {
                  if (state is SuccessSpecializationFilter) {
                    specializations = state.specializationsList;
                  } else if (state is FailedSpecializationFilter) {
                    setState(() {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(_filterFailed)));
                    });
                  }
                }
            ),
          BlocListener<HomeOrganizationBloc, HomeOrganizationBlocState>(
                listener: (context, state) {
                  if (state is OrganizationsObtained) {
                    organizations = state.organizationsList;
                  } else if (state is FailedSpecializationFilter) {
                    setState(() {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(_filterFailed)));
                    });
                  }
                }
            )
          ],
          child: Column(
            // all the possible space between the filter and button to apply the filters
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'Filtros',
                        style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      BlocBuilder<SpecializationFilterBloc, SpecializationFilterState>(
                          builder: (context, state){
                            if(state is FailedSpecializationFilter){
                              DataFetchErrorWidget(
                                  retryCallback: () =>
                                      BlocProvider.of<SpecializationFilterBloc>(context)
                                          .add(GetSpecializations()));
                            }if (state is SuccessSpecializationFilter){
                              return Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    height: 200,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: specializations.length > 4
                                            ? 4
                                            : specializations.length,
                                        itemBuilder: _specialization),
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 44,
                                        width: MediaQuery.of(context).size.width,
                                        color: Colors.white,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          specializationsSelected != null
                                              ? specializationsSelected!.length > 0
                                              ? _loadingFilter
                                              ? const Center(child: CircularProgressIndicator())
                                              : Card(
                                              clipBehavior: Clip.antiAlias,
                                              color: ConstantsV2.orange,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: Container(
                                                padding:
                                                const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                                child: Text(
                                                    "${specializationsSelected!.length}"),
                                              )
                                          )
                                              : Container()
                                              : Container(),
                                          const SizedBox(width: 5),
                                          GestureDetector(
                                            onTap: () async {
                                              // because the direct assignment only references
                                              specializationsSelectedCopy =
                                                  specializationsSelected!.toList();
                                              // show popup
                                              await _showSpecializations();
                                              setState(() {
                                                specializationsSelected =
                                                    Provider.of<DoctorFilterProvider>(
                                                        context,
                                                        listen: false)
                                                        .getSpecializations;
                                              });
                                            },
                                            child: Container(
                                                width: 100,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(6),
                                                  color:
                                                  ConstantsV2.rightBottonNavigaton,
                                                ),
                                                child: const Center(
                                                    child: Text('ver todos')
                                                )
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              );
                            }else{
                              return  const Center(child: CircularProgressIndicator());
                            }
                          }
                      ),
                      const SizedBox(height: 8),
                      Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          color: ConstantsV2.lightest,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                        value: inPersonAppointment,
                                        onChanged: (value) {
                                          setState(() {
                                            Provider.of<DoctorFilterProvider>(context,
                                                listen: false)
                                                .setInPersonAppointment(context: context);
                                            inPersonAppointment = Provider.of<DoctorFilterProvider>(context,
                                                listen: false)
                                                .getInPersonAppointment;
                                            BlocProvider.of<DoctorFilterBloc>(context).add(
                                                GetDoctorsPreview(
                                                    specializations: specializationsSelected,
                                                    virtualAppointment: virtualAppointment,
                                                    inPersonAppointment: inPersonAppointment,
                                                    organizations: organizationsSelected
                                                )
                                            );
                                          });
                                        }
                                    ),
                                    Container(
                                        child: Row(
                                          children: [
                                            Text(
                                              "Presencial",
                                              style: boldoCorpMediumTextStyle.copyWith(
                                                  color: ConstantsV2.activeText
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            SvgPicture.asset(
                                              'assets/icon/person.svg',
                                              color: ConstantsV2.green,
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                        value: virtualAppointment,
                                        onChanged: (value) {
                                          setState(() {
                                            Provider.of<DoctorFilterProvider>(context,
                                                listen: false)
                                                .setVirtualAppointment(context: context);
                                            virtualAppointment = Provider.of<DoctorFilterProvider>(context,
                                                listen: false)
                                                .getVirtualAppointment;
                                            BlocProvider.of<DoctorFilterBloc>(context).add(
                                                GetDoctorsPreview(
                                                    specializations: specializationsSelected,
                                                    virtualAppointment: virtualAppointment,
                                                    inPersonAppointment: inPersonAppointment,
                                                    organizations: organizationsSelected
                                                )
                                            );
                                          });
                                        }
                                    ),
                                    Container(
                                      child: Container(
                                          child: Row(
                                            children: [
                                              Text(
                                                "Remoto",
                                                style: boldoCorpMediumTextStyle.copyWith(
                                                    color: ConstantsV2.activeText
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              SvgPicture.asset(
                                                'assets/icon/videocam.svg',
                                                color: ConstantsV2.orange,
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                      ),
                      BlocBuilder<HomeOrganizationBloc, HomeOrganizationBlocState>(
                          builder: (context, state){
                            if(state is HomeOrganizationFailed){
                              DataFetchErrorWidget(
                                  retryCallback: () =>
                                      BlocProvider.of<HomeOrganizationBloc>(context)
                                          .add(GetOrganizationsSubscribed()));
                            }if (state is OrganizationsObtained){
                              return Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                color: ConstantsV2.lightest,
                              child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  shrinkWrap: true,
                                  itemCount: organizations.length,
                                  itemBuilder: _organizationSelector,
                                  physics: const ClampingScrollPhysics(),
                                ),
                              );
                            }else{
                              return  const Center(child: CircularProgressIndicator());
                            }
                          }
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 16),
                    child: Container(
                      child: TextButton(
                          onPressed: () {
                            Provider.of<DoctorFilterProvider>(context,
                                listen: false)
                                .filterApplied(
                                specializationsApplied:
                                [],
                                virtualAppointmentApplied:
                                false,
                                inPersonAppointmentApplied:
                                false,
                                organizationsApplied: []);
                            Provider.of<DoctorFilterProvider>(context,
                                listen: false)
                                .clearFilter();
                            BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorFilter(
                                specializations: [],
                                virtualAppointment: false,
                                inPersonAppointment: false,
                                organizations: []));
                            // call doctor list page
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Limpiar filtros',
                          )
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        // to disable the button
                        if (doctors != null && doctors!.length > 0) {
                          Provider.of<DoctorFilterProvider>(context,
                              listen: false)
                              .filterApplied(
                              specializationsApplied:
                              specializationsSelected,
                              virtualAppointmentApplied:
                              virtualAppointment,
                              inPersonAppointmentApplied:
                              inPersonAppointment,
                              organizationsApplied: organizationsSelected);
                          Provider.of<DoctorFilterProvider>(context,
                              listen: false)
                              .setDoctors(doctors: doctors!);
                          BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorFilter(
                              specializations: specializationsSelected,
                              virtualAppointment: virtualAppointment,
                              inPersonAppointment: inPersonAppointment,
                              organizations: organizationsSelected));
                          // call doctor list page
                          Navigator.pop(context);
                        }
                      },
                      child: BlocBuilder<DoctorFilterBloc, DoctorFilterState>(
                        builder: (context, state){
                          if(state is LoadingDoctorFilter){
                            return const Center(child: CircularProgressIndicator());
                          }else if(state is SuccessDoctorFilter || state is DoctorFilterInitial){
                            return Container(
                              decoration: BoxDecoration(
                                color: !Provider.of<DoctorFilterProvider>(
                                    context,
                                    listen: false).getFilterState
                                    ? ConstantsV2.gray
                                    : (doctors?.length?? 0) > 0
                                    ? ConstantsV2
                                    .buttonPrimaryColor100
                                    : ConstantsV2.gray,
                                borderRadius:
                                BorderRadius.circular(100),
                                boxShadow: !Provider.of<DoctorFilterProvider>(
                                    context,
                                    listen: false).getFilterState
                                    ? [
                                  const BoxShadow(
                                    color: Color(0x00000000),
                                    blurRadius: 4,
                                    offset: Offset(0,
                                        2), // changes position of shadow
                                  ),
                                ]
                                    : [],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: !Provider.of<DoctorFilterProvider>(
                                    context,
                                    listen: false).getFilterState
                                    ? Text(
                                  'aplique algún filtro',
                                  style: boldoCorpMediumBlackTextStyle
                                      .copyWith(
                                      fontSize: 16,
                                      color: ConstantsV2
                                          .inactiveText),
                                )
                                    : (doctors?.length?? 0) > 0
                                    ? Row(
                                  children: [
                                    Text(
                                      'ver ${(doctors?.length?? 0)} ${(doctors?.length?? 0) == 1 ? 'coincidencia' : 'coincidencias'}',
                                      style:
                                      boldoCorpMediumBlackTextStyle
                                          .copyWith(
                                          fontSize:
                                          16),
                                    ),
                                    const SizedBox(
                                        width: 8),
                                    SvgPicture.asset(
                                      'assets/icon/chevron-right.svg',
                                      color: Colors.white,
                                    )
                                  ],
                                )
                                    : Text(
                                  'sin coincidencias',
                                  style: boldoCorpMediumBlackTextStyle
                                      .copyWith(
                                      fontSize: 16,
                                      color: ConstantsV2
                                          .inactiveText),
                                ),
                              ),
                            );
                          }else {
                            return Container();
                          }
                        },
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
            if (specializationsSelected
                .any((element) => element.id == specializations[index].id)) {
              // delete item from specialization selected list
              Provider.of<DoctorFilterProvider>(context, listen: false)
                  .removeSpecialization(
                      specializationId: specializations[index].id?? "0",
                      context: context);
              // get the update list
              specializationsSelected =
                  Provider.of<DoctorFilterProvider>(context, listen: false)
                      .getSpecializations;
            } else {
              Provider.of<DoctorFilterProvider>(context, listen: false)
                  .addSpecializations(
                      specialization: specializations[index],
                      context: context);
              // get the update list
              specializationsSelected =
                  Provider.of<DoctorFilterProvider>(context, listen: false)
                      .getSpecializations;
            }
            BlocProvider.of<DoctorFilterBloc>(context).add(GetDoctorsPreview(
                specializations: specializationsSelected,
                virtualAppointment: virtualAppointment,
                inPersonAppointment: inPersonAppointment,
                organizations: organizationsSelected));
          });
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle ,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            color: specializationsSelected.any(
                    (element) => element.id == specializations[index].id)
                ? ConstantsV2.orange.withOpacity(.8)
                : Colors.transparent
          ),
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                shape: StadiumBorder(),
                color: ConstantsV2.orange,
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text("${specializations[index].description?[0]?? ""}"),
                  ),
                )
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                      child: Column(
                    children: [
                      Text(
                          '${specializations[index].description != null ? specializations[index].description : 'Sin descripción'}')
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

  Widget _organizationSelector(BuildContext context, index) {

    return
      Row(
        children: [
          Checkbox(
              value: organizationsSelected.any((element) => element.id == organizations[index].id),
              onChanged: (value) {
                setState(() {
                  bool status = value?? false;
                  if(status) {
                    Provider.of<DoctorFilterProvider>(context,
                        listen: false)
                        .addOrganization(
                        context: context, organization: organizations[index]);
                    organizationsSelected = Provider
                        .of<DoctorFilterProvider>(context,
                        listen: false)
                        .getOrganizations;
                  }else{
                    Provider.of<DoctorFilterProvider>(context,
                        listen: false)
                        .removeOrganization(
                        context: context, organizationId: organizations[index].id?? '0');
                    organizationsSelected = Provider
                        .of<DoctorFilterProvider>(context,
                        listen: false)
                        .getOrganizations;
                  }
                });
              }
          ),
          Container(
            child: Container(
                child: Row(
                  children: [
                    Text(
                      "${organizations[index].name?? 'Desconocido'}",
                      style: boldoCorpMediumTextStyle.copyWith(
                          color: ConstantsV2.activeText
                      ),
                    ),
                  ],
                )
            ),
          ),
        ],
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
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Row(
                        children: [
                          Flexible(
                              child: Column(
                            children: [
                              const Text("Seleccione las especialidades")
                            ],
                          ))
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, 'Cancel');
                      },
                      child: SvgPicture.asset(
                        'assets/icon/close.svg',
                        color: ConstantsV2.inactiveText,
                        height: 36,
                        width: 36,
                      ),
                    )
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actionsAlignment: MainAxisAlignment.end,
                actionsPadding: const EdgeInsets.only(right: 16.0, bottom: 16),
                actions: [
                  GestureDetector(
                    onTap: () {
                      Provider.of<DoctorFilterProvider>(context, listen: false)
                          .setSpecializations(
                              specializationsSelectedCopy:
                                  specializationsSelectedCopy!,
                              context: context);
                      Navigator.pop(context, 'OK');
                    },
                    child: Container(
                      width: 115,
                      decoration: BoxDecoration(
                          color: ConstantsV2.buttonPrimaryColor100,
                          borderRadius: BorderRadius.circular(100)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              'aplicar',
                              style: boldoCorpMediumBlackTextStyle.copyWith(
                                  fontSize: 16),
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
                              padding:
                                  const EdgeInsets.only(bottom: 8, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  color: specializationsSelectedCopy!.any(
                                          (element) =>
                                              element.id ==
                                              specializations![index].id)
                                      ? ConstantsV2.buttonPrimaryColor100
                                          .withOpacity(0.1)
                                      : Colors.white,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (specializationsSelectedCopy!.any(
                                          (element) =>
                                              element.id ==
                                              specializations![index].id)) {
                                        // delete item from specialization selected copy
                                        specializationsSelectedCopy =
                                            specializationsSelectedCopy!
                                                .where((element) =>
                                                    element.id !=
                                                    specializations![index].id)
                                                .toList();
                                      } else {
                                        specializationsSelectedCopy!
                                            .add(specializations![index]);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Card(
                                            shape: StadiumBorder(),
                                            color: ConstantsV2.orange,
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              padding: EdgeInsets.all(16),
                                              child: Center(
                                                child: Text("${specializations[index].description?[0]?? ""}"),
                                              ),
                                            )
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                '${specializations![index].description}',
                                                style: boldoTitleBlackTextStyle
                                                    .copyWith(
                                                  fontSize: 16,
                                                  color: specializationsSelectedCopy!
                                                          .any((element) =>
                                                              element.id ==
                                                              specializations![
                                                                      index]
                                                                  .id)
                                                      ? ConstantsV2
                                                          .buttonPrimaryColor100
                                                      : ConstantsV2
                                                          .inactiveText,
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })),
                ),
              );
            },
          );
        });
  }
}
