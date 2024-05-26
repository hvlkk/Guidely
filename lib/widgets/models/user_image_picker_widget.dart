import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePickerWidget extends StatefulWidget {
  const UserImagePickerWidget({
    super.key,
    required this.onImagePicked,
    required this.onTourSession,
    this.radius = 40.0,
  });

  final void Function(File pickedImage) onImagePicked;
  final bool onTourSession;
  final double radius;

  @override
  State<UserImagePickerWidget> createState() => _UserImagePickerWidgetState();
}

class _UserImagePickerWidgetState extends State<UserImagePickerWidget> {
  File? _takenImage;

  void _takeImage() async {
    final takenImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 150);

    if (takenImage == null) return;

    setState(() {
      _takenImage = File(takenImage.path);
    });

    widget.onImagePicked(File(takenImage.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _takeImage,
          child: widget.onTourSession
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent, 
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: const Text(
                    'Take Picture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: widget.radius,
                  backgroundColor: Colors.grey,
                  foregroundImage:
                      _takenImage != null ? FileImage(_takenImage!) : null,
                  child: _takenImage == null
                      ? const Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
        ),
      ],
    );
  }
}
