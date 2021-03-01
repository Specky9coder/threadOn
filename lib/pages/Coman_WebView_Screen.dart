import 'package:flutter/material.dart';
// ignore: uri_does_not_exist
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


class WebView_Screen extends StatelessWidget{

  String appbar_name;
  String Link;

  var url = "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_xclick&business=your@email.tld&amount=1.99&currency_code=USD";


  WebView_Screen({Key key, this.appbar_name,this.Link}) : super(key: key);
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  MaterialApp(
      routes: {
        '/': (_) => new WebviewScaffold(
          url: Link,
          appBar: new AppBar(
            elevation: 10.0,
            backgroundColor: Colors.white70,
            title: Text(appbar_name,style: TextStyle(color: Colors.black),),
            leading: GestureDetector(
    child: Icon(Icons.arrow_back,color: Colors.black,),
              onTap: (){
      Navigator.pop(context);
              },
    )
          ),
          withZoom: false,
          withLocalStorage: true,
        )
      },
    );
  }


}
/*

class webview extends StatelessWidget{

  String appBarname;
  String Link;


  webview(this.appBarname, this.Link);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      routes: {
        new WebviewScaffold(
          url: "https:\\FlutterCentral.com",
          appBar: new AppBar(
            title: const Text('Widget Webview'),
          ),
          withZoom: false,
          withLocalStorage: true,
        )
      },
    );
  }

}*/
