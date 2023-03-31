import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/providers/parking_spot_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/spot_status_listtile.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingSpotList extends ConsumerStatefulWidget {
  const ParkingSpotList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ParkingSpotListState();
}

class _ParkingSpotListState extends ConsumerState<ParkingSpotList> {
  SpotProviderInput providerInput = SpotProviderInput();
  LatLng? position;
  List<ParkingInfo>? spots;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    position = arguments['position'];
    spots = arguments['spots'];

    providerInput.position = position;
    providerInput.context = context;
    providerInput.spots = spots;
    final providerData = ref.watch(spotProvider(providerInput));

    return providerData.when(data: (providerData) {
      return Scaffold(
          appBar: const CustomAppBar(showHome: true),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.slateGray,
            onPressed: () async {
              setState(() {
                // TODO: check state update
                ref.invalidate(spotProvider(providerInput));

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(
                            width: AppMargins.M,
                          ),
                          Text("Checking for new spots...")
                        ]),
                    backgroundColor: AppColors.blueGreen,
                  ));
                }
              });
            },
            child: const Icon(Icons.refresh),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: ListView.separated(
            itemCount: providerData.spots.length,
            itemBuilder: (context, index) {
              ParkingInfo spot = providerData.spots[index];
              if (spot.state != SpotState.occupied) {
                return SpotStatusListTile(
                  spot: spot,
                  location: providerData.location,
                );
              } else {
                return Container();
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                thickness: 2,
                height: 0,
              );
            },
          ),
          bottomNavigationBar: const CustomNavBar());
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
