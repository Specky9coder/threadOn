import 'package:flutter/material.dart';

class TermsServiceScreen extends StatefulWidget {
  static String tag = 'terms';

  @override
  _TermsServiceScreenState createState() => new _TermsServiceScreenState();
}

class _TermsServiceScreenState extends State<TermsServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Terms of Service"),
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