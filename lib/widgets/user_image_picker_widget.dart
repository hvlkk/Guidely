import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePickerWidget extends StatefulWidget {
  const UserImagePickerWidget({super.key, required this.onImagePicked});

  final void Function(File pickedImage) onImagePicked;

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
    return Column(children: [
      GestureDetector(
        onTap: _takeImage,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: FileImage(
            _takenImage ?? File(''),
          ),
          child: const Icon(
            Icons.add,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    ]);
  }
}
