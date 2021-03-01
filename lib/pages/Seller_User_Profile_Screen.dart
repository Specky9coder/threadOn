import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Product.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/tab_screen/Followers_Tab.dart';
import 'package:threadon/tab_screen/Following_Tab.dart';
import 'package:threadon/tab_screen/Items_Tab.dart';
import 'package:threadon/tab_screen/Sold_Tab.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:permission/permission.dart';
import 'package:flutter/services.dart';

class Seller_Profile extends StatefulWidget {
  String appbar_name;
  String profile;

  Seller_Profile({Key key, this.appbar_name, this.profile}) : super(key: key);

  @override
  State<StatefulWidget> createState() => seller_profile(appbar_name, profile);
}

class seller_profile extends State<Seller_Profile>
    with SingleTickerProviderStateMixin {
  String tool_name1;
  TabController tabController;

  List<Shell_Product_Model> item_list;
  List<Shell_Product_Model> final_item_list = new List<Shell_Product_Model>();
  List<Shell_Product_Model> Sold_final_item_list =
      new List<Shell_Product_Model>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  bool _isInAsyncCall = false;
  String profileImage;
  String refer_code = '';

  seller_profile(this.tool_name1, this.profileImage);

  SharedPreferences sharedPreferences;
  String Name = "",
      email_id = "",
      profile_image = "",
      facebook_id = "",
      user_id = "",
      about_me = "",
      country = "",
      cover_picture = "",
      password = "",
      username = "@",
      followers = "",
      following = "",
      device_id = "";
  TabController controller;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();

    user_id = sharedPreferences.getString('user_id');

    CollectionReference ref = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
    } else {
      eventsQuery.documents.forEach((doc) async {
        sharedPreferences = await SharedPreferences.getInstance();
        if (this.mounted) {
          setState(() {
            Name = (doc['name']);
            email_id = (doc['email_id']);
            profile_image = (doc['profile_picture']);
            country = (doc['country']);
            about_me = (doc['about_me']);
            password = (doc['password']);
            username = (doc['username']);

            following = (doc['following']);
            followers = (doc['followers']);
            device_id = (doc['device_id']);
            cover_picture = (doc['cover_picture']);
            refer_code = (doc['refer_code']);
          });
        }
      });
    }
    // _isInAsyncCall = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {
    //     _isInAsyncCall = true;
    // });
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getCredential();
    item_list = new List();

    noteSub?.cancel();
    noteSub = db.getProductList().listen((QuerySnapshot snapshot) {
      final List<Shell_Product_Model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shell_Product_Model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (user_id == notes[i].user_id) {
            if (notes[i].status == "0") {
              final_item_list.add(Shell_Product_Model(
                notes[i].any_sign_wear,
                notes[i].category,
                notes[i].category_id,
                notes[i].country,
                notes[i].date,
                notes[i].favourite_count,
                notes[i].is_cart,
                notes[i].is_favorite_count,
                notes[i].item_Ounces,
                notes[i].item_brand,
                notes[i].item_color,
                notes[i].item_description,
                notes[i].item_measurements,
                notes[i].item_picture,
                notes[i].item_pound,
                notes[i].item_price,
                notes[i].item_sale_price,
                notes[i].item_size,
                notes[i].item_sold,
                notes[i].item_sub_title,
                notes[i].item_title,
                notes[i].item_type,
                notes[i].packing_type,
                notes[i].picture,
                notes[i].product_id,
                notes[i].retail_tag,
                notes[i].shipping_charge,
                notes[i].shipping_id,
                notes[i].status,
                notes[i].sub_category,
                notes[i].sub_category_id,
                notes[i].user_id,
                notes[i].tracking_id,
                notes[i].order_id,
                notes[i].brand_new,
              ));
            } else if (notes[i].status == "2") {
              Sold_final_item_list.add(Shell_Product_Model(
                notes[i].any_sign_wear,
                notes[i].category,
                notes[i].category_id,
                notes[i].country,
                notes[i].date,
                notes[i].favourite_count,
                notes[i].is_cart,
                notes[i].is_favorite_count,
                notes[i].item_Ounces,
                notes[i].item_brand,
                notes[i].item_color,
                notes[i].item_description,
                notes[i].item_measurements,
                notes[i].item_picture,
                notes[i].item_pound,
                notes[i].item_price,
                notes[i].item_sale_price,
                notes[i].item_size,
                notes[i].item_sold,
                notes[i].item_sub_title,
                notes[i].item_title,
                notes[i].item_type,
                notes[i].packing_type,
                notes[i].picture,
                notes[i].product_id,
                notes[i].retail_tag,
                notes[i].shipping_charge,
                notes[i].shipping_id,
                notes[i].status,
                notes[i].sub_category,
                notes[i].sub_category_id,
                notes[i].user_id,
                notes[i].tracking_id,
                notes[i].order_id,
                notes[i].brand_new,
              ));
            }
          }
        }
        tabController = new TabController(length: 4, vsync: this);
        this.item_list = final_item_list;
        this.Sold_final_item_list = Sold_final_item_list;
      });
    });
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          wifiName = await _connectivity.getWifiName();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          wifiBSSID = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
        break;
      case ConnectivityResult.none:
        setState(() {
          _showDialog1();
        });
        break;
      default:
        break;
    }
  }

  void _showDialog1() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("No Internet connection"),
          content: new Text(
              "We can\'t reach our network right now. Please check your connection."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new FlatButton(
              child: new Text("Retry"),
              onPressed: () {
                setState(() {
                  initConnectivity();
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
    dispose();
  }

  Widget _getHomeContainer() {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new Container(),
        ),
        _getTextContainer()
      ],
    );
  }

  Widget _getTextContainer() {
    return new Container(
        padding: new EdgeInsets.only(bottom: 24.0, top: 60.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 40.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80.0,
                    width: 80.0,
                    child: CircleAvatar(
                        backgroundImage: NetworkImage(profile_image)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20.0),
                    child: new Text(Name != null ? Name : '',
                        style: new TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        )),
                  )
                ],
              ),
            ),
            Container(
                alignment: Alignment.center,
                child: new Padding(
                    padding: new EdgeInsets.symmetric(vertical: 40.0),
                    child: new RaisedButton(
                        onPressed: () => MyNavigator.gotoSEditProfile(
                            context, "Edit Profile", profile_image),
                        color: Colors.black,
                        padding: new EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 80.0),
                        splashColor: Colors.grey,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        child: new Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                              "Edit Profile",
                              style:
                                  new TextStyle(color: new Color(0xFFFFFFFF)),
                            ),
                          ],
                        ))))
          ],
        ),
        alignment: Alignment.bottomLeft);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double width12 = width;

    return Scaffold(
        body: ModalProgressHUD(
      child: DefaultTabController(
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                      elevation: 0.0,
                      backgroundColor: Colors.white,
                      expandedHeight: 280.0,
                      pinned: true,
                      actions: <Widget>[
                        new IconButton(
                            icon: new Icon(Icons.search),
                            tooltip: 'Search product',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Coman_SearchList()));
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
                              if (user_id == null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupPage()));
                              } else {
                                MyNavigator.gotoAddItemScreen(context);
                              }
                            }),
                        IconButton(
                          icon: new Icon(Icons.chat_bubble_outline),
                          tooltip: 'MessageList',
                          onPressed: () {
                            if (user_id == null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatMessageList()));
                            }
                          },
                        ),
                        new IconButton(
                          icon: new Icon(Icons.perm_identity),
                          tooltip: 'Me',
                          onPressed: () => MyNavigator.goToProfile(context),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        title: Text("",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 1.0,
                            )),
                        background: Stack(
                          fit: StackFit.passthrough,
                          children: <Widget>[
                            new Image.network(cover_picture,
                                fit: BoxFit.cover,
                                alignment: new AlignmentDirectional(0.2, 0.0)),
                            Container(
                              decoration:
                                  new BoxDecoration(color: Colors.white54),
                            ),
                            _getHomeContainer(),
                          ],
                        ),
                      ),
                      bottom: PreferredSize(
                          child: TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black54,
                            isScrollable: true,

                            tabs: [
                              new Tab(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      item_list.length.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17.0),
                                    ),
                                    Text(
                                      'ITEMS',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13.0),
                                    ),
                                  ],
                                ),

                                // set icon to the tab
                              ),
                              new Tab(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      Sold_final_item_list.length.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17.0),
                                    ),
                                    Text(
                                      'SOLD',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13.0),
                                    ),
                                  ],
                                ),

                                // set icon to the tab
                              ),
                              new Tab(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      followers,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17.0),
                                    ),
                                    Text(
                                      'FOLLOWERS',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13.0),
                                    ),
                                  ],
                                ),

                                // set icon to the tab
                              ),
                              new Tab(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      following,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17.0),
                                    ),
                                    Text(
                                      'FOLLOWING',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13.0),
                                    ),
                                  ],
                                ),

                                // set icon to the tab
                              ),
                            ],
                            // setup the controller
                            controller: tabController,
                          ),
                          preferredSize: Size.fromHeight(50.0))),

                  /* SliverPersistentHeader(

                  delegate: _SliverAppBarDelegate(


                  ),
                  pinned: true,
                ),*/
                ];
              },
              body: getTabBarView(<Widget>[
                new Items_Tab(),
                new Sold_Tab(),
                new Followers_Tab(),
                new Following_Tab()
              ])),
          length: 4),
      inAsyncCall: _isInAsyncCall,
      opacity: 0.7,
      color: Colors.white,
      progressIndicator: CircularProgressIndicator(),
    ));
  }

  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: tabController,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
