import 'package:flutter/material.dart';
import 'package:mobifront/utils/utl.dart';

const _defaultDecoration = BoxDecoration(
  color: Colors.white,
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.all(Radius.circular(10)),
);
const _transpDecoration = BoxDecoration(
  color: Colors.transparent,
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class FutureProgressDialog extends StatefulWidget {
  /// Dialog will be closed when [future] task is finished.
  @required
  final Future future;

  /// [BoxDecoration] of [FutureProgressDialog].
  final BoxDecoration? decoration;

  /// opacity of [FutureProgressDialog]
  final double opacity;

  /// If you want to use custom progress widget set [progress].
  final Widget? progress;

  /// If you want to use message widget set [message].
  final Widget? message;

  FutureProgressDialog(
    this.future, {
    this.decoration,
    this.opacity = 1.0,
    this.progress,
    this.message,
  });

  @override
  _FutureProgressDialogState createState() => _FutureProgressDialogState();
}

class _FutureProgressDialogState extends State<FutureProgressDialog> {
  bool started = false;

  @override
  Widget build(BuildContext context) {
    if (!started) {
      started = true;
      widget.future.then((_) {
        Future.delayed(Duration.zero, () {
          bool popped = false;
          try {
            final nav = Navigator.of(context);
            if (nav.canPop()) nav.pop(true);
            popped = true;
          } catch (e) {
            Utl.log("falha popup", e);
          }

          if (!popped) {
            try {
              final nav = Navigator.of(context);
              if (nav.canPop()) nav.pop(true);
            } catch (e) {
              Utl.log("falha popup main", e);
            }
          }
        });
      }).catchError((e) {
        Utl.log("falha", e);
        Future.delayed(Duration.zero, () {
          bool popped = false;
          try {
            final nav = Navigator.of(context);
            if (nav.canPop()) nav.pop(true);
            popped = true;
          } catch (e) {
            Utl.log("falha popup", e);
          }

        });
      });
    }

    return _buildDialog(context);
  }

  Widget _buildDialog(BuildContext context) {
    Widget content;
    if (widget.message == null) {
      content = Center(
        child: Container(
          height: 75,
          width: 75,
          alignment: Alignment.center,
          decoration: widget.decoration ?? _transpDecoration,
          child: widget.progress ?? const CircularProgressIndicator(),
        ),
      );
    } else {
      content = Container(
        padding: const EdgeInsets.all(20),
        decoration: widget.decoration ?? _defaultDecoration,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          SizedBox(
              width: 25,
              height: 25,
              child: widget.progress ?? const CircularProgressIndicator()),
          const SizedBox(width: 20),
          _buildText(context)
        ]),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Opacity(
        opacity: widget.opacity,
        child: content,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    if (widget.message == null) {
      return const SizedBox.shrink();
    }
    return Expanded(
      flex: 1,
      child: widget.message!,
    );
  }
}
