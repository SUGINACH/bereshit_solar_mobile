import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// עוטף כל עמוד HTML קיים (Form.html, שלושת קבצי השלבים, PrintQuote.html) בתוך
/// WebView - כדי לא לשכפל את כל הלוגיקה המורכבת (מנוע איחוד המקורות, זיהוי
/// שבת הלכתי, מנוע ההמלצה, המודל הפיננסי) בקוד Dart נפרד. אותו הדף המדויק
/// שכבר עובד ונבדק בדפדפן, נטען כאן כמו שהוא.
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
