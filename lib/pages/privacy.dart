import 'package:flutter/material.dart';


class PrivacyScreen extends StatefulWidget {
  static String tag = 'privacy';

  @override
  _PrivacyScreenState createState() => new _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Privacy Policy"),
        backgroundColor: Colors.white70,
//        automaticallyImplyLeading: false,
//        actions: <Widget>[
//        ],
      ),

//      body: ListView(
//        children: <Widget>[
//          ListTile(
//            title: Text('All'),
//            onTap: () => MyNavigator.goToDepartmentss(context),
//
//          ),
//
//
//
//          ListTile(
//            title: Text('Activewear'),
//
//          ),
//
//
//          ListTile(
//            title: Text('Dresses'),
//          ),
//
//
//          ListTile(
//            title: Text('Jeans'),
//          ),
//
//
//          ListTile(
//            title: Text('Maternity'),
//          ),
//        ],
//      ),

    );
  }
}