import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Container(
            padding: const EdgeInsets.all(8),
            height: 180,
            width: 180,
            decoration: const BoxDecoration(
              color: AppColors.pineTree,
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: Image.network(
                    'https://cdn.icon-icons.com/icons2/2468/PNG/512/user_kids_avatar_user_profile_icon_149314.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: .0,
          right: .0,
          child: Center(
            child: CircleAvatar(
              backgroundColor: AppColors.pineTree,
              radius: 25.0,
              child: Icon(
                Icons.add_a_photo,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        )
      ],
    );
  }
}
