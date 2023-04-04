import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomNavBar extends StatelessWidget {
  final LatLng? position;
  final List<SpotInfo>? spots;
  const CustomNavBar({super.key, this.position, this.spots});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.slateGray,
      showUnselectedLabels: true,
      iconSize: AppFontSizes.XL,
      selectedFontSize: AppFontSizes.L,
      unselectedFontSize: AppFontSizes.L,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: "Profile",
            backgroundColor: AppColors.slateGray),
        BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
            backgroundColor: AppColors.slateGray),
        BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: "Pay",
            backgroundColor: AppColors.slateGray),
        BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Spots",
            backgroundColor: AppColors.slateGray)
      ],
      onTap: ((index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/profile');
            break;
          case 1:
            Navigator.pushNamed(context, '/history');
            break;
          case 2:
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('Pay for parking'),
                actions: <TextButton>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  )
                ],
              ),
            );
            break;
          case 3:
            Navigator.pushNamed(
              context,
              '/spot-list',
              arguments: <String, dynamic>{
                'position': position,
                'spots': spots,
              },
            );
            break;
        }
      }),
    );
  }
}
