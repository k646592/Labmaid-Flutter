import 'package:image_picker/image_picker.dart';

import 'package:labmaidfastapi/domain/pick_image_data.dart';

class PickImage {
  Future<PickedImage?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    final uint8List = await image.readAsBytes();
    // ファイル名を取得
    String fileName = image.name;

    return PickedImage(bytes: uint8List, fileName: fileName);
  }
}