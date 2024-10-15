import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';

class SaveImage {
  Future<void> saveImage(Uint8List image) async {
    return await ImageGallerySaver.saveImage(
      image,
      quality: 100,  // 品質を設定
      name: "saved_image",  // 保存する画像の名前
    );
  }
}

