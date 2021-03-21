import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin GeolocatorMixin {
  GeolocationResult<double> distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      final distance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
      return GeolocationResult(Status.ok, distance);
    } catch (e) {
      return GeolocationResult(Status.genericError, null);
    }
  }

  Future<GeolocationResult<LatLng>> getCurrentPosition() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if(position == null) {
        return GeolocationResult(
          Status.locationNotFound, null
        );
      }

      return GeolocationResult(
        Status.ok,
        LatLng(
          position.latitude,
          position.longitude,
        ),
      );
    } else {
      return GeolocationResult(Status.missingPermission, null);
    }
  }
}

class GeolocationResult<T> {
  final Status status;
  final T result;

  GeolocationResult(this.status, this.result);
}

enum Status { ok, genericError, locationNotFound, missingPermission }
