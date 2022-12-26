import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.slateGray,
      showUnselectedLabels: true,
      iconSize: AppFontSizes.XL,
      selectedFontSize: AppFontSizes.L,
      unselectedFontSize: AppFontSizes.L,
      items: const [
        BottomNavigationBarItem(
            backgroundColor: AppColors.slateGray,
            icon: Icon(Icons.history),
            label: "History"),
        BottomNavigationBarItem(
            backgroundColor: AppColors.slateGray,
            icon: Icon(Icons.payment),
            label: "Pay"),
        BottomNavigationBarItem(
            backgroundColor: AppColors.slateGray,
            icon: Icon(Icons.search),
            label: "Find"),
        BottomNavigationBarItem(
            backgroundColor: AppColors.slateGray,
            icon: Icon(Icons.list),
            label: "Spots")
      ],
      onTap: ((index) {
        switch (index) {
          case 0:
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('Parking history'),
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
          case 1:
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
          case 2:
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('Find parking spots'),
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
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('View parking spots'),
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
        }
      }),
    );
  }
}
