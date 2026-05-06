import 'package:flutter/material.dart';

/// A small helper widget that slightly shrinks its child when the keyboard is visible.
///
/// Usage: wrap the main content with `ShrinkOnKeyboard(child: ...)`.
class ShrinkOnKeyboard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double shrinkFactor;

  const ShrinkOnKeyboard(
      {Key? key,
      required this.child,
      this.duration = const Duration(milliseconds: 200),
      this.shrinkFactor = 0.94})
      : super(key: key);

  @override
  State<ShrinkOnKeyboard> createState() => _ShrinkOnKeyboardState();
}

class _ShrinkOnKeyboardState extends State<ShrinkOnKeyboard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final target = inset > 0 ? widget.shrinkFactor : 1.0;

    return AnimatedScale(
      scale: target,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: widget.child,
    );
  }
}
