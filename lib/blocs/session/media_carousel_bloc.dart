import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class MediaCarouselBloc {
  // void showImageDialog(BuildContext context, String url) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Image.network(url),
  //             TextButton(
  //               onPressed: () => _downloadImage(context, url),
  //               child: Text('Download Image'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

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
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: (await getApplicationDocumentsDirectory()).path,
        fileName: url.split('/').last,
        headers: {"network-type": "ANY"},
      );

      // Introduce a delay between update calls
      await Future.delayed(
          Duration(seconds: 100)); // Adjust delay duration as needed

      print('Download task ID: $taskId');
    } catch (error, stackTrace) {
      print('Error downloading image: $error');
      print('Stack trace: $stackTrace');
    }
  }
}
