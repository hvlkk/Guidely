// Media Carousel
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guidely/blocs/main/session_bloc.dart';
import 'package:guidely/widgets/models/user_image_picker_widget.dart';
import 'package:image_picker/image_picker.dart';

class MediaCarousel extends StatefulWidget {
  final Stream<List<String>> mediaUrlsStream;
  final SessionBloc sessionBloc;
  final String sessionId;

  const MediaCarousel({
    super.key,
    required this.mediaUrlsStream,
    required this.sessionBloc,
    required this.sessionId,
  });

  @override
  _MediaCarouselState createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
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
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: mediaUrls
                    .map((url) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0), // Add horizontal padding here
                          child: Image.network(url),
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserImagePickerWidget(
                    onTourSession: true,
                    onImagePicked: (pickedImage) {
                      // upload picture logic
                      widget.sessionBloc
                          .addMedia(context, pickedImage, widget.sessionId);
                      setState(() {
                        takenImage = pickedImage;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery, maxWidth: 150);
                      if (pickedFile != null) {
                        File image = File(pickedFile.path);
                        setState(() {
                          uploadedImage = image;
                        });
                        widget.sessionBloc
                            .addMedia(context, image, widget.sessionId);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue, // Background color
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
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
