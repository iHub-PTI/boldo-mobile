import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

enum BackIcon {
  backArrow(
    icon: Icons.arrow_back_rounded,
    iconSize: 24,
    iconColor: ConstantsV2.primaryRegular,
  ),
  backClose(
    icon: Icons.close_rounded,
    iconSize: 40,
    iconColor: ConstantsV2.activeText,
  );

  const BackIcon({
    required this.icon,
    required this.iconSize,
    required this.iconColor,
  });
  final IconData icon;
  final double iconSize;
  final Color iconColor;
}

class BackButtonLabel<T> extends StatelessWidget {

  /// Back Button to pop the context and return [result] to previous page,
  /// if the Widget icon is defined, this will override and unused [iconColor],
  /// [iconSize] and [iconType].
  ///
  /// [result] is the value that will be returned on pop the context.
  ///
  /// [labelText] it the text to showed next to icon.
  ///
  /// [labelWidget] is a widget to replace [labelText], this value will override the [labelText].
  ///
  /// [gapSpace] is the space between [icon] and [labelText] or [labelWidget].
  ///
  /// [callback] is an async function, pop context will await to end this function.
  ///
  /// [icon] is a Widget to override default icon defined by [iconType].
  ///
  /// if [reversed] is true the default elements order set reversed mode .
  BackButtonLabel({
    Key? key,
    this.result,
    this.labelText,
    this.labelWidget,
    this.padding = const EdgeInsets.only(left: 16),
    this.gapSpace = 16,
    this.callback,
    this.iconColor,
    this.iconSize,
    this.iconType = BackIcon.backArrow,
    this.icon,
    this.reversed = false,
  }) : super(key: key);


  final T? result;

  final String? labelText;

  final Widget? labelWidget;

  final EdgeInsetsGeometry? padding;

  final double gapSpace;

  final Function()? callback;
  final Color? iconColor;
  final BackIcon iconType;

  Widget? icon ;
  final double? iconSize;

  final bool reversed;

  @override
  Widget build(BuildContext context) {

    icon = icon?? Icon(
      iconType.icon,
      color: iconColor?? iconType.iconColor,
      size: iconSize?? iconType.iconSize,
    );

    List<Widget> children =[
      icon!,
      if(labelWidget!= null || labelText!= null)
        SizedBox(width: gapSpace,),
      Flexible(
        child: labelWidget?? Text(
          labelText?? '',
          style: boldoScreenTitleTextStyle.copyWith(color: ConstantsV2.activeText),
        ),
      ),
    ];

    return InkWell(
      onTap: () async {
        await callback?.call();
        Navigator.pop(context, result);
      },
      child: Container(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: reversed? children.reversed.toList(): children,
        ),
      ),
    );
  }

}