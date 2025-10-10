import 'package:flutter/material.dart';
import 'package:nielsen_flutter_plugin/nielsen_flutter_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OptOutWebView extends StatefulWidget {
  final NielsenFlutterPlugin nielsen;
  final String sdkId;
  final String optOutUrl;

  const OptOutWebView({
    super.key,
    required this.nielsen,
    required this.sdkId,
    required this.optOutUrl,
  });

  @override
  State<OptOutWebView> createState() => _OptOutWebViewState();
}

class _OptOutWebViewState extends State<OptOutWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                final url = request.url;

                if (url == 'nielsen://close') {
                  debugPrint("Intercepted nielsen://close");
                  Navigator.of(context).maybePop();
                  return NavigationDecision.prevent;
                }

                if (url.startsWith('nielsen')) {
                  debugPrint("Intercepted Nielsen callback: $url");
                  widget.nielsen.userOptOut(widget.sdkId, url);
                  Navigator.of(context).maybePop();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.optOutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
