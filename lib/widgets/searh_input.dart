import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

class CustomSearchInput extends StatefulWidget {
  final String? initialText;
  final bool? expanded;
  final double? maxWidth;
  final String? hintText;
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
  })  : assert(expanded != null || maxWidth != null,
            'If this is not expanded must be have a width '),
        super(key: key);

  @override
  State<CustomSearchInput> createState() => _StateCustomSearchInput();
}

class _StateCustomSearchInput extends State<CustomSearchInput> {
  bool showClearIcon = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.initialText ?? '';
    super.initState();
    widget.initialText?.isEmpty ?? true
        ? showClearIcon = false
        : showClearIcon = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget form = TapRegion(
      child: SearchBar(
        controller: _controller,
        hintText: widget.hintText,
        hintStyle:
            MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.w400)),
        leading: IconButton(
          onPressed: () {
            widget.onEditingComplete?.call(_controller.text);
          },
          icon: const Icon(
            Icons.search_outlined,
            color: ConstantsV2.grayDark,
          ),
        ),
        trailing: [
          if (showClearIcon)
            IconButton(
              onPressed: () {
                _controller.text = '';
                widget.onEditingComplete?.call('');
                setState(() {});
              },
              icon: const Icon(
                Icons.clear,
                color: ConstantsV2.grayDark,
              ),
            ),
        ],
        onSubmitted: widget.onEditingComplete,
        onChanged: (String value) {
          widget.onChange?.call(value);
          setState(() {
            showClearIcon = value.isNotEmpty;
          });
        },
        constraints: BoxConstraints(maxHeight: 44),
      ),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );

    Widget child;

    widget.expanded ?? false
        ? child = Expanded(child: form)
        : child = Container(
            width: widget.maxWidth,
            child: form,
          );

    return child;
  }
}
