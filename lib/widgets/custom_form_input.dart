import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';
import '../size_config.dart';

class CustomFormInput extends StatefulWidget {
  final String label;
  final Icon customIcon;
  final String secondaryLabel;
  final String Function(String) validator;
  final Function(String) changeValueCallback;
  final bool obscureText;
  final onChanged;
  CustomFormInput(
      {Key key,
      @required this.label,
      @required this.validator,
      @required this.changeValueCallback,
      this.customIcon,
      this.secondaryLabel,
      this.onChanged,
      this.obscureText = false})
      : super(key: key);

  @override
  _CustomFormInputState createState() => _CustomFormInputState();
}

class _CustomFormInputState extends State<CustomFormInput> {
  FocusNode _textFocus = FocusNode();
  bool focused = false;
  @override
  void initState() {
    _textFocus.addListener(onChangeFocus);
    super.initState();
  }

  void onChangeFocus() {
    bool focusedItem = _textFocus.hasFocus;
    setState(() {
      focused = focusedItem;
    });
  }

  @override
  void dispose() {
    _textFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockHorizontal * 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                  color: focused
                      ? Constants.extraColor400
                      : Constants.extraColor400,
                ),
              ),
              if (widget.secondaryLabel != null)
                Text(
                  widget.secondaryLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                    color: Constants.extraColor300,
                  ),
                ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: SizeConfig.safeBlockHorizontal * 13,
              maxHeight: SizeConfig.safeBlockHorizontal * 20),
          child: TextFormField(
            obscureText: widget.obscureText,
            focusNode: _textFocus,
            style: TextStyle(
                height: 1,
                color:
                    focused ? const Color(0xffD2D6DC) : const Color(0xffD2D6DC),
                fontSize: SizeConfig.safeBlockHorizontal * 4.40),
            decoration: InputDecoration(
              suffixIcon: widget.customIcon != null ? widget.customIcon : null,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal * 4,
                  vertical: SizeConfig.safeBlockHorizontal * 2.4),
            ),
            //keyboardType: TextInputType.emailAddress,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onSaved: (String val) {
              widget.changeValueCallback(val);
            },
          ),
        ),
      ],
    );
  }
}
