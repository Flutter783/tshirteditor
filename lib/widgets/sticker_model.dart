import 'dart:typed_data';
class StickerModel{
  bool isTextSticker;
  String stickerUri;
  Uint8List? textSticker;
  bool isSelected;
  double size;
  double top;
  double left;
  double angle;
  bool isFlipped;

  StickerModel({this.isTextSticker=false, this.stickerUri='None', this.textSticker, this.isSelected=true, this.size=200, this.top=0, this.left=0, this.angle=0,this.isFlipped=false});
}