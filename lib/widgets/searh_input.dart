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

  bool showClearIcon = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState(){
    _controller.text = widget.initialText?? '';
    super.initState();
    widget.initialText?.isEmpty?? true? showClearIcon = false : showClearIcon = true;
  }

  @override
  Widget build(BuildContext context) {

    Widget form = TextFormField(
      controller: _controller,
      style: const TextStyle(
        color: ConstantsV2.activeText,
        fontSize: 12,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        height: 0,
      ),
      decoration: InputDecoration(
        prefixIcon: InkWell(
          onTap: (){
            widget.onEditingComplete?.call(_controller.text);
          },
          child: const Icon(
            Icons.search_outlined,
            size: 12,
            color: ConstantsV2.grayDark,
          ),
        ),
        suffixIcon: showClearIcon? InkWell(
          onTap: (){
            _controller.text = '';
            widget.onEditingComplete?.call('');
            setState(() {

            });
          },
          child: const Icon(
            Icons.clear,
            size: 12,
            color: ConstantsV2.grayDark,
          ),
        ): null,
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: ConstantsV2.gray,
          fontSize: 10,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                width: 1,
                color: Color(0xFFAFBACA),
            )
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                width: 1,
                color: ConstantsV2.blueDark,
            )
        ),
        fillColor: const Color(0xFFF9FAFB),
      ),
      keyboardType: TextInputType.name,
      onFieldSubmitted: widget.onEditingComplete,
      onChanged: (String value){
        widget.onChange?.call(value);
        setState(() {
          showClearIcon = value.isNotEmpty;
        });
      },
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          child
        ],
      ),
    );
  }

}