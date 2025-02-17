import 'package:flutter/material.dart';
import '../theme.dart';

class CustomToggleButton extends StatefulWidget {
  final Function(bool) onChanged;
  final bool isToggled;
  final bool showText;

  const CustomToggleButton(
      {super.key,
      required this.onChanged,
      required this.isToggled,
      required this.showText});

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  bool isToggled = true;

  @override
  initState() {
    super.initState();
    isToggled = widget.isToggled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // widget.showText
        //     ? Text(
        //         isToggled ? 'visible' : 'invisible',
        //         // style: const TextStyle(color: textColor, fontSize: 20),
        //       )
        //     : Container(),
        SwitchTheme(
          data: const SwitchThemeData(),
          child: Transform.scale(
            scale: 1.0,
            child: Switch(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              value: isToggled,
              onChanged: (value) {
                widget.onChanged(value);
                setState(() {
                  isToggled = value;
                });
              },
              // activeColor: const Color.fromARGB(255, 185, 103, 73),
              // activeTrackColor: const Color(0xff714e26),
              // inactiveThumbColor: Colors.white,
              // inactiveTrackColor: const Color(0xffefcead),
              activeColor: toogleActiveColor,
              activeTrackColor: toogleActiveTrackColor,
              // inactiveThumbColor: toogleInactiveThumbColor,
              // inactiveTrackColor: toogleInactiveTrackColor,
            ),
          ),
        ),
      ],
    );
  }
}
