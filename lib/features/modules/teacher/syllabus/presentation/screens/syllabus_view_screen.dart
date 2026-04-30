import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';

import '../../../../../../core/utils/snackbarNotification/snackbar_notification.dart';

class SyllabusViewScreen extends StatelessWidget {
  final String url;
  final String title;

  const SyllabusViewScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    debugPrint("Attempting to load PDF from URL: $url");
    if (url.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text("Error: PDF URL is empty")),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title, 
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        leading: const BackButton(color: AppColors.black),
      ),
      body: SfPdfViewer.network(
        url,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('PDF Load Failed: ${details.error} - ${details.description}');
          String errorMsg = details.description.isNotEmpty ? details.description : details.error;
          if (errorMsg.isEmpty) errorMsg = "Unknown error (check URL)";
          
          SnackbarService().showError('Failed to load PDF: $errorMsg');
        },
      ),
    );
  }
}
