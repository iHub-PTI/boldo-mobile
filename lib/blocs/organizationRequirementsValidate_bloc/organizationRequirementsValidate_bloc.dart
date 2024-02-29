import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'organizationRequirementsValidate_event.dart';
part 'organizationRequirementsValidate_state.dart';

class OrganizationRequirementsValidateBloc extends Bloc<OrganizationRequirementsValidateEvent, OrganizationRequirementsValidateState> {

  List<OrganizationRequirement> requirements;
  bool confirmedDataVeracity = false;

  late Iterator<OrganizationRequirement> iterator;

  OrganizationRequirementsValidateBloc({
    required this.requirements,
  }) : super(OrganizationRequirementsValidateInitial()) {

    on<ValidateRequirement>(_validateRequirement);
    on<InitValidation>(_initValidation);
    on<ConfirmVeracity>(_confirmVeracity);

  }

  Future<void> _validateRequirement(
      ValidateRequirement event,
      Emitter<OrganizationRequirementsValidateState> emit,
      ) async {
    confirmedDataVeracity = event.confirmedDataVeracity;

    if(confirmedDataVeracity ) {
      if (iterator.current.answer == event.answer) {
        if (iterator.moveNext()) {
          emit(ValidateRequirementNeeded(
            requirement: iterator.current,
            confirmedDataVeracity: confirmedDataVeracity,
          ));
        } else {
          Navigator.of(event.context).pop(true);
        }
      } else {
        await showDialog<void>(
          context: event.context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              scrollable: true,
              contentTextStyle: boldoCardHeadingTextStyle.copyWith(
                color: ConstantsV2.blueDark,
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          top: 20.0,
                          right: 24.0,
                          bottom: 24.0,
                        ),
                        child: const Center(
                          child: Text(
                            "No has cumplido con los requisitos del centro asistencial para acceder a los servicios.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.black87,
                        height: 10.0,
                      )
                    ],
                  )
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cerrar',
                    style: boldoCardHeadingTextStyle.copyWith(
                      color: ConstantsV2.secondaryRegular,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Entendido',
                    style: boldoCardHeadingTextStyle.copyWith(
                      color: ConstantsV2.blueDark,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        Navigator.of(event.context).pop(false);
      }
    }else {
      emit(ValidateRequirementNeeded(
        requirement: iterator.current,
        confirmedDataVeracity: confirmedDataVeracity,
        remarkNeedConfirmation: !confirmedDataVeracity,
      ));
    }
  }

  Future<void> _initValidation(
      InitValidation event,
      Emitter<OrganizationRequirementsValidateState> emit,
      ) async {

    iterator = requirements.iterator;

    confirmedDataVeracity = event.confirmedDataVeracity;

    if(iterator.moveNext()){
      emit(ValidateRequirementNeeded(
        requirement: iterator.current,
        confirmedDataVeracity: confirmedDataVeracity,
      ));
    }else{
      Navigator.of(event.context).pop(true);
    }

  }

  Future<void> _confirmVeracity(
      ConfirmVeracity event,
      Emitter<OrganizationRequirementsValidateState> emit,
      ) async {


    confirmedDataVeracity = event.confirmedDataVeracity;

    emit(OrganizationRequirementsValidateInitial(
      confirmedDataVeracity: confirmedDataVeracity,
    ));

  }

}
