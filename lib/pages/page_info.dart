import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class InfoPage extends StatelessWidget {

  final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate())
    ..loadRequest(Uri.parse("https://docs.magicmirror.builders/modules/introduction.html"));

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: WebViewWidget(controller: controller),
    );
  }
}
