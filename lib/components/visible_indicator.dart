import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/visible_notifier.dart';
import '../theme.dart';

class VisibleIndicator extends StatefulWidget {
  const VisibleIndicator({
    super.key,
  });

  @override
  State<VisibleIndicator> createState() => _VisibleIndicatorState();
}

class _VisibleIndicatorState extends State<VisibleIndicator> {
  late bool isToggled;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isToggled =
        Provider.of<PersistentVisibleProvider>(context).isVisibleChanged;

    return GestureDetector(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isToggled ? toogleActiveColor : toogleInactiveTrackColor,
        ),
      ),
    );
  }
}
