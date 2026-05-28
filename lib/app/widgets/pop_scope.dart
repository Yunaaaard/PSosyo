import 'package:flutter/widgets.dart';

/// A small wrapper around [WillPopScope] that exposes two optional callbacks:
/// - `onPopInvoked`: called with a single boolean `didPop` indicating whether
///   the system pop will proceed.
/// - `onPopInvokedWithResult`: called with `(didPop, result)`; `result` is
///   currently always `null` but kept for compatibility with callers that
///   expect a two-argument callback.
class PopScope extends StatelessWidget {
  const PopScope({
    Key? key,
    required this.child,
    this.canPop = true,
    this.onPopInvoked,
    this.onPopInvokedWithResult,
  }) : super(key: key);

  final Widget child;
  final bool canPop;
  final void Function(bool didPop)? onPopInvoked;
  final void Function(bool didPop, Object? result)? onPopInvokedWithResult;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final didPop = canPop;
        if (onPopInvokedWithResult != null) {
          onPopInvokedWithResult!(didPop, null);
        }
        if (onPopInvoked != null) onPopInvoked!(didPop);
        return didPop;
      },
      child: child,
    );
  }
}
