import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(double latitude, double longitude) async {
  final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

  await canLaunchUrl(googleMapsUrl)
      ? await launchUrl(googleMapsUrl)
      : throw 'Could not launch $googleMapsUrl';
}
