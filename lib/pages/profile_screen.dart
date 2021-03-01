import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/login_screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  static String tag = 'profile';

  @override
  _ProfileScreenState createState() => new _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SharedPreferences preferences;
  String UserName = '';
  String loginname = '';
  String profilImage;
  bool isLogin = false;
  String Carttotal = "0";
  String user_id = '';
  var facebookLogin = FacebookLogin();
  List<String> d;
  PackageInfo packageInfo;
  String appName;
  String packageName;
  String version;
  String buildNumber;
  @override
  void initState() {
    // TODO: implement initState
    getCredential();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Me"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // leading: GestureDetector(
        //   child: IconButton(
        //     icon : Icon(Icons.arrow_back),
        //     color: Colors.black,
        //     onPressed: (){
        //            Navigator.of(context).pop();
        //     },
        //   ),
        //   onTap: () {
        //     Navigator.of(context).pop();
        //   },
        // ),
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
          new IconButton(
              icon: new Icon(Icons.local_offer),
              tooltip: 'Add Product',
              onPressed: () {
                if (user_id == "") {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupPage()));
                } else {
                  MyNavigator.gotoAddItemScreen(context);
                }
              }),
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
        ],
      ),
      body: Container(
        child: _withoutLogin(),
      ),
    );
  }

/*
  Future<Null> _logOut() async {
    await facebookLogin.logOut();
    _showMessage('Logged out.');
  }*/

  Future<Null> _logOut() async {
    await facebookLogin.logOut();
    //  _showMessage('Logged out.');
    preferences = await SharedPreferences.getInstance();
    setState(() {
      UserName = '';
      preferences.clear();
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(
              builder: (BuildContext context) => new LoginPage()),
          (Route<dynamic> route) => false);
    });
  }

  getCredential() async {
    preferences = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
    user_id = preferences.getString("user_id");
    if (user_id == null) {
      user_id = "";
    }
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    setState(() {
      isLogin = preferences.getBool("check");
      if (isLogin != null) {
        if (isLogin) {
          /* username.text = sharedPreferences.getString("username");
          password.text = sharedPreferences.getString("password");*/
          UserName = preferences.getString('UserName');
          user_id = preferences.getString("user_id");
          loginname = preferences.getString('loginname');
          profilImage = preferences.getString('profile_image');
        } else {
          UserName = '';
          preferences.clear();
        }
      } else {
        isLogin = false;
      }
    });
  }

  Widget _withoutLogin() {
    if (isLogin == false) {
      return new ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: new Row(
              children: <Widget>[
                Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            title: Text('Log In'),
            onTap: () => MyNavigator.goToLogin(context),
          ),

//          ListTile(
//            title: Text('Join'),
//            onTap: () => MyNavigator.goToHome(context),
//          ),
          new Divider(color: Colors.black26),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: new Row(
              children: <Widget>[
                Text(
                  "About",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Money Back Guarantee'),
            onTap: () => MyNavigator.gotoWebViewScreen(context,
                'Money Back Guarantee', "https://threadon.com/gaurantee"),
          ),
          ListTile(
            title: Text('Help & Support'),
            onTap: () => MyNavigator.gotoWebViewScreen(
                context, 'Help & Support', "https://threadon.com/helpsupport"),
          ),
          ListTile(
            title: Text('How it Works'),
            onTap: () => MyNavigator.gotoWebViewScreen(
                context, 'How it Works', "https://threadon.com/howwork"),
          ),
          ListTile(
            title: Text('Returns'),
            onTap: () => MyNavigator.gotoWebViewScreen(
                context, 'Returns', "https://threadon.com/return"),
          ),
          ListTile(
            title: Text('Company'),
            onTap: () => MyNavigator.goToCompany(context, "Company"),
          ),
          new Divider(color: Colors.black26),
          Container(
            padding: EdgeInsets.all(30.0),
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Text(
                //   appName+' for Androd',
                //   style: TextStyle(fontSize: 16.0, color: Colors.black45,fontWeight: FontWeight.w500),
                // ),

                // new Container(
                //   height: 5.0,
                // ),
                Container(
                  child: Text(
                    'Version $version',
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black45,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                new Container(
                  height: 5.0,
                ),
                Text(
                  'Made in New York',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return new ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: new Row(
              children: <Widget>[
                Text(
                  "Activity",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () => MyNavigator.gotoEditProfile(context),
          ),
          ListTile(
            title: Text('Favorites'),
            onTap: () => MyNavigator.gotoFavoriteScreen(context, 'Favorites'),
          ),
          ListTile(
            title: Text('Purchases'),
            onTap: () => MyNavigator.gotoPurchasesScreen(context, 'Purchases'),
          ),
          ListTile(
            title: Text('Order'),
            onTap: () => MyNavigator.gotoOrderScreen(context, 'Order'),
          ),
          ListTile(
            title: Text('Sales'),
            onTap: () => MyNavigator.gotoSalesScreen(context, 'Sales'),
          ),
          ListTile(
            title: Text('Payouts'),
            onTap: () => MyNavigator.gotoPayoutScreen(context, 'Payouts'),
          ),
          ListTile(
            onTap: () => MyNavigator.gotoRefer_Screen(context, 'Refer'),
            title: Text('Earn by referring'),
          ),
          new Divider(color: Colors.black26),

          Container(
            padding: const EdgeInsets.all(16.0),
            child: new Row(
              children: <Widget>[
                Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            title: Text('Billing Info'),
            onTap: () => MyNavigator.gotoPaymentMethodsScreen(
                context, 'Payments Methods', d),
          ),
          ListTile(
            title: Text('Address Book'),
            onTap: () => MyNavigator.gotoAddress(context, 'Address Book'),
          ),

          ListTile(
            title: Text('Log Out'),
            onTap: () => _logOut(),
          ),

//          ListTile(
//            title: Text('Join'),
//            onTap: () => MyNavigator.goToHome(context),
//          ),
          new Divider(color: Colors.black26),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: new Row(
              children: <Widget>[
                Text(
                  "About",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Money Back Guarantee'),
            onTap: () => MyNavigator.gotoWebViewScreen(context,
                'Money Back Guarantee', "https://threadon.com/gaurantee"),
          ),
          ListTile(
            title: Text('Help & Support'),
            onTap: () => MyNavigator.gotoWebViewScreen(
                context, 'Help & Support', "https://threadon.com/helpsupport"),
          ),
          ListTile(
            title: Text('How it Works'),
            onTap: () => MyNavigator.gotoWebViewScreen(
                context, 'How it Works', "https://threadon.com/howwork"),
          ),
          ListTile(
            title: Text('Returns'),
            onTap: () => MyNavigator.gotoWebViewScreen(
                context, 'Returns', "https://threadon.com/return"),
          ),
          ListTile(
            title: Text('Company'),
            onTap: () => MyNavigator.goToCompany(context, "Company"),
          ),
          new Divider(color: Colors.black26),
          Container(
            padding: EdgeInsets.all(30.0),
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Text(
                //   appName+' for Androd',
                //   style: TextStyle(fontSize: 16.0, color: Colors.black45,fontWeight: FontWeight.w500),
                // ),

                // new Container(
                //   height: 5.0,
                // ),
                Container(
                  child: Text(
                    'Version $version',
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black45,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                new Container(
                  height: 5.0,
                ),
                Text(
                  'Made in New York',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
