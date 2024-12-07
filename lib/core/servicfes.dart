import 'package:geolocator/geolocator.dart';
//import 'package:geocoder/geocoder.dart';
class LocationService {
  // Get Current Location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the device's current location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Extract Latitude and Longitude from Google Maps URL
  Future<Position> getLocationFromGoogleMaps(String url) async {
    final regex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = regex.firstMatch(url);

    if (match != null) {
      double latitude = double.parse(match.group(1)!);
      double longitude = double.parse(match.group(2)!);
      return Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 1.0,
        heading: 1.0,
        speed: 1.0,
        speedAccuracy: 1.0,
      );
    } else {
      throw Exception('Invalid Google Maps URL.');
    }
  }

  // Resolve Address from Coordinates
  Future<String> getAddressFromCoordinates(Position position) async {
    List<Placemark> placemarks =
        await  Geolocator.placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
    }
    throw Exception('No address found for the given coordinates.');
  }
}
