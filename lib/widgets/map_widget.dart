import 'package:flutter/material.dart';
import 'package:journey_demo/notifier/model/plug_type.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/common/asset/image_helper.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/common/widget/border_button.dart';
import 'package:journey_demo/notifier/map_notifier.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MapNotifier>(context, listen: false).init();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapNotifier>(
      builder: (_, notifier, __) {
        return BaseWidget(
          loadingBundle: notifier.loadingBundle,
          child: Stack(
            children: [
              _buildMap(notifier),
              _buildTopAlert(notifier),
              _buildBottomLayout(notifier),
            ],
          ),
        );
      },
    );
  }

  _buildTopAlert(MapNotifier notifier) {
    final markersLen = notifier.markers.length;

    final infoText = _getAlertTopText(markersLen);

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: notifier.hasNotReachedMaxMarkerOnMap() ? 1 : 0,
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BoldText(
                infoText,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildMap(MapNotifier notifier) {
    return GoogleMap(
      mapType: notifier.mapType,
      initialCameraPosition: notifier.initialPosition,
      onMapCreated: (GoogleMapController controller) {
        notifier.completeMapController(controller);
      },
      myLocationButtonEnabled: false,
      onTap: (position) => notifier.onTapMap(position),
      markers: notifier.markers,
    );
  }

  _buildDeleteAllMarker(MapNotifier notifier) {
    return CircularButton(
      onTap: () => notifier.clearAllMarkers(),
      iconName: Icons.delete_forever,
    );
  }

  _buildReload(MapNotifier notifier) {
    return CircularButton(
      onTap: () => notifier.init(),
      iconName: Icons.refresh,
    );
  }

  String _getAlertTopText(int len) {
    switch (len) {
      case 0:
        return 'Select starting point on map.';
      default:
        return 'Select ending point on map.';
    }
  }

  _buildBottomLayout(MapNotifier notifier) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildStationSelectedCard(notifier),
              Visibility(
                visible: !notifier.hasNotReachedMaxMarkerOnMap(),
                child: BorderButton(
                  onTap: () => notifier.onCalculateTap(),
                  child: BoldText("Calculate"),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildDeleteAllMarker(notifier),
                  _buildReload(notifier),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildStationSelectedCard(MapNotifier notifier) {
    final stationSelected = notifier.stationSelected;
    if (stationSelected != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BoldText(
                "OCM-ID: ${stationSelected.id}",
                color: Colors.black,
              ),
              Wrap(
                children: [
                  ...stationSelected.plugs.map((plug) {
                    return Container(
                      width: 50,
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getSvg(
                            path: plug.type.svg,
                            width: 30,
                            height: 30,
                          ),
                          RegularText(
                            plug.type?.name ?? '',
                            color: Colors.black,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    );
                  },),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class CircularButton extends StatelessWidget {
  final IconData iconName;
  final Function onTap;

  const CircularButton({
    Key key,
    this.iconName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: CircleBorder(),
      child: IconButton(
        icon: Icon(iconName),
        onPressed: () => onTap?.call(),
      ),
    );
  }
}
