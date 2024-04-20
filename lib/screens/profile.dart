import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guidely/misc/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: poppinsFont.copyWith(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    // placeholder image, replace with user's image
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'John Doe',
                  style: poppinsFont.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              width: 310,
              height: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainColors.background,
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Become a tour guide',
                            style: poppinsFont.copyWith(
                              fontSize: 15,
                              color: MainColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Earn money by becoming a tour guide',
                            style: poppinsFont.copyWith(
                                fontSize: 10,
                                color: MainColors.textHint,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    SvgPicture.asset(
                      'assets/images/car.svg',
                      height: 70,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Settings",
                    style: poppinsFont.copyWith(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Personal Information",
                    style: poppinsFont.copyWith(
                      fontSize: 17,
                    ),
                  ),
                ),
                const Divider(
                  color: MainColors.divider,
                  thickness: 0.4,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.payment_outlined,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Payment Information",
                    style: poppinsFont.copyWith(
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
