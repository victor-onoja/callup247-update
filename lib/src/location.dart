import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final BuildContext context;

  LocationService(this.context);

  Future<Position> getLocation() async {
    await requestLocationPermission();

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      await showLocationServiceDialog();
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
    }

    while (permission == LocationPermission.denied) {
      await showPermissionNecessityDialog();
      permission = await Geolocator.requestPermission();
    }
  }

  Future<void> showPermissionNecessityDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFF4E7D5),
          title: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text(
              'Location Access is Necessary',
              textAlign: TextAlign.center,
              style: responsiveTextStyle(
                context,
                22,
                const Color(0xFF36DCFF),
                FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Callup247 needs access to your location to work properly. Please allow us to access your device\'s location services.',
            textAlign: TextAlign.center,
            style: responsiveTextStyle(context, 16, Colors.grey.shade600, null),
          ),
        );
      },
    );
  }

  Future<void> showLocationServiceDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFF4E7D5),
          title: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text(
              'Enable GPS',
              textAlign: TextAlign.center,
              style: responsiveTextStyle(
                context,
                22,
                const Color(0xFF36DCFF),
                FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Callup247 needs access to GPS to display your location properly on the screen. Please enable GPS from the App Settings...',
            textAlign: TextAlign.center,
            style: responsiveTextStyle(context, 16, Colors.grey.shade600, null),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.all(12),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    Colors.white,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    Colors.black,
                  ),
                  overlayColor: MaterialStateProperty.all(
                    Colors.black.withOpacity(0.2),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                child: Text(
                  'Ok'.toUpperCase(),
                  style: responsiveTextStyle(
                      context, 18, const Color(0xFF36DCFF), null),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
