
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:saver_gallery/saver_gallery.dart';

class SaveImage {
  Future<void> saveImage(String imageURL) async {
    var response = await Dio().get(
      imageURL,
      options: Options(responseType: ResponseType.bytes),
    );

    final result = await SaverGallery.saveImage(
      Uint8List.fromList(response.data),
      quality: 60,
      fileName: path.basename(imageURL),
      androidRelativePath: "Pictures/appName/images",
      skipIfExists: false,
    );

    print(result.toString());
  }
}



