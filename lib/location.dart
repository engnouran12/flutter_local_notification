// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class LocationFinder extends StatefulWidget {
//   const LocationFinder({Key? key}) : super(key: key);

//   @override
//   State<LocationFinder> createState() => _LocationFinderState();
// }

// class _LocationFinderState extends State<LocationFinder> {
//   String _address = '';
//   Position? _currentPosition;

//   // Function to extract coordinates from Google Maps URL
//   Future<Position> _getLocationFromGoogleMapsLink(String url) async {
//     // Extract latitude and longitude from the URL (example: regex)
//     RegExp regExp = RegExp(r'(@|!)([\d\-.]+),([\d\-.]+)'); 
//     Match? match = regExp.firstMatch(url);
//     if (match != null) {
//       double latitude = double.parse(match.group(2)!);
//       double longitude = double.parse(match.group(3)!);
//       return Position(
//         speedAccuracy: 49,
//         headingAccuracy:50 ,
//         heading: 3,
//         altitudeAccuracy: 2,
//           latitude: latitude, longitude: longitude, 
//           timestamp: DateTime.now(),
//            accuracy: 100, 
//            altitude: 9, speed:5 );
//     } else {
//       throw Exception('Invalid Google Maps URL');
//     }
//   }

//   // Function to get location from coordinates
//   Future<Position> _getLocationFromCoordinates(double latitude, double longitude) async {
//     return Geolocator.getCurrentPosition(latitude: latitude, 
//     longitude: longitude, timestamp: DateTime.now());
//   }

//   // Function to get current location
//   Future<Position> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied, we cannot request permissions.');
//     }

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.best, 
//     );
//   }

//   // Function to get address from coordinates
//   Future<void> _getAddressFromCoordinates(Position position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         setState(() {
//           _address =
//               '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
//         });
//       } else {
//         setState(() {
//           _address = 'No address found';
//         });
//       }
//     } catch (e) {
//       print('Error getting address: $e');
//       setState(() {
//         _address = 'Error getting address';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Location Finder'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Textfield for Google Maps URL
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Enter Google Maps URL',
//               ),
//               onChanged: (value) async {
//                 try {
//                   Position position = await _getLocationFromGoogleMapsLink(value);
//                   _currentPosition = position;
//                   _getAddressFromCoordinates(position);
//                 } catch (e) {
//                   setState(() {
//                     _address = 'Invalid URL';
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 20),

//             // Textfields for Latitude and Longitude
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Latitude',
//                     ),
//                     onChanged: (value) async {
//                       double? latitude = double.tryParse(value);
//                       if (latitude != null) {
//                         Position position =
//                             await _getLocationFromCoordinates(latitude, 0.0); 
//                         _currentPosition = position;
//                         _getAddressFromCoordinates(position);
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Longitude',
//                     ),
//                     onChanged: (value) async {
//                       double? longitude = double.tryParse(value);
//                       if (longitude != null) {
//                         Position position =
//                             await _getLocationFromCoordinates(0.0, longitude); 
//                         _currentPosition = position;
//                         _getAddressFromCoordinates(position);
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Button to get current location
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   Position position = await _getCurrentLocation();
//                   _currentPosition = position;
//                   _getAddressFromCoordinates(position);
//                 } catch (e) {
//                   setState(() {
//                     _address = 'Error getting current location: $e';
//                   });
//                 }
//               },
//               child: const Text('Get Current Location'),
//             ),
//             const SizedBox(height: 20),

//             // Display the address
//             Text(
//               'Address: $_address',
//               style: const TextStyle(fontSize: 18.0),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }