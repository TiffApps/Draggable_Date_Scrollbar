import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Build the Scroll Thumb and label using the current configuration
typedef ScrollThumbBuilder = Widget Function(
  Color backgroundColor,
  Color arrowColor,
  Animation<double> thumbAnimation,
  Animation<double> labelAnimation,
  double height, {
  DateTime? labelDate,
  BoxConstraints? labelConstraints,
});

/// Build a Text widget using the current scroll offset
typedef LabelDateBuilder = DateTime Function(double offsetY);

/// A widget that will display a BoxScrollView with a ScrollThumb that can be dragged
/// for quick navigation of the BoxScrollView.
class DraggableDateScrollbar extends StatefulWidget {
  /// The view that will be scrolled with the scroll thumb
  final BoxScrollView child;

  /// A function that builds a thumb using the current configuration
  final ScrollThumbBuilder scrollThumbBuilder;

  /// The height of the scroll thumb
  final double heightScrollThumb;

  /// The background color of the label and thumb
  final Color backgroundColor;

  /// The color of the arrow indicators and the thin border on the thumb
  final Color arrowColor;

  /// The amount of padding that should surround the thumb
  final EdgeInsetsGeometry? padding;

  /// Determines how quickly the scrollbar will animate in and out
  final Duration scrollbarAnimationDuration;

  /// How long should the thumb be visible before fading out
  final Duration scrollbarTimeToFade;

  /// Build a Text widget from the current offset in the BoxScrollView
  final LabelDateBuilder? labelDateBuilder;

  /// Determines box constraints for Container displaying label
  final BoxConstraints? labelConstraints;

  /// The ScrollController for the BoxScrollView
  final ScrollController controller;

  /// Determines scrollThumb displaying. If you draw own ScrollThumb and it is true you just don't need to use animation parameters in [scrollThumbBuilder]
  final bool alwaysVisibleScrollThumb;

  /// Updates [isReversed] to reverse the date label when it comes too close to the left side.
  final Function()? onReversed;

  /// Defines the direction of the date label.
  /// false = on the right of the scrollThumb
  /// true = on the left of the scrollThumb
  final bool isReversed;

  static List<Widget> _widgets = [];

  DraggableDateScrollbar({
    Key? key,
    this.alwaysVisibleScrollThumb = false,
    required this.heightScrollThumb,
    required this.backgroundColor,
    required this.scrollThumbBuilder,
    required this.child,
    required this.controller,
    this.arrowColor = Colors.grey,
    this.padding,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelDateBuilder,
    this.labelConstraints,
    this.onReversed,
    this.isReversed = false,
  })  : assert(child.scrollDirection == Axis.vertical),
        super(key: key);

  DraggableDateScrollbar.circle({
    Key? key,
    Key? scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    required this.child,
    required this.controller,
    required this.onReversed,
    this.isReversed = false,
    this.heightScrollThumb = 48.0,
    this.backgroundColor = Colors.white,
    this.arrowColor = Colors.grey,
    this.padding,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelDateBuilder,
    this.labelConstraints,
  })  : assert(child.scrollDirection == Axis.vertical),
        scrollThumbBuilder = _thumbCircleBuilder(heightScrollThumb * 0.6,
            scrollThumbKey, alwaysVisibleScrollThumb, isReversed),
        super(key: key);

  @override
  _DraggableDateScrollbarState createState() => _DraggableDateScrollbarState();

  static buildScrollThumbAndLabel(
      {required Widget scrollThumb,
      required Color backgroundColor,
      required Color arrowColor,
      required Animation<double>? thumbAnimation,
      required Animation<double>? labelAnimation,
      required DateTime? labelDate,
      required BoxConstraints? labelConstraints,
      required bool alwaysVisibleScrollThumb,
      required bool isReversed}) {
    if (labelDate != null) {
      _widgets = [
        ScrollLabel(
          animation: labelAnimation,
          date: labelDate,
          backgroundColor: backgroundColor,
          borderColor: arrowColor,
          constraints: labelConstraints,
        ),
        // const SizedBox(width: 15),
        scrollThumb,
      ];
    }
    Widget scrollThumbAndLabel = labelDate == null
        ? scrollThumb
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: isReversed ? _widgets.reversed.toList() : _widgets,
          );

    if (alwaysVisibleScrollThumb) {
      return scrollThumbAndLabel;
    }
    return SlideFadeTransition(
      animation: thumbAnimation!,
      child: scrollThumbAndLabel,
    );
  }

  static ScrollThumbBuilder _thumbCircleBuilder(double width,
      Key? scrollThumbKey, bool alwaysVisibleScrollThumb, bool isReversed) {
    return (
      Color backgroundColor,
      Color arrowColor,
      Animation<double> thumbAnimation,
      Animation<double> labelAnimation,
      double size, {
      DateTime? labelDate,
      BoxConstraints? labelConstraints,
    }) {
      final scrollThumb = CustomPaint(
        foregroundPainter: ArrowCustomPainter(arrowColor),
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(size)),
              border: Border.all(width: 0.1, color: arrowColor)),
          height: size,
          width: size,
        ),
      );

      return buildScrollThumbAndLabel(
        scrollThumb: scrollThumb,
        backgroundColor: backgroundColor,
        arrowColor: arrowColor,
        thumbAnimation: thumbAnimation,
        labelAnimation: labelAnimation,
        labelDate: labelDate,
        labelConstraints: labelConstraints,
        alwaysVisibleScrollThumb: alwaysVisibleScrollThumb,
        isReversed: isReversed,
      );
    };
  }
}

class ScrollLabel extends StatelessWidget {
  final Animation<double>? animation;
  final Color backgroundColor;
  final Color borderColor;
  final DateTime date;

  final BoxConstraints? constraints;
  static const BoxConstraints _defaultConstraints =
      BoxConstraints.tightFor(width: 72.0, height: 28.0);

  const ScrollLabel({
    Key? key,
    required this.date,
    required this.animation,
    required this.backgroundColor,
    required this.borderColor,
    this.constraints = _defaultConstraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation!,
      child: Container(
        margin: const EdgeInsets.only(right: 12.0, left: 12.0),
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(50.0)),
          elevation: 4.0,
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat("MMM").format(date),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      date.day.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      date.year.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableDateScrollbarState extends State<DraggableDateScrollbar>
    with TickerProviderStateMixin {
  late double _barOffsetY;
  late double _barOffsetX;
  late double _viewOffset;
  late bool _isDragInProcess;

  late AnimationController _thumbAnimationController;
  late Animation<double> _thumbAnimation;
  late AnimationController _labelAnimationController;
  late Animation<double> _labelAnimation;
  Timer? _fadeoutTimer;
  bool isOnLeftSide = false;

  @override
  void initState() {
    super.initState();
    _barOffsetY = 0.0;
    _barOffsetX = 30.0;
    _viewOffset = 0.0;
    _isDragInProcess = false;

    _thumbAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _thumbAnimation = CurvedAnimation(
      parent: _thumbAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    _labelAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _labelAnimation = CurvedAnimation(
      parent: _labelAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    _labelAnimationController.dispose();
    _fadeoutTimer?.cancel();
    super.dispose();
  }

  double get barMaxYExtent => context.size!.height - widget.heightScrollThumb;

  double get barMinYExtent => 0.0;

  double get barMaxXExtent => context.size!.width / 2 + 7;

  double get barMinXExtent => 30.0;

  double get viewMaxScrollExtent => widget.controller.position.maxScrollExtent;

  double get viewMinScrollExtent => widget.controller.position.minScrollExtent;

  @override
  Widget build(BuildContext context) {
    DateTime? labelDate;
    if (widget.labelDateBuilder != null && _isDragInProcess) {
      labelDate = widget.labelDateBuilder!(
        _viewOffset + _barOffsetY + widget.heightScrollThumb / 2,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            changePosition(notification);
            return false;
          },
          child: Stack(
            children: <Widget>[
              RepaintBoundary(
                child: widget.child,
              ),
              RepaintBoundary(
                child: _isDragInProcess
                    ? Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Column(
                          children: const [
                            // TODO: Replace the Spacers by an actual way to calculate the distance between them from number of pictures
                            Spacer(flex: 1),
                            YearLabel(year: "2022"),
                            Spacer(flex: 1),
                            YearLabel(year: "2021"),
                            Spacer(flex: 3),
                            YearLabel(year: "2015"),
                            Spacer(flex: 1),
                          ],
                        ),
                      )
                    : Container(),
              ),
              RepaintBoundary(
                child: Draggable(
                  onDragStarted: _onDragStart,
                  onDragUpdate: _onDragUpdate,
                  onDragEnd: _onDragEnd,
                  child: Container(
                    alignment: Alignment.topRight,
                    margin:
                        EdgeInsets.only(top: _barOffsetY, right: _barOffsetX),
                    padding: widget.padding,
                    child: widget.scrollThumbBuilder(
                      widget.backgroundColor,
                      widget.arrowColor,
                      _thumbAnimation,
                      _labelAnimation,
                      widget.heightScrollThumb,
                      labelDate: labelDate,
                      labelConstraints: widget.labelConstraints,
                    ),
                  ),
                  feedback: Container(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //scroll bar has received notification that it's view was scrolled
  //so it should also changes his position
  //but only if it isn't dragged
  changePosition(ScrollNotification notification) {
    if (_isDragInProcess) {
      return;
    }

    setState(() {
      if (notification is ScrollUpdateNotification) {
        _barOffsetY += getBarDelta(
          notification.scrollDelta!,
          barMaxYExtent,
          viewMaxScrollExtent,
        );

        if (_barOffsetY < barMinYExtent) {
          _barOffsetY = barMinYExtent;
        }
        if (_barOffsetY > barMaxYExtent) {
          _barOffsetY = barMaxYExtent;
        }

        _viewOffset += notification.scrollDelta!;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
      }

      if (notification is ScrollUpdateNotification ||
          notification is OverscrollNotification) {
        if (_thumbAnimationController.status != AnimationStatus.forward) {
          _thumbAnimationController.forward();
        }

        _fadeoutTimer?.cancel();
        _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
          _thumbAnimationController.reverse();
          _labelAnimationController.reverse();
          _fadeoutTimer = null;
        });
      }
    });
  }

  double getBarDelta(
    double scrollViewDelta,
    double barMaxYExtent,
    double viewMaxScrollExtent,
  ) {
    return scrollViewDelta * barMaxYExtent / viewMaxScrollExtent;
  }

  double getScrollViewDelta(
    double barDelta,
    double barMaxYExtent,
    double viewMaxScrollExtent,
  ) {
    return barDelta * viewMaxScrollExtent / barMaxYExtent;
  }

  void _onDragStart() {
    setState(() {
      _isDragInProcess = true;
      _labelAnimationController.forward();
      _fadeoutTimer?.cancel();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_thumbAnimationController.status != AnimationStatus.forward) {
        _thumbAnimationController.forward();
      }
      if (_isDragInProcess) {
        _barOffsetY += details.delta.dy;
        _barOffsetX -= details.delta.dx;

        if (_barOffsetY < barMinYExtent) {
          _barOffsetY = barMinYExtent;
        }
        if (_barOffsetY > barMaxYExtent) {
          _barOffsetY = barMaxYExtent;
        }
        if (_barOffsetX < 0) {
          _barOffsetX = 0;
        }
        if (_barOffsetX > barMaxXExtent) {
          _barOffsetX = barMaxXExtent;
        }

        if (widget.onReversed != null &&
            isOnLeftSide == false &&
            _barOffsetX > context.size!.width / 2) {
          widget.onReversed!.call();
          setState(() {
            isOnLeftSide = true;
          });
        }

        if (widget.onReversed != null &&
            isOnLeftSide == true &&
            _barOffsetX < context.size!.width / 2) {
          widget.onReversed!.call();
          setState(() {
            isOnLeftSide = false;
          });
        }

        double viewDelta = getScrollViewDelta(
            details.delta.dy, barMaxYExtent, viewMaxScrollExtent);

        _viewOffset = widget.controller.position.pixels + viewDelta;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
        widget.controller.jumpTo(_viewOffset);
      }
    });
  }

  void _onDragEnd(DraggableDetails details) {
    if (details.offset.dx.abs() < MediaQuery.of(context).size.width / 2 &&
        _barOffsetX < MediaQuery.of(context).size.width / 2) {
      _barOffsetX = barMinXExtent; // move to right side
    } else {
      _barOffsetX = MediaQuery.of(context).size.width -
          (widget.heightScrollThumb + barMinXExtent); // move to left side
    }
    _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
      _thumbAnimationController.reverse();
      _labelAnimationController.reverse();
      _fadeoutTimer = null;
    });
    setState(() {
      _isDragInProcess = false;
    });
  }
}

class YearLabel extends StatelessWidget {
  final String year;
  const YearLabel({Key? key, required this.year}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(year),
    );
  }
}

/// Draws 2 triangles like arrow up and arrow down
class ArrowCustomPainter extends CustomPainter {
  Color color;

  ArrowCustomPainter(this.color);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const width = 12.0;
    const height = 8.0;
    const baseX = 50 / 2;
    const baseY = 60 / 2;

    canvas.drawPath(
      _trianglePath(const Offset(baseX, baseY - 2.0), width, height, true),
      paint,
    );
    canvas.drawPath(
      _trianglePath(const Offset(baseX, baseY + 2.0), width, height, false),
      paint,
    );
  }

  static Path _trianglePath(Offset o, double width, double height, bool isUp) {
    return Path()
      ..moveTo(o.dx, o.dy)
      ..lineTo(o.dx + width, o.dy)
      ..lineTo(o.dx + (width / 2), isUp ? o.dy - height : o.dy + height)
      ..close();
  }
}

///This cut 2 lines in arrow shape
class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();

    double arrowWidth = 8.0;
    double startPointX = (size.width - arrowWidth) / 2;
    double startPointY = size.height / 2 - arrowWidth / 2;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY - arrowWidth / 2);
    path.lineTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth, startPointY + 1.0);
    path.lineTo(
        startPointX + arrowWidth / 2, startPointY - arrowWidth / 2 + 1.0);
    path.lineTo(startPointX, startPointY + 1.0);
    path.close();

    startPointY = size.height / 2 + arrowWidth / 2;
    path.moveTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2);
    path.lineTo(startPointX, startPointY);
    path.lineTo(startPointX, startPointY - 1.0);
    path.lineTo(
        startPointX + arrowWidth / 2, startPointY + arrowWidth / 2 - 1.0);
    path.lineTo(startPointX + arrowWidth, startPointY - 1.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SlideFadeTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) =>
          animation.value == 0.0 ? Container() : child!,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.3, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}
