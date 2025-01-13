import 'package:url_launcher/url_launcher.dart';

class SaveImage {
  Future<void> saveImage(String imageURL) async {
    if (await canLaunch(imageURL)) {
      await launch(imageURL);
    } else {
      throw 'Could not open the image URL';
    }

  }
}