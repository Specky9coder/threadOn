import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:custom_multi_image_picker/asset.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

// ignore: uri_does_not_exist
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Brand.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/model/Shipping.dart';
import 'package:threadon/pages/Add_Address_screen.dart';
import 'package:threadon/pages/Add_Item_Screen_ManagePhoto.dart';
import 'package:threadon/pages/Drafts_Screen.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/GridItemDetails1.dart';
import 'package:threadon/pages/ItemDetails_Screen.dart';
import 'package:threadon/pages/SearchList_Screen.dart';
import 'package:threadon/pages/Seller_User_Profile_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Edit_Drafts_Listing_details extends StatefulWidget {
  String appbar_name;
  List<Asset> ListOfGalleryimage;
  List<String> ListOfCameraImage;

  List<Shipping_model> shipping_list;
  String Dname;
  String Size;
  String Item_brand_name;

  // ignore: non_constant_identifier_names
  Edit_Drafts_Listing_details(
      {Key key,
      this.appbar_name,
      this.ListOfCameraImage,
      this.ListOfGalleryimage,
      this.Dname,
      this.Size,
      this.Item_brand_name,
      this.shipping_list})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => edit_draft_screen(
        appbar_name,
      );
}

class edit_draft_screen extends State<Edit_Drafts_Listing_details> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String name_type;
  String Dname;
  var db1 = Firestore.instance;
  String Size;
  List<Asset> ListOfGalleryimage;
  String PubishFlag = "0";
  List<String> ListOfCameraImage;
  List<Shipping_model> shipping_list;
  List<String> UplodImageList = new List();
  List<String> UplodImageListNames = new List();
  List<Asset> ListOfGalleryimage1 = new List<Asset>();
  List<String> ListOfCameraImage1 = new List<String>();
  String Item_brand_name = "", Retail_Tag = "", Signs_Wear = "";
  int view_flag;
  String Item_shipping_id = '';

  int Flag = 0;

  edit_draft_screen(this.name_type);

  int ship_value = 0;
  List<DemoItem<dynamic>> _demoItems;
  bool tag_press_yes = false;
  bool tag_press_no = false;

  bool signs_press_yes = false;
  bool signs_press_no = false;
  String signs_press_text = '';
  String tag_press_Text = '';

  bool anySingpress = false;

  bool _isInAsyncCall = false;
  String Item_result = "";
  //

  int Item_pound = 0, Item_Ounces = 0;
  String shipping_charge = "0";
  List<String> packing_type = new List();
  String Status = '';
  TextEditingController shippingcost = new TextEditingController();
  TextEditingController Item_Size = new TextEditingController();
  TextEditingController Item_titile = new TextEditingController();
  TextEditingController Item_retailPrice = new TextEditingController();
  TextEditingController Item_sellingPrice = new TextEditingController();
  TextEditingController Item_description = new TextEditingController();
  TextEditingController Item_color = new TextEditingController();
  List<Shell_Product_Model> productList = new List();
  //
  List reversedAnimals;

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  TextEditingController lenght,
      title,
      retailprice,
      sellingprice,
      itemdescription,
      itemcolor;

  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  final formKey4 = GlobalKey<FormState>();
  final formKey5 = GlobalKey<FormState>();
  final formKey6 = GlobalKey<FormState>();
  final formKey7 = GlobalKey<FormState>();
  int _radioValue = 0;
  var _loadImage = 'images/place_h.png';

  Color mycoloryes = Colors.black;
  Color mycolorni = Colors.black;
  FirebaseStorage _storage;

  String Cat_Name = "",
      Cat_Id = "",
      Sub_Cat_Name = "",
      Sub_Cat_Id = "",
      User_id = "",
      User_country = "";
  // Item_Size = "";
  String managphoto = "";
  int cameraFlag = 0;
  String Product_Id = "";
  SharedPreferences sharedPreferences;
  List<Shell_Product_Model> productlist;
  List<Shell_Product_Model> productlist1;
  List<BrandModel> item_list;
  TextEditingController controller = new TextEditingController();
  List<BrandModel> item_list2;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    _isInAsyncCall = true;
    sharedPreferences = await SharedPreferences.getInstance();

    User_id = await sharedPreferences.getString('user_id');
    Product_Id = await sharedPreferences.getString('product_id_user');
    view_flag = await sharedPreferences.getInt('view_flag');

    shipping_list = new List();

    noteSub = db.getShippingList().listen((QuerySnapshot snapshot) {
      final List<Shipping_model> shippist = snapshot.documents
          .map((documentSnapshot) =>
              Shipping_model.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        _isInAsyncCall = true;
        this.shipping_list = shippist;
      });
    });

    getData();
  }

  Future getData() async {
    productlist = new List();
    productlist1 = new List();
    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: User_id)
        .where('product_id', isEqualTo: Product_Id)
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        productlist.add(Shell_Product_Model(
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
        setState(() {
          this.productlist1 = productlist;
          Item_brand_name = productlist1[0].item_brand;

          lenght = TextEditingController(text: productlist1[0].item_size);
          title = TextEditingController(text: productlist1[0].item_title);
          retailprice = TextEditingController(text: productlist1[0].item_price);
          sellingprice =
              TextEditingController(text: productlist1[0].item_sale_price);
          itemdescription =
              TextEditingController(text: productlist1[0].item_description);
          itemcolor = TextEditingController(text: productlist1[0].item_color);

          if (doc['any_sign_wear'] == "yes") {
            signs_press_yes = true;
          } else if (doc['any_sign_wear'] == "no") {
            signs_press_no = true;
          }

          if (doc['retail_tag'] == "yes") {
            tag_press_yes = true;
          } else if (doc['retail_tag'] == "no") {
            tag_press_no = true;
          }

          for (int i = 0; i < shipping_list.length; i++) {
            if (doc['shipping_id'] == shipping_list[i].Id) {
              _radioValue = i;
            }
          }

          _isInAsyncCall = false;
        });
      });
    }
  }

  Widget _getImageFromFile(List imagePath) {
    reversedAnimals = imagePath.reversed.toList();

    return Container(
      child: new GridView.builder(
          itemCount: imagePath.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            String value = reversedAnimals[index].toString();
            return Container(
                margin: EdgeInsets.all(5.0),
                child: FadeInImage.assetNetwork(
                    placeholder: 'images/place_h.png',
                    image: value,
                    height: 60.0,
                    width: 50.0,
                    fit: BoxFit
                        .scaleDown) /*Image.asset(
                    _loadImage,
                    //fit: BoxFit.fill,
                    fit: BoxFit.cover,
                    width: 50.0,
                    height: 60.0,
                    //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
                    //colorBlendMode: BlendMode.srcOver,
                    //color: Color.fromARGB(120, 20, 10, 40),
                  ),*/
                );
          }),
    );
  }

  Widget shippingListdata() {
    return Container(
      child: ListView.builder(
          itemCount: shipping_list.length,
          itemBuilder: (context, position) {
            return GestureDetector(
              child: Container(
                height: 100.0,
                alignment: Alignment.centerRight,
                color: Colors.white,

                child: new Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: new Radio<int>(
                        value: position,
                        groupValue: _radioValue,
                        onChanged: (int value) {
                          setState(() {
                            _radioValue = value;
                            Item_shipping_id = '${shipping_list[position].Id}';
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: new Text(
                                    '${shipping_list[position].Method}',
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black)),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5.0),
                              ),
                              new Text(
                                '${shipping_list[position].Other_info}',
                                maxLines: 4,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87),
                              ),
                            ],
                          )),
                    )
                  ],
                ),
                // photo and title
              ),
            );
          }),
    );
  }

  onSearchTextChanged(String text) async {
    item_list2.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    item_list.forEach((userDetail) {
      if (userDetail.Brand_name.toLowerCase().contains(text.toLowerCase()))
        item_list2.add(userDetail);
    });

    setState(() {});
  }

  Future _openAddUserDialog() async {
    AlertDialog dialog2;

    dialog2 = new AlertDialog(
      content: new Container(
        height: 300.0,
        /*   decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),*/
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Container(
              color: Theme.of(context).primaryColor,
              child: new ListTile(
                leading: new Icon(Icons.search),
                title: new TextField(
                  controller: controller,
                  decoration: new InputDecoration(
                      hintText: 'Search designer', border: InputBorder.none),
                  onChanged: onSearchTextChanged,
                ),
              ),
            ),

            // dialog top
            new Expanded(
              child: item_list2.length != 0 || controller.text.isNotEmpty
                  ? new ListView.builder(
                      itemCount: item_list2.length,
                      itemBuilder: (context, i) {
                        return new ListTile(
                          title: new Text(item_list2[i].Brand_name),
                          onTap: () async {
                            // Save the user preference
                            await SharedPreferencesHelper.setLanguageCode(
                                item_list2[i].Brand_name);
                            // Refresh
                            setState(() {
                              Item_brand_name = item_list[i].Brand_name;
                              /* Navigator.of(context).pushAndRemoveUntil(
                            new MaterialPageRoute(
                                builder: (BuildContext context) => new Add_Item_4_Listing_details(appbar_name: name_type,ListOfCameraImage: ListOfCameraImage,ListOfGalleryimage: ListOfGalleryimage,Dname: Dname,Size: Size,shipping_list: shippingList,)),
                                (Route<dynamic> route) => false);*/
                            });
                          },
                        );
                      },
                    )
                  : new ListView.builder(
                      itemCount: item_list.length,
                      itemBuilder: (context, index) {
                        return new ListTile(
                          title: new Text(item_list[index].Brand_name),
                          onTap: () async {
                            // Save the user preference
                            await SharedPreferencesHelper.setLanguageCode(
                                item_list[index].Brand_name);
                            // Refresh
                            setState(() {
                              Item_brand_name = item_list[index].Brand_name;
                              /*   Navigator.of(context).pushAndRemoveUntil(
                            new MaterialPageRoute(
                                builder: (BuildContext context) => new Add_Item_4_Listing_details(appbar_name: name_type,ListOfCameraImage: ListOfCameraImage,ListOfGalleryimage: ListOfGalleryimage,Dname: Dname,Size: Size,shipping_list: shippingList,)),
                                (Route<dynamic> route) => false);*/
                            });
                          },
                        );
                      },
                    ),
            ),

            Container(
                child: Card(
              elevation: 4.0,
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)),
              color: Colors.black,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openAddUserDialog1();
                },
                child: Text(
                  'Add new Brand',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
            )),
          ],
        ),
      ),
    );
    showDialog(context: context, child: dialog2);
  }

  void _openAddUserDialog1() {
    TextEditingController brandname = new TextEditingController();
    AlertDialog dialog;

    dialog = new AlertDialog(
      content: new Container(
        height: 300.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Add Brand',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            TextFormField(
              controller: brandname,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black87, style: BorderStyle.solid),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black87, style: BorderStyle.solid),
                  ),
                  hintText: 'Enter brand name',
                  labelText: 'Brand Name',
                  labelStyle: TextStyle(color: Colors.black54)),
              keyboardType: TextInputType.text,
              /* validator: (val) =>
              !val.contains('@') ? 'Not a valid email.' : null,
              onSaved: (val) => _email= val,*/
            ),

            SizedBox(height: 24.0),
            new RaisedButton(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 10.0,
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              color: Colors.black,
              elevation: 4.0,
              splashColor: Colors.grey,
              onPressed: () {
                if (brandname.text != null) {
                  db.add_Brand('', brandname.text, "0").then((_) {
                    setState(() {
                      //  _isInAsyncCall = false;
                      showInSnackBar('Brand successfully Add');
                      Navigator.pop(context);
                    });
                  });
                } else {
                  showInSnackBar('Brand name is required.');
                }
                // Perform some action
              },
            ),
          ],
        ),
      ),
    );

    showDialog(context: context, child: dialog);
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
  void initState() {
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _storage = FirebaseStorage.instance;

    item_list = new List();
    item_list2 = [];
    noteSub = db.getBrandList().listen((QuerySnapshot snapshot) {
      final List<BrandModel> notes = snapshot.documents
          .map((documentSnapshot) => BrandModel.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this.item_list = notes;
      });
    });

    setState(() {
      getCredential();
    });

    _demoItems = <DemoItem<dynamic>>[
      DemoItem<String>(
        name: 'PHOTOS',
        hint: 'Change trip name',
        builder: (DemoItem<String> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }

          return Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    'Choose your primary photo ',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                  ),
                  new Text(
                    'we\'ll put your primary photo on a white background. ',
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                  ),
                  new Text(
                    'front and centered photos work best.',
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                  ),
                  Container(
                      // child: Icon(Icons.ac_unit),
                      child: productlist1 == null || productlist1.length == 0
                          ? new Container()
                          : _getImageFromFile(
                              productlist1[0].item_picture.toList())),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                  ),
                  /* Container(
                      child: GestureDetector(
                    child: Text(
                      'Manage Photo',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.redAccent),
                    ),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ManagePhoto_Screen(
                                ListOfCameraImage, ListOfGalleryimage))),
                  )),*/
                  Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                                child: FlatButton(
                                    onPressed: () async {
                                      final form = formKey.currentState;
                                      form.save();
                                      // Save the user preference
                                      /*  await SharedPreferencesHelper
                                          .setLanguageCode(Disiner_Name);*/
                                      PubishFlag = "1";
                                      sharedPreferences.setString(
                                          'PubishFlag', "1");
                                      addEditDraft();
                                      // Refresh
                                      setState(() {
                                        close();
                                      });
                                    },
                                    child: const Text(
                                      'SAVE&CONTINUE',
                                      style: TextStyle(color: Colors.redAccent),
                                    )))
                          ]))
                ],
              ),
            ),
          );
        },
      ),
      DemoItem<String>(
          name: 'DESIGNER',
          hint: 'Select location',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = false;
              });
            }

            return Form(
              key: formKey1,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      'Enter a designer ',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 20.0),
                      alignment: Alignment.center,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new OutlineButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(2.0)),
                              color: Colors.grey,
                              highlightedBorderColor: Colors.white,
                              onPressed: () {
                                _openAddUserDialog();
                              },
                              child: new Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 5.0,
                                ),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Expanded(
                                      child: Text(
                                        Item_brand_name,
                                        /*Disiner_Name != null
                                            ? Disiner_Name
                                            : */
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                  child: FlatButton(
                                      onPressed: () async {
                                        // Save the user preference
                                        final form = formKey1.currentState;
                                        form.save();
                                        PubishFlag = "1";
                                        sharedPreferences.setString(
                                            'PubishFlag', "1");

                                        if (Item_brand_name == "") {
                                          showInSnackBar(
                                              'Please select designer and brand name!');
                                        } else {
                                          await SharedPreferencesHelper
                                              .setLanguageCode(Item_brand_name);
                                          //   UpdateDataPost();
                                          // Refresh
                                          setState(() {
                                            close();
                                          });
                                        }
                                      },
                                      child: const Text(
                                        'SAVE&CONTINUE',
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      )))
                            ]))
                  ],
                ),
              ),
            );
          }),
      DemoItem<String>(
          name: 'CONDITION',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = false;
              });
            }

            return Form(
                key: formKey2,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          'Retail tags attached? ',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 5.0, left: 5.0, right: 5.0, bottom: 10.0),
                          child: new Row(
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: Container(
                                  child: new RaisedButton(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new Text("Yes"),
                                      textColor: tag_press_yes == false
                                          ? Colors.black
                                          : Colors.white,
                                      color: tag_press_yes == false
                                          ? Colors.white
                                          : Colors.black,
                                      onPressed: () {
                                        setState(() {
                                          tag_press_yes = true;
                                          tag_press_Text = 'yes';
                                          tag_press_no = false;
                                        });
                                      },
                                      /*=> setState(
                                          () => tag_press_yes = !tag_press_no),*/

                                      shape: new RoundedRectangleBorder(
                                          side:
                                              BorderSide(color: Colors.black))),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: new RaisedButton(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new Text("No"),
                                      textColor: tag_press_no == false
                                          ? Colors.black
                                          : Colors.white,
                                      color: tag_press_no == false
                                          ? Colors.white
                                          : Colors.black,
                                      onPressed: () {
                                        setState(() {
                                          tag_press_no = true;
                                          tag_press_Text = 'no';
                                          tag_press_yes = false;
                                        });
                                      },
                                      shape: new RoundedRectangleBorder(
                                          side:
                                              BorderSide(color: Colors.black))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                        ),
                        new Text(
                          'Any signs wear? ',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 5.0, left: 5.0, right: 5.0, bottom: 10.0),
                          child: new Row(
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: Container(
                                  child: new RaisedButton(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new Text("Yes"),
                                      textColor: signs_press_yes == false
                                          ? Colors.black
                                          : Colors.white,
                                      color: signs_press_yes == false
                                          ? Colors.white
                                          : Colors.black,
                                      onPressed: () {
                                        setState(() {
                                          signs_press_yes = true;
                                          signs_press_text = 'yes';
                                          signs_press_no = false;
                                        });
                                      },
                                      /*=> setState(
                                          () => tag_press_yes = !tag_press_no),*/

                                      shape: new RoundedRectangleBorder(
                                          side:
                                              BorderSide(color: Colors.black))),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: new RaisedButton(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new Text("No"),
                                      textColor: signs_press_no == false
                                          ? Colors.black
                                          : Colors.white,
                                      color: signs_press_no == false
                                          ? Colors.white
                                          : Colors.black,
                                      onPressed: () {
                                        setState(() {
                                          signs_press_no = true;
                                          signs_press_text = 'no';
                                          signs_press_yes = false;
                                        });
                                      },
                                      shape: new RoundedRectangleBorder(
                                          side:
                                              BorderSide(color: Colors.black))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                      child: FlatButton(
                                          onPressed: () async {
                                            PubishFlag = "1";
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");
                                            // Save the user preference
                                            final form = formKey2.currentState;
                                            form.save();
                                            await SharedPreferencesHelper
                                                .set_tag(tag_press_Text);
                                            Retail_Tag = tag_press_Text;
                                            await SharedPreferencesHelper
                                                .set_signs(signs_press_text);
                                            Signs_Wear = signs_press_text;
                                            // Refresh

                                            //  UpdateDataPost();
                                            setState(() {
                                              close();
                                            });
                                          },
                                          child: const Text(
                                            'SAVE&CONTINUE',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          )))
                                ]))
                      ]),
                ));
          }),
      DemoItem<String>(
          name: 'PRODUCT INFO',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = false;
              });
            }

            return Form(
                key: formKey3,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          'What\'s the length (inch)?',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 9,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                                child: TextFormField(
                                  controller: lenght,
                                  decoration: const InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black54,
                                          style: BorderStyle.solid),
                                    ),
                                    hintText: '0.00',
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                  ),
                                  keyboardType: TextInputType.text,
                                  /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/
                                  onSaved: (val) => lenght.text = val,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.info,
                                      size: 30.0,
                                      color: Colors.grey,
                                    ),
                                    onTap: _openAddUserDialo,
                                  )),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.0),
                        ),
                        /*  new Text(
                      'Whate\'s the width (inch)?',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 234.0, 5.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black54,
                                  style: BorderStyle.solid),
                            ),
                            hintText: '0.00',
                            labelStyle: TextStyle(color: Colors.black54)),
                        keyboardType: TextInputType.number,
                        */ /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/ /*
                        onSaved: (val) => __width = val,
                      ),
                    ),
                    Container(
                      height: 10.0,
                    ),
                    new Text(
                      'Whate\'s the height (inch)?',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 234.0, 5.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid),
                              ),
                              hintText: '0.00',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.number,
                          */ /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/ /*
                          onSaved: (val) => _hight = val,
                        )),
                    Container(
                      height: 10.0,
                    ),*/
                        new Text(
                          'What\'s the title?',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                          child: TextFormField(
                            controller: title,
                            decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black54,
                                      style: BorderStyle.solid),
                                ),
                                hintText: 'Example \'Neverful\'',
                                labelStyle: TextStyle(color: Colors.black54)),
                            keyboardType: TextInputType.text,
                            /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/
                            onSaved: (val) => title.text = val,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                      child: FlatButton(
                                          onPressed: () async {
                                            PubishFlag = "1";
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");
                                            // Save the user preference
                                            final form = formKey3.currentState;
                                            form.save();
                                            await SharedPreferencesHelper
                                                .set_length(lenght.text);
                                            await SharedPreferencesHelper
                                                .set_titile(title.text);

                                            // UpdateDataPost();

                                            // Refresh
                                            setState(() {
                                              close();
                                            });
                                          },
                                          child: const Text(
                                            'SAVE&CONTINUE',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          )))
                                ]))
                      ]),
                ));
          }),
      DemoItem<String>(
          name: 'RETAIL PRICE',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = false;
              });
            }

            return Form(
                key: formKey4,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          'Retail Price',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 5.0),
                          child: TextFormField(
                            controller: retailprice,
                            decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black54,
                                      style: BorderStyle.solid),
                                ),
                                hintText: '0.00',
                                labelStyle: TextStyle(color: Colors.black54)),
                            keyboardType: TextInputType.number,
                            /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/
                            onSaved: (val) => retailprice.text = val,
                          ),
                        ),
                        Container(
                          height: 20.0,
                        ),
                        new Text(
                          'Entering the retail price helps us offer a better pricing recommendation for your item.',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                      child: FlatButton(
                                          onPressed: () async {
                                            // Save the user preference
                                            final form = formKey4.currentState;
                                            form.save();
                                            await SharedPreferencesHelper
                                                .set_retailprice(
                                                    retailprice.text);
                                            PubishFlag = "1";
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");
                                            //   UpdateDataPost();
                                            // Refresh
                                            setState(() {
                                              close();
                                            });
                                          },
                                          child: const Text(
                                            'SAVE&CONTINUE',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          )))
                                ]))
                      ]),
                ));
          }),
      DemoItem<String>(
          name: 'SELLING PRICE(Optional)',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = false;
              });
            }

            return Form(
                key: formKey5,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          'Your Listing Price',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 5.0),
                          child: TextFormField(
                            controller: sellingprice,
                            decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black54,
                                      style: BorderStyle.solid),
                                ),
                                labelStyle: TextStyle(color: Colors.black54)),
                            keyboardType: TextInputType.number,
                            /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/
                            onSaved: (val) => sellingprice.text = val,
                          ),
                        ),
                        Container(
                          height: 20.0,
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                      child: FlatButton(
                                          onPressed: () async {
                                            // Save the user preference
                                            final form = formKey5.currentState;
                                            form.save();
                                            PubishFlag = "1";
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");
                                            await SharedPreferencesHelper
                                                .set_sellingprice(
                                                    sellingprice.text);
                                            // UpdateDataPost();
                                            // Refresh
                                            setState(() {
                                              close();
                                            });
                                          },
                                          child: const Text(
                                            'SAVE&CONTINUE',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          )))
                                ]))
                      ]),
                ));
          }),
      DemoItem<String>(
          name: 'SHIPPING',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = false;
              });
            }

            return Form(
                key: formKey6,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 300.0,
                          child: shippingListdata(),
                        ),
                        Divider(),
                        Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                      child: FlatButton(
                                          onPressed: () async {
                                            // Save the user preference
                                            final form = formKey6.currentState;
                                            PubishFlag = "1";
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");
                                            form.save();
                                            await SharedPreferencesHelper
                                                .set_sippingkit(
                                                    Item_shipping_id);
                                            // UpdateDataPost();
                                            // Refresh
                                            setState(() {
                                              close();
                                            });
                                          },
                                          child: const Text(
                                            'SAVE&CONTINUE',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          )))
                                ]))
                      ]),
                ));
          }),
      DemoItem<String>(
          name: 'OPTIONAL INFO(Optional)',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = false;
              });
            }

            return Form(
              key: formKey7,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        'How would you describe this item?',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                        child: TextFormField(
                          controller: itemdescription,
                          decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid),
                              ),
                              hintText: 'Describe the fit, condition,etc',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/
                          onSaved: (val) => itemdescription.text = val,
                        ),
                      ),
                      Container(
                        height: 10.0,
                      ),
                      new Text(
                        'What\'s the color that best represents your item?',
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                        child: TextFormField(
                          controller: itemcolor,
                          decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid),
                              ),
                              hintText: 'Example \'black\'',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.text,
                          /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/
                          onSaved: (val) => itemcolor.text = val,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                    child: FlatButton(
                                        onPressed: () async {
                                          // Save the user preference
                                          final form = formKey7.currentState;
                                          PubishFlag = "1";
                                          sharedPreferences.setString(
                                              'PubishFlag', "1");
                                          form.save();
                                          await SharedPreferencesHelper
                                              .set_description(
                                                  itemdescription.text);
                                          await SharedPreferencesHelper
                                              .set_color(itemcolor.text);
                                          // Refresh
                                          // UpdateDataPost();
                                          setState(() {
                                            close();
                                          });
                                        },
                                        child: const Text(
                                          'SAVE&CONTINUE',
                                          style: TextStyle(
                                              color: Colors.redAccent),
                                        )))
                              ]))
                    ]),
              ),
            );
          }),
    ];
  }

  void _increaseCounter() {
    setState(() {
      tag_press_yes = true;
      // _counter = _counter + 1;
    });
  }

  void _decreaseCounter() {
    setState(() {
      tag_press_no = true;
      //_//counter = _counter - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double width1 = width * 0.65;
    return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          backgroundColor: Colors.white70,
          title: Text(name_type),
          leading: GestureDetector(
            child: IconButton(
                icon: Icon(Icons.close),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            onTap: () {
              if (view_flag == 1) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Drafts_Screen()));
              } else if (view_flag == 2) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Seller_Profile()));
              }

              /*if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              SystemNavigator.pop();
            }*/
            },
          ),
          actions: <Widget>[
            Center(
                child: GestureDetector(
              child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500),
                  )),
              onTap: () {
                sharedPreferences.setString('product_id', Product_Id);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ItemDetails(Product_Id)));
              },
            ))
          ],
        ),
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: SafeArea(
                child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 10.0, bottom: 5.0),
                  child: ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _demoItems[index].isExpanded = !isExpanded;
                        });
                      },
                      children: _demoItems
                          .map<ExpansionPanel>((DemoItem<dynamic> item) {
                        return ExpansionPanel(
                            isExpanded: item.isExpanded,
                            headerBuilder: item.headerBuilder,
                            body: Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: item.build(),
                            ));
                      }).toList()),
                ),
                Container(
                  margin: EdgeInsets.only(left: 60.0, right: 60.0, top: 20.0),
                  child: Divider(),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: 30.0, right: 30.0, top: 10.0, bottom: 30.0),
                  child: Center(
                    child: new Text(
                      'Earnings Breackdown',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new Text(
                    'Your earnings should be available 21 days (usually sooner) after delivvery or 4 days after delivvery if you\'re a verified seller.',
                    maxLines: 5,
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.black54),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new RichText(
                      text: new TextSpan(
                    children: [
                      new TextSpan(
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black54),
                          text:
                              'By Publishing this listing, I am agreeing that this listing adheres to the '),
                      new TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.redAccent),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            MyNavigator.goToTerms(context);
                          },
                      ),
                    ],
                  )),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Return Policy',
                    style:
                        TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new RichText(
                      text: new TextSpan(
                    children: [
                      new TextSpan(
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black54),
                          text:
                              'ThreadOn will take and pay for returns for this item at on cost to you according to our '),
                      new TextSpan(
                        text: 'Return Policy',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.redAccent),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            MyNavigator.goToTerms(context);
                          },
                      ),
                      new TextSpan(
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black54),
                          text:
                              ', as long as the information in this listing is accurate and complete.'),
                    ],
                  )),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new RichText(
                      text: new TextSpan(
                    children: [
                      new TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.black54,
                          ),
                          text:
                              'ThreadOn does not cover return on wedding items. ThreadOn Wedding Returns & Shipping Policies apply to all wedding sales. '),
                    ],
                  )),
                ),
                new Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 35.0),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(color: Colors.black),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new OutlineButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(2.0)),
                          borderSide: BorderSide(color: Colors.black),
                          color: Colors.black,
                          splashColor: Colors.grey,
                          highlightedBorderColor: Colors.black,
                          onPressed: () => publisSubmit(),
                          child: new Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 15.0,
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Expanded(
                                  child: Text(
                                    "Publish Listing",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ),
          inAsyncCall: _isInAsyncCall,
          opacity: 0.7,
          color: Colors.white,
          progressIndicator: CircularProgressIndicator(),
        ));
  }

//
  Future publisSubmit() async {
    if (PubishFlag == "1") {
      if (Item_brand_name == "") {
        showInSnackBar('Product designer and brand required.');
      } else {
        if (Retail_Tag == "") {
          showInSnackBar('Retail tags Attached? (YES/NO)');
        } else {
          if (Signs_Wear == "") {
            showInSnackBar('Any signs wear? (YES/NO)');
          } else {
            if (Item_Size.text == "") {
              showInSnackBar('Product size required.');
            } else {
              if (Item_titile.text == "") {
                showInSnackBar('Product title required.');
              } else {
                if (Item_retailPrice.text == "") {
                  showInSnackBar('Please add Retailprice');
                } else {
                  if (Item_sellingPrice.text == "") {
                    showInSnackBar('Product selling price required.');
                  } else {
                    if (Item_shipping_id == "") {
                      showInSnackBar('Shipping type required.');
                    } else {
                      if (Item_description.text == "") {
                        showInSnackBar('Product description required.');
                      } else {
                        if (Item_color.text == "") {
                          showInSnackBar('Product color required.');
                        } else {
                          if (Item_pound > 0 || Item_Ounces > 0) {
                            setState(() {
                              _isInAsyncCall = true;
                            });

                            String Is_cart = "0";
                            String Item_sold = "";

                            var updateId = {
                              "product_id": Product_Id,
                              "any_sign_wear": Signs_Wear,
                              "category": Cat_Name,
                              "category_id": Cat_Id,
                              "country": User_country,
                              "date": DateTime.now(),
                              "favourite_count": "0",
                              "is_cart": Is_cart,
                              "is_favorite_count": "0",
                              "item_brand": Item_brand_name,
                              "item_color": Item_color.text,
                              "item_description": Item_description.text,
                              "item_measurements": "",
                              "item_picture": UplodImageList,
                              "item_price": Item_retailPrice.text,
                              "item_sale_price": Item_sellingPrice.text,
                              "item_size": Item_Size.text,
                              "item_sold": Item_sold,
                              "item_sub_title": "",
                              "item_title": Item_titile.text,
                              "item_type": "",
                              "picture": managphoto,
                              "retail_tag": Retail_Tag,
                              "shipping_id": Item_shipping_id,
                              "status": Status,
                              "sub_category": Sub_Cat_Name,
                              "sub_category_id": Sub_Cat_Id,
                              "user_id": User_id,
                              "shipping_charge": shipping_charge,
                              "packing_type": packing_type,
                              "item_pound": Item_pound,
                              "item_Ounces": Item_Ounces
                            };

                            db1
                                .collection("product")
                                .document(Product_Id)
                                .updateData(updateId)
                                .then((val) {
                              sharedPreferences.setString(
                                  'product_id', Product_Id);

                              setState(() {
                                _isInAsyncCall = false;
                              });
                              // sharedPreferences = await SharedPreferences.getInstance();
                              // sharedPreferences.setString('product_id', );
                              showInSnackBar('Your draft is saved!');

                              if (Status == "3") {
                                sharedPreferences.setInt('draft_flag', null);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Add_Address_Screen(
                                              appbar_name: 'Selling Address',
                                              Flag: 3,
                                              exit_Flag: 3,
                                            )));
                              } else {
                                Firestore.instance
                                    .collection('product')
                                    .where("product_id", isEqualTo: Product_Id)
                                    .snapshots()
                                    .listen((data) {
                                  data.documents.forEach((doc) async {
                                    if (doc.exists) {
                                      setState(() {
                                        productList.add(Shell_Product_Model(
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
                                      });
                                      showInSnackBar(
                                          'Product successfully Updated');
                                      sharedPreferences.setInt(
                                          'draft_flag', null);
                                      sharedPreferences.setString('pro_id', "");

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GridItemDetails1(
                                                    item: productList[0],
                                                    exitflag: 1,
                                                  )));
                                    } else {
                                      showInSnackBar('No payoutd data found!');
                                    }
                                  });
                                });
                              }

                              print("sucess");
                            }).catchError((err) {
                              print(err);
                              _isInAsyncCall = false;
                            });
                          } else {
                            showInSnackBar(
                                'Product Missing value for Pounds or Ounces');
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
//

  Future addEditDraft() async {
    setState(() {
      _isInAsyncCall = true;
    });

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);
    String Is_cart = "";
    String Item_sold = "";
    String Status = "3";

    switch (cameraFlag) {
      case 1:
        {
          for (var i = 0; i < reversedAnimals.length; i++) {
            String imageFile = reversedAnimals[i].toString();
            if (imageFile == "") {
            } else {
              File contents = new File(imageFile);

              DateTime now = DateTime.now();
              String formattedDate =
                  DateFormat('kk:mm:ss EEE d MMM').format(now);

              String Old_profile_name = 'product' + formattedDate + ".jpg";
              String folder = "product";

              StorageReference reference =
                  _storage.ref().child(folder).child(Old_profile_name);
              StorageUploadTask uploadTask = reference.putFile(contents);
              var dowurl =
                  await (await uploadTask.onComplete).ref.getDownloadURL();

              if (uploadTask.isComplete) {
                //  Old_profile_name = Name+formattedDate+".jpg";

                managphoto = dowurl;
                UplodImageList.add(dowurl.toString());
                UplodImageListNames.add(Old_profile_name);
              } else {}
            }
          }
        }
        break;

      case 2:
        {
          for (var i = 0; i < ListOfGalleryimage.length; i++) {
            String imageFile = ListOfGalleryimage[i].toString();
            if (imageFile == null) {
            } else {
              File contents = new File(imageFile);
              DateTime now = DateTime.now();
              String formattedDate =
                  DateFormat('kk:mm:ss EEE d MMM').format(now);

              String Old_profile_name = 'product' + formattedDate + ".jpg";
              String folder = "product";

              StorageReference reference =
                  _storage.ref().child(folder).child(Old_profile_name);
              StorageUploadTask uploadTask = reference.putFile(contents);
              var dowurl =
                  await (await uploadTask.onComplete).ref.getDownloadURL();

              if (uploadTask.isComplete) {
                //  Old_profile_name = Name+formattedDate+".jpg";

                managphoto = dowurl;
                UplodImageList.add(dowurl.toString());
                UplodImageListNames.add(Old_profile_name);
              } else {}
            }
          }
        }
        break;
    }

    db1.collection("product").add({
      "any_sign_wear": signs_press_text,
      "category": Cat_Name,
      "category_id": Cat_Id,
      "country": User_country,
      "date": DateTime.now(),
      "favourite_count": "0",
      "is_cart": Is_cart,
      "is_favorite_count": "0",
      "item_brand": Item_brand_name,
      "item_color": itemcolor.text,
      "item_description": itemdescription.text,
      "item_measurements": "",
      "item_picture": UplodImageList,
      "item_price": retailprice.text,
      "item_sale_price": sellingprice.text,
      "item_size": Item_Size,
      "item_sold": Item_sold,
      "item_sub_title": "",
      "item_title": title.text,
      "item_type": "",
      "picture": managphoto,
      "retail_tag": tag_press_Text,
      "shipping_id": Item_shipping_id,
      "status": Status,
      "sub_category": Sub_Cat_Name,
      "sub_category_id": Sub_Cat_Id,
      "user_id": User_id,
      "shipping_charge": "", //shipping_charge,
      "packing_type": "", //packing_type,
      "item_pound": "", //Item_pound,
      "item_Ounces": "" //Item_Ounces
    }).then((val) {
      var docId = val.documentID;
      String user_id = sharedPreferences.getString(docId);

      var updateId = {"product_id": docId};

      db1
          .collection("product")
          .document(docId)
          .updateData(updateId)
          .then((val) {
        sharedPreferences.setString('product_id', docId);
        Product_Id = docId;
        setState(() {
          _isInAsyncCall = false;
        });
        // sharedPreferences = await SharedPreferences.getInstance();
        // sharedPreferences.setString('product_id', );
        showInSnackBar('Your draft is saved!');

        print("sucess");
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });
      print("sucess");
    }).catchError((err) {
      print(err);
      _isInAsyncCall = false;
    });
  }

  /* void UpdateDataPost() async {


    setState(() {
      _isInAsyncCall = true;
    });

    DateTime now = DateTime.now();
    String formattedDate =
    DateFormat('kk:mm:ss EEE d MMM').format(now);
    String Is_cart = "";
    String Item_sold = "";
    String Status = "3";




    db.updateProduct(Shell_Product_Model(
        Product_Id,
        signs_press_text,
        tag_press_Text,
        Cat_Name,
        Cat_Id,
        User_country,
        DateTime.now(),
        Is_cart,
        Item_brand_name,
        itemcolor.text,
        itemdescription.text,
        sellingprice.text,
        retailprice.text,
        Item_Size,
        Item_sold,
        title.text,
        managphoto,
        Status,
        Sub_Cat_Name,
        Sub_Cat_Id,
        Item_shipping_id,
        User_id,
        UplodImageList))
        .then((_) async {


      setState(() {
        _isInAsyncCall = false;
      });

     // showInSnackBar('Profile data update successfully');
    });

  }*/

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _openAddUserDialo() {
    AlertDialog dialog = new AlertDialog(
      content: new Container(
        height: 300.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        /*   child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Add Item to your',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

           */ /* Container(
                child: Card(
                  elevation: 4.0,
                  shape: new RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black)),
//                  color: Colors.black,
                  child: FlatButton.icon(
                    onPressed: () => (
                        setState((){
                          if(favourite == false){
                            favourite = true;
                            favouritesubmit();
                          } else {
                            favourite = false;
                          }
                        })
                    ),
                    icon: favourite?new Icon(Icons.favorite):new Icon(Icons.favorite_border, ),
//                    icon: Icon(Icons.favorite_border, color: Colors.black,),
                    label: Text('Favorite', style: TextStyle(
                        color: Colors.black, fontSize: 17.0),),),

                )
            ),
*/ /*
            Container(
              height: 150,

            ),

            Container(
                child: Card(
                  elevation: 4.0,
                  shape: new RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black)),
                  color: Colors.black,
                  child: FlatButton.icon(
                   // onPressed: () => _openAddUserDialog1(),
                    icon: Icon(null),
                    label: Text('Add Item to new Share List', style: TextStyle(
                        color: Colors.white, fontSize: 14.0),),),

                )
            ),

          ],
        ),*/
      ),
    );

    showDialog(context: context, child: dialog);
  }
}

typedef DemoItemBodyBuilder<T> = Widget Function(DemoItem<T> item);
typedef ValueToString<T> = String Function(T value);

class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({this.name, this.hint, this.showHint});

  final String name;
  final String hint;
  final bool showHint;

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
    return AnimatedCrossFade(
      firstChild: first,
      secondChild: second,
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Row(children: <Widget>[
      Expanded(
        flex: 2,
        child: Container(
          height: 30.0,
          margin: const EdgeInsets.only(left: 15.0),
          child: Text(name,
              style: textTheme.body1.copyWith(
                  fontSize:
                      15.0)), /*FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          */ /*  child: Text(
              name,
              style: textTheme.body1.copyWith(fontSize: 15.0),
            ),*/ /*
          ),*/
        ),
      ),
      /*Expanded(
          flex: 3,
          child: Container(
              margin: const EdgeInsets.only(left: 24.0),
              child: _crossFade(
                  Text(value,
                      style: textTheme.caption.copyWith(fontSize: 15.0)),
                  Text(hint, style: textTheme.caption.copyWith(fontSize: 15.0)),
                  showHint)))*/
    ]);
  }
}

class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody(
      {this.margin = EdgeInsets.zero, this.child, this.onSave, this.onCancel});

  final EdgeInsets margin;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Column(children: <Widget>[
      Container(
          margin: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0) -
              margin,
          child: Center(
              child: DefaultTextStyle(
                  style: textTheme.caption.copyWith(fontSize: 15.0),
                  child: child))),
      const Divider(height: 1.0),
      Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: FlatButton(
                    onPressed: onCancel,
                    child: const Text('',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500)))),
            Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: FlatButton(
                    onPressed: onSave,
                    textTheme: ButtonTextTheme.accent,
                    child: const Text('SAVE&CONTINUE')))
          ]))
    ]);
  }
}

class DemoItem<T> {
  DemoItem({this.name, this.hint, this.builder});

  final String name;
  final String hint;
  final DemoItemBodyBuilder<T> builder;
  bool isExpanded = true;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return DualHeaderWithHint(name: name, hint: hint, showHint: isExpanded);
    };
  }

  Widget build() => builder(this);
}
