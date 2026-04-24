import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      throw Exception('Could not launch $url');
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}