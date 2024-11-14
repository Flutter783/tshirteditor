import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tshirteditor/widgets/text_model.dart';

class TextEditor extends StatefulWidget {
  final TextModel textModel;
  final Function() onTap;
  final Function() onDelete;
  final double boundWidth;
  final double boundHeight;
  const TextEditor(
      {Key? key,
      required this.textModel,
      required this.onTap,
      required this.onDelete,
      required this.boundWidth,
      required this.boundHeight})
      : super(key: key);

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  Offset initialFocalPoint = Offset.zero;
  Offset initialPosition = Offset.zero;
  double rotationStartAngle = 0;
  Offset? lastTouchPosition;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.textModel.left,
      top: widget.textModel.top,
      child: Transform.rotate(
        angle: widget.textModel.angle * pi / 180,
        child: GestureDetector(
          onScaleStart: (details) {
            initialFocalPoint = details.focalPoint;
            initialPosition =
                Offset(widget.textModel.left, widget.textModel.top);
          },
          onScaleUpdate: (details) {
            setState(() {
              if (widget.textModel.isSelected) {
                if (details.pointerCount == 1) {
                  double newLeft = initialPosition.dx +
                      (details.focalPoint.dx - initialFocalPoint.dx);
                  double newTop = initialPosition.dy +
                      (details.focalPoint.dy - initialFocalPoint.dy);
                  widget.textModel.left = newLeft;
                  widget.textModel.top = newTop;
                }
              }
            });
          },
          onTap: widget.onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  decoration: widget.textModel.isSelected
                      ? const BoxDecoration(
                          border: Border.fromBorderSide(
                              BorderSide(color: Colors.red, width: 0.5)))
                      : const BoxDecoration(),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(0.01 * widget.textModel.valueX)
                      ..rotateY(0.01 * widget.textModel.valueY),
                    alignment: FractionalOffset.center,
                    child: Text(widget.textModel.text,
                        textAlign: widget.textModel.textAlign,
                        style: widget.textModel.textStyle),
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  child: widget.textModel.isSelected
                      ? GestureDetector(
                          onTap: widget.onDelete,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(Icons.delete,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        )
                      : Container()),
              Positioned(
                  top: 0,
                  right: 0,
                  child: widget.textModel.isSelected
                      ? GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(Icons.done,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        )
                      : Container()),
              Positioned(
                  bottom: 0,
                  left: 0,
                  child: widget.textModel.isSelected
                      ? GestureDetector(
                          onPanStart: _onRotationStart,
                          onPanUpdate: _onRotationUpdate,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(Icons.screen_rotation,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        )
                      : Container()),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: widget.textModel.isSelected
                      ? GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              double deltaSize = details.delta.dx.abs() >
                                      details.delta.dy.abs()
                                  ? details.delta.dx
                                  : details.delta.dy;
                              double newSize =
                                  widget.textModel.textStyle.fontSize! +
                                      (deltaSize.isNegative ? -1 : 1);
                              if (newSize >= 5.0 &&
                                  newSize <= widget.boundWidth / 2) {
                                widget.textModel.updateTextSize(newSize);
                              }
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(Icons.crop,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        )
                      : Container()),
            ],
          ),
        ),
      ),
    );
  }

  void _onRotationStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset center = box.size.center(Offset.zero);
    lastTouchPosition = box.globalToLocal(details.globalPosition);
    final Offset touchPositionFromCenter = lastTouchPosition! - center;
    rotationStartAngle =
        atan2(touchPositionFromCenter.dy, touchPositionFromCenter.dx);
  }

  void _onRotationUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset center = box.size.center(Offset.zero);
    final Offset currentTouchPosition =
        box.globalToLocal(details.globalPosition);
    final Offset touchPositionFromCenter = currentTouchPosition - center;
    final double currentAngle =
        atan2(touchPositionFromCenter.dy, touchPositionFromCenter.dx);

    setState(() {
      final double angleDelta = currentAngle - rotationStartAngle;
      widget.textModel.angle += angleDelta * (180 / pi);
      rotationStartAngle = currentAngle;
    });
  }
}
