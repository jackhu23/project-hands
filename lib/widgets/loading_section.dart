import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../theme.dart';

/// A section that loads its data with [load]. While waiting it shows a
/// skeleton of [builder] with [placeholder]; after [timeout] or an error it
/// shows "Couldn't load this" with Try again. Only this section fails.
class LoadingSection<T> extends StatefulWidget {
  const LoadingSection({
    super.key,
    required this.load,
    required this.placeholder,
    required this.builder,
    this.onLoaded,
  });

  static const timeout = Duration(seconds: 10);

  final Future<T> Function() load;
  final T placeholder;
  final Widget Function(BuildContext context, T value) builder;

  /// Called with the value only when it loads in time; a load that ends
  /// after the timeout is dropped.
  final ValueChanged<T>? onLoaded;

  @override
  State<LoadingSection<T>> createState() => _LoadingSectionState<T>();
}

class _LoadingSectionState<T> extends State<LoadingSection<T>> {
  late Future<T> _future = _start();

  Future<T> _start() =>
      widget.load().timeout(LoadingSection.timeout).then((value) {
        if (mounted) widget.onLoaded?.call(value);
        return value;
      });

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (context, snapshot) {
      // Checked first: after Try again, the snapshot keeps the old error
      // while the new load waits.
      if (snapshot.connectionState != ConnectionState.done) {
        return Skeletonizer(child: widget.builder(context, widget.placeholder));
      }
      if (snapshot.hasError) return _failure();
      // Not requireData: T may be nullable, and null is a loaded value.
      return widget.builder(context, snapshot.data as T);
    },
  );

  Widget _failure() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: HandsSizes.gapS,
      children: [
        Text(
          "Couldn't load this",
          style: HandsText.body.copyWith(color: HandsColors.inkMuted),
        ),
        OutlinedButton(
          onPressed: () => setState(() {
            _future = _start();
          }),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, HandsSizes.minTouch),
            foregroundColor: HandsColors.inkMuted,
            side: const BorderSide(color: HandsColors.borderStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
            ),
          ),
          child: Text(
            'Try again',
            style: HandsText.buttonSmall.copyWith(color: HandsColors.inkMuted),
          ),
        ),
      ],
    ),
  );
}
