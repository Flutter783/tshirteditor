import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tshirteditor/widgets/sticker_model.dart';

class StickerEditor extends StatefulWidget {
  final StickerModel stickerModel;
  final Function() onTap;
  final Function() onDelete;
  final double boundWidth;
  final double boundHeight;

  const StickerEditor(
      {Key? key,
      required this.stickerModel,
      required this.onTap,
      required this.onDelete,
      required this.boundWidth,
      required this.boundHeight})
      : super(key: key);

  @override
  State<StickerEditor> createState() => _StickerEditorState();
}

class _StickerEditorState extends State<StickerEditor> {
  Offset initialFocalPoint = Offset.zero;
  Offset initialPosition = Offset.zero;
  double rotationStartAngle = 0;
  Offset? lastTouchPosition;
  double? lastSize;
  @override
  void initState() {
    super.initState();
    lastSize = widget.stickerModel.size;
  }



  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.stickerModel.left,
      top: widget.stickerModel.top,
      child: Transform.rotate(
        angle: widget.stickerModel.angle * pi / 180,
        child: GestureDetector(
          onScaleStart: (details) {
            initialFocalPoint = details.focalPoint;
            initialPosition = Offset(widget.stickerModel.left, widget.stickerModel.top);
            lastSize = widget.stickerModel.size;

          },
          onScaleUpdate: (details) {
            if(widget.stickerModel.isSelected){
              setState(() {
                if (details.pointerCount == 2) {
                  double newSize = lastSize! * details.scale;
                  if (newSize > 70 && newSize < widget.boundWidth) {
                    widget.stickerModel.size = newSize;
                  }
                } else if (details.pointerCount == 1) {
                  double newLeft = initialPosition.dx + (details.focalPoint.dx - initialFocalPoint.dx);
                  double newTop = initialPosition.dy + (details.focalPoint.dy - initialFocalPoint.dy);
                  widget.stickerModel.left = newLeft;
                  widget.stickerModel.top = newTop;
                }
              });
            }

          },

          onTap: widget.onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: widget.stickerModel.size,
                  height: widget.stickerModel.size,
                  decoration: widget.stickerModel.isSelected
                      ? const BoxDecoration(
                          border: Border.fromBorderSide(
                              BorderSide(color: Colors.red, width: 0.5)))
                      : const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..scale(widget.stickerModel.isFlipped ? -1.0 : 1.0, 1.0), // Flip horizontally
                      alignment: Alignment.center,
                      child:  widget.stickerModel.isTextSticker && widget.stickerModel.textSticker != null
                          ? Image.memory(widget.stickerModel.textSticker!)
                          : CachedNetworkImage(
                        imageUrl: widget.stickerModel.stickerUri,
                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.black, value: downloadProgress.progress),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  child: widget.stickerModel.isSelected
                      ? GestureDetector(
                    onTap: (){
                      setState(() {
                        widget.stickerModel.isFlipped = !widget.stickerModel.isFlipped;  // Toggle flip state
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Icon(Icons.flip,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  )
                      : Container()),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: widget.stickerModel.isSelected
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
                  child: widget.stickerModel.isSelected
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
                  child: widget.stickerModel.isSelected
                      ? GestureDetector(
                    onPanStart: _onRotationStart,
                    onPanUpdate: _onRotationUpdate,
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child:
                                  Icon(Icons.screen_rotation, size: 18, color: Colors.white),
                            ),
                          ),
                      )
                      : Container()),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: widget.stickerModel.isSelected
                      ? GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              double deltaSize = details.delta.dx.abs() > details.delta.dy.abs() ? details.delta.dx : details.delta.dy;
                              double newSize = widget.stickerModel.size + (deltaSize.isNegative ? -2 : 2);
                              if(newSize>70){
                                widget.stickerModel.size=newSize;
                              }

                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child:
                                  Icon(Icons.crop, size: 18, color: Colors.white),
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
    rotationStartAngle = atan2(touchPositionFromCenter.dy, touchPositionFromCenter.dx);
  }

  void _onRotationUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset center = box.size.center(Offset.zero);
    final Offset currentTouchPosition = box.globalToLocal(details.globalPosition);
    final Offset touchPositionFromCenter = currentTouchPosition - center;
    final double currentAngle = atan2(touchPositionFromCenter.dy, touchPositionFromCenter.dx);

    setState(() {
      final double angleDelta = currentAngle - rotationStartAngle;
      widget.stickerModel.angle += angleDelta * (180 / pi);
      rotationStartAngle = currentAngle;
    });
  }
}
