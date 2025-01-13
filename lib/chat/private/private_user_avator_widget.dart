// Separate widget for user avatar
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/user_data.dart';

class UserAvatar extends StatelessWidget {
  final UserData userData;

  const UserAvatar({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CachedNetworkImage(
        imageUrl: userData.imageURL,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 20,
          backgroundImage: AssetImage('assets/images/default.png'),
        ),
      ),
    );
  }
}

