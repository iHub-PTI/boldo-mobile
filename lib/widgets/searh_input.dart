import 'package:boldo/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchInput extends StatefulWidget {

  final String? initialText;
  final bool? expanded;
  final double? maxWidth;
  final hintText;
  final Function(String)? onEditingComplete;
  final Function(String)? onChange;

  CustomSearchInput({
    Key? key,
    this.initialText,
    this.expanded,
    this.maxWidth,
    this.hintText,
    this.onEditingComplete,
    this.onChange,
  }) : assert( expanded == null && maxWidth != null,
  'If this is not expanded must bd have a width ')
  , super(key: key) ;

  @override
  State<CustomSearchInput> createState() => _StateCustomSearchInput();

}

class _StateCustomSearchInput extends State<CustomSearchInput> {

  @override
  Widget build(BuildContext context) {

    Widget form = TextFormField(
      initialValue: widget.initialText,
      style: const TextStyle(
        color: ConstantsV2.activeText,
        fontSize: 12,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        height: 0,
      ),
      decoration: InputDecoration(
        icon: const Icon(
          Icons.search_outlined,
          size: 12,
          color: ConstantsV2.grayDark,
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: ConstantsV2.gray,
          fontSize: 10,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        fillColor: const Color(0xFFF9FAFB),
      ),
      keyboardType: TextInputType.name,
      onFieldSubmitted: widget.onEditingComplete,
      onChanged: widget.onChange,
      validator: (value) {
        //remove unnecessary spaces
        value = value?.trimLeft().trimRight() ?? '';
        if (value.isEmpty) {
          return "Ingrese al menos un valor";
        }
        return null;
      },
    );

    Widget child;

    widget.expanded?? false ? child = Expanded(child: form)
    : child = Container(
      width: widget.maxWidth,
      child: form,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: ShapeDecoration(
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                width: 1,
                color: Colors.black54
            )
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          child
        ],
      ),
    );
  }

}