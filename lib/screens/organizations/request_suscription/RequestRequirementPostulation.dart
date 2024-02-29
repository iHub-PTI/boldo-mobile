import 'package:boldo/blocs/organizationRequirementsValidate_bloc/organizationRequirementsValidate_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/screens/organizations/request_suscription/components/confirm_veracity.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestRequirementPostulation extends StatefulWidget {

  final Organization organization;

  RequestRequirementPostulation({
    super.key,
    required this.organization,
  });

  @override
  State<StatefulWidget> createState() => _RequestRequirementPostulationState();

}

class _RequestRequirementPostulationState extends State<RequestRequirementPostulation> with SingleTickerProviderStateMixin {

  late AnimationController? _confirmVeracityController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 100),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _confirmVeracityController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<OrganizationRequirementsValidateBloc>(
        create: (BuildContext context) => OrganizationRequirementsValidateBloc(
          requirements: widget.organization.organizationSettings!.organizationRequirements!,
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BackButtonLabel(
                    gapSpace: 0,
                    iconType: BackIcon.backClose,
                  ),
                ],
              ),
              BlocBuilder<OrganizationRequirementsValidateBloc, OrganizationRequirementsValidateState>(
                builder: (BuildContext context, state){
                  if(state is ValidateRequirementNeeded) {

                    if(state.remarkNeedConfirmation){
                      _confirmVeracityController?.reset();
                      _confirmVeracityController?.forward();
                    }


                    return Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Center(
                          key: ValueKey<OrganizationRequirement>(state.requirement),
                          child: requirementWidget(
                            requirement: state.requirement,
                            confirmedDataVeracity: state.confirmedDataVeracity,
                            context: context,
                          ),
                        ),
                      ),
                    );
                  }else if(state is OrganizationRequirementsValidateInitial) {
                    return Expanded(
                      child: requirementsDescriptionPreviewWidget(
                        organization: widget.organization,
                        context: context,
                        confirmedDataVeracity: state.confirmedDataVeracity,
                      ),
                    );
                  }else
                    return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget requirementWidget({
    required OrganizationRequirement requirement,
    required bool confirmedDataVeracity,
    required BuildContext context,
  }){

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(requirement.title?? "Titulo",
                    style: boldoCardHeadingTextStyle.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25,),
                  Text(requirement.description?? "Descripción",
                    style: bodyMediumRegular.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 57,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (){
                            BlocProvider.of<OrganizationRequirementsValidateBloc>(context).add(
                                ValidateRequirement(
                                  context: context,
                                  answer: true,
                                  confirmedDataVeracity: confirmedDataVeracity,
                                )
                            );

                          },
                          child: Text(
                            "Si",
                            style: boldoCardSubtitleTextStyle,
                          ),
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                            padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(
                              vertical: 20,
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 22,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => BlocProvider.of<OrganizationRequirementsValidateBloc>(context).add(
                              ValidateRequirement(
                                context: context,
                                answer: false,
                                confirmedDataVeracity: confirmedDataVeracity,
                              )
                          ),
                          child: Text(
                            "No",
                            style: boldoCardSubtitleTextStyle,
                          ),
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                            padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(
                              vertical: 20,
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              padding: const EdgeInsets.only(top: 57),
            ),
          ),
        ],
      ),
    );
  }

  Widget responseChoice({
    required ButtonStyle buttonStyle,
    Function()? callback,
    required Widget child,
  }){

    Widget? button;

    MaterialStateProperty<EdgeInsetsGeometry?>? _defaultPadding
    = const MaterialStatePropertyAll(
        EdgeInsets.symmetric(
      vertical: 20,
    ));


      button = OutlinedButton(
        onPressed: callback,
        child: child,
        style: OutlinedButtonTheme.of(context).style?.copyWith(
          padding: _defaultPadding,
        ),
      );


    return Container(
      constraints: const BoxConstraints(
        maxWidth: 130,
      ),
      child: Expanded(
        child: button,
      ),
    );
  }

  Widget requirementsDescriptionPreviewWidget({
    required Organization organization,
    required BuildContext context,
    required bool confirmedDataVeracity,
  }){

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Requisitos ${organization.name?? "Desconocido"}",
                    style: boldoCardHeadingTextStyle.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Text(
                    'Para acceder a los servicios, este centro tiene requisitos a cumplir.\n\nPor favor, dedica un momento para responder las preguntas con sinceridad y precisión.',
                    textAlign: TextAlign.center,
                    style: boldoCorpSmallSTextStyle.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  ConfirmVeracityWidget(
                    organization: widget.organization,
                    controller: _confirmVeracityController,
                    confirmedDataVeracity: confirmedDataVeracity,
                  ),
                  const SizedBox(height: 57,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: confirmedDataVeracity? () => BlocProvider.of<OrganizationRequirementsValidateBloc>(context).add(
                            InitValidation(
                              context: context,
                              confirmedDataVeracity: confirmedDataVeracity,
                            )
                        ):null,
                        child: const Text(
                          "Continuar",
                          style: boldoCorpMediumBlackTextStyle,
                        ),
                        style: ElevatedButtonTheme.of(context).style?.copyWith(
                            padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20, horizontal: 80))
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              padding: const EdgeInsets.only(top: 57),
            ),
          ),
          Container(
          ),
        ],
      ),
    );
  }

}