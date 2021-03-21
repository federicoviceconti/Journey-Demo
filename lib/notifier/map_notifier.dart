import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:journey_demo/common/mixin_geolocator.dart';
import 'package:journey_demo/notifier/mixin/mixin_loader_notifier.dart';
import 'package:journey_demo/notifier/model/direction.dart';
import 'package:journey_demo/services/open_charge_map/charge_map_service.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/common/asset/image_helper.dart';
import 'package:journey_demo/navigation/mixin/mixin_route.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/model/map_item.dart';
import 'package:xml2json/xml2json.dart';

class MapNotifier extends BaseNotifier
    with LoaderNotifierMixin, GeolocatorMixin {
  static const MAX_MARKER_TYPE_SET = 2;

  StationItem _stationSelected;

  StationItem get stationSelected => _stationSelected;

  Set<GeoNode> _directions = {};
  Set<MapItem> _mapItems = {};
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.9375349, 12.4722733),
    zoom: 14,
  );

  MapType get mapType => MapType.normal;

  CameraPosition get initialPosition => _initialPosition;

  Set<Marker> get markers => _markers;

  void init() async {
    try {
      showLoader();

      clearAllMarkers();

      final service = GetIt.instance<ChargeMapService>();
      final response = await service.getChargingStationsFromStartingPoint(
          startingPoint: _initialPosition.target, maxResult: 20);

      final markerIcon = await _getMarkerIcon("marker_cu");

      response.items.forEach((item) {
        final stationItem = StationItem.fromChargingStationItem(item);

        _markers.add(
          Marker(
            markerId: MarkerId(item.uuid),
            position: item.getLatLng(),
            icon: markerIcon,
            onTap: () => _onChargingUnitTap(stationItem),
          ),
        );

        _mapItems.add(stationItem);
      });

      hideLoader();
    } catch (e) {
      print(e);
      hideLoader();
    }
  }

  void completeMapController(GoogleMapController controller) {
    if (!_controller.isCompleted) _controller.complete(controller);
  }

  onTapMap(LatLng position) async {
    if (_stationSelected != null) {
      _stationSelected = null;
      notifyListeners();
    } else if (hasNotReachedMaxMarkerOnMap()) {
      final markerIcon = await _getMarkerIcon("marker");
      final uuid = Uuid().v1();

      markers.add(
        Marker(
          markerId: MarkerId(uuid),
          icon: markerIcon,
          position: position,
        ),
      );

      final items = _mapItems.where((element) => element is PositionItem);

      _mapItems.add(
        PositionItem(
          status: items.isEmpty ? PositionStatus.start : PositionStatus.end,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      notifyListeners();
    }
  }

  clearAllMarkers() {
    _clearBeforeCalculating();
    markers.clear();
    _mapItems.clear();
    _stationSelected = null;
    notifyListeners();
  }

  List<MapItem> filterMapItemByType(MapItemType type) {
    return _mapItems.where((element) => element.type == type).toList();
  }

  bool hasNotReachedMaxMarkerOnMap() {
    final items = filterMapItemByType(MapItemType.marker);
    return items.length < MAX_MARKER_TYPE_SET;
  }

  onCalculateTap() async {
    _clearBeforeCalculating();
    await loadGeoPoints();
    await findNearestPoint();
  }

  Future<BitmapDescriptor> _getMarkerIcon(String name) async {
    final ctx = RouteMixin.navigatorKey.currentContext;
    return await getBitmapDescriptorFromSvg(ctx, name, 60, 93);
  }

  _onChargingUnitTap(StationItem stationItem) {
    _stationSelected = stationItem;
    notifyListeners();
  }

  Future<void> loadGeoPoints() async {
    showLoader(subtitle: "Importing geo positions from Open Street Map");

    if (_directions.isEmpty) {
      final mapXml = await rootBundle.loadString('assets/map/map.osm');

      final myTransformer = Xml2Json();

      myTransformer.parse(mapXml);
      var json = jsonDecode(myTransformer.toBadgerfish());

      json['osm']['node'].take().forEach((element) {
        final direction = GeoNode(
          id: element['@id'],
          lat: double.tryParse(element['@lat']),
          lon: double.tryParse(element['@lon']),
          changeset: element['@changeset'],
        );

        _directions.add(direction);
      });
    }

    hideLoader();
  }

  void _clearBeforeCalculating() {
    _directions.clear();
    notifyListeners();
  }

  findNearestPoint() {
    showLoader(subtitle: "Finding the nearest marker");
    final startPosition = _mapItems.firstWhere((element) =>
        element is PositionItem && element.status == PositionStatus.start);

    return _directions.reduce(
      (curr, next) {
        final currItem = distanceBetween(startPosition.latitude,
            startPosition.longitude, curr.lat, curr.lon);
        final nextItem = distanceBetween(startPosition.latitude,
            startPosition.longitude, next.lat, next.lon);
        return currItem.result < nextItem.result ? curr : next;
      },
    );
  }
}
