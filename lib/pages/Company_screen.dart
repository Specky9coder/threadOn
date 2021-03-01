import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/my_navigator.dart';

class CompanyScreen extends StatefulWidget {
  static String tag = 'profile';
  String tool_name;
  String user_id = '';

  CompanyScreen({Key key, this.tool_name}) : super(key: key);

  @override
  _CompanyScreenState createState() => new _CompanyScreenState(tool_name);
}

class _CompanyScreenState extends State<CompanyScreen> {
  String toolname;
  String Carttotal = '';
  String user_id = '';

  @override
  void initState() {
    super.initState();

    getCredential();
  }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = sharedPreferences.getString("user_id");
      if (user_id == null) {
        user_id = "";
      }
    });

    //  getData();
  }

  _CompanyScreenState(this.toolname);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Me"),
        backgroundColor: Colors.white70,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.search),
              tooltip: 'Search product',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Coman_SearchList()));
              }
              /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductExampleHome()));
              },*/
              ),
          new Stack(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (user_id == "") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartScreen()));
                      }
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection("cart")
                        .where("user_id", isEqualTo: user_id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      Carttotal = snapshot.data.documents.length.toString();

                      if (Carttotal == "0") {
                        return Container();
                      } else {
                        return Container(
                          height: 30,
                          width: 60,
                          padding: EdgeInsets.only(right: 10),
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(2),
                            child: Text(
                              Carttotal,
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        );
                      }
                    },
                  )
                ],
              )
            ],
          ),
          IconButton(
            icon: new Icon(Icons.chat_bubble_outline),
            tooltip: 'MessageList',
            onPressed: () {
              if (user_id == "") {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupPage()));
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatMessageList()));
              }
            },
          ),
        ],
      ),
      body: ListView(children: <Widget>[
        ListTile(
          title: Text('About Thread On'),
          onTap: () => MyNavigator.gotoWebViewScreen(
              context, 'About Us', "threadon.com/aboutUs"),
          // onTap: () => MyNavigator.gotoWebViewScreen(
          //     context, 'About Us', "http://www.stealmylogin.com/"),
        ),
        ListTile(
          title: Text('Terms and Condition'),
          onTap: () => MyNavigator.gotoWebViewScreen(
              context, 'Terms of Service', "threadon.com/terms"),
          // onTap: () => MyNavigator.gotoWebViewScreen(
          //     context, 'Terms of Service', "https://www.taboola.com/demo"),
        ),
        ListTile(
          title: Text('Privacy Policy'),
          onTap: () => MyNavigator.gotoWebViewScreen(
              context, 'Privacy Policy', "threadon.com/policy"),
          // onTap: () => MyNavigator.gotoWebViewScreen(
          //     context, 'Privacy Policy', "https://www.taboola.com/demo"),
        ),
      ]),
    );
  }
}
