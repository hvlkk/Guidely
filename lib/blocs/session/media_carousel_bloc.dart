import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class MediaCarouselBloc {
  Future<void> showImageDialog(BuildContext context, String url) async {
    var status = await Permission.storage.request();
    print('Storage permission status: $status');
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      // Handle permission denied or restricted state
      print('Storage permission denied or restricted');
      // Optionally, show a dialog instructing the user how to enable permissions
      return;
    }

    // Permission granted, navigate to the PhotoView screen
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
      if (status.isDenied ||
          status.isPermanentlyDenied ||
          status.isRestricted) {
        // Ask for permission again or show a dialog instructing the user how to enable it in settings
        print('Storage permission denied or restricted');
        return;
      }

      final savedDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generate a unique file name
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification:
            true, // Open file when the notification is tapped
      );

      print('Download task ID: $taskId');
    } catch (error, stackTrace) {
      print('Error downloading image: $error');
      print('Stack trace: $stackTrace');
      // Handle error accordingly, e.g., show a snackbar with an error message
    }
  }
}
