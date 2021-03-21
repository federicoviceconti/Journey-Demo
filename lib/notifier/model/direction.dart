import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoNode {
  final String id;
  final String changeset;
  final double lat;
  final double lon;
  Set<GeoNode> nearNode;

  GeoNode({
    this.id,
    this.lat,
    this.lon,
    this.changeset,
  });

  LatLng getLatLng() => LatLng(lat, lon);

  @override
  String toString() {
    return 'Direction{id: $id, changeset: $changeset, lat: $lat, lon: $lon}';
  }
}
