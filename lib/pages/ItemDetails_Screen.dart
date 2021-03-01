
import 'dart:async';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Login.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';


class ItemDetails extends StatefulWidget {
  String Product_Id;



  ItemDetails(this.Product_Id);

  @override
  State<StatefulWidget> createState() => itemdetails(Product_Id);
}

class itemdetails extends State<ItemDetails> {
  String tool_name1 = '';
  bool _isButtonDisabled = true;


  itemdetails(this.Product_Id);


  String _length,
      __width,
      Item_shipping_id = "",
      Item_titile = "",
      Item_retailPrice = "",
      Item_sellingPrice = "",
      Item_description = "",
      Item_color = "",
  sheller_name = '';

  String Cat_Name = "",
      Cat_Id = "",
      Sub_Cat_Name = "",
      Sub_Cat_Id = "",
      User_id = "",
      User_country = "",
      Item_Size = "";
  String managphoto = "";
  int cameraFlag = 0;
  String Item_brand_name = "", Retail_Tag = "", Signs_Wear = "";
  String Product_Id = '', user_id = '';

  List<Shell_Product_Model> productdata = new List<Shell_Product_Model>();
  List<Shell_Product_Model> productdata1  = new List<Shell_Product_Model>();
  List<Login_Modle> userData  = new List<Login_Modle>();
  List<Login_Modle> userData1  = new List<Login_Modle>();

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  bool _isInAsyncCall = true;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;



  _loadCounter() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Item_brand_name = await SharedPreferencesHelper.getLanguageCode();
    Cat_Name = await SharedPreferencesHelper.getcat_name();
    Cat_Id = await SharedPreferencesHelper.getcat_id();
    Sub_Cat_Name = await SharedPreferencesHelper.getsub_cat_name();
    Sub_Cat_Id = await SharedPreferencesHelper.getsubcat_id();
    User_id = await sharedPreferences.getString('user_id');
    User_country = await sharedPreferences.getString('country');
    cameraFlag = await sharedPreferences.getInt('cameraflag');

   Product_Id = sharedPreferences.getString('product_id');

    user_id = sharedPreferences.getString("user_id");

    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery =
        await ref.where("product_id", isEqualTo: Product_Id)
           .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      /* DateTime date = DateTime.now();
        String datea = date.toString();
        noteSub?.cancel();
        db.cartItem('', productid, '0', userId, datea).then((_) {
          geetcart();
        });
        sharedPreferences.setString('pid', '');*/
      /* setState(() {
        _isInAsyncCall = false;
        return favourite = false;
      });*/

      _isInAsyncCall = false;
    } else {
      eventsQuery.documents.forEach((doc) async {
        productdata = new List();
        productdata.add(Shell_Product_Model(
            doc['Any_sign_wear'],
            doc['category'],
            doc['category_id'],
            doc['country'],
            doc['date'].toDate(),
            doc['favourite_count'],
            doc['is_cart'],
            doc['is_favorite_count'],
            doc['item_Ounces'],
            doc['item_brand'],
            doc['item_color'],
            doc['item_description'],
            doc['item_measurements'],
            doc['item_picture'],
            doc['item_pound'],
            doc['item_price'],
            doc['item_sale_price'],
            doc['item_size'],
            doc['item_sold'],
            doc['item_sub_title'],
            doc['item_title'],
            doc['item_type'],
            doc['packing_type'],

            doc['picture'],
            doc['product_id'],
            doc['retail_tag'],
            doc['shipping_charge'],
            doc['shipping_id'],
            doc['status'],

            doc['sub_category'],
            doc['sub_category_id'],
            doc['user_id'],
            doc['tracking_id'],
            doc['order_id'],
            doc['like_new']));

        // setState(() {
          productdata1 = new List();
          this.productdata1 = productdata;
        
        // });
      });
    }

    CollectionReference ref1 = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery1 =
        await ref1.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery1.documents.isEmpty) {
      /* DateTime date = DateTime.now();
        String datea = date.toString();
        noteSub?.cancel();
        db.cartItem('', productid, '0', userId, datea).then((_) {
          geetcart();
        });
        sharedPreferences.setString('pid', '');*/
      /* setState(() {
        _isInAsyncCall = false;
        return favourite = false;
      });*/
      _isInAsyncCall = false;
    } else {
      eventsQuery1.documents.forEach((doc) async {
        userData = new List();
        userData.add(Login_Modle(
          doc['user_id '],
          doc['username'],
          doc['password'],
          doc['name'],
          doc['status'],
          doc['profile_picture'],
          doc['latlong'],
          doc['following'],
          doc['followers'],
          doc['facebook_id'],
          doc['email_id'],
          doc['device_id'],
          doc['device'],
          doc['cover_picture'],
          doc['country'],
          doc['about_me'],
          doc['refer_code'],
          doc['token_id']
        ));

        setState(() {
          userData1 = new List();
          this.userData1 = userData;
         _isInAsyncCall = false;          
        });
      });
    }

   
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();  
   
          _loadCounter(); 

   
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
    // if (!mounted) {
    //   return;
    // }

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



  Widget build(BuildContext context) {    
     // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Container(
          // child: productdata[0].item_title != '' && productdata1[0].item_title != null ?
          // new Text(productdata1[0].item_title):new Text('')
             child: productdata1.isEmpty ? new Text('') : new Text(productdata1[0].item_title)          
        ),
        backgroundColor: Colors.white70,

      //  automaticallyImplyLeading: false,
      ),
      body:
       ModalProgressHUD(
        child: productdata1.isEmpty ? Center(child:Text("No product found")) : 
        ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0),
              color: Colors.white,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        height: 350.0,
                        child: productdata1[0].item_picture.length != 0
                            ?
                        new CarouselSlider(
                            items: productdata1[0].item_picture.map((i) {
                              return new Builder(
                                builder: (BuildContext context) {
                                  return new Container(
                                    width:
                                    MediaQuery.of(context).size.width,
                                    margin: new EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    /*decoration: new BoxDecoration(
                                        image: NetworkImage('$i')
                                    ),*/

                                    /* child: CachedNetworkImage(
                                    imageUrl: ('$i'),
                                    placeholder: new CircularProgressIndicator(),
                                    errorWidget: new Icon(Icons.error),
                                  ),*/
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'images/tonlogo.png',
                                      image: ('$i'),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            height: 350.0,
                            autoPlay: true): new CarouselSlider(
                            items: [
                              'images/tonlogo.png',
                              'images/tonlogo.png',
                              'images/tonlogo.png'
                            ].map((i) {
                              return new Builder(
                                builder: (BuildContext context) {
                                  return new Container(
                                    width:
                                    MediaQuery.of(context).size.width,
                                    margin: new EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    /*decoration: new BoxDecoration(
                                        image: NetworkImage('$i')
                                    ),*/

                                    /* child: CachedNetworkImage(
                                    imageUrl: ('$i'),
                                    placeholder: new CircularProgressIndicator(),
                                    errorWidget: new Icon(Icons.error),
                                  ),*/
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'images/tonlogo.png',
                                      image: ('$i'),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            height: 350.0,
                            autoPlay: true)
                            ),
                  ]),
            ),
//          GetTags(),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
              child:productdata1[0].item_title !="" && productdata1[0].item_title != null? Text(
                productdata1[0].item_title,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ):Text(
               "----",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
//          Container(
//            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
//            child: Text(
//              'not',
//              style: TextStyle(
//                fontSize: 13.0,
//                color: Colors.black,
//              ),
//            ),
//          ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: productdata1[0].item_size !="" && productdata1[0].item_size != null? new Row(
                children: <Widget>[
                  Text(
                    "Size :    ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                    ),
                  ),
                  Text(
                    productdata1[0].item_size,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ):new Row(
                children: <Widget>[
                  Text(
                    "Size : ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                    ),
                  ),
                  Text(
                    "----",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),

              alignment: Alignment.topLeft,
              child:  productdata1[0].item_sale_price != "" && productdata1[0].item_sale_price != null?   new RichText(
                textAlign: TextAlign.left,
                text: new TextSpan(

                  text: 'Sale Price: ',

                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                      text:  '\$' + productdata1[0].item_sale_price,
                      style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,

                      ),
                    ),

                  ],
                ),
              ): new RichText(
                textAlign: TextAlign.left,
                text: new TextSpan(

                  text: 'Sale Price: ',

                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                      text:  "----",
                      style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,

                      ),
                    ),

                  ],
                ),
              ),


            ),

            Container(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),

                alignment: Alignment.topLeft,
                child:productdata1[0].item_price != "" && productdata1[0].item_price != null? new Column(

                    children: <Widget>[


                      new RichText(
                        textAlign: TextAlign.left,
                        text: new TextSpan(
                          text: 'Product Price: ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black26,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                              text:  '\$' + productdata1[0].item_price,
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black26,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough

                              ),
                            ),

                          ],
                        ),
                      ),
                    ]
                ):new Column(

                    children: <Widget>[


                      new RichText(
                        textAlign: TextAlign.left,
                        text: new TextSpan(
                          text: 'Product Price: ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black26,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                              text:  "---",
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black26,
                                  fontWeight: FontWeight.bold,


                              ),
                            ),

                          ],
                        ),
                      ),
                    ]
                ) ),



            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: productdata1[0].shipping_charge =="" || productdata1[0].shipping_charge == null ? Text(
                "Shipping charge  " +"---",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black45,
                ),
              ):Text(
                "Shipping charge  " + "\$"+productdata1[0].shipping_charge,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black45,
                ),
              ),
            ),

            new Divider(color: Colors.black26),

            new GestureDetector(
              onTap: () {
                MyNavigator.gotoEditProfile(context);
              },
              child: new Row(
                children: <Widget>[
                  new Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, right: 0.0, top: 0.0, bottom: 0.0),
                      width: 60.0,
                      height: 60.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                  userData1[0].Profile_picture)))),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, right: 0.0, top: 0.0, bottom: 0.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Listed by: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.0,
                          ),
                        ),
                        Text(
                          userData1[0].Name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            new Divider(color: Colors.black26),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Text(
                "Item Description",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child:productdata1[0].item_description != "" && productdata1[0].item_description != null? Text(
                productdata1[0].item_description,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                ),
              ):Text(
                "----",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                ),
              ),
            ),

            new Divider(color: Colors.black26),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Text(
                "Item Details",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),



            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Type",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Text(
                      '' + 'not',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Size",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: productdata1[0].item_size != "" && productdata1[0].item_size != null?Text(
                      productdata1[0].item_size,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ):Text(
                      "----",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Color",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: productdata1[0].item_color != "" && productdata1[0].item_color != null? Text(
                      productdata1[0].item_color,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ):Text(
                      "----",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Brand",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child:productdata1[0].item_brand != "" && productdata1[0].item_brand != null? Text(
                      productdata1[0].item_brand,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ): Text(
                      "----",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            new Divider(color: Colors.black26),

            new Divider(color: Colors.black26),
/*

            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
//            margin: const EdgeInsets.only(left: 20.0, right: 0.0, top: 0.0, bottom: 0.0),
              child: new GestureDetector(
                onTap: () {
                  MyNavigator.gotoEditProfile(context);
                },
                child: new Row(
                  children: <Widget>[
                    new Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 0.0, top: 0.0, bottom: 0.0),
                        width: 75.0,
                        height: 75.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new NetworkImage(
                                    userData1[0].Profile_picture)))),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 0.0, top: 0.0, bottom: 0.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Listed by: ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            userData1[0].Name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              //  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),

              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        item_list.length.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ITEMS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  _verticalD(),
                  Column(
                    children: <Widget>[
                      Text(
                        "11",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "FAVORITES",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  _verticalD(),
                  Column(
                    children: <Widget>[
                      Text(
                        userData1[0].Followers != ""
                            ? userData1[0].Followers
                            : '0',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "FOLLOWERS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  _verticalD(),
                  Column(
                    children: <Widget>[
                      Text(
                        userData1[0].Following != ""
                            ? userData1[0].Following
                            : '0',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "FOLLOWING",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            new Divider(color: Colors.black26),

            new Divider(color: Colors.black26),

            Container(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "More from "+sheller_name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        MyNavigator.gotoEditProfile(context);
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    )
                  ],
                )),
*/

            /*   Container(
              width: 600,
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, position) {
                  return GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                        alignment: Alignment.centerRight,
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 120.0, right: 30.0, top: 0.0),
                                      alignment: Alignment.centerRight,
                                      child: ListTile(
                                        leading: Icon(Icons.favorite_border),
                                      ),
                                    ),
//                onTap:() => _openAddUserDialog ,
                                    onTap: () {
                                      _openAddUserDialog();
                                    },
                                  ),
                                  AspectRatio(
                                    aspectRatio: 18.0 / 12.0,
                                    child: Image.network(
                                      productList1[position].Picture,
                                    ),
                                  ),
                                  new Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 10.0, 4.0, 0.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            productList1[position].Item_title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        new Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            productList1[position].Category,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 0.0),
//                  GetRatings(),
                                        SizedBox(height: 2.0),

                                        new Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            productList1[position].Item_price,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 0.0),
//                  GetRatings(),
                                        SizedBox(height: 2.0),

                                        new Container(
                                            child: Text(
                                              productList1[position].Item_size,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Divider(color: Colors.black26),
                          ],
                        ),
                        // photo and title
                      ),
                      onTap: () async {

                      });
                },
              ),
            ),*/

//            GetTrailers(this.productList),
          ],
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  _verticalD() => Container(
        margin: EdgeInsets.only(left: 30.0, right: 0.0, top: 0.0, bottom: 0.0),
      );

  Widget _getImageFromFile(List<String> imagePath) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          String first = imagePath[index].toString();

          if (first == "") {
            return Container(
              margin: EdgeInsets.all(5.0),
              child: SizedBox(
                height: 350.0,
                child: new Carousel(
                  images: [
                    new AssetImage(
                      imagePath[index],
                      // package: destination.assetPackage,
                    ),
                  ],
                  boxFit: BoxFit.none,
                  dotBgColor: Colors.white,
                  dotColor: Colors.redAccent,
                  dotSize: 5.0,
                  dotIncreaseSize: 2.0,
                  dotSpacing: 20.0,
                  autoplay: false,
                ),
              ),
            );
          }
        });
    /*
  */
  }
}

class ImageList extends StatelessWidget {
  final List<String> photos;

  ImageList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {}
}
