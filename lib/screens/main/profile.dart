import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/enums/tour_guide_auth_state.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/screens/util/profile/personal_information.dart';
import 'package:guidely/screens/util/tour_guide_registration/tour_guide_registration.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: poppinsFont.copyWith(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: userDataAsync.when(
        data: (userData) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        userData.imageUrl,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      userData.username,
                      style: poppinsFont.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              if (userData.authState == TourGuideAuthState.authenticated) ...[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 96, 94, 94)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thank you for being a tour guide!',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: MainColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start organizing your tours now',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: MainColors.textHint,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else if (userData.authState ==
                  TourGuideAuthState.unauthenticated) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SizedBox(
                    width: 310,
                    height: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MainColors.background,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) {
                              return TourGuideRegistrationScreen();
                            },
                          ),
                        );
                      },
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
                                    fontWeight: FontWeight.bold,
                                  ),
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
              ] else if (userData.authState == TourGuideAuthState.pending) ...[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 96, 94, 94)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color.fromARGB(255, 31, 30, 30),
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your tour guide status is pending',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: MainColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please wait for approval.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: MainColors.textHint,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
                      onTap: () {
                        // navigate to the personal information screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const PersonalInformationScreen();
                            },
                          ),
                        );
                      },
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
                      onTap: () {
                        // navigate to the payment information screen
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Text('Error: $error'),
      ),
    );
  }
}
