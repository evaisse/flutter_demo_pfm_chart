import 'dart:math';

import 'package:flutter/material.dart';

///
/// @see https://gist.github.com/rxlabz/081b6272f35471463a62e2ae8414025e

class SegmentData {
  final String label;
  final double value;
  final Color color;
  final dynamic ref;

  SegmentData({
    required this.label,
    required this.value,
    required this.color,
    this.ref,
  });
}

class DataProvider {
  List<SegmentData> segments;

  DataProvider(this.segments);

  double get total => segments.map((e) => e.value).reduce((a, b) => a + b);
}

class PieceOfDonut {
  final SegmentData segment;
  final double startAngle;
  final double sweepAngle;

  PieceOfDonut({required this.segment, required this.sweepAngle, required this.startAngle});
}

class DoughnutWidget extends StatefulWidget {
  final DataProvider? data;
  final Size size;
  late final Color _backgroundColor;

  final Function(SegmentData segment)? onTapSegment;

  DoughnutWidget(
      {Key? key, required this.data, required this.size, this.onTapSegment, Color backgroundColor = Colors.grey})
      : super(key: key) {
    _backgroundColor = backgroundColor;
  }

  @override
  State createState() => _DoughnutState();
}

class _DoughnutState extends State<DoughnutWidget> with TickerProviderStateMixin {
  late final anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  final List<CurvedAnimation> intervals = [];

  DataProvider get data => widget.data ?? DataProvider([]);

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// add debug
    // anim.addListener(() => debugPrint("progress: ${anim.value}"));

    anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    /// will create every interval of the animation process
    final intervalValues = <List<double>>[];
    intervals.clear();
    for (final segment in data.segments) {
      final end = segment.value / data.total;
      final previousInterval = intervalValues.isNotEmpty ? intervalValues.last : [0.0, 0.0];
      final interval = CurvedAnimation(
        parent: anim,
        curve: Interval(previousInterval.last, previousInterval.last + end),
      );
      intervals.add(interval);
      intervalValues.add([previousInterval.last, previousInterval.last + end]);
    }

    List<PieceOfDonut> pieces = [];
    for (var segment in data.segments) {
      final previousStartAngle = pieces.isNotEmpty ? pieces.last.startAngle : 0.0;
      final previousSweepAngle = pieces.isNotEmpty ? pieces.last.sweepAngle : 0.0;
      final elementSweepAngle = (segment.value / data.total) * pi * 2;

      debugPrint('cat. ${segment.label} $elementSweepAngle $previousStartAngle $previousSweepAngle');

      pieces.add(
        PieceOfDonut(
          segment: segment,
          sweepAngle: elementSweepAngle,
          startAngle: previousStartAngle + previousSweepAngle,
        ),
      );
    }

    final bgPlaceholderPie = Center(
      child: CustomPaint(
        size: widget.size,
        painter: DonutSegmentPainter(
          PieceOfDonut(
            segment: SegmentData(label: "", color: Colors.grey, value: 1),
            startAngle: 0,
            sweepAngle: 360,
          ),
          progress: 1,
          size: widget.size,
        ),
      ),
    );

    // @todo add first full circle to stack
    return Stack(
      children: [
        bgPlaceholderPie,
        if (data.segments.isNotEmpty)
          AnimatedBuilder(
            animation: anim,
            builder: (context, _) => Stack(
              children: pieces.map((piece) {
                return Center(
                  key: Key('segment/${piece.segment.label}'),
                  child: GestureDetector(
                    onTap: () => widget.onTapSegment != null
                        ? widget.onTapSegment!(piece.segment)
                        : debugPrint('Tap segment ${piece.segment}'),
                    child: CustomPaint(
                      size: widget.size,
                      painter: DonutSegmentPainter(
                        piece,
                        progress: intervals[pieces.indexOf(piece)].value,
                        size: widget.size,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
      ],
    );
  }
}

class DonutSegmentPainter extends CustomPainter {
  final PieceOfDonut data;
  final double progress;
  final Size size;

  Path get path {
    final center = size.center(Offset.zero);
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx, 0);
    path.addArc(
      Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
      data.startAngle /*-pi / 2*/,
      data.sweepAngle * progress /*pi / 2*/,
    );
    path.lineTo(center.dx, center.dy);
    return path;
  }

  DonutSegmentPainter(
    this.data, {
    required this.progress,
    required this.size,
  }) {
    // debugPrint('DonutSegmentPainter.DonutSegmentPainter... $progress');
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.clipPath(
      Path()
        ..addOval(
          Rect.fromCenter(
            center: center,
            width: size.width / 2,
            height: size.height / 2,
          ),
        )
        ..addRect(
          Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
        )
        ..fillType = PathFillType.evenOdd,
    );
    canvas.drawPath(path, Paint()..color = data.segment.color);
  }

  @override
  bool shouldRepaint(DonutSegmentPainter oldDelegate) => true /*oldDelegate.data != data*/;

  @override
  bool? hitTest(Offset position) => path.contains(position);
}
