import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:labmaidfastapi/domain/pick_image_data.dart';

class PickImage {
  Future<PickedImage?> pickImage() async {
    // ファイルピッカーを開いて画像を選択
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return null;

    // 選択したファイルのバイトデータを取得
    Uint8List bytes = result.files.single.bytes!;
    String fileName = result.files.single.name; // ファイル名を取得

    return PickedImage(bytes: bytes, fileName: fileName);
  }
}