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
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/header_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class Organizations extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return OrganizationsSubscribedScreen();

  }

}

class OrganizationsScreen extends StatefulWidget {
  final Patient patientSelected;
  const OrganizationsScreen({
    Key? key,
    required this.patientSelected,
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
      create: (context) => OrganizationBloc()..add(GetAllOrganizations(patientSelected: widget.patientSelected)),
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
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BackButtonLabel(
                          iconType: BackIcon.backArrow,
                          labelText: 'Centros Asistenciales',
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
                                          "Seleccioná los Centros Asistenciales a los que desea "
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
                                url: widget.patientSelected.photoUrl,
                                gender: widget.patientSelected.gender,
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
                                return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<OrganizationBloc>(context).add(GetAllOrganizations(patientSelected: widget.patientSelected)));
                              } else if(state is Loading){
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Constants.primaryColor400),
                                    backgroundColor: Constants.primaryColor600,
                                  ),
                                );
                              }else{
                                return Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ConstantsV2.grayLightest,
                                      boxShadow: [
                                        shadowRegular,
                                      ]
                                    ),
                                    child: _organizationsNotSubscribed.isNotEmpty? ListView.builder(
                                        physics: const ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: _organizationsNotSubscribed.length,
                                        itemBuilder: selectOrganizationsBox
                                    ): organizationAvailableEmpty(),
                                  ),
                                );
                              }
                            }
                        ),
                      ],
                    ),
                  ),
                  BotonAdd(organizationsSelected: _organizationsSelected, patientSelected: widget.patientSelected,)
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xffEAEAEA),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: ConstantsV2.grayLightAndClear,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const ShapeDecoration(
          color: ConstantsV2.grayLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
        ),
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _organizationsNotSubscribed[index].name?? "Sin nombre",
            style: bodyLargeBlack,
          ),
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

  Widget organizationAvailableEmpty(){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const EmptyStateV2(
                picture: "undraw_add_files.svg",
                titleBottom: "No hay organizaciones",
                textBottom:
                "La lista de organizaciones aparecerá "
                    "aquí una vez que estén disponibles.",
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class BotonAdd extends StatelessWidget {

  BotonAdd({
    required this.organizationsSelected,
    required this.patientSelected,
  });
  final Patient patientSelected;
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
              BlocProvider.of<OrganizationBloc>(context).add(SubscribeToAnManyOrganizations(organizations: organizationsSelected, patientSelected: patientSelected));
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

  Patient patientSelected = patient;

  List<Organization> _organizationsSubscribed = [];
  List<OrganizationRequest> _organizationsPostulated = [];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<subscribed.OrganizationSubscribedBloc>(
          create: (BuildContext context) => subscribed.OrganizationSubscribedBloc()..add(subscribed.GetOrganizationsSubscribed(patientSelected: patientSelected)),
        ),
        BlocProvider<applied.OrganizationAppliedBloc>(
          create: (BuildContext context) => applied.OrganizationAppliedBloc()..add(applied.GetOrganizationsPostulated(patientSelected: patientSelected)),
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
                        text: "Solicitud a ${_organizationsPostulated.firstWhere((element) => element.id == state.id).organizationName} cancelada",
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
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              BackButtonLabel(
                                iconType: BackIcon.backArrow,
                                labelText: 'Centros Asistenciales',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Builder(builder: (context){
                        return FamilySelector(
                          patientSelected: patientSelected,
                          actionCallback: (_patientSelected){
                            setState(() {
                              patientSelected = _patientSelected;
                            });
                            BlocProvider.of<subscribed.OrganizationSubscribedBloc>(context).add(subscribed.GetOrganizationsSubscribed(patientSelected: patientSelected));
                            BlocProvider.of<applied.OrganizationAppliedBloc>(context).add(applied.GetOrganizationsPostulated(patientSelected: patientSelected));
                          },
                        );
                      })
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    BlocBuilder<subscribed.OrganizationSubscribedBloc, subscribed.OrganizationSubscribedBlocState>(
                      builder: (context, state){
                        Widget child;
                        if (state is subscribed.Failed){
                          child = DataFetchErrorWidget(retryCallback: () => BlocProvider.of<subscribed.OrganizationSubscribedBloc>(context).add(subscribed.GetOrganizationsSubscribed(patientSelected: patientSelected)));
                        } else if(state is subscribed.Loading){
                          child = const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Constants.primaryColor400),
                              backgroundColor: Constants.primaryColor600,
                            ),
                          );
                        }else{
                          if ( _organizationsSubscribed.isEmpty ) {
                            child = emptyView(context);
                          } else {
                            child = Container(
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
                                              //'Arrastrá los elementos para establecer el orden de prioridad',
                                              'Gestioná las organizaciones a las cuales perteneces',
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
                                                MaterialPageRoute(builder: (context) => OrganizationsScreen(patientSelected: patientSelected)),
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
                                    // ReorderableListView.builder(
                                    //   buildDefaultDragHandles: false,
                                    ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _organizationsSubscribed.length,
                                      itemBuilder: organizationsBox,
                                      // onReorder: (int oldIndex, int newIndex) {
                                      //   final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                                      //   final organization = _organizationsSubscribed.removeAt(oldIndex);
                                      //   _organizationsSubscribed.insert(index, organization);
                                      //   BlocProvider.of<subscribed.OrganizationSubscribedBloc>(context).add(subscribed.ReorderByPriority(organizations: _organizationsSubscribed));
                                      // },
                                    )
                                  ]
                                )
                              )
                            );
                          }
                        }
                        return AnimatedSwitcher(
                          duration: appearWidgetDuration,
                          child: child,
                        );
                      }
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<applied.OrganizationAppliedBloc, applied.OrganizationAppliedBlocState>(
                      builder: (context, state){
                        Widget child;
                        if (state is applied.Failed){
                          child = DataFetchErrorWidget(retryCallback: () => BlocProvider.of<applied.OrganizationAppliedBloc>(context).add(applied.GetOrganizationsPostulated(patientSelected: patientSelected)));
                        } else if(state is applied.Loading){
                          child = const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Constants.primaryColor400),
                              backgroundColor: Constants.primaryColor600,
                            ),
                          );
                        }else{
                          if ( _organizationsPostulated.isEmpty ) {
                            child = Container();
                          } else {
                            child = Container(
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
                                            'Centros Asistenciales pendientes de aprobación',
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
                        return AnimatedSwitcher(
                          duration: appearWidgetDuration,
                          child: child,
                        );
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
                  'Aún no perteneces a ningún Centro Asistencial',
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
                    MaterialPageRoute(builder: (context) => OrganizationsScreen(patientSelected: patientSelected)),
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
    return OrganizationSubscribedCard(organization: organization, patientSelected: patientSelected,);
  }

  Widget _cardFunderPostulated(OrganizationRequest organization){
    return OrganizationPostulationCard(organization: organization, patientSelected: patientSelected);
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

  OrganizationPostulationCard({
    required this.organization,
    required this.patientSelected,
  });
  final Patient patientSelected;
  final OrganizationRequest organization;

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
                            Flexible(
                              child: Text(
                                "${organization.organizationName?? "Sin nombre"}",
                                style: bodyLargeBlack,
                              ),
                            ),
                            cancelSubscriptionOption(organization, context),
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

  Widget cancelSubscriptionOption(OrganizationRequest organization, BuildContext context){
    return InkWell(
      onTap: () async {
        String? action = await cancelApplication(context, organization);
        if(action == 'cancel') {
          BlocProvider.of<applied.OrganizationAppliedBloc>(context)
              .add(applied.UnPostulated(organization: organization, patientSelected: patientSelected));
        }
      },
      child: SvgPicture.asset('assets/icon/familyTrash.svg'),
    );
  }

  Future<String?> cancelApplication(BuildContext context, OrganizationRequest organization){
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Cancelar solicitud pendiente'),
        content: Text('¿Desea cancelar la solicitud a ${organization.organizationName}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'atrás'),
            child: const Text('atrás'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

}


class OrganizationSubscribedCard extends StatelessWidget {

  OrganizationSubscribedCard({required this.organization, required this.patientSelected});

  final Patient patientSelected;
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
                          Flexible(
                            child: Text(
                              "${organization.name}",
                              style: bodyLargeBlack,
                            ),
                          ),
                          moreOptions(organization, context),
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

  Widget moreOptions(Organization organization, BuildContext context){
    return PopupMenuButton<String>(
      onSelected: (String result) async {
        if (result == 'baja') {
          String? action = await dropOut(context, organization);
          if(action == 'cancel') {
            BlocProvider.of<subscribed.OrganizationSubscribedBloc>(context).add(
                subscribed.RemoveOrganization(organization: organization, patientSelected: patientSelected));
          }
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

  Future<String?> dropOut(BuildContext context, Organization organization){
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Desvincular Centro Asistencial'),
        content: Text('¿Desea darse de baja de ${organization.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'atrás'),
            child: const Text('atrás'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Sí, darse de baja'),
          ),
        ],
      ),
    );
  }

}


class FamilySelector extends StatefulWidget {

  FamilySelector({required this.patientSelected, this.actionCallback});

  Patient patientSelected;
  void Function(Patient patientSelected)? actionCallback;

  @override
  FamilySelectorState createState() => FamilySelectorState();


}

class FamilySelectorState extends State<FamilySelector>{

  @override
  void initState() {
    super.initState();

    BlocProvider.of<family_bloc.FamilyBloc>(context).add(family_bloc.GetFamilyList());
  }

  @override
  Widget build(BuildContext context) {

    List<Patient> _families = families;
    return BlocBuilder<family_bloc.FamilyBloc, family_bloc.FamilyState>(
      builder: (context, state){
        Widget child;
        if(state is family_bloc.Success){
          _families = families;
          child = _families.isNotEmpty? Container(
            height: 60,
            child: ListView.builder(
              itemCount: _families.length + 1, //patient is first element
              scrollDirection: Axis.horizontal,
              itemBuilder: _buildPictureRoundedFamily
            ),
          ) : Container();
        }else if(state is family_bloc.Failed){
          child = DataFetchErrorWidget(retryCallback: () => BlocProvider.of<family_bloc.FamilyBloc>(context).add(family_bloc.GetFamilyList()));
        }else {
          child = const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Constants.primaryColor400),
              backgroundColor: Constants.primaryColor600,
            ),
          );
        }
        return AnimatedSwitcher(
          duration: appearWidgetDuration,
          child: child,
        );
      }
    );
  }

  Widget _buildPictureRoundedFamily(BuildContext context, int index){
    return Center(
      child: GestureDetector(
        onTap: () => {
          setState((){
            Patient _patient = Patient(
              id: prefs.getString("userId"),
              photoUrl: prefs.getString("profile_url"),
              givenName: prefs.getString("name"),
              familyName: prefs.getString("lastName"),
              identifier: prefs.getString("identifier"),
            );
            widget.patientSelected = index==0? _patient : families[index-1];
          }),
          if(widget.actionCallback != null)
            widget.actionCallback!(widget.patientSelected),
        },
        child: _profileFamily(index, "rounded"),
      ),
    );
  }

  Widget _profileFamily(int index, String type){
    double height = type == "rounded"? 54 : 85;
    double width = type == "rounded"? 54 : 120;
    bool disable = index == 0 ? widget.patientSelected.id == prefs.getString("userId") ? false : true : widget.patientSelected.id == families[index-1].id ? false : true;
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