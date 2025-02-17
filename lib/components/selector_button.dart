import 'package:flutter/material.dart';

class SelectorButton extends StatefulWidget {
  final List<Function> functions;
  final List<String> texts;
  const SelectorButton(
      {super.key, required this.functions, required this.texts});

  @override
  State<SelectorButton> createState() => _SelectorButtonState();
}

class _SelectorButtonState extends State<SelectorButton> {
  List<bool> _selections = List.generate(2, (index) => index == 0);

  void _onSelection(int index) {
    widget.functions[index]();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: _selections,
        selectedColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        selectedBorderColor: Colors.white,
        // renderBorder: false,
        onPressed: (index) {
          setState(() {
            _selections = List.generate(_selections.length, (_) => false);
            _selections[index] = true;
          });
          _onSelection(index);
        },
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: Center(
              child: Text(widget.texts[0]),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: Center(
              child: Text(widget.texts[1]),
            ),
          ),
        ],
      ),
    );
  }
}
