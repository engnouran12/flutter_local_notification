import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationFetcher extends StatefulWidget {
  const LocationFetcher({super.key});

  @override
  _LocationFetcherState createState() => _LocationFetcherState();
}

class _LocationFetcherState extends State<LocationFetcher> {
  String address = '';
  double? latitude;
  double? longitude;

  // Default Google Maps link (for example, a link to a location)
  TextEditingController linkController = TextEditingController(
    text:
        'https://www.google.com/maps/@37.7749,-122.4194,12z', // Default Google Maps link (San Francisco, CA)
  );
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();

  // Function to extract coordinates from Google Maps URL
  void getLocationFromLink(String googleMapsLink) {
    RegExp regExp = RegExp(r'@([-\d.]+),([-\d.]+)');
    final match = regExp.firstMatch(googleMapsLink);
    if (match != null) {
      latitude = double.parse(match.group(1)!);
      longitude = double.parse(match.group(2)!);
      getAddressFromCoordinates(latitude!, longitude!);
    } else {
      setState(() {
        address = 'Invalid Google Maps link';
      });
    }
  }

  // Function to get address from coordinates using Geocoding package
  Future<void> getAddressFromCoordinates(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      setState(() {
        address =
            '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      });
    } catch (e) {
      setState(() {
        address = 'Failed to get address';
      });
    }
  }

  // Function to get the current location of the device
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        address = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          address = 'Location permission denied';
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude;
    longitude = position.longitude;
    getAddressFromCoordinates(latitude!, longitude!);
  }

  // Function to handle coordinates input
  void handleCoordinatesInput() {
    try {
      double lat = double.parse(latController.text);
      double lon = double.parse(longController.text);

      // Check if the coordinates are valid
      if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
        setState(() {
          address =
              'Invalid coordinates. Latitude must be between -90 and 90, Longitude between -180 and 180.';
        });
      } else {
        getAddressFromCoordinates(lat, lon);
      }
    } catch (e) {
      setState(() {
        address =
            'Please enter valid numeric values for latitude and longitude.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Fetcher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Google Maps link input (with default link)
              TextField(
                controller: linkController,
                decoration:
                    const InputDecoration(labelText: 'Google Maps Link'),
              ),
              ElevatedButton(
                onPressed: () {
                  String googleMapsLink = linkController.text;
                  getLocationFromLink(googleMapsLink);
                },
                child: const Text('Get Location from Link'),
              ),

              const SizedBox(height: 20),

              // Coordinates input
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: longController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: handleCoordinatesInput,
                child: const Text('Get Address from Coordinates'),
              ),

              const SizedBox(height: 20),

              // Current Location button
              ElevatedButton(
                onPressed: getCurrentLocation,
                child: const Text('Get Current Location'),
              ),

              const SizedBox(height: 20),

              // Display the address
              Text(
                'Address: $address',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
