import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  MapScreen({required this.onLocationSelected});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onMapTap(LatLng tappedPoint) {
    widget.onLocationSelected(tappedPoint); // Pass the selected location back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // Initial map location
          zoom: 12,
        ),
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: MarkerId('selected_location'),
            position: _selectedLocation!,
          ),
        }
            : {},
      ),
    );
  }
}
