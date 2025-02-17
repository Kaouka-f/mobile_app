import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final int maxLines;
  final int maxLength;
  final Function(String) onChanged;
  final TextEditingController? controller;

  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.maxLines,
      required this.maxLength,
      required this.onChanged,
      this.controller});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      scrollPhysics: const AlwaysScrollableScrollPhysics(),
      controller: _controller,
      onChanged: widget.onChanged,
      minLines: widget.maxLines != 0 ? widget.maxLines : null,
      maxLines: 5,
      maxLength: widget.maxLength,
      textInputAction: TextInputAction.done,
      // style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        isDense: true,
        // isCollapsed: true,
        counterText: '',
        // fillColor: Colors.white,
        hintText: widget.hintText,
        // hintStyle: const TextStyle(color: Colors.white),
      ),
      onTapOutside: (pointer) => _closeKeyboard(context),
    );
  }
}
