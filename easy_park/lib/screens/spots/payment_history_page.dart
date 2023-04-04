import 'package:easy_park/providers/payment_history_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/loading_snack_bar.dart';
import 'package:easy_park/ui_components/payment_listtile.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParkingHistoryPage extends ConsumerStatefulWidget {
  const ParkingHistoryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ParkingHistoryPageState();
}

class _ParkingHistoryPageState extends ConsumerState<ParkingHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final providerData = ref.watch(paymentHistoryProvider);

    return providerData.when(data: (providerData) {
      return Scaffold(
          appBar: const CustomAppBar(showHome: true),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.slateGray,
            onPressed: () async {
              setState(() {
                ref.invalidate(paymentHistoryProvider);

                if (mounted) {
                  showLoadingSnackBar(context, "Refreshing...");
                }
              });
            },
            child: const Icon(Icons.refresh),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: ListView.separated(
            itemCount: providerData.length,
            itemBuilder: (context, index) {
              return PaymentListTile(
                parkingHistory: providerData[index],
              );
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
