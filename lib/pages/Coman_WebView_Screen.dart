import 'dart:async';

import 'package:flutter/material.dart';

// ignore: uri_does_not_exist
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebView_Screen extends StatefulWidget {
//   @override
//   _WebView_ScreenState createState() => _WebView_ScreenState();
// }
//
// class _WebView_ScreenState extends State<WebView_Screen> {
//   Completer<WebViewController> _controller = Completer<WebViewController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }



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



// class WebView_Screen extends StatefulWidget {
//   String appbar_name;
//   String Link;
//
//   WebView_Screen({Key key, this.appbar_name, this.Link}) : super(key: key);
//
//   @override
//   _WebView_ScreenState createState() => _WebView_ScreenState();
// }
//
// class _WebView_ScreenState extends State<WebView_Screen> {
//   Completer<WebViewController> _controller = Completer<WebViewController>();
//   var _url =
//       "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_xclick&business=your@email.tld&amount=1.99&currency_code=USD";
//
//   // final flutterWebviewPlugin = new FlutterWebviewPlugin();
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return MaterialApp(
//       routes: {
//         '/': (_) => new WebView(
//               initialUrl: _url,
//               javascriptMode: JavascriptMode.unrestricted,
//               onWebViewCreated: (WebViewController webViewController) {
//                 _controller.complete(webViewController);
//               },
//               javascriptChannels: <JavascriptChannel>[
//                 _toasterJavascriptChannel(context),
//               ].toSet(),
//               // url: widget.Link,
//               navigationDelegate: (NavigationRequest request) {
//                 if (request.url.startsWith('https://www.sandbox.paypal.com/')) {
//                   print('Blocking Navigation To $request}');
//                   return NavigationDecision.prevent;
//                 }
//                 print('Allowing Navition To $request}');
//                 return NavigationDecision.navigate;
//               },
//               onPageStarted: (String url) {
//                 print('Page Started Loading $url}');
//               },
//               onPageFinished: (String url) {
//                 print('Page Finished Loading $url}');
//               },
//               gestureNavigationEnabled: true,
//               // appBar: new AppBar(
//               //   elevation: 10.0,
//               //   backgroundColor: Colors.white70,
//               //   title: Text(
//               //     widget.appbar_name,
//               //     style: TextStyle(color: Colors.black),
//               //   ),
//               //   leading: GestureDetector(
//               //     child: Icon(
//               //       Icons.arrow_back,
//               //       color: Colors.black,
//               //     ),
//               //     onTap: () {
//               //       Navigator.pop(context);
//               //     },
//               //   ),
//               // ),
//               // withZoom: false,
//               // withLocalStorage: true,
//             ),
//       },
//     );
//   }
//
//   JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//     return JavascriptChannel(
//         name: 'Toaster',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           Scaffold.of(context).showSnackBar(
//             SnackBar(
//               content: Text(message.message),
//             ),
//           );
//         });
//   }
// }
//
// enum MenuOptions {
//   showUserAgent,
//   listCookies,
//   clearCookies,
//   addToCache,
//   listCache,
//   clearCache,
//   navigationDelegate,
// }
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
