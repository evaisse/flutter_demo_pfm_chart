import 'dart:math';

import 'package:flutter/material.dart';

///
/// @see https://gist.github.com/rxlabz/081b6272f35471463a62e2ae8414025e

class SegmentData {
  final String label;
  final double value;
  final Color color;

  SegmentData({
    required this.label,
    required this.value,
    required this.color,
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
  final DataProvider data;
  final Size size;

  const DoughnutWidget({Key? key, required this.data, required this.size}) : super(key: key);

  @override
  State createState() => _DoughnutState();
}

class _DoughnutState extends State<DoughnutWidget> with TickerProviderStateMixin {
  late final anim = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  final List<CurvedAnimation> intervals = [];

  DataProvider get data => widget.data;

  @override
  void initState() {
    super.initState();

    /// add debug
    anim.addListener(() => debugPrint("progress: ${anim.value}"));

    final intervalValues = <List<double>>[];

    /// will create every interval of the animation process
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

    anim.forward();
  }

  @override
  Widget build(BuildContext context) {
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

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => Stack(
        children: pieces.map((piece) {
          return Center(
            child: GestureDetector(
              onTap: () => debugPrint('operation ${piece.segment.label}'),
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
    debugPrint('DonutSegmentPainter.DonutSegmentPainter... $progress');
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
