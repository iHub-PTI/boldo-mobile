import 'package:boldo/blocs/organizationRequirementsValidate_bloc/organizationRequirementsValidate_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmVeracityWidget extends StatefulWidget {

  final Organization organization;
  final AnimationController? controller;
  final bool confirmedDataVeracity;

  ConfirmVeracityWidget({
    super.key,
    required this.organization,
    required this.controller,
    required this.confirmedDataVeracity,
  });

  @override
  State<StatefulWidget> createState() => _ConfirmVeracityWidgetState();


}

class _ConfirmVeracityWidgetState extends State<ConfirmVeracityWidget> with SingleTickerProviderStateMixin {

  final DecorationTween decorationTween = DecorationTween(
    begin: const ShapeDecoration(
      shape: RoundedRectangleBorder(
      ),
    ),
    end: const ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 2,
          color: ConstantsV2.secondaryRegular,
        ),
      ),
    ),
  );

  late final AnimationController _controller;

  Widget? child;

  Widget indicatorText = Column(
    key: const ValueKey<String>("indicatorText"),
    children: [
      Text(
        'Antes de continuar. Marque la casilla para confirmar que los'
            ' datos son ciertos.',
        style: boldoCorpSmallInterTextStyle.copyWith(
          color: Colors.black,
        ),
      ),
      const SizedBox(
        height: 18,
      ),
    ],
  );

  @override
  void initState() {

    _controller = widget.controller?? AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 100),
    );

    _controller.addListener(() {
      if(_controller.velocity > 0){
        child = indicatorText;
        if(mounted)
        setState(() {

        });
      }
      if(_controller.velocity < 0){
        child = null;

        if(mounted)
        setState(() {

        });
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(ConfirmVeracityWidget oldWidget){

    if(widget.controller != oldWidget.controller) {

      _controller = widget.controller?? AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 100),
      );

      _controller.addListener(() {
        if(_controller.velocity > 0){
          child = indicatorText;

          if(mounted)
          setState(() {

          });
        }
        if(_controller.velocity < 0){
          child = null;

          if(mounted)
          setState(() {

          });
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 100),
            child: child,
          ),
          DecoratedBoxTransition(
            decoration: decorationTween.animate(_controller),
            child: Container(
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: widget.confirmedDataVeracity,
                onChanged: (value) {
                  if( value== true) {
                    widget.controller?.reverse();
                  }
                  BlocProvider.of<OrganizationRequirementsValidateBloc>(
                      context).add(
                      ConfirmVeracity(
                        context: context,
                        confirmedDataVeracity: value ?? false,
                      )
                  );
                },
                title: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Declaro que los datos proveídos son auténticos. ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}