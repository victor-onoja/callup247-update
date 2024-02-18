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
          title: const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text(
              'Location Access is Necessary',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF81571A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Callup247 needs access to your location to work properly. Please allow us to access your device\'s location services.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
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
          title: const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text(
              'Enable GPS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF81571A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Callup247 needs access to GPS to display your location properly on the screen. Please enable GPS from the App Settings...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
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
                    const Color(0xFFFEC10F),
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    const Color(0xFF923A06),
                  ),
                  overlayColor: MaterialStateProperty.all(
                    const Color(0xFF923A06).withOpacity(0.2),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                child: Text(
                  'Ok'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF81571A),
                  ),
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
