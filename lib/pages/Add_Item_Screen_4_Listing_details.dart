import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:threadon/model/Category.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/GridItemDetails1.dart';
import 'package:xml/xml.dart' as xml;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:custom_multi_image_picker/asset.dart';
// import 'package:multi_image_picker/asset.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/model/Shipping.dart';
import 'package:threadon/model/Sub_Category.dart';
import 'package:threadon/pages/Add_Address_screen.dart';
import 'package:threadon/pages/ItemDetails_Screen.dart';
import 'package:threadon/pages/SearchList_Screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/SharedPreferencesHelper.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Add_Item_4_Listing_details extends StatefulWidget {
  String appbar_name;
  List<String> listOfGalleryimage;
  List<String> listOfCameraImage;

  // List<String> listOfCameraImage;
  String Dname;

  String Size;

  // ignore: non_constant_identifier_names
  Add_Item_4_Listing_details({
    Key key,
    this.appbar_name,
    this.listOfCameraImage,
    this.listOfGalleryimage,
    this.Dname,
    this.Size,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => add_item_4(
      appbar_name, listOfCameraImage, listOfGalleryimage, Dname, Size);
}

class add_item_4 extends State<Add_Item_4_Listing_details> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String name_type;
  String Dname;
  String productStatus;
  String Size;
  List<String> listOfGalleryimage;
  int PubishFlag = 0;

  List<String> listOfCameraImage;

  List<Shipping_model> shipping_list;

  List<String> UplodImageList = new List();
  List<String> UplodImageListNames = new List();

  // List<Asset> listOfGalleryimage1 = new List<Asset>();
  // List<String> listOfCameraImage1 = new List<String>();
  String Item_brand_name = "", Retail_Tag = "", Signs_Wear = "", New_Wear = "";

  int Flag = 0;

  add_item_4(this.name_type, this.listOfCameraImage, this.listOfGalleryimage,
      this.Dname, this.Size);

  int value = 0;
  List<DemoItem<dynamic>> _demoItems;
  bool tag_press_yes = false;
  bool tag_press_no = false;

  bool signs_press_yes = false;
  bool signs_press_no = false;

  bool new_press_yes = false;
  bool new_press_no = false;

  bool anySingpress = false;

  String Item_shipping_id = "";
  int Item_pound = 0, Item_Ounces = 0;
  bool _isInAsyncCall = true;
  String Item_result = "";
  List<String> reversedAnimals;
  String shipping_charge = "0";
  List<String> packing_type = new List();

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  TextEditingController shippingcost = new TextEditingController();
  TextEditingController Item_Size = new TextEditingController();
  TextEditingController Item_titile = new TextEditingController();
  TextEditingController Item_retailPrice = new TextEditingController();
  TextEditingController Item_sellingPrice = new TextEditingController();
  TextEditingController Item_description = new TextEditingController();
  TextEditingController Item_color = new TextEditingController();

  List<Shell_Product_Model> productList = new List();

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
  SharedPreferences sharedPreferences;

  String Cat_Name = "",
      Cat_Id = "",
      Sub_Cat_Name = "",
      Sub_Cat_Id = "",
      User_id = "",
      User_country = "";
  String managphoto = "";
  int cameraFlag = 0;
  String Product_Id = "";
  var db1 = Firestore.instance;

  bool costbool = false;
  bool pakegbool = false;
  bool fixbool = true;

  List<Sub_CategoryModel> sub_cat_list = new List();
  List<Shell_Product_Model> productlist;
  List<Shell_Product_Model> productlist1;
  List<CategoryModel> cat_list = new List();
  bool ispolybag = false;
  bool isbox = false;
  String Status = '';
  int draft_Flag = 0;
  List<String> listOfImages;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();

    User_id = await sharedPreferences.getString('user_id');

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

    if (Size == "2") {
      getData();
    } else {
      draft_Flag = await sharedPreferences.getInt('draft_flag');
      Product_Id = sharedPreferences.getString('pro_id');
      Item_brand_name = await SharedPreferencesHelper.getLanguageCode();
      Cat_Name = await SharedPreferencesHelper.getcat_name();
      Cat_Id = await SharedPreferencesHelper.getcat_id();
      Sub_Cat_Name = await SharedPreferencesHelper.getsub_cat_name();
      Sub_Cat_Id = await SharedPreferencesHelper.getsubcat_id();
      managphoto = await SharedPreferencesHelper.getpic_url();

      User_country = await sharedPreferences.getString('country');
      UplodImageList = await sharedPreferences.getStringList('image');
      cameraFlag = await sharedPreferences.getInt('cameraflag');

      getSubCat();
    }
  }

  Future getData() async {
    productlist = new List();
    productlist1 = new List();
    PubishFlag = 1;
    Product_Id = Dname;
    UplodImageList = listOfCameraImage;
    CollectionReference ref = Firestore.instance.collection('product');
    QuerySnapshot eventsQuery = await ref
        .where("user_id", isEqualTo: User_id)
        .where('product_id', isEqualTo: Dname)
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
            doc['brand_new']));
        setState(() {
          this.productlist1 = productlist;
          Item_brand_name = productlist1[0].item_brand;

          Item_Size = TextEditingController(text: productlist1[0].item_size);
          Item_titile = TextEditingController(text: productlist1[0].item_title);
          Item_pound = productlist1[0].item_pound;
          Item_Ounces = productlist1[0].item_Ounces;
          Item_retailPrice =
              TextEditingController(text: productlist1[0].item_price);
          Item_sellingPrice =
              TextEditingController(text: productlist1[0].item_sale_price);
          Item_description =
              TextEditingController(text: productlist1[0].item_description);
          Item_color = TextEditingController(text: productlist1[0].item_color);
          Retail_Tag = productlist1[0].retail_tag;
          Signs_Wear = productlist1[0].any_sign_wear;
          New_Wear = productlist1[0].brand_new;

          Item_shipping_id = productlist1[0].shipping_id;

          shipping_charge = doc['shipping_charge'];

          //  UplodImageList = [];

          // UplodImageList = productlist1[0].item_picture.cast<String>();

          Cat_Name = productlist1[0].category;
          Cat_Id = productlist1[0].category_id;
          Sub_Cat_Id = productlist1[0].sub_category_id;
          Sub_Cat_Name = productlist1[0].sub_category;

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

          if (doc['brand_new'] == "yes") {
            new_press_yes = true;
          } else if (doc['brand_new'] == "no") {
            new_press_no = true;
          }

          for (int i = 0; i < shipping_list.length; i++) {
            if (doc['shipping_id'] == shipping_list[i].Id) {
              _radioValue = i;
            }
          }

          getSubCat();
        });
      });
    }
  }

  getSubCat() async {
    if (Sub_Cat_Id == "" || Sub_Cat_Id == null) {
      CollectionReference ref = Firestore.instance.collection('category');
      QuerySnapshot eventsQuery =
          await ref.where("category_id", isEqualTo: Cat_Id).getDocuments();

      if (eventsQuery.documents.isEmpty) {
        getAddressStatus();
      } else {
        eventsQuery.documents.forEach((doc) async {
          cat_list.add(CategoryModel(
            doc['category_name'],
            doc['category_id'],
            doc['category_image'],
            doc['is_sub_category'],
            doc['polybag'].toList(),
            doc['premium_box'].toList(),
          ));
        });

        setState(() {
          this.cat_list = cat_list;
        });
        getAddressStatus();
      }
    } else {
      CollectionReference ref = Firestore.instance.collection('sub_category');
      QuerySnapshot eventsQuery = await ref
          .where("sub_category_id", isEqualTo: Sub_Cat_Id)
          .getDocuments();

      if (eventsQuery.documents.isEmpty) {
        getAddressStatus();
      } else {
        eventsQuery.documents.forEach((doc) async {
          sub_cat_list.add(Sub_CategoryModel(
            doc['category_id'],
            doc['is_sub_category'],
            doc['is_sub_category_id'],
            doc['polybag'].toList(),
            doc['premium_box'].toList(),
            doc['sub_category_id'],
            doc['sub_category_image'],
            doc['sub_category_name'],
          ));
        });

        setState(() {
          this.sub_cat_list = sub_cat_list;
        });
        getAddressStatus();
      }
    }
  }

  getAddressStatus() async {
    CollectionReference ref = Firestore.instance.collection('shipping_address');
    QuerySnapshot eventsQuery = await ref
        .where('user_id', isEqualTo: User_id)
        .where("status", isEqualTo: "0")
        .getDocuments();

    if (eventsQuery.documents.isEmpty) {
      Status = "3";

      if (draft_Flag == null) {
        addEditDraft();
      } else if (draft_Flag == 1) {
        setState(() {
          _isInAsyncCall = false;
        });
      }
    } else {
      eventsQuery.documents.forEach((doc) async {
        Status = "4";
      });

      if (draft_Flag == null) {
        if (Size != "2") {
          addEditDraft();
        }
      } else if (draft_Flag == 1) {
        setState(() {
          _isInAsyncCall = false;
        });
      } else if (draft_Flag == 0) {
        if (this.mounted) {
          setState(() {
            addEditDraft();
          });
        }
      }
    }
  }

  Widget _getImageFromFile(List<String> imagePath) {
    reversedAnimals = imagePath.reversed.toList();

    return Container(
      child: new GridView.builder(
          itemCount: reversedAnimals.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            String value = reversedAnimals[index].toString();
            if (value == "") {
              return Container(
                margin: EdgeInsets.all(5.0),
                child: new GridTile(
                  child: Image.asset(
                    _loadImage,
                    //fit: BoxFit.fill,
                    fit: BoxFit.cover,
                    width: 50.0,
                    height: 60.0,
                    //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
                    //colorBlendMode: BlendMode.srcOver,
                    //color: Color.fromARGB(120, 20, 10, 40),
                  ),
                ),
              );
            } else {
              return Container(
                  margin: EdgeInsets.all(5.0),
                  child: GestureDetector(
                      child: Size == "2"
                          ? FadeInImage.assetNetwork(
                              placeholder: 'images/place_h.png',
                              image: value,
                              height: 60.0,
                              width: 50.0,
                              fit: BoxFit.scaleDown)
                          : Image.file(
                              File(
                                value,
                              ),
                              fit: BoxFit.cover,
                              width: 50.0,
                              height: 60.0,
                            ),
                      onTap: () {
                        setState(() {
                          // _showAlert(reversedAnimals[index].toString());
                        });
                      }));
            }
          }),
    );
  }

  Widget getImages() {
    return Container(
      child: new GridView.builder(
          itemCount: listOfImages.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.all(5.0),
              child: new GridTile(
                child: Image.file(
                  File(
                    listOfImages[index],
                  ),

                  //fit: BoxFit.fill,
                  fit: BoxFit.cover,
                  width: 50.0,
                  height: 60.0,
                  //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
                  //colorBlendMode: BlendMode.srcOver,
                  //color: Color.fromARGB(120, 20, 10, 40),
                ),
              ),
            );
            // String first = listOfImages[index].toString();
            // print('$first');
            // if (first == null) {

            // } else {
            //   /* listOfGalleryimage1.add(Asset(
            //       _identifier, _originalWidth, _originalHeight,
            //       filePath: value.toString()));*/
            //   return Container(
            //       margin: EdgeInsets.all(5.0),
            //       child: GestureDetector(
            //           child: Image.file(
            //             File(
            //               first.toString(),
            //             ),
            //             fit: BoxFit.cover,
            //             width: 50.0,
            //             height: 60.0,
            //           ),
            //           onTap: () {
            //             setState(() {
            //               // _showAlert(reversedAnimals[index].toString());
            //             });
            //           }));
            // }
          }),
    );
  }

  Widget shippingListdata() {
    // return shipping_list[position].Id == "3" ?
    return shipping_list.length == null
        ? Container()
        : Container(
            // height: 600.0,
            child: ListView.builder(
                itemCount: shipping_list.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, position) {
                  return GestureDetector(
                    child: Container(
                        margin: EdgeInsets.only(top: 5.0),
                        alignment: Alignment.centerRight,
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            new Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: new Radio<int>(
                                    value: position,
                                    groupValue: _radioValue,
                                    onChanged: (int value) async {
                                      setState(() {
                                        _radioValue = value;
                                        // Item_shipping_id = '${shipping_list[position]}';
                                        if (shipping_list[position].Id == "1") {
                                          packing_type = new List();
                                          costbool = true;
                                          pakegbool = false;
                                          fixbool = false;
                                          Item_shipping_id =
                                              shipping_list[position]
                                                  .shipping_id;
                                        } else if (shipping_list[position].Id ==
                                            "2") {
                                          packing_type = new List();
                                          costbool = false;
                                          pakegbool = false;
                                          fixbool = true;
                                          shipping_charge =
                                              shipping_list[position]
                                                  .shipping_charge;
                                          Item_shipping_id =
                                              shipping_list[position]
                                                  .shipping_id;
                                        } else if (shipping_list[position].Id ==
                                            "3") {
                                          packing_type = new List();
                                          costbool = false;
                                          fixbool = false;
                                          pakegbool = true;
                                          Item_shipping_id =
                                              shipping_list[position]
                                                  .shipping_id;
                                        }
                                      });
                                    },

                                    /* onChanged: handleRadioValueChanged(_radioValue,'${shipping_list[position].Id}'),*/
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      child: new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                            new Container(
                                padding: EdgeInsets.all(10.0),
                                child: shipping_list[position].Id == "1"
                                    ? new Container(
                                        child: costbool
                                            ? new Column(
                                                children: <Widget>[
                                                  new Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    margin: EdgeInsets.only(
                                                        top: 5.0,
                                                        right: 5.0,
                                                        bottom: 5.0),
                                                    child: Text(
                                                      'Custom Shipping Cost',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  TextField(
                                                    controller: shippingcost,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    autofocus: true,
                                                    decoration: InputDecoration(
                                                      hintText: "\$0.00",
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                              1.0,
                                                              5.0,
                                                              10.0,
                                                              0.0),
                                                      border:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black87,
                                                            style: BorderStyle
                                                                .solid),
                                                      ),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black87,
                                                            style: BorderStyle
                                                                .solid),
                                                      ),
                                                    ),
                                                    onChanged: (String cost) {
                                                      setState(() {
                                                        shipping_charge = cost;
                                                      });
                                                    },
                                                  )
                                                ],
                                              )
                                            : new Container(),
                                      )
                                    : new Container()),
                            new Container(
                                margin: EdgeInsets.only(
                                    top: 5.0,
                                    left: 10.0,
                                    right: 5.0,
                                    bottom: 5.0),
                                child: shipping_list[position].Id == "2"
                                    ? new Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.all(10.0),
                                        child: fixbool
                                            ? Text(
                                                "+ \$" +
                                                    shipping_list[position]
                                                        .shipping_charge +
                                                    "  Cost to Buyer",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            : new Container())
                                    : new Container()),
                            new Container(
                                margin: EdgeInsets.only(
                                    top: 5.0,
                                    left: 5.0,
                                    right: 5.0,
                                    bottom: 5.0),
                                child: shipping_list[position].Id == "3"
                                    ? new Container(
                                        alignment: Alignment.centerLeft,
                                        child: pakegbool
                                            ? new Row(
                                                children: <Widget>[
                                                  Expanded(
                                                      flex: 5,
                                                      child: GestureDetector(
                                                        child: Container(
                                                            height: 210.0,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              border: Border.all(
                                                                  color: ispolybag
                                                                      ? Colors
                                                                          .redAccent
                                                                          .withOpacity(
                                                                              0.8)
                                                                      : Colors
                                                                          .black),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Text(
                                                                    'Polybag',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Text(
                                                                    '',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                ),
                                                                Container(
                                                                    padding: EdgeInsets.only(
                                                                        top: 0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            20.0,
                                                                        bottom:
                                                                            10.0),
                                                                    child: Image
                                                                        .asset(
                                                                      'images/polybag.png',
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.1,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.2,
                                                                    )),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              2.0),
                                                                  child:
                                                                      Sub_Cat_Id !=
                                                                              ""
                                                                          ? Text(
                                                                              sub_cat_list[0].polybag[0] + "\" L x " + sub_cat_list[0].polybag[1] + "\" W",
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12.0),
                                                                            )
                                                                          : Text(
                                                                              cat_list[0].polybag[0] + "\" L x " + cat_list[0].polybag[1] + "\" W",
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12.0),
                                                                            ),
                                                                ),
                                                              ],
                                                            )),
                                                        onTap: () {
                                                          packing_type =
                                                              new List();
                                                          setState(() {
                                                            ispolybag = true;
                                                            isbox = false;
                                                            shipping_charge =
                                                                "";
                                                            packing_type
                                                                .add("Polybag");

                                                            if (Sub_Cat_Id ==
                                                                    "" ||
                                                                Sub_Cat_Id ==
                                                                    null) {
                                                              packing_type.add(
                                                                  cat_list[0]
                                                                      .polybag[0]);
                                                              packing_type.add(
                                                                  cat_list[0]
                                                                      .polybag[1]);
                                                            } else {
                                                              packing_type.add(
                                                                  sub_cat_list[
                                                                          0]
                                                                      .polybag[0]);
                                                              packing_type.add(
                                                                  sub_cat_list[
                                                                          0]
                                                                      .polybag[1]);
                                                            }
                                                          });
                                                        },
                                                      )),
                                                  new Container(
                                                    margin: EdgeInsets.only(
                                                        left: 3.0),
                                                  ),
                                                  Expanded(
                                                      flex: 5,
                                                      child: GestureDetector(
                                                        child: Container(
                                                          height: 210.0,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            border: Border.all(
                                                                color: isbox
                                                                    ? Colors
                                                                        .redAccent
                                                                        .withOpacity(
                                                                            0.8)
                                                                    : Colors
                                                                        .black),
                                                            color: Colors.white,
                                                          ),
                                                          child: Column(
                                                            children: <Widget>[
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                child: Text(
                                                                  'Premiun Box',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                child: Text(
                                                                  '',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                              Container(
                                                                  padding: EdgeInsets.only(
                                                                      top: 10,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          20.0,
                                                                      bottom:
                                                                          10.0),
                                                                  child: Image
                                                                      .asset(
                                                                    'images/box.png',
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.1,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.2,
                                                                  )),
                                                              Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              2.0),
                                                                  child:
                                                                      Sub_Cat_Id !=
                                                                              ""
                                                                          ? Text(
                                                                              sub_cat_list[0].premium_box[0] + "\" L x " + sub_cat_list[0].premium_box[1] + "\" W x" + sub_cat_list[0].premium_box[2] + "\" H",
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12.0),
                                                                            )
                                                                          : Text(
                                                                              cat_list[0].premium_box[0] + "\" L x " + cat_list[0].premium_box[1] + "\" W x" + cat_list[0].premium_box[2] + "\" H",
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12.0),
                                                                            )),
                                                            ],
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            ispolybag = false;
                                                            isbox = true;

                                                            packing_type =
                                                                new List();
                                                            packing_type.add(
                                                                "Premiun Box");
                                                            shipping_charge =
                                                                "";

                                                            if (Sub_Cat_Id ==
                                                                    "" ||
                                                                Sub_Cat_Id ==
                                                                    null) {
                                                              packing_type.add(
                                                                  cat_list[0]
                                                                      .premium_box[0]);
                                                              packing_type.add(
                                                                  cat_list[0]
                                                                      .premium_box[1]);
                                                              packing_type.add(
                                                                  cat_list[0]
                                                                      .premium_box[2]);
                                                            } else {
                                                              packing_type.add(
                                                                  sub_cat_list[
                                                                          0]
                                                                      .premium_box[0]);
                                                              packing_type.add(
                                                                  sub_cat_list[
                                                                          0]
                                                                      .premium_box[1]);
                                                              packing_type.add(
                                                                  sub_cat_list[
                                                                          0]
                                                                      .premium_box[2]);
                                                            }
                                                          });
                                                        },
                                                      )),
                                                ],
                                              )
                                            : new Container())
                                    : new Container()),
                            Divider(
                              height: 5.0,
                              color: Colors.black87,
                            )
                          ],
                        )
                        // photo and title
                        ),
                  );
                }),
          );
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
        if (this.mounted) {
          setState(() {
            _connectionStatus = '$result\n'
                'Wifi Name: $wifiName\n'
                'Wifi BSSID: $wifiBSSID\n'
                'Wifi IP: $wifiIP\n';
          });
        }
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
    listOfImages = listOfCameraImage + listOfGalleryimage;
    print("listOfGalleryimage : $listOfGalleryimage");
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _storage = FirebaseStorage.instance;

    getCredential();

    _demoItems = <DemoItem<dynamic>>[
      DemoItem<String>(
        name: 'PHOTOS',
        hint: 'Change trip name',
        builder: (DemoItem<String> item) {
          void close() {
            setState(() {
              item.isExpanded = true;
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
                      child: getImages()),
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
                                listOfCameraImage, listOfGalleryimage))),
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
                                      PubishFlag = 1;
                                      sharedPreferences.setString(
                                          'PubishFlag', "1");

/*
                                      if(Product_Id == "" && Product_Id == null){
                                        addEditDraft();
                                      }
*/

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
                item.isExpanded = true;
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
                              color: Colors.redAccent,
                              highlightedBorderColor: Colors.white,
                              onPressed: () {
                                sharedPreferences.setInt('draft_flag', 1);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchList(
                                              ListOfGalleryimage:
                                                  listOfGalleryimage,
                                              ListOfCameraImage:
                                                  listOfCameraImage,
                                              appbar_name: name_type,
                                              Dname: Dname,
                                              Size: Size,
                                            )));
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
                                        PubishFlag = 1;
                                        sharedPreferences.setString(
                                            'PubishFlag', "1");
                                        if (Item_brand_name == "") {
                                          showInSnackBar(
                                              'Product designer and brand required.');
                                        } else {
                                          if (Product_Id == "" &&
                                              Product_Id == null) {
                                            addEditDraft();
                                          } else {
                                            var docId = Product_Id;
                                            var updateId = {
                                              "item_brand": Item_brand_name
                                            };

                                            db1
                                                .collection("product")
                                                .document(docId)
                                                .updateData(updateId)
                                                .then((val) {
                                              print("sucess");
                                            }).catchError((err) {
                                              print(err);
                                              _isInAsyncCall = false;
                                            });

                                            await SharedPreferencesHelper
                                                .setLanguageCode(
                                                    Item_brand_name);
                                          }

                                          //UpdateDataPost();
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
                item.isExpanded = true;
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
                                          Retail_Tag = 'yes';
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
                                          Retail_Tag = 'no';
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
                                          Signs_Wear = 'yes';
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
                                          Signs_Wear = 'no';
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
                        ),
                        new Text(
                          'Brand New Product ',
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
                                      textColor: new_press_yes == false
                                          ? Colors.black
                                          : Colors.white,
                                      color: new_press_yes == false
                                          ? Colors.white
                                          : Colors.black,
                                      onPressed: () {
                                        setState(() {
                                          new_press_yes = true;
                                          New_Wear = 'yes';
                                          new_press_no = false;
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
                                      textColor: new_press_no == false
                                          ? Colors.black
                                          : Colors.white,
                                      color: new_press_no == false
                                          ? Colors.white
                                          : Colors.black,
                                      onPressed: () {
                                        setState(() {
                                          new_press_no = true;
                                          New_Wear = 'no';
                                          new_press_yes = false;
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
                                            // Save the user preference
                                            final form = formKey2.currentState;
                                            form.save();
                                            await SharedPreferencesHelper
                                                .set_tag(Retail_Tag);

                                            await SharedPreferencesHelper
                                                .set_signs(Signs_Wear);

                                            await SharedPreferencesHelper
                                                .set_new(New_Wear);
                                            // Refresh
                                            PubishFlag = 1;
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");

                                            if (Retail_Tag != "") {
                                              if (Signs_Wear != "") {
                                                if (New_Wear != "") {
                                                  if (Product_Id == "" &&
                                                      Product_Id == null) {
                                                    addEditDraft();
                                                  } else {
                                                    var docId = Product_Id;
                                                    var updateId = {
                                                      "any_sign_wear":
                                                          Signs_Wear,
                                                      "retail_tag": Retail_Tag,
                                                      "brand_new": New_Wear
                                                    };

                                                    db1
                                                        .collection("product")
                                                        .document(docId)
                                                        .updateData(updateId)
                                                        .then((val) {
                                                      print("sucess");
                                                    }).catchError((err) {
                                                      print(err);
                                                      _isInAsyncCall = false;
                                                    });
                                                  }
                                                } else {
                                                  showInSnackBar(
                                                      'Brand New Product? (YES/NO)');
                                                }
                                              } else {
                                                showInSnackBar(
                                                    'Any signs wear? (YES/NO)');
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Retail tags Attached? (YES/NO)');
                                            }

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
                item.isExpanded = true;
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
                                  controller: Item_Size,
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
                                  onSaved: (val) => Item_Size.text = val,
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
                                    onTap: _openAddUserDialog,
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
                            controller: Item_titile,
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
                            onSaved: (val) => Item_titile.text = val,
                          ),
                        ),
                        new Container(
                          height: 20.0,
                        ),
                        new Container(
                            child: Text(
                          'Package Weight',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        new Container(
                          height: 10.0,
                        ),
                        new Row(
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 0.0,
                                      right: 10.0,
                                      top: 5.0,
                                      bottom: 5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: new Text(
                                            'What\'s the Pounds?',
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black),
                                          )),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 0.0, 5.0),
                                        child: TextFormField(
                                          initialValue: Item_pound.toString(),
                                          decoration: const InputDecoration(
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black54,
                                                    style: BorderStyle.solid),
                                              ),
                                              hintText: '00',
                                              contentPadding:
                                                  EdgeInsets.only(left: 2.0),
                                              labelStyle: TextStyle(
                                                  color: Colors.black54)),
                                          keyboardType: TextInputType.number,
                                          /* validator: (val) =>
                            !val.contains('@') ? 'Not a valid email.' : null,*/
                                          onSaved: (val) =>
                                              Item_pound = int.parse(val),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      right: 5.0, top: 5.0, bottom: 5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: new Text(
                                            'What\'s the Ounces?',
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black),
                                          )),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 0.0, 5.0),
                                        child: TextFormField(
                                          initialValue: Item_Ounces.toString(),
                                          decoration: const InputDecoration(
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black54,
                                                    style: BorderStyle.solid),
                                              ),
                                              hintText: '00',
                                              contentPadding:
                                                  EdgeInsets.only(left: 2.0),
                                              labelStyle: TextStyle(
                                                  color: Colors.black54)),
                                          keyboardType: TextInputType.number,
                                          onSaved: (val) =>
                                              Item_Ounces = int.parse(val),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
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
                                            PubishFlag = 1;
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");
                                            final form = formKey3.currentState;
                                            form.save();

                                            if (Item_Size.text != "") {
                                              if (Item_titile.text != "") {
                                                if (Item_pound > 0 ||
                                                    Item_Ounces > 0) {
                                                  await SharedPreferencesHelper
                                                      .set_length(
                                                          Item_Size.text);
                                                  await SharedPreferencesHelper
                                                      .set_titile(
                                                          Item_titile.text);
                                                  //   UpdateDataPost();

                                                  if (Product_Id == "" &&
                                                      Product_Id == null) {
                                                    addEditDraft();
                                                  } else {
                                                    var docId = Product_Id;
                                                    var updateId = {
                                                      "item_title":
                                                          Item_titile.text,
                                                      "item_size":
                                                          Item_Size.text,
                                                      "item_pound": Item_pound,
                                                      "item_Ounces": Item_Ounces
                                                    };

                                                    db1
                                                        .collection("product")
                                                        .document(docId)
                                                        .updateData(updateId)
                                                        .then((val) {
                                                      print("sucess");
                                                    }).catchError((err) {
                                                      print(err);
                                                      _isInAsyncCall = false;
                                                    });
                                                  }
                                                } else {
                                                  showInSnackBar(
                                                      'Product Missing value for Pounds or Ounces');
                                                }
                                              } else {
                                                showInSnackBar(
                                                    'Product title required. ');
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Product size required.');
                                            }

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
                item.isExpanded = true;
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
                            controller: Item_retailPrice,
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
                            onSaved: (val) => Item_retailPrice.text = val,
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
                                            PubishFlag = 1;
                                            sharedPreferences.setString(
                                                'PubishFlag', "1");
                                            final form = formKey4.currentState;
                                            form.save();
                                            if (Item_retailPrice.text != "") {
                                              await SharedPreferencesHelper
                                                  .set_retailprice(
                                                      Item_retailPrice.text);
                                              // UpdateDataPost();

                                              if (Product_Id == "" &&
                                                  Product_Id == null) {
                                                addEditDraft();
                                              } else {
                                                var docId = Product_Id;
                                                var updateId = {
                                                  "item_price":
                                                      Item_retailPrice.text,
                                                };

                                                db1
                                                    .collection("product")
                                                    .document(docId)
                                                    .updateData(updateId)
                                                    .then((val) {
                                                  print("sucess");
                                                }).catchError((err) {
                                                  print(err);
                                                  _isInAsyncCall = false;
                                                });
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Product retailprice required.');
                                            }
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
          name: 'SELLING PRICE',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = true;
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
                            controller: Item_sellingPrice,
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
                            //  validator: (val) =>
                            // !val.contains('@') ? 'Not a valid email.' : null,
                            onSaved: (val) => Item_sellingPrice.text = val,
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

                                            if (Item_sellingPrice.text == "") {
                                              showInSnackBar(
                                                  'Product selling price required.');
                                            }
                                            // else if(){
                                            //     showInSnackBar(
                                            //       'Product Selling price is less than Retails price');
                                            // }
                                            else {
                                              if (double.parse(
                                                      Item_sellingPrice.text) <=
                                                  double.parse(
                                                      Item_retailPrice.text)) {
                                                await SharedPreferencesHelper
                                                    .set_sellingprice(
                                                        Item_sellingPrice.text);
                                                PubishFlag = 1;
                                                sharedPreferences.setString(
                                                    'PubishFlag', "1");
                                                // UpdateDataPost();

                                                if (Product_Id == "" &&
                                                    Product_Id == null) {
                                                  addEditDraft();
                                                } else {
                                                  var docId = Product_Id;
                                                  var updateId = {
                                                    "item_sale_price":
                                                        Item_sellingPrice.text,
                                                  };

                                                  db1
                                                      .collection("product")
                                                      .document(docId)
                                                      .updateData(updateId)
                                                      .then((val) {
                                                    print("sucess");
                                                  }).catchError((err) {
                                                    print(err);
                                                    _isInAsyncCall = false;
                                                  });
                                                }
                                              } else {
                                                showInSnackBar(
                                                    'Product Selling price is Greater than Retails price');
                                              }
                                            }
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
                item.isExpanded = true;
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
                          // height: 600.0,
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
                                            form.save();
                                            PubishFlag = 1;

                                            if (Item_shipping_id != "") {
                                              sharedPreferences.setString(
                                                  'PubishFlag', "1");
                                              await SharedPreferencesHelper
                                                  .set_sippingkit(
                                                      Item_shipping_id);
                                              //  UpdateDataPost();

                                              if (Product_Id == "" &&
                                                  Product_Id == null) {
                                                addEditDraft();
                                              } else {
                                                var docId = Product_Id;
                                                var updateId = {
                                                  "shipping_id":
                                                      Item_shipping_id,
                                                  "shipping_charge":
                                                      shipping_charge,
                                                  "packing_type": packing_type
                                                };

                                                db1
                                                    .collection("product")
                                                    .document(docId)
                                                    .updateData(updateId)
                                                    .then((val) {
                                                  print("sucess");
                                                }).catchError((err) {
                                                  print(err);
                                                  _isInAsyncCall = false;
                                                });
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Shipping type required.');
                                            }

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
          name: 'OTHER INFO',
          hint: '',
          builder: (DemoItem<String> item) {
            void close() {
              setState(() {
                item.isExpanded = true;
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
                          controller: Item_description,
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
                          onSaved: (val) => Item_description.text = val,
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
                          controller: Item_color,
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
                          onSaved: (val) => Item_color.text = val,
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
                                          form.save();
                                          PubishFlag = 1;
                                          sharedPreferences.setString(
                                              'PubishFlag', "1");

                                          if (Item_description.text != "") {
                                            if (Item_color.text != "") {
                                              await SharedPreferencesHelper
                                                  .set_description(
                                                      Item_description.text);
                                              await SharedPreferencesHelper
                                                  .set_color(Item_color.text);
                                              // Refresh

                                              if (Product_Id == "" &&
                                                  Product_Id == null) {
                                                addEditDraft();
                                              } else {
                                                var docId = Product_Id;
                                                var updateId = {
                                                  "item_color": Item_color.text,
                                                  "item_description":
                                                      Item_description.text
                                                };

                                                db1
                                                    .collection("product")
                                                    .document(docId)
                                                    .updateData(updateId)
                                                    .then((val) {
                                                  print("sucess");
                                                }).catchError((err) {
                                                  print(err);
                                                  _isInAsyncCall = false;
                                                });
                                              }
                                            } else {
                                              showInSnackBar(
                                                  'Product color required.');
                                            }
                                          } else {
                                            showInSnackBar(
                                                'Product description required.');
                                          }

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double width1 = width * 0.65;
    return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          backgroundColor: Colors.white70,
          title: Text(name_type),
          leading: IconButton(
            icon: Icon(Icons.close),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
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
                if (Product_Id == "" && Product_Id == null) {
                  showInSnackBar("No product found");
                } else {
                  sharedPreferences.setString('product_id', Product_Id);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ItemDetails(Product_Id)));
                }
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

  Future publisSubmit() async {
    if (PubishFlag == 1) {
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
                    if (double.parse(Item_sellingPrice.text) >
                        double.parse(Item_retailPrice.text)) {
                      showInSnackBar(
                          'Product Selling price is Greater than Retails price');
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
                                //"item_picture": UplodImageList,
                                "item_price": Item_retailPrice.text,
                                "item_sale_price": Item_sellingPrice.text,
                                "item_size": Item_Size.text,
                                "item_sold": Item_sold,
                                "item_sub_title": "",
                                "item_title": Item_titile.text,
                                "item_type": "",
                                //"picture": managphoto,
                                "retail_tag": Retail_Tag,
                                "brand_new": New_Wear,
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
                                      .where("product_id",
                                          isEqualTo: Product_Id)
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
                                            doc['brand_new'],
                                          ));
                                        });
                                        showInSnackBar(
                                            'Product successfully Add');
                                        sharedPreferences.setInt(
                                            'draft_flag', null);
                                        sharedPreferences.setString(
                                            'pro_id', "");

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GridItemDetails1(
                                                      item: productList[0],
                                                      exitflag: 1,
                                                    )));
                                      } else {
                                        showInSnackBar(
                                            'No payoutd data found!');
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
                    //
                  }
                }
              }
            }
          }
        }
      }
    }

    /* else {
      if (Item_brand_name == "") {
        showInSnackBar('Please select designer and brand name!');
      } else {
        if (Retail_Tag == "") {
          showInSnackBar('Retail tags Attached? (YES/NO)');
        } else {
          if (Signs_Wear == "") {
            showInSnackBar('Any signs wear? (YES/NO)');
          } else {
            if (Item_Size == "") {
              showInSnackBar('Please add item size!');
            } else {
              if (Item_titile == "") {
                showInSnackBar('Please add item title');
              } else {
                if (Item_retailPrice == "") {
                  showInSnackBar('Please add Retailprice');
                } else {
                  if (Item_shipping_id == "") {
                    showInSnackBar('Please select shipping type.');
                  } else {
                    setState(() {
                      _isInAsyncCall = true;
                    });

                    String Is_cart = "";
                    String Item_sold = "";
                    String Status = "0";

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

                              String Old_profile_name =
                                  'product' + formattedDate + ".jpg";
                              String folder = "product";

                              StorageReference reference = _storage
                                  .ref()
                                  .child(folder)
                                  .child(Old_profile_name);
                              StorageUploadTask uploadTask =
                                  reference.putFile(contents);
                              var dowurl = await (await uploadTask.onComplete)
                                  .ref
                                  .getDownloadURL();

                              if (uploadTask.isComplete) {
                                //  Old_profile_name = Name+formattedDate+".jpg";

                                managphoto = dowurl;
                                UplodImageList.add(dowurl.toString());
                                UplodImageListNames.add(Old_profile_name);

                                await SharedPreferencesHelper.setpic_url(
                                    managphoto);
                              } else {}
                            }
                          }
                        }
                        break;

                      case 2:
                        {
                          for (var i = 0; i < listOfGalleryimage.length; i++) {
                            String imageFile = listOfGalleryimage[i].filePath;
                            if (imageFile == null) {
                            } else {
                              File contents = new File(imageFile);
                              DateTime now = DateTime.now();
                              String formattedDate =
                                  DateFormat('kk:mm:ss EEE d MMM').format(now);

                              String Old_profile_name =
                                  'product' + formattedDate + ".jpg";
                              String folder = "product";

                              StorageReference reference = _storage
                                  .ref()
                                  .child(folder)
                                  .child(Old_profile_name);
                              StorageUploadTask uploadTask =
                                  reference.putFile(contents);
                              var dowurl = await (await uploadTask.onComplete)
                                  .ref
                                  .getDownloadURL();

                              if (uploadTask.isComplete) {
                                //  Old_profile_name = Name+formattedDate+".jpg";

                                managphoto = dowurl;
                                UplodImageList.add(dowurl.toString());
                                UplodImageListNames.add(Old_profile_name);
                                await SharedPreferencesHelper.setpic_url(
                                    managphoto);
                              } else {}
                            }
                          }
                        }
                        break;
                    }

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
                            Item_color,
                            Item_description,
                            Item_sellingPrice,
                            Item_retailPrice,
                            Item_Size,
                            Item_sold,
                            Item_titile,
                            managphoto,
                            Status,
                            Sub_Cat_Name,
                            Sub_Cat_Id,
                            Item_shipping_id,
                            User_id,
                            UplodImageList))
                        .then((_) {
                      setState(() {
                        _isInAsyncCall = false;
                        showInSnackBar('Product successfully Add');
                        sharedPreferences.setStringList(
                            'up_image', UplodImageList);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Add_Address_Screen(
                                      appbar_name: 'Selling Address',
                                      Flag: 3,
                                      exit_Flag: 3,
                                    )));
                      });
                    });
                  }
                }
              }
            }
          }
        }
      }
    }*/
  }

  Future addEditDraft() async {
    String Is_cart = "";
    String Item_sold = "0";
    String Status = "3";
    UplodImageList = new List();

    // switch (cameraFlag) {
    //   case 1:
    //     {
    //       for (var i = 0; i < reversedAnimals.length; i++) {
    //         String imageFile = reversedAnimals[i].toString();
    //         if (imageFile == "") {
    //         } else {
    //           File contents = new File(imageFile);

    //           DateTime now = DateTime.now();
    //           String formattedDate =
    //               DateFormat('kk:mm:ss EEE d MMM').format(now);

    //           String Old_profile_name = 'product' + formattedDate + ".jpg";
    //           String folder = "product";

    //           StorageReference reference =
    //               _storage.ref().child(folder).child(Old_profile_name);
    //           StorageUploadTask uploadTask = reference.putFile(contents);
    //           var dowurl =
    //               await (await uploadTask.onComplete).ref.getDownloadURL();

    //           if (uploadTask.isComplete) {
    //             //  Old_profile_name = Name+formattedDate+".jpg";

    //             managphoto = dowurl;
    //             UplodImageList.add(dowurl.toString());
    //             UplodImageListNames.add(Old_profile_name);
    //             await SharedPreferencesHelper.setpic_url(managphoto);
    //           } else {}
    //         }
    //       }
    //     }
    //     break;

    //   case 2:
    //     {
    //       for (var i = 0; i < listOfGalleryimage.length; i++) {
    //         String imageFile = listOfGalleryimage[i].toString();
    //         if (imageFile == null) {
    //         } else {
    //           File contents = new File(imageFile);
    //           DateTime now = DateTime.now();
    //           String formattedDate =
    //               DateFormat('kk:mm:ss EEE d MMM').format(now);

    //           String Old_profile_name = 'product' + formattedDate + ".jpg";
    //           String folder = "product";

    //           StorageReference reference =
    //               _storage.ref().child(folder).child(Old_profile_name);
    //           StorageUploadTask uploadTask = reference.putFile(contents);
    //           var dowurl =
    //               await (await uploadTask.onComplete).ref.getDownloadURL();

    //           if (uploadTask.isComplete) {
    //             //  Old_profile_name = Name+formattedDate+".jpg";

    //             managphoto = dowurl;
    //             UplodImageList.add(dowurl.toString());
    //             UplodImageListNames.add(Old_profile_name);

    //             await SharedPreferencesHelper.setpic_url(managphoto);
    //           } else {}
    //         }
    //       }
    //     }
    //     break;
    // }

    for (var i = 0; i < listOfImages.length; i++) {
      String imageFile = listOfImages[i].toString();
      if (imageFile == null) {
      } else {
        File contents = new File(imageFile);
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);

        String Old_profile_name = 'product' + formattedDate + ".jpg";
        String folder = "product";

        StorageReference reference =
            _storage.ref().child(folder).child(Old_profile_name);
        StorageUploadTask uploadTask = reference.putFile(contents);
        var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();

        if (uploadTask.isComplete) {
          //  Old_profile_name = Name+formattedDate+".jpg";

          managphoto = dowurl;
          UplodImageList.add(dowurl.toString());
          UplodImageListNames.add(Old_profile_name);

          await SharedPreferencesHelper.setpic_url(managphoto);
        } else {}
      }
    }

    sharedPreferences.setStringList('image', UplodImageList);

    print("Dname: ${this.Dname}");

    if (this.Dname == null || this.Dname == "") {
      db1.collection("product").add({
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
        "brand_new": New_Wear,
        "shipping_id": Item_shipping_id,
        "status": Status,
        "sub_category": Sub_Cat_Name,
        "sub_category_id": Sub_Cat_Id,
        "user_id": User_id,
        "shipping_charge": shipping_charge,
        "packing_type": packing_type,
        "item_pound": Item_pound,
        "item_Ounces": Item_Ounces
      }).then((val) {
        var docId = val.documentID;
        String user_id = sharedPreferences.getString(docId);

        var updateId = {"product_id": docId};

        db1
            .collection("product")
            .document(docId)
            .updateData(updateId)
            .then((val) {
          sharedPreferences.setString('pro_id', docId);
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
    } //If Ended
    else {
      setState(() {
        _isInAsyncCall = false;
      });
    }

    /*db.add_Product(
            '',
            signs_press_text,
            tag_press_Text,
            Cat_Name,
            Cat_Id,
            User_country,
            DateTime.now(),
            Is_cart,
            Item_brand_name,
            Item_color,
            Item_description,
            Item_sellingPrice,
            Item_retailPrice,
            Item_Size,
            Item_sold,
            Item_titile,
            managphoto,
            Status,
            Sub_Cat_Name,
            Sub_Cat_Id,
            Item_shipping_id,
            User_id,
            UplodImageList)
        .then((_) {
      setState(() async {
        setState(() {
          _isInAsyncCall = false;
        });
        // sharedPreferences = await SharedPreferences.getInstance();
        // sharedPreferences.setString('product_id', );
        showInSnackBar('Your draft is saved!');
      });
    });*/
  }

  /* void UpdateDataPost() async {
    setState(() {
      _isInAsyncCall = true;
    });

  */ /*  DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);
  */ /*  String Is_cart = "";
    String Item_sold = "0";
    String Status = "3";

    db
        .updateProduct(Shell_Product_Model(
            Product_Id,
            signs_press_text,
            tag_press_Text,
            Cat_Name,
            Cat_Id,
            User_country,
            formattedDate,
            Is_cart,
            Item_brand_name,
            Item_color,
            Item_description,
            Item_sellingPrice,
            Item_retailPrice,
            Item_Size,
            Item_sold,
            Item_titile,
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

      showInSnackBar('Profile data update successfully');
    });
  }
*/
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _openAddUserDialog() {
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
