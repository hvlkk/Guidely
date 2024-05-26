// Media Carousel
import 'package:flutter/material.dart';

class MediaCarousel extends StatelessWidget {
  final Stream<List<String>> mediaUrlsStream;

  const MediaCarousel({super.key, required this.mediaUrlsStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: mediaUrlsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final List<String> mediaUrls = snapshot.data!;
        return Column(
          children: [
            Container(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: mediaUrls.map((url) => Image.network(url)).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // take picture logic
                  },
                  child: const Text('Take Picture'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // upload picture logic
                  },
                  child: const Text('Upload Picture'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
