import 'dart:typed_data';

class PickedImage {
  Uint8List bytes;
  String fileName;

  PickedImage({required this.bytes, required this.fileName});
}
