import 'package:easy_park/providers/parking_spot_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class _HomeState extends ConsumerState<Home> {
  SpotProviderInput providerInput = SpotProviderInput(
      context: null, position: null, sensorRange: 1, spots: null);
  bool showRefresh = false;
  LatLng? tmpPosition;

  @override
  Widget build(BuildContext context) {
    providerInput.context = context;
    final providerData = ref.watch(spotProvider(providerInput));

    return providerData.when(data: (providerData) {
      return Scaffold(
          appBar: const CustomAppBar(showHome: true),
          floatingActionButton: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: showRefresh ? 1.0 : 0.0,
            child: FloatingActionButton.extended(
              isExtended: true,
              backgroundColor: Colors.blueGrey,
              onPressed: () async {
                setState(() {
                  providerInput.position = tmpPosition;
                  // ignore: unused_result
                  ref.refresh(spotProvider(providerInput));
                  showRefresh = false;

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(
                              width: AppMargins.M,
                            ),
                            Text("Finding parking spots around here...")
                          ]),
                      backgroundColor: AppColors.blueGreen,
                    ));
                  }
                });
              },
              label: const Text("Search this area"),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: LatLng(providerData.location.latitude!,
                    providerData.location.longitude!),
                zoom: 18),
            onCameraMoveStarted: () {
              showRefresh = true;
              setState(() {});
            },
            onCameraMove: (position) {
              setState(() {
                tmpPosition = position.target;
              });
            },
            myLocationEnabled: true,
            markers: getMarkers(
                context,
                providerData.spots,
                LatLng(providerData.location.latitude!,
                    providerData.location.longitude!)),
          ),
          bottomNavigationBar: CustomNavBar(
              position: tmpPosition,
              spots: !showRefresh ? providerData.spots : null));
    }, error: ((error, stackTrace) {
      return ErrorPage(errorMsg: 'Error: ${error.toString()}');
    }), loading: () {
      return Container(
        color: Colors.white,
        child: const Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    });
  }
}
