import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebView extends StatefulWidget {
  final String blogUrl;
  const ArticleWebView({required this.blogUrl});

  @override
  State<ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<ArticleWebView> {
  late final WebViewController _controller;
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.blogUrl));

    _controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (String url) {
        setState(() {
          _isLoading = true; 
        });
      },
      onPageFinished: (String url) {
        setState(() {
          _isLoading =
              false;
        });
      },
      onWebResourceError: (error) {
        setState(() {
          _isLoading = false; 
        });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true, title: Text("Full Article", style: TextStyle(color: Colors.deepPurple[900], fontWeight: FontWeight.bold, fontSize: 26),)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
