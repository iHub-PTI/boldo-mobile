import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart' as family_bloc;
import 'package:boldo/blocs/homeOrganization_bloc/homeOrganization_bloc.dart' as home_organization;
import 'package:boldo/blocs/organizationSubscribed_bloc/organizationSubscribed_bloc.dart' as subscribed;
import 'package:boldo/blocs/organizationApplied_bloc/organizationApplied_bloc.dart' as applied;
import 'package:boldo/blocs/organization_bloc/organization_bloc.dart';
import 'package:boldo/blocs/user_bloc/patient_bloc.dart' as patientBloc;
import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class Organizations extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    bool has_organizations = BlocProvider.of<patientBloc.PatientBloc>(context).getOrganizations().isNotEmpty || organizationsPostulated.isNotEmpty;

    return has_organizations ? OrganizationsSubscribedScreen() : OrganizationsScreen();

  }

}

class OrganizationsScreen extends StatefulWidget {
  const OrganizationsScreen({
    Key? key,
  }) : super(key: key);

  @override
  _OrganizationsScreenState createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {

  List<Organization> _organizationsNotSubscribed = [];
  List<Organization> _organizationsSelected = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganizationBloc>(
      create: (context) => OrganizationBloc()..add(GetAllOrganizations()),
      child: Scaffold(
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
        child: Container(
          child: BlocListener<OrganizationBloc, OrganizationBlocState>(
            listener: (context, state) {
              if (state is OrganizationsObtained) {
                _organizationsNotSubscribed = state.organizationsList;

              }
              if(state is SuccessSubscribed){

                String text = _organizationsSelected.length == 1
                    ? "Una solicitud enviada correctamente":
                    "${_organizationsSelected.length} solicitudes enviadas correctamente"
                ;

                emitSnackBar(
                  context: context,
                  text: text,
                  status: ActionStatus.Success
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OrganizationsSubscribedScreen()),
                  ModalRoute.withName('/home')
                );
              }else if(state is Failed){
                emitSnackBar(
                    context: context,
                    text: state.response,
                    status: ActionStatus.Fail
                );
              }
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 25,
                            color: ConstantsV2.primaryRegular,
                          ),
                          label: Text(
                            'Organizaciones',
                            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Container(
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
                                          "Seleccioná las organizaciones a las que desea "
                                              "enviar una solicitud",
                                          style: bodyMediumRegular.copyWith(
                                              color: ConstantsV2.activeText),
                                        ),
                                      ],
                                    ),
                                  )),
                              ImageViewTypeForm(
                                height: 54,
                                width: 54,
                                border: true,
                                url: patient.photoUrl,
                                gender: patient.gender,
                                borderColor: ConstantsV2.orange,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        BlocBuilder<OrganizationBloc, OrganizationBlocState>(
                            builder: (context, state){
                              if (state is Failed){
                                return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<OrganizationBloc>(context).add(GetAllOrganizations()));
                              } else if(state is Loading){
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Constants.primaryColor400),
                                    backgroundColor: Constants.primaryColor600,
                                  ),
                                );
                              }else{
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  color: ConstantsV2.grayLightest,
                                  child: ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _organizationsNotSubscribed.length,
                                      itemBuilder: selectOrganizationsBox
                                  ),
                                );
                              }
                            }
                        ),
                      ],
                    ),
                  ),
                  BotonAdd(organizationsSelected: _organizationsSelected,)
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget selectOrganizationsBox(BuildContext context, int index){
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_organizationsNotSubscribed[index].name?? "Sin nombre"),
          value: _organizationsSelected.contains(_organizationsNotSubscribed[index]),
          activeColor: ConstantsV2.secondaryRegular,
          checkColor: Colors.white,
          onChanged: (value) {
            setState(() {
              if (_organizationsSelected.contains(_organizationsNotSubscribed[index])) {
                _organizationsSelected.remove(_organizationsNotSubscribed[index]);
              } else {
                _organizationsSelected.add(_organizationsNotSubscribed[index]);
              }
            });
          },
        ),
      ),
    );
  }

}

class BotonAdd extends StatelessWidget {

  BotonAdd({required this.organizationsSelected});

  final List<Organization> organizationsSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: organizationsSelected.isEmpty ? null : (){
              BlocProvider.of<OrganizationBloc>(context).add(SubscribeToAnManyOrganizations(organizations: organizationsSelected));
            },
            child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Solicitar${organizationsSelected.isNotEmpty ? '(${organizationsSelected.length})': ''}',
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

}

class OrganizationsSubscribedScreen extends StatefulWidget {
  const OrganizationsSubscribedScreen({
    Key? key,
  }) : super(key: key);

  @override
  _OrganizationsSubscribedScreenState createState() => _OrganizationsSubscribedScreenState();
}

class _OrganizationsSubscribedScreenState extends State<OrganizationsSubscribedScreen> {

  List<Organization> _organizationsSubscribed = [];
  List<Organization> _organizationsPostulated = [];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<subscribed.OrganizationSubscribedBloc>(
          create: (BuildContext context) => subscribed.OrganizationSubscribedBloc()..add(subscribed.GetOrganizationsSubscribed()),
        ),
        BlocProvider<applied.OrganizationAppliedBloc>(
          create: (BuildContext context) => applied.OrganizationAppliedBloc()..add(applied.GetOrganizationsPostulated()),
        ),
      ],
      child: Scaffold(
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
          child: Container(
            child: MultiBlocListener(
              listeners: [
                BlocListener<subscribed.OrganizationSubscribedBloc, subscribed.OrganizationSubscribedBlocState>(
                  listener: (context, state) {
                    if (state is subscribed.OrganizationsSubscribedObtained) {
                      _organizationsSubscribed = state.organizationsList;

                    }else if(state is subscribed.OrganizationRemoved){

                      emitSnackBar(
                        context: context,
                        text: "Suscripcion a ${_organizationsSubscribed.firstWhere((element) => element.id == state.id).name} eliminada",
                        status: ActionStatus.Success
                      );

                      _organizationsSubscribed.removeWhere((element) => element.id == state.id);

                      // notify the home to remove an organization
                      BlocProvider.of<home_organization.HomeOrganizationBloc>(context).add(home_organization.GetOrganizationsSubscribed());
                    } else if(state is subscribed.Failed){
                      emitSnackBar(
                          context: context,
                          text: state.response,
                          status: ActionStatus.Fail
                      );
                    }
                  },
                ),
                BlocListener<applied.OrganizationAppliedBloc, applied.OrganizationAppliedBlocState>(
                  listener: (context, state) {
                    if (state is applied.OrganizationsObtained) {
                      _organizationsPostulated = state.organizationsList;

                    }else if(state is applied.PostulationRemoved){
                      emitSnackBar(
                        context: context,
                        text: "Solicitud a ${_organizationsPostulated.firstWhere((element) => element.id == state.id).name} cancelada",
                        status: ActionStatus.Success
                      );
                      _organizationsPostulated.removeWhere((element) => element.id == state.id);
                    }else if(state is applied.Failed){
                      emitSnackBar(
                          context: context,
                          text: state.response,
                          status: ActionStatus.Fail
                      );
                    }
                  },
                )
              ],
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 25,
                        color: ConstantsV2.primaryRegular,
                      ),
                      label: Text(
                        'Membresías',
                        style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: FamilySelector(patient: patient,)
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    BlocBuilder<subscribed.OrganizationSubscribedBloc, subscribed.OrganizationSubscribedBlocState>(
                      builder: (context, state){
                        if (state is subscribed.Failed){
                          return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<subscribed.OrganizationSubscribedBloc>(context).add(subscribed.GetOrganizationsSubscribed()));
                        } else if(state is subscribed.Loading){
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Constants.primaryColor400),
                              backgroundColor: Constants.primaryColor600,
                            ),
                          );
                        }else{
                          if ( _organizationsSubscribed.isEmpty ) {
                            return emptyView(context);
                          } else {
                            return Container(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                color: ConstantsV2.grayLightest,
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width-30,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Arrastrá los elementos para establecer el orden de prioridad',
                                              style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.grayDark),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const OrganizationsScreen()),
                                              );
                                            },
                                            child: Card(
                                              elevation: 0,
                                              margin: EdgeInsets.zero,
                                              color: ConstantsV2.secondaryRegular,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                child: const Center(
                                                  child: Icon(Icons.add)
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    ReorderableListView.builder(
                                      buildDefaultDragHandles: false,
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _organizationsSubscribed.length,
                                      itemBuilder: organizationsBox,
                                      onReorder: (int oldIndex, int newIndex) {
                                        final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                                        final organization = _organizationsSubscribed.removeAt(oldIndex);
                                        _organizationsSubscribed.insert(index, organization);
                                        BlocProvider.of<subscribed.OrganizationSubscribedBloc>(context).add(subscribed.ReorderByPriority(organizations: _organizationsSubscribed));
                                      },
                                    )
                                  ]
                                )
                              )
                            );
                          }
                        }
                      }
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<applied.OrganizationAppliedBloc, applied.OrganizationAppliedBlocState>(
                      builder: (context, state){
                        if (state is applied.Failed){
                          return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<applied.OrganizationAppliedBloc>(context).add(applied.GetOrganizationsPostulated()));
                        } else if(state is applied.Loading){
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Constants.primaryColor400),
                              backgroundColor: Constants.primaryColor600,
                            ),
                          );
                        }else{
                          if ( _organizationsPostulated.isEmpty ) {
                            return Container();
                          } else {
                            return Container(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                color: ConstantsV2.grayLightest,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'Membresías pendientes de aprobación',
                                            style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.grayDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _organizationsPostulated.length,
                                      itemBuilder: organizationsPostulatedBox,
                                    )
                                  ]
                                )
                              )
                            );
                          }
                        }
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyView(BuildContext context) {
    return Column(
      children: [
        // this structure prevent overflow in small screens
        Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aún no contas con membresía en este perfil',
                  style: boldoSubTextMediumStyle,
                )
              )
            )
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left:16.0, right: 16.0, bottom: 16.0),
                child: Text(
                  'Para usar algunos de los servicios que Boldo tiene para ofrecer, es necesario que este perfil de tu grupo familiar sea miembro de la organización que las provee.',
                  style: boldoInfoTextStyle
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 26.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: ElevatedButton(
                onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrganizationsScreen()),
                  );
                },
                child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Agregar',
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 16,
                        ),
                      ],
                    )),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget organizationsBox(BuildContext context, int index){
    return ReorderableDelayedDragStartListener(
      key: ValueKey(_organizationsSubscribed[index]),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardPriority(index + 1),
              const SizedBox(width: 12,),
              _cardFunder(_organizationsSubscribed[index]),
            ],
          ),
        ),
      ),
      index: index
    );
  }

  Widget _cardPriority(int priority){
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: ConstantsV2.secondaryLightAndClear,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      child: Container(
        width: 30,
        height: 30,
        child: Center(
          child: Text(
              "$priority"
          ),
        ),
      ),
    );
  }

  Widget _cardFunder(Organization organization){
    return OrganizationSubscribedCard(organization: organization,);
  }

  Widget _cardFunderPostulated(Organization organization){
    return OrganizationPostulationCard(organization: organization,);
  }

  Widget organizationsPostulatedBox(BuildContext context, int index){
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12,),
            _cardFunderPostulated(_organizationsPostulated[index]),
          ],
        ),
      ),
    );
  }

}

class OrganizationPostulationCard extends StatelessWidget {

  OrganizationPostulationCard({required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: ConstantsV2.CardBG.withOpacity(0.05),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: ConstantsV2.grayLightAndClear,
              )
          ),
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: ConstantsV2.grayLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: ConstantsV2.grayLightAndClear,
                        )
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Text(
                                "${organization.name}"
                            ),
                            cancelSubscriptionOption(organization.id?? 'without id', context),
                          ]
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SvgPicture.asset('assets/icon/Handle.svg',
                      color: ConstantsV2.blueLight),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget cancelSubscriptionOption(String id, BuildContext context){
    return InkWell(
      onTap: (){
        BlocProvider.of<applied.OrganizationAppliedBloc>(context).add(applied.UnPostulated(id: id));
      },
      child: SvgPicture.asset('assets/icon/familyTrash.svg'),
    );
  }

}


class OrganizationSubscribedCard extends StatelessWidget {

  OrganizationSubscribedCard({required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: ConstantsV2.CardBG,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: ConstantsV2.grayLightAndClear,
            )
        ),
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: ConstantsV2.grayLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: ConstantsV2.grayLightAndClear,
                      )
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Text(
                              "${organization.name}"
                          ),
                          moreOptions(organization.id?? 'without id', context),
                        ]
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SvgPicture.asset('assets/icon/Handle.svg'),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget moreOptions(String id, BuildContext context){
    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (result == 'baja') {
          BlocProvider.of<subscribed.OrganizationSubscribedBloc>(context).add(subscribed.RemoveOrganization(id: id));
        }
      },
      child: SvgPicture.asset('assets/icon/more-horiz.svg'),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'baja',
          child: Container(
            height: 45,
            decoration: const BoxDecoration(color: Constants.accordionbg),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SvgPicture.asset('assets/icon/familyTrash.svg'),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 2.0),
                  child: Text('Darse de baja'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

}


class FamilySelector extends StatelessWidget {

  FamilySelector({required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context) {

    List<Patient> _families = families;
    return BlocBuilder(
      bloc: family_bloc.FamilyBloc()..add(family_bloc.GetFamilyList()),
      builder: (context, state){
        if(state is family_bloc.Success){
          _families = families;
          return Container(
            height: 60,
            child: ListView.builder(
              itemCount: _families.length + 1, //patient is first element
              scrollDirection: Axis.horizontal,
              itemBuilder: _buildPictureRoundedFamily
            ),
          );
        }else if(state is family_bloc.Failed){
          return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<family_bloc.FamilyBloc>(context).add(family_bloc.GetFamilyList()));
        }else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Constants.primaryColor400),
              backgroundColor: Constants.primaryColor600,
            ),
          );
        }
      }
    );
  }

  Widget _buildPictureRoundedFamily(BuildContext context, int index){
    return Center(
      child: _profileFamily(index, "rounded"),
    );
  }

  Widget _profileFamily(int index, String type){
    double height = type == "rounded"? 54 : 85;
    double width = type == "rounded"? 54 : 120;
    bool disable = index == 0 ? patient.id == prefs.getString("userId") ? false : true : patient.id == families[index-1].id ? false : true;
    return Container(
      child:
        index == 0
            ? ImageViewTypeForm(
            height: height,
            width: width,
            border: true,
            form: type,
            color: disable? ConstantsV2.grayLightAndClear : null,
            opacity: disable? 0.6 : 1,
            borderColor: disable? ConstantsV2.grayLightAndClear: ConstantsV2.secondaryRegular,
            url: prefs.getString('profile_url'),
            gender: prefs.getString('gender'),
        )
            :ImageViewTypeForm(
            height: height,
            width: width,
            border: true,
            url: families[index-1].photoUrl,
            gender: families[index-1].gender,
            form: type,
            color: disable? ConstantsV2.gray : null,
            opacity: disable? 0.6 : 1,
            borderColor: disable? ConstantsV2.grayLightAndClear: ConstantsV2.secondaryRegular,
        )
        ,
    );
  }

}