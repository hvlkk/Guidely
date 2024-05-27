import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/blocs/main/session_bloc.dart';
import 'package:guidely/models/entities/session.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/screens/session/sections/chat_section.dart';
import 'package:guidely/screens/session/sections/map_section.dart';
import 'package:guidely/screens/session/sections/media_carousel_section.dart';
import 'package:guidely/screens/session/sections/voice_chat_section/voice_chat_section.dart';
import 'package:guidely/services/business_layer/session_service.dart';
import 'package:guidely/services/general/live_location_service.dart';

// Tour Session Screen
class TourSessionScreen extends ConsumerStatefulWidget {
  const TourSessionScreen({super.key, required this.tour});

  final Tour tour;

  bool get isGuide {
    return FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.uid == tour.organizer.uid;
  }

  @override
  _TourSessionScreenState createState() => _TourSessionScreenState();
}

class _TourSessionScreenState extends ConsumerState<TourSessionScreen> {
  final SessionBloc _sessionBloc = SessionBloc();

  final LiveLocationService _locationService = LiveLocationService();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start periodic location updates
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // _locationService.updateLocation(widget.tour.organizer.uid); 
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.tour.tourDetails.title} Session',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 181, 161, 160),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VoiceChatSection(
                    sessionId: widget.tour.sessionId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<Object>(
        stream: SessionService.getSession(widget.tour.sessionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Text('Error loading session');
          }
          if (snapshot.hasData && snapshot.data != null) {
            var documentSnapshot = snapshot.data as DocumentSnapshot;
            var sessionData = documentSnapshot.data() as Map<String, dynamic>;
            Session session = Session.fromMap(sessionData);
            return Column(
              children: [
                MapSection(
                  tour: widget.tour,
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.5),
                  thickness: 1,
                ),
                MediaCarousel(
                  mediaUrlsStream: Stream.value(session.mediaUrls),
                  sessionId: widget.tour.sessionId,
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.5),
                  thickness: 1,
                ),
                Expanded(
                  child: ChatSection(
                      chatMessagesStream: Stream.value(session.chatMessages)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text(
                          'Back to Main',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (widget.isGuide)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text(
                            'End Session',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
