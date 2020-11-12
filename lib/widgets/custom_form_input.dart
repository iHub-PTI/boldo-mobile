import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../size_config.dart';

class CustomFormInput extends StatefulWidget {
  final int maxLines;
  final bool isPhoneNumber;
  final String label;
  final Icon customIcon;
  final String secondaryLabel;
  final String initialValue;
  final String customSVGIcon;
  final bool isDateTime;
  final String Function(String) validator;
  final Function(String) changeValueCallback;
  final bool obscureText;
  final onChanged;
  final List<TextInputFormatter> inputFormatters;
  CustomFormInput(
      {Key key,
      @required this.label,
      this.validator,
      @required this.changeValueCallback,
      this.isDateTime = false,
      this.inputFormatters = const [],
      this.maxLines = 1,
      this.customSVGIcon,
      this.isPhoneNumber = false,
      this.customIcon,
      this.initialValue,
      this.secondaryLabel,
      this.onChanged,
      this.obscureText = false})
      : super(key: key);

  @override
  _CustomFormInputState createState() => _CustomFormInputState();
}

class _CustomFormInputState extends State<CustomFormInput> {
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _textFocus = FocusNode();
  bool focused = false;

  @override
  void initState() {
    _textFocus.addListener(onChangeFocus);
    if (widget.initialValue != null)
      _textEditingController.text = widget.initialValue;
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Constants.extraColor400,
                ),
              ),
              if (widget.secondaryLabel != null)
                Text(
                  widget.secondaryLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Constants.extraColor300,
                  ),
                ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: SizeConfig.safeBlockHorizontal * 11,
              maxHeight: widget.maxLines == 1
                  ? SizeConfig.safeBlockHorizontal * 20
                  : 999),
          child: GestureDetector(
            onTap: () async {
              if (!widget.isDateTime) return;

              await DatePicker.showDatePicker(context,
                  currentTime: DateTime.parse(
                      _textEditingController.text ?? "1980-01-01"),
                  showTitleActions: true, onConfirm: (DateTime dt) {
                String newTime = DateFormat('yyyy-MM-dd').format(dt);

                _textEditingController.text = newTime;
                widget.changeValueCallback(newTime);
              });
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              child: IgnorePointer(
                ignoring: widget.isDateTime,
                child: TextFormField(
                  maxLines: widget.maxLines,
                  inputFormatters: widget.inputFormatters,
                  keyboardType:
                      widget.isPhoneNumber ? TextInputType.number : null,
                  obscureText: widget.obscureText,
                  focusNode: _textFocus,
                  controller: _textEditingController,
                  style: TextStyle(
                      height: 1,
                      color: Constants.extraColor300,
                      fontSize: SizeConfig.safeBlockHorizontal * 4.40),
                  decoration: InputDecoration(
                    // isDense: true,
                    prefixIcon: widget.isPhoneNumber
                        ? Container(
                            height: 50,
                            width: 60,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: const BoxDecoration(
                              color: Constants.extraColor200,

                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                bottomLeft: Radius.circular(6),
                              ), // BorderRadius
                            ), // BoxDecoration
                            child: Container(
                              child: const Center(
                                child: Text(
                                  "+595",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Constants.extraColor300,
                                      fontSize: 16),
                                ),
                              ),
                              margin: const EdgeInsetsDirectional.only(
                                  start: 1, top: 1, bottom: 1),
                              decoration: const BoxDecoration(
                                color: Color(0xffF9FAFB),

                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ), // BorderRadius
                              ), // BoxDecoration
                            ), // Container
                          )
                        : null,
                    suffixIcon: widget.customIcon != null
                        ? widget.customIcon
                        : widget.customSVGIcon != null
                            ? Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: SvgPicture.asset(
                                  widget.customSVGIcon,
                                  color: Constants.extraColor300,
                                ),
                              )
                            : null,
                    contentPadding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                  ),
                  //keyboardType: TextInputType.emailAddress,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  onSaved: (String val) {
                    widget.changeValueCallback(val);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
