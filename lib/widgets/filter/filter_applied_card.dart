import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

class FilterAppliedCard extends StatelessWidget {

  final String text;
  final void Function()? removeFilter;

  FilterAppliedCard({
    super.key,
    required this.text,
    this.removeFilter,
  });

  @override
  Widget build(BuildContext context) {

    Widget child = Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        child: TextButton.icon(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(70),
            ),
            backgroundColor: ConstantsV2.primaryColor300.withOpacity(.1),
            foregroundColor: ConstantsV2.activeText,
            textStyle: regularText,
          ),
          onPressed: removeFilter,
          icon: const Icon(
            Icons.close_rounded,
            color: ConstantsV2.inactiveText,
            size: 17,
          ),
          label: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(text),
          ),
        ),
      )
    );


    return Container(
      child: child,
    );
  }

}