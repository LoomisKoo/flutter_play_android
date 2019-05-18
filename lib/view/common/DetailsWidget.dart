import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class DetailsWidget extends StatefulWidget {
  String url;
  String title;

  DetailsWidget(this.url, this.title);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DetailsState(url, title);
  }
}

class DetailsState extends State<DetailsWidget> {
  String url;
  String title;

  bool isLoad = true;

  final webViewPlugin = FlutterWebviewPlugin();

  DetailsState(this.url, this.title);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  WebviewScaffold(
      url: url,
      appBar:  AppBar(title: Text(title)),
      withZoom: false,
      withLocalStorage: true,
      withJavascript: true,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webViewPlugin.onStateChanged.listen((state) {
      if (state.type == WebViewState.finishLoad) {
        //加载完成
        setState(() {
          isLoad = false;
        });
      } else if (state.type == WebViewState.startLoad) {
        setState(() {
          isLoad = false;
        });
      }
    });
  }
}
