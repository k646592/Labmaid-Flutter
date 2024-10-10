import 'package:flutter/material.dart';

class GeoLocationIndexPage extends StatefulWidget {
  const GeoLocationIndexPage({Key? key}) : super(key: key);

  @override
  GeoLocationIndexPageState createState() => GeoLocationIndexPageState();
}

class GeoLocationIndexPageState extends State<GeoLocationIndexPage> {



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
            'リアルタイムメンバー位置表示',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.lightGreen.shade700,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: false,
        elevation: 0.0,
      ),

    );
  }
}
