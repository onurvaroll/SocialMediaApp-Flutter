import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/theme.dart';

class MapWidget extends StatefulWidget {
  final String city;

  const MapWidget({super.key, required this.city});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late double latitude;

  late double longitude;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.city=='İstanbul'){
      latitude=41.01314238871488;
      longitude= 28.98327915565964;
    }
    if(widget.city=='Ankara'){
      latitude=39.93327783714547;
      longitude=32.85063978025036;
    }
    if(widget.city=='İzmir'){
      latitude= 38.42032550830405;
      longitude=27.138349900249242;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ThemeOfSocialMedia().normalAppBarText('Harita', context),
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12, // Yakınlaştırma seviyesi
        ),
        markers: {
          Marker(
            markerId: const MarkerId('City'),
            position:  LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: widget.city,
            ),
          ),
        },
      ),
    );
  }
}
