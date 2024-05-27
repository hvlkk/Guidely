// Media Carousel
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guidely/blocs/session/media_carousel_bloc.dart';
import 'package:guidely/widgets/models/user_image_picker_widget.dart';
import 'package:image_picker/image_picker.dart';

class MediaCarousel extends StatefulWidget {
  final Stream<List<String>> mediaUrlsStream;
  final String sessionId;

  const MediaCarousel({
    super.key,
    required this.mediaUrlsStream,
    required this.sessionId,
  });

  @override
  _MediaCarouselState createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  MediaCarouselBloc _mediaCarouselBloc = MediaCarouselBloc();
  File? uploadedImage;
  File? takenImage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: widget.mediaUrlsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final List<String> mediaUrls = snapshot.data!;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: mediaUrls.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 30,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'No media available yet. \nUpload a picture!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 125,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: mediaUrls
                            .map((url) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          8.0), // Add horizontal padding here
                                  child: Image.network(url),
                                ))
                            .toList(),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserImagePickerWidget(
                    onTourSession: true,
                    onImagePicked: (pickedImage) {
                      // upload picture logic
                      _mediaCarouselBloc.addMedia(
                          context, pickedImage, widget.sessionId);
                      setState(() {
                        takenImage = pickedImage;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery, maxWidth: 150);
                      if (pickedFile != null) {
                        File image = File(pickedFile.path);
                        setState(() {
                          uploadedImage = image;
                        });
                        _mediaCarouselBloc.addMedia(
                            context, image, widget.sessionId);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue, // Background color
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: const Text(
                        'Upload Picture',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 16, // Font size
                          fontWeight: FontWeight.bold, // Font weight
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
