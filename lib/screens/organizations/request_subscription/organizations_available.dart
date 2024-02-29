part of '../memberships_screen.dart';

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
                if (state is AllOrganizationsObtained) {
                  _organizationsNotSubscribed = state.organizationsList.items?? [];

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
                  ).then((value) =>
                      Navigator.of(context).pop(true)
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
                                            style: medicationTextStyle.copyWith(
                                              color: ConstantsV2.activeText,
                                            ),
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
                                  return loadingStatus();
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
                    ConfirmRequest(organizationsSelected: _organizationsSelected, patientSelected: widget.patientSelected,)
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
          controlAffinity: ListTileControlAffinity.leading,
          title: Container(
            child: Row(
              children: [
                OrganizationPhoto(
                  organization: _organizationsNotSubscribed[index],
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _organizationsNotSubscribed[index].name?? "Sin nombre",
                        style: bodyLargeBlack,
                      ),
                      Text(
                        _organizationsNotSubscribed[index].organizationSettings
                            ?.automaticPatientSubscription?? false
                            ? "Suscripción condicionada" : "Suscripción con verificación por el centro",
                        style: boldoBodySBlackTextStyle.copyWith(
                            color: ConstantsV2.blueLight
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          value: _organizationsSelected.any((element) => _organizationsNotSubscribed[index].id == element.id),
          activeColor: ConstantsV2.secondaryRegular,
          checkColor: Colors.white,
          onChanged: (value) {
            setState(() {
              if (_organizationsSelected.any((element) => _organizationsNotSubscribed[index].id == element.id)) {
                _organizationsSelected.removeWhere((element) => _organizationsNotSubscribed[index].id == element.id);
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
        child: const SingleChildScrollView(
          child: Column(
            children: [
              EmptyStateV2(
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
