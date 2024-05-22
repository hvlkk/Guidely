import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';

class TourSessionScreen extends StatefulWidget {
  const TourSessionScreen({super.key, required this.tour});

  final Tour tour;

  @override
  State<TourSessionScreen> createState() => _TourSessionScreenState();
}

class _TourSessionScreenState extends State<TourSessionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Session'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.tour.tourDetails.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 181, 161, 160),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          mapSection(),
          mediaWithActionCarousel(),
          Expanded(child: sessionChatSection()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text(
                    'Back to Main',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'End Session',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget mapSection() {
    return Column(
      children: [
        Container(
          height: 200,
          color: Colors.grey,
          child: const Center(child: Text('Map Placeholder')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Guide\'s Current Location'),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget mediaWithActionCarousel() {
    return Column(
      children: [
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(
              10,
              (index) => GestureDetector(
                onTap: () {
                  // open screen to show media in full screen, and let user interact with it
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Image.network('https://via.placeholder.com/150'),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // take picture logic
              },
              child: Text('Take Picture'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // upload picture logic
              },
              child: Text('Upload Picture'),
            ),
          ],
        ),
      ],
    );
  }

  Widget sessionChatSection() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: const [
              ListTile(
                leading: CircleAvatar(child: Text('P')),
                title: Text('Participant: Message here'),
                subtitle: Text('11:31 AM'),
              ),
              ListTile(
                leading: CircleAvatar(child: Text('P')),
                title: Text('Participant: Message here'),
                subtitle: Text('11:31 AM'),
              ),
              ListTile(
                leading: CircleAvatar(child: Text('P')),
                title: Text('Participant: Message here'),
                subtitle: Text('11:31 AM'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
