import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';

class DccViewerLauncher {
  /// Builds the Microsoft Office Online Viewer URL for a given file URL.
  /// Uses embed.aspx with cache-busting to match web implementation.
  static String getOfficeViewerUrl(String fileUrl) {
    final encoded = Uri.encodeComponent(fileUrl);
    final cacheBust = DateTime.now().millisecondsSinceEpoch;
    return 'https://view.officeapps.live.com/op/embed.aspx?src=$encoded&t=$cacheBust';
  }

  /// Builds the ShareCAD viewer URL for CAD files (dwg, dxf).
  static String getCadViewerUrl(String fileUrl) {
    final encoded = Uri.encodeComponent(fileUrl);
    return 'https://sharecad.org/cadframe/load?url=$encoded';
  }

  /// Builds the PDF viewer URL for S3 files with toolbar parameter.
  static String getPdfViewerUrl(String fileUrl) {
    return '$fileUrl#toolbar=1';
  }

  /// Launches a URL in a stable in-app view (SafariViewController/Custom Tabs).
  /// This maintains the "In-App" feel while providing better stability than WebView.
  static Future<void> launchInAppViewer(String url) async {
    final uri = Uri.parse(url);
    try {
      log("DCC: Launching stable in-app viewer for $url");
      
      // Attempt to launch using inAppBrowserView (Custom Tabs/SafariVC)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );

      if (!launched) {
        log("DCC: Failed to launch via inAppBrowserView, falling back to external application");
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log("DCC: Error launching URL: $e");
      // Fallback to external application on error
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (innerError) {
        log("DCC: Ultimate fallback failed: $innerError");
      }
    }
  }
}
