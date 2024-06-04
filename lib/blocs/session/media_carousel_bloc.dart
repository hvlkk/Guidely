import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class MediaCarouselBloc {
  Future<void> showImageDialog(BuildContext context, String url) async {
    // Permission granted, navigate to the PhotoView screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: PhotoView(
            imageProvider: NetworkImage(
              url,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => downloadImage(url),
            child: const Icon(Icons.download),
          ),
        ),
      ),
    );
  }

  Future<void> downloadImage(String url) async {
    try {
      // Get the downloads directory
      Directory? downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception("Unable to get downloads directory");
      }
      final savedDir = downloadsDir.path;
      print("Saved directory: $savedDir");

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    } catch (error, stackTrace) {
      print('Error downloading image: $error');
      print('Stack trace: $stackTrace');
    }
  }
}
