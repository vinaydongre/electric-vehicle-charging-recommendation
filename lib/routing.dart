import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:evscrs/location_service.dart';

import 'location_service.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> _polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  void initState() {
    super.initState();

    _setMarker(LatLng(37.42796133580664, -122.085749655962));
  }

  void _setMarker(LatLng point) {
    setState() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    }
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: _polygonLatLngs,
        strokeColor: Colors.red,
        strokeWidth: 2,
        fillColor: Colors.transparent));
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polygon_id_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        color: Colors.red,
        width: 2,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('Routing'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'Search by city'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                    TextFormField(
                      controller: _destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'Search by city'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () async {
                    var directions = await LocationService().getDirections(
                        _originController.text, _destinationController.text);
                    _goToPlace(
                        directions['start_location']['lat'],
                        directions['start_location']['lng'],
                        directions['bound_ne'],
                        directions['bound_sw']);
                    _setPolyline(directions['polyline_decoded']['points']);
                  },
                  icon: Icon(Icons.search)),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  _polygonLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(
    //Map<String, dynamic> place
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    //final double lat = place['geometry']['location']['lat'];
    //final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14.4746,
        ),
      ),
    );
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
              northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
          25),
    );
    _setMarker(LatLng(lat, lng));
  }
}
