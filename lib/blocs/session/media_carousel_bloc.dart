import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MediaCarouselBloc {
  void showImageDialog(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: PhotoView(
            imageProvider: NetworkImage(url),
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
      var status = await Permission.storage.request();
      if (status.isDenied) {
        // ask for permission again
        print('Storage permission denied');
        return;
      }

      final savedDir = await getApplicationDocumentsDirectory();
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir.path,
        fileName: url.split('/').last,
        showNotification: true,
        openFileFromNotification:
            true, // Open file when the notification is tapped
      );

      print('Download task ID: $taskId');
    } catch (error, stackTrace) {
      print('Error downloading image: $error');
      print('Stack trace: $stackTrace');
    }
  }
}
