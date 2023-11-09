import 'package:boldo/blocs/organization_bloc/organization_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/pharmacy/components/pharmacy_available_card.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/searh_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({
    Key? key,
  }) : super(key: key);

  @override
  _OrganizationsScreenState createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<PharmaciesScreen> {


  String? nameFiltered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<OrganizationBloc>(
        create: (context) => OrganizationBloc()..add(GetAllOrganizationsByType(type: OrganizationType.pharmacy)),
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
                  if(state is Failed){
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
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ConstantsV2.BGNeutral,
                                      boxShadow: [
                                        shadowHeader,
                                      ],
                                    ),
                                    child: BackButtonLabel(
                                      iconType: BackIcon.backArrow,
                                      labelText: 'Farmacias',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            BlocBuilder<OrganizationBloc, OrganizationBlocState>(
                                builder: (context, state){
                                  if (state is Failed){
                                    return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<OrganizationBloc>(context).add(GetAllOrganizationsByType(type: OrganizationType.pharmacy)));
                                  } else if(state is AllOrganizationsObtained){
                                    return Flexible(
                                      child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFFAFAFA),
                                          boxShadow: [
                                            shadowRegular,
                                          ]
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
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
                                                            "Estas farmacias se encuentran adheridas a Boldo",
                                                            style: bodyMediumRegular.copyWith(
                                                                color: ConstantsV2.activeText),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              CustomSearchInput(
                                                initialText: nameFiltered,
                                                maxWidth: 168,
                                                hintText: "Buscar por nombre",
                                                onEditingComplete: (value)=> BlocProvider.of<OrganizationBloc>(context).add(GetAllOrganizationsByType(type: OrganizationType.pharmacy, name: value)),
                                                onChange: (value) => nameFiltered = value,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          state.organizationsList.isNotEmpty? listPharmacies(state) : organizationAvailableEmpty(),
                                        ],
                                      ),
                                    ),
                                    );
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget listPharmacies(AllOrganizationsObtained state){
    return Flexible(
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.organizationsList.length,
        itemBuilder: (BuildContext context, int index){
          return Container(
            child: Row(
              children: [
                Center(
                  child: ImageViewTypeForm(
                    height: 30,
                    width: 30,
                    border: false,
                    elevation: 0,
                    text: (index+ 1).toString(),
                    backgroundColor: ConstantsV2.secondaryLightAndClear,
                    textStyle: const TextStyle(
                      color: ConstantsV2.grayDark,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: pharmacyAvailable(state.organizationsList[index]),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: 16,
          );
        },
      ),
    );
  }

  Widget pharmacyAvailable(Organization organization){
    return PharmacyAvailableCard(organization: organization);
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



