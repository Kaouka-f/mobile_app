import 'package:flutter/material.dart';

class PermissionToggleButton extends StatefulWidget {
  final Function(bool) onChanged;
  final bool isToggled;
  final String text;
  final bool lock;

  const PermissionToggleButton(
      {super.key,
      required this.onChanged,
      required this.isToggled,
      required this.text,
      required this.lock});

  @override
  State<PermissionToggleButton> createState() => _PermissionToggleButtonState();
}

class _PermissionToggleButtonState extends State<PermissionToggleButton> {
  bool isToggled = true;

  @override
  initState() {
    super.initState();
    isToggled = widget.isToggled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.text,
        ),
        SwitchTheme(
          data: const SwitchThemeData(),
          child: Transform.scale(
            scale: 1.0,
            child: Switch(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              value: widget.lock ? true : isToggled,
              onChanged: (value) {
                if (!widget.lock) {
                  widget.onChanged(value);
                  setState(() {
                    isToggled = value;
                  });
                }
              },
              activeColor: widget.lock ? Colors.grey : Colors.pinkAccent,
              activeTrackColor: widget.lock ? Colors.blueGrey : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
