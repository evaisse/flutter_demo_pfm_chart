import 'package:flutter/material.dart';

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
  final double sweepAngle;

  PieceOfDonut({required this.segment, required this.sweepAngle});
}

class DoughnutWidget extends StatelessWidget {
  final DataProvider data;
  final Size size;

  const DoughnutWidget({super.key, required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    // calcul des angles des ≠ segments

    List<PieceOfDonut> categorySegmentsData = [];

    for (var segment in data.segments) {
      categorySegmentsData.add(
        PieceOfDonut(
          segment: segment,
          sweepAngle: categorySegmentsData.isEmpty ? 0 : categorySegmentsData.last.sweepAngle,
        ),
      );
    }
    return Stack(
      children: <Widget>[
        ...categorySegmentsData.map((e) {
          return Center(
            child: GestureDetector(
              onTap: () => debugPrint('operation ${e.segment.label}'),
              child: CustomPaint(
                size: size,
                painter: DonutSegmentPainter(e, size: size),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class DonutSegmentPainter extends CustomPainter {
  final PieceOfDonut data;
  final Size size;

  const DonutSegmentPainter(this.data, {required this.size});

  Path get path {
    final center = size.center(Offset.zero);
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx, 0);
    path.addArc(
      Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
      data.segment.value /*-pi / 2*/,
      data.sweepAngle /*pi / 2*/,
    );
    path.lineTo(center.dx, center.dy);
    return path;
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
  bool shouldRepaint(DonutSegmentPainter oldDelegate) => true;

  @override
  bool? hitTest(Offset position) => path.contains(position);
}
