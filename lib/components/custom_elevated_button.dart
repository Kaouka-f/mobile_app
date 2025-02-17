import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isIcon;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isIcon = false,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // PersistentModeProvider darkMode =
    //     Provider.of<PersistentModeProvider>(context);
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: widget.onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: _isPressed ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 192, 192, 192),
              offset: Offset(0, 0),
              blurRadius: 20,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent),
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
