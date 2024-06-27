import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

class CustomSearchInput extends StatefulWidget {
  const CustomSearchInput({
    super.key,
    this.initialText,
    this.expanded,
    this.maxWidth,
    this.hintText,
    this.onEditingComplete,
    this.onChange,
  }) : assert(
          expanded != null || maxWidth != null,
          'If this is not expanded must be have a width ',
        );
  final String? initialText;
  final bool? expanded;
  final double? maxWidth;
  final String? hintText;
  final Function(String)? onEditingComplete;
  final Function(String)? onChange;

  @override
  State<CustomSearchInput> createState() => _StateCustomSearchInput();
}

class _StateCustomSearchInput extends State<CustomSearchInput> {
  bool showClearIcon = false;
  final TextEditingController _controller = TextEditingController();

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
    final Widget form = SearchBar(
      controller: _controller,
      hintText: widget.hintText,
      hintStyle: const MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w400),
      ),
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
      constraints: const BoxConstraints(maxHeight: 44),
    );

    Widget child;

    widget.expanded ?? false
        ? child = Expanded(child: form)
        : child = SizedBox(
            width: widget.maxWidth,
            child: form,
          );

    return child;
  }
}
