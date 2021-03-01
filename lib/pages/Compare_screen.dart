
import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Cart.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';

class Compare_screen extends StatefulWidget {

 final Shell_Product_Model item;
  const Compare_screen({this.item});

  @override
  State<StatefulWidget> createState() => new compare_screen(item);
// TODO: implement createState

}

class compare_screen extends State<Compare_screen> {

  final Shell_Product_Model item;
  bool _isInAsyncCall = false;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  compare_screen(this.item);
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  List<Cart> cart_list;
  List<Cart> cartList;
  int  cart_count;
  List<Cart> cartList1 = new List<Cart>();

  String Sub_Cat_Name = '', title = '', image = '', size = '', price = '', type = '', color = '', brand = '',productId ="",userId="";
     String title1 = '', image1 = '', size1 = '', price1 = '', type1 = '', color1 = '', brand1 = '';

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    getCredential();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

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
        setState((){
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
          content: new Text("We can\'t reach our network right now. Please check your connection."),
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

  _showSnackBar(String messageString) {

    print(messageString);
    final snackBar = new SnackBar(
      content: new Text(
        messageString,
        style: new TextStyle(fontWeight: FontWeight.normal, fontSize: 15.0),
      ),
//      duration: new Duration(seconds: 20),
      backgroundColor: Colors.black,
      action: new SnackBarAction(
          label: "BAG",
          textColor: Colors.red,
          onPressed: () {
            print("Action from Click SnackBar");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartScreen()));
          }),
    );
    _scaffold.currentState.showSnackBar(snackBar);
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new WillPopScope(
    child: Scaffold(
      key: _scaffold,
        appBar: AppBar(
          title: Text('Compare'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white70,
//          leading: GestureDetector(
//            onTap: () {
//              MyNavigator.goToUserProfile(context);
//            },
//          ),
         /* leading: IconButton(
            icon:Icon(Icons.arrow_back),
//            onPressed:() => MyNavigator.goToDepartmentss(context, ''),),
              onPressed: () async {
                String Cat_name = Sub_Cat_Name;
                await SharedPreferencesHelper.setsub_cat_name(Cat_name);

                if(title1 == ''){

                } else{
                  MyNavigator.goToDepartmentss(context, Cat_name);
                }
//                  onTap: () {
//                    Navigator.push(context,
//                        MaterialPageRoute(builder: (context) => ItemDetails(appbar_name: Cat_name)));

              }),*/
          actions: <Widget>[

            new IconButton(
              icon: new Icon(Icons.close),
              tooltip: 'Action Tool Tip',
              onPressed: ()async {
                SharedPreferences sharedPreferences = await SharedPreferences .getInstance();
                sharedPreferences.setString('Title', '');
                sharedPreferences.setString('Title1', '');
                sharedPreferences.setString('Image', '');
                sharedPreferences.setString('Image1', '');
                sharedPreferences.setString('Size', '');
                sharedPreferences.setString('Size1', '');
                sharedPreferences.setString('Price', '');
                sharedPreferences.setString('Price1', '');
                sharedPreferences.setString('Type', '');
                sharedPreferences.setString('Type1', '');
                sharedPreferences.setString('Color', '');
                sharedPreferences.setString('Color1', '');
                sharedPreferences.setString('Brand', '');
                sharedPreferences.setString('Brand1', '');
                sharedPreferences.setString('flag1', '');
                sharedPreferences.setString('pid', '');

                Navigator.pop(context);
              /*  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new GridItemDetails()),
                          (Route<dynamic> route) => false);*/
              }
            ),
          ],
        ),
        body:ModalProgressHUD(
    child:ListView(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(
                    left: 0.0, top: 30.0, bottom: 0.0),
                alignment: Alignment.center,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Expanded(
                      flex: 2,
                      child: new Container(

                        child: new Text(
                          '',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    new Expanded(
                      flex: 4,
                      child: new Container(

                        child: new Text(
                          item.item_title,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    new Expanded(
                      flex: 4,
                      child: new Container(

                        child: new Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                     top: 20.0, bottom: 0.0),
                alignment: Alignment.centerLeft,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: new Container(
                        margin: const EdgeInsets.only(
                            left: 00.0, top: 0.0, bottom: 0.0),
                        child:Text('')

                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: new Container(
                        padding: new EdgeInsets.only(right: 8.0),
                        margin: const EdgeInsets.only(
                            left: 0.0, top: 0.0, bottom: 0.0),

                        child:
                        FadeInImage.assetNetwork(
                          placeholder: 'images/tonlogo.png',
                          image:item.picture,
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),

                      ),
                    ),

                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 00.0, top: 0.0, bottom: 0.0),
                        //padding: EdgeInsets.only(left: 8.0),
                        padding: new EdgeInsets.only(right: 8.0),
                        child:  FadeInImage.assetNetwork(
                          placeholder: 'images/tonlogo.png',
                          image:image,
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, top: 30.0, bottom: 0.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[

                    Expanded(
                      flex: 2,
                      child: new Container(
                        child: Text('Size:',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left:0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 13.0),
                        child: new Text(
                          item.item_size,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        child: new Text(
                          size,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, top: 30.0, bottom: 0.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: new Container(
                        child: Text('Price:',
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),


                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 13.0),
                        child: new Text(
                          item.item_price,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 13.0),
                        child: new Text(
                          price,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, top: 30.0, bottom: 0.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child : new Container(
                        child: Text('Color:',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),


                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 13.0),
                        child: new Text(
                          item.item_color,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 13.0),
                        child: new Text(
                          color,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, top: 30.0, bottom: 0.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                     child:new Container(
                        child: Text('Brand:',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),


                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 13.0),
                        child: new Text(
                          item.item_brand,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 13.0),
                        child: new Text(
                          brand,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                            color: new Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                    left: 10.0, top: 30.0, bottom: 0.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child:new Container(
                        child: Text('',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),


                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 8.0),
                        child:  new RaisedButton(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 15.0,
                            ),
                            child: new Text('Add to Bag',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 15.0)),
                            textColor: Colors.white,
                            color: Colors.black,
                            onPressed: () async {

                              cartsubmit(item.product_id);
                         /*     if (pressAttention == false) {
                                setState(() => pressAttention = !pressAttention);
                                _showSnackBar();

                                db.updateNote(Shell_Product_Model(
                                  widget.item.Product_id,
                                  widget.item.Any_sign_wear,
                                  widget.item.Retail_tag,
                                  widget.item.Category,
                                  widget.item.Cat_id,
                                  widget.item.Country.toString(),
                                  widget.item.Date.toString(),
                                  widget.item.Is_cart.toString(),
                                  widget.item.Item_brand.toString(),
                                  widget.item.Item_color.toString(),
                                  widget.item.Item_description.toString(),
                                  widget.item.Item_price.toString(),
                                  widget.item.Item_sale_price.toString(),
                                  widget.item.Item_size.toString(),
                                  widget.item.Item_sold.toString(),
                                  widget.item.Item_title.toString(),
                                  widget.item.Picture.toString(),
                                  widget.item.Status.toString(),
                                  widget.item.Sub_category.toString(),
                                  widget.item.Sub_category_id.toString(),
                                  widget.item.Shipping_id.toString(),
                                  widget.item.User_id.toString(),
                                  widget.item.item_picture,));

                                cartsubmit();
                              } else {}*/
                            }),
                      ),
                    ),

                    new Expanded(
                      flex: 4,
                      child: new Container(
                        margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
                        padding: new EdgeInsets.only(right: 8.0),
                        child:  new RaisedButton(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 15.0,
                            ),
                            child: new Text('Add to Bag',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 15.0)),
                            textColor: Colors.white,
                            color: Colors.black,
                            onPressed: () async {
                              cartsubmit(productId);
                              /*     if (pressAttention == false) {
                                setState(() => pressAttention = !pressAttention);
                                _showSnackBar();

                                db.updateNote(Shell_Product_Model(
                                  widget.item.Product_id,
                                  widget.item.Any_sign_wear,
                                  widget.item.Retail_tag,
                                  widget.item.Category,
                                  widget.item.Cat_id,
                                  widget.item.Country.toString(),
                                  widget.item.Date.toString(),
                                  widget.item.Is_cart.toString(),
                                  widget.item.Item_brand.toString(),
                                  widget.item.Item_color.toString(),
                                  widget.item.Item_description.toString(),
                                  widget.item.Item_price.toString(),
                                  widget.item.Item_sale_price.toString(),
                                  widget.item.Item_size.toString(),
                                  widget.item.Item_sold.toString(),
                                  widget.item.Item_title.toString(),
                                  widget.item.Picture.toString(),
                                  widget.item.Status.toString(),
                                  widget.item.Sub_category.toString(),
                                  widget.item.Sub_category_id.toString(),
                                  widget.item.Shipping_id.toString(),
                                  widget.item.User_id.toString(),
                                  widget.item.item_picture,));

                                cartsubmit();
                              } else {}*/
                            }),
                      ),
                    ),

                  ],
                ),
              ),

//              Container(
//                margin: const EdgeInsets.only(
//                    left: 10.0, top: 30.0, bottom: 0.0),
//                child: new Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      child: Text('Color:     ',
//                        style: new TextStyle(
//                          color: Colors.black,
//                          fontSize: 18.0,
//                          fontWeight: FontWeight.normal,
//                          letterSpacing: 0.3,
//                        ),
//                      ),
//                    ),
//
//                    Container(
//                      margin: const EdgeInsets.only(
//                          left: 100.0, top: 0.0, bottom: 0.0),
//                      child: Text(color,
//                        style: new TextStyle(
//                          color: Colors.black,
//                          fontSize: 18.0,
//                          fontWeight: FontWeight.bold,
//                          letterSpacing: 0.3,
//                        ),
//                      ),
//                    ),
//                    Container(
//                      margin: const EdgeInsets.only(
//                          left: 100.0, top: 0.0, bottom: 0.0),
//                      child: Text(color1,
//                        style: new TextStyle(
//                          color: Colors.black,
//                          fontSize: 18.0,
//                          fontWeight: FontWeight.bold,
//                          letterSpacing: 0.3,
//                        ),
//                      ),
//                    ),
//
//                  ],
//                ),
//              ),

//              Container(
//                margin: const EdgeInsets.only(
//                    left: 10.0, top: 30.0, bottom: 0.0),
//                child: new Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      child: Text('Brand:     ',
//                        style: new TextStyle(
//                          color: Colors.black,
//                          fontSize: 18.0,
//                          fontWeight: FontWeight.normal,
//                          letterSpacing: 0.3,
//                        ),
//                      ),
//                    ),
//
//                    Container(
//                      margin: const EdgeInsets.only(
//                          left: 100.0, top: 0.0, bottom: 0.0),
//                      child: Text(brand,
//                        style: new TextStyle(
//                          color: Colors.black,
//                          fontSize: 18.0,
//                          fontWeight: FontWeight.bold,
//                          letterSpacing: 0.3,
//                        ),
//                      ),
//                    ),
//                    Container(
//                      margin: const EdgeInsets.only(
//                          left: 100.0, top: 0.0, bottom: 0.0),
//                      child: Text(brand1,
//                        style: new TextStyle(
//                          color: Colors.black,
//                          fontSize: 18.0,
//                          fontWeight: FontWeight.bold,
//                          letterSpacing: 0.3,
//                        ),
//                      ),
//                    ),
//
//                  ],
//                ),
//              ),

            ],
        ),
    inAsyncCall: _isInAsyncCall,
    opacity: 0.7,
    color: Colors.white,
    progressIndicator: CircularProgressIndicator(),
        )
    ),
     onWillPop: () async {

       SharedPreferences sharedPreferences = await SharedPreferences .getInstance();
       sharedPreferences.setString('Title', '');
       sharedPreferences.setString('Title1', '');
       sharedPreferences.setString('Image', '');
       sharedPreferences.setString('Image1', '');
       sharedPreferences.setString('Size', '');
       sharedPreferences.setString('Size1', '');
       sharedPreferences.setString('Price', '');
       sharedPreferences.setString('Price1', '');
       sharedPreferences.setString('Type', '');
       sharedPreferences.setString('Type1', '');
       sharedPreferences.setString('Color', '');
       sharedPreferences.setString('Color1', '');
       sharedPreferences.setString('Brand', '');
       sharedPreferences.setString('Brand1', '');
       sharedPreferences.setString('flag1', '');
       sharedPreferences.setString('pid', '');

       /*Navigator.of(context).pushAndRemoveUntil(
           new MaterialPageRoute(
               builder: (BuildContext context) => new GridItemDetails()),
               (Route<dynamic> route) => false);
*/
       Navigator.pop(context);
     },
    );
  }

  void geetcart() {
    cart_count =0;
    print('Child added1: ${cartList.length}');
    noteSub = db.getCartList().listen((QuerySnapshot snapshot) {
      final List<Cart> notes = snapshot.documents
          .map((documentSnapshot) => Cart.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        for (int i = 0; i < notes.length; i++) {
          if (userId == notes[i].user_id) {
            cartList1.add(Cart(notes[i].cart_id, notes[i].product_id,
                notes[i].status, notes[i].user_id, notes[i].date));
          }
        }
      });
    });
    this.cartList = cartList1;
    cart_count = cartList.length + 1;
    print('Child added2: ${cartList.length}');
  }


  void cartsubmit(String productid) async {
    SharedPreferences sharedPreferences = await SharedPreferences .getInstance();
    setState(() {
      _isInAsyncCall = true;
    });

    CollectionReference ref = Firestore.instance.collection('cart');
    QuerySnapshot eventsQuery = await ref
        .where("product_id", isEqualTo: productid)
        .getDocuments();

    if(eventsQuery.documents.isEmpty){
      DateTime date = DateTime.now();
      String datea = date.toString();
      noteSub?.cancel();
      db.cartItem('', productid, '0', userId, DateTime.now()).then((_) {
        geetcart();
      });
      sharedPreferences.setString('pid', '');
      _showSnackBar('Item Added to Bag');
    }
    else{
      /*DateTime date = DateTime.now();
      String datea = date.toString();
      db.updateCart(Cart('', productid, '0', userId, datea));*/
      _showSnackBar('Product is already Added.');
    }


        setState(() {
          _isInAsyncCall = false;
        });



     }

  getCredential() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Sub_Cat_Name = await SharedPreferencesHelper.getsub_cat_name();
    setState(() {

      title = sharedPreferences.getString("Title");
      image = sharedPreferences.getString("Image");
      size = sharedPreferences.getString("Size");
      price = sharedPreferences.getString("Price");
      type = sharedPreferences.getString("Type");
      color = sharedPreferences.getString("Color");
      brand = sharedPreferences.getString("Brand");
      productId = sharedPreferences.getString('pid');
      userId =sharedPreferences.getString("user_id");
      sharedPreferences.setString('flag1', '');

    /*  title1 = sharedPreferences.getString("Title1");
      image1 = sharedPreferences.getString("Image1");
      size1 = sharedPreferences.getString("Size1");
      price1 = sharedPreferences.getString("Price1");
      type1 = sharedPreferences.getString("Type1");
      color1 = sharedPreferences.getString("Color1");
      brand1 = sharedPreferences.getString("Brand1");*/

    });
  }

}
