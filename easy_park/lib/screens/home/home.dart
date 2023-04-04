import 'package:easy_park/models/address.dart';
import 'package:easy_park/providers/parking_spot_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/loading_snack_bar.dart';
import 'package:easy_park/ui_components/search_address_textfield.dart';
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
  SpotProviderInput providerInput = SpotProviderInput();
  bool showRefresh = false;
  LatLng? tmpPosition;
  final TextEditingController _controller = TextEditingController();
  GoogleMapController? _mapController;

  @override
  void dispose() {
    super.dispose();
    if (_mapController != null) {
      _mapController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                ref.invalidate(spotProvider(providerInput));
                Address newAddress = await LocationService.addressFromLatLng(
                    tmpPosition!.latitude, tmpPosition!.longitude);
                if (mounted) {
                  showLoadingSnackBar(
                      context, "Finding parking spots around here...",
                      color: AppColors.blueGreen, durationSeconds: 2);
                }
                setState(() {
                  providerInput.context = context;
                  providerInput.position = tmpPosition;
                  showRefresh = false;
                  _controller.text = newAddress.toString();
                });
              },
              label: const Text("Search this area"),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          body: Stack(alignment: AlignmentDirectional.topStart, children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(providerData.location.latitude!,
                      providerData.location.longitude!),
                  zoom: 18),
              onMapCreated: (controller) => _mapController = controller,
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
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppMargins.S, vertical: AppMargins.S),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: SearchAddressTextField(
                    label: 'Search...',
                    controller: _controller,
                    mapController: _mapController,
                  )),
            )
          ]),
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
