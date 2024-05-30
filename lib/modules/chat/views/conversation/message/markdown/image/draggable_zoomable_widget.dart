import 'package:flutter/material.dart';

/// 拖拽缩放组件
class DraggableZoomableWidget extends StatefulWidget {
  final Widget child;

  const DraggableZoomableWidget({required this.child, Key? key})
      : super(key: key);

  @override
  DraggableZoomableWidgetState createState() => DraggableZoomableWidgetState();
}

class DraggableZoomableWidgetState extends State<DraggableZoomableWidget> {
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = _previousScale * details.scale;
            _offset += details.focalPointDelta;
          });
        },
        child: Transform.translate(
          offset: _offset,
          child: Transform.scale(
            scale: _scale,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
