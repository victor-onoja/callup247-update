import 'dart:math';

class GeoUtils {
  static const earthRadiusKm = 6371.0; // Radius of the earth in kilometers

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    final double dLat = degreesToRadians(lat2 - lat1);
    final double dLon = degreesToRadians(lon2 - lon1);

    final double a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c; // Distance in kilometers
  }
}
