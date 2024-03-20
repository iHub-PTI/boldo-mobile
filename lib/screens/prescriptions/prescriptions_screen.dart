import 'package:boldo/blocs/download_prescriptions_bloc/download_prescriptions_bloc.dart' as download_prescriptions_bloc;
import 'package:boldo/blocs/prescriptions_bloc/prescriptionsBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Encounter.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/filters/PrescriptionFilter.dart';

import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/prescriptions/filter_precription_screen.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/filter/filters_applied.dart';
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
    BlocProvider.of<PrescriptionsBloc>(context).add(GetPastEncounterWithPrescriptionsList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PrescriptionsBloc>(
      create: (BuildContext context) => PrescriptionsBloc()..add(GetPastEncounterWithPrescriptionsList()),
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
                        ),
                        BlocBuilder<PrescriptionsBloc, PrescriptionsState>(
                            builder: (context, state) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton.icon(
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (newContext) => FilterPrescriptionsScreen(
                                            initialFilter: BlocProvider.of<PrescriptionsBloc>(context).prescriptionFilter,
                                            filterCallback: (PrescriptionFilter filter )=> BlocProvider.of<PrescriptionsBloc>(context).prescriptionFilter = filter,
                                          ),
                                        )
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icon/filter.svg',
                                    color: ConstantsV2.blueDark,
                                  ),
                                  label: Text(
                                    'Filtrar',
                                    style: label.copyWith(
                                      color: ConstantsV2.blueDark,
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<PrescriptionsBloc, PrescriptionsState>(builder: (context, state){
                    bool ifFiltered = BlocProvider.of<PrescriptionsBloc>(context).prescriptionFilter.ifFiltered;

                    Widget body;
                    if(state is EncounterWithPrescriptionsLoadedState){

                      if(allEncounters.isEmpty){
                        body = EmptyStateV2(
                          picture: ifFiltered? null : "empty_prescriptions.svg",
                          titleBottom: ifFiltered? 'No hay resultados': "Aún no tenés recetas",
                          textBottom: ifFiltered? 'No hay información disponible para los criterios de búsqueda especificados':
                          "A medida en que uses la aplicación podrás ir viendo tus recetas",
                        );
                      }else{
                        body = Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableWidgets<Encounter, download_prescriptions_bloc.Loading>(
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
                          ],
                        ),
                        );
                      }
                    }else if(state is Loading){
                      body = loadingStatus();
                    }else if(state is Failed){
                      body = DataFetchErrorWidget(retryCallback: () => BlocProvider.of<PrescriptionsBloc>(context).add(GetPastEncounterWithPrescriptionsList()) ) ;
                    }else{
                      body = Container();
                    }

                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(ifFiltered)
                            Container(
                              padding: const EdgeInsets.all(4),
                              child: FiltersApplied<PrescriptionFilter>(
                                filter: BlocProvider.of<PrescriptionsBloc>(context).prescriptionFilter,
                                filterCallback: (PrescriptionFilter filter )=> BlocProvider.of<PrescriptionsBloc>(context).prescriptionFilter = filter,
                              ),
                            ),
                          body,
                        ],
                      ),
                    );

                  }),
                ],
              ),
            ),
          )
      ),
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
