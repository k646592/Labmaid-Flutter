import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  LocationPageState createState() => LocationPageState();
}

class LocationPageState extends State<LocationPage> {

  final center = const LatLng(34.77513, 135.51208);
  final mealCenter = const LatLng(34.77441, 135.51176);
  final libraryCenter = const LatLng(34.77496, 135.51013);
  final forthCenter = const LatLng(34.77358, 135.51256);
  final labCenter = const LatLng(34.77456, 135.51286);
  final stationCenter = const LatLng(34.77094, 135.50615);
  String currentLocation = 'キャンパス外';

  @override
  void initState() {
    super.initState();
  }

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }

  double distanceInMeters(Position target, LatLng center) {
    return Geolocator.distanceBetween(center.latitude, center.longitude, target.latitude, target.longitude);
  }

  void _checkDistance(Position position) {
    double centerDistance = distanceInMeters(position, center);
    double mealDistance = distanceInMeters(position, mealCenter);
    double libraryDistance = distanceInMeters(position, libraryCenter);
    double forthDistance = distanceInMeters(position, forthCenter);
    double labDistance = distanceInMeters(position, labCenter);
    double stationDistance = distanceInMeters(position, stationCenter);

    String newLocation;
    if (stationDistance <= 100) {
      newLocation = '関大前駅周辺';
    } else if (labDistance <= 10) {
      newLocation = '研究室周辺';
    } else if (forthDistance <= 100) {
      newLocation = '第４学舎周辺';
    } else if (libraryDistance <= 20) {
      newLocation = '図書館周辺';
    } else if (mealDistance <= 10) {
      newLocation = '凛風館周辺';
    } else if (centerDistance <= 340) {
      newLocation = 'キャンパス内';
    } else {
      newLocation = 'キャンパス外';
    }

    // ビルドが完了後にsetStateを呼び出す
    if (currentLocation != newLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentLocation = newLocation;
        });
      });
    }
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
      body: StreamBuilder<Position>(
          stream: Geolocator.getPositionStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final position = snapshot.data;
              _checkDistance(position!);
              return Center(
                child: Text(currentLocation),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
      ),
    );
  }
}
