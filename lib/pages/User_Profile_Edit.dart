import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/image_picker/image_picker_handler.dart';
import 'package:threadon/model/Signup.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/ChatMessage.dart';
import 'package:threadon/pages/Coman_SearchList_Screen.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'package:permission/permission.dart';
import 'package:flutter/services.dart';

class Edit_Profile extends StatefulWidget {
  String appbar_name;
  String profileimage;

  Edit_Profile({Key key, this.appbar_name, this.profileimage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      user_edit_profile(appbar_name, profileimage);
}

class user_edit_profile extends State<Edit_Profile>
    with TickerProviderStateMixin, ImagePickerListener {
  String _platformVersion;
  Permission permission;
  String tool_name1;

  File _image;
  File _image_cover;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  TextEditingController _name,
      _emailid,
      _country,
      _about_me,
      _password,
      _username;

  //String Name="",email_id="",profile_image="",facebook_id="",user_id="",about_me="",country="",cover_picture="",password="",username="@",followers ="",following="",device_id="";
  String profileImage1, Name;
  String loginName;
  String EmileId, user_id;
  user_edit_profile(this.tool_name1, this.profileImage1);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  FirebaseStorage _storage;
  SharedPreferences sharedPreferences;
  bool _isInAsyncCall = false;
  bool hidePassword = false;
  String Old_profile_name = "", Old_cover_pic = "", profile_image = "";

  int Flag = 0;
  String refer_code = '';
  String Carttotal = "0", cover_picture = "";
  bool passwordVisible = true;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _storage = FirebaseStorage.instance;
    getCredential();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
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

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();

    user_id = sharedPreferences.getString('user_id');
    if (user_id == null) {
      user_id = "";
    }
    refer_code = sharedPreferences.getString('refer_code');

    CollectionReference ref = Firestore.instance.collection('users');
    QuerySnapshot eventsQuery =
        await ref.where("user_id", isEqualTo: user_id).getDocuments();

    if (eventsQuery.documents.isEmpty) {
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      eventsQuery.documents.forEach((doc) async {
        Name = doc['name'];
        _name = TextEditingController(text: doc['name']);
        _emailid = TextEditingController(text: doc['email_id']);

        _country = TextEditingController(text: doc['country']);
        _about_me = TextEditingController(text: doc['about_me']);

        _password = TextEditingController(text: doc['password']);

        _username = TextEditingController(text: doc['username']);

        profile_image = doc['profile_picture'];
        cover_picture = doc['cover_picture'];
        Old_profile_name = doc['profile_picture'];
      });

      setState(() {
        _isInAsyncCall = false;
      });
    }
  }

  void UpdateDataPost() async {
    var db1 = Firestore.instance;
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();

      var up1 = {
        'profile_picture': profile_image,
        'cover_picture': cover_picture,
        'name': _name.text,
        'email_id': _emailid.text,
        'country': _country.text,
        'about_me': _about_me.text,
      };

      db1.collection("users").document(user_id).updateData(up1).then((val) {
        print("sucess");
        setState(() {
          _isInAsyncCall = false;
        });

        showInSnackBar('Profile data update successfully');
      }).catchError((err) {
        print(err);
        _isInAsyncCall = false;
      });
    } else {
      _isInAsyncCall = false;
    }
  }

  bool _isEnabled = false;

  requestPermissions() async {
    final res = await Permission.requestPermissions(
        [PermissionName.Camera, PermissionName.Storage]);
    res.forEach((permission) {
      imagePicker.showDialog(context);
    });
  }

/*
  requestPermission() async {
    final res = await Permission.requestSinglePermission(PermissionName.Calendar);
    print(res);
  }*/

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double width12 = width;

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(tool_name1),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
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
            onPressed: () => MyNavigator.gotoAddItemScreen(context),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatMessageList()));
            },
          ),
          new IconButton(
            icon: new Icon(Icons.perm_identity),
            tooltip: 'Me',
            onPressed: () => MyNavigator.goToProfile(context),
          ),
        ],

//        automaticallyImplyLeading: false,
      ),
      body: ModalProgressHUD(
        child: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(
              left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 5.0, top: 10.0, bottom: 10.0),
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        'Public Profile',
                        style: TextStyle(
                            fontSize: 17.0, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                new Row(
                  children: <Widget>[
                    new GestureDetector(
                      onTap: () {
                        Flag = 0;
                        imagePicker.showDialog(context);
                      },
                      child: _image == null
                          ? new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  alignment: Alignment.topLeft,
                                  height: 80.0,
                                  width: 80.0,
                                  margin: EdgeInsets.only(left: 5.0),
                                  decoration: new BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black54, width: 2.0),
                                    borderRadius: new BorderRadius.all(
                                        const Radius.circular(70.0)),
                                  ),
                                  child: profile_image == ""
                                      ? new CircleAvatar(
                                          radius: 60.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage: AssetImage(
                                              'images/placeholder_face.png'),
                                        )
                                      : new CircleAvatar(
                                          radius: 60.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage:
                                              NetworkImage(profile_image),
                                        ),
                                ),
                                /* new Center(
                        //  child: new Image.asset("assets/photo_camera.png"),
                        child: Icon(Icons.perm_identity),
                      ),*/
                              ],
                            )
                          : new Container(
                              height: 80.0,
                              width: 80.0,
                              decoration: new BoxDecoration(
                                color: const Color(0xff7c94b6),
                                image: new DecorationImage(
                                  image: new ExactAssetImage(_image.path),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                    color: Colors.black54, width: 2.0),
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(80.0)),
                              ),
                            ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left: 5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Profile Photo',
                              style: TextStyle(fontSize: 10.0)),
                          Text('Upload a profile photo',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              )),
                          Text('Use your camera to get the perfect shot',
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.black)),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 5.0, top: 10.0, bottom: 10.0),
                  alignment: Alignment.topLeft,
                  child: new Column(
                    children: <Widget>[
                      new Text('Cover Photo', style: TextStyle(fontSize: 16.0))
                    ],
                  ),
                ),
                new GestureDetector(
                  onTap: () {
                    Flag = 1;
                    imagePicker.showDialog(context);
                  },
                  child: _image_cover == null
                      ? new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 150.0,
                              width: width12 / 1.1,
                              alignment: Alignment.center,
                              padding:
                                  new EdgeInsets.only(left: 16.0, bottom: 8.0),
                              decoration: new BoxDecoration(
                                border: Border.all(
                                    color: Colors.black54, width: 2.0),
                                image: cover_picture == ""
                                    ? new DecorationImage(
                                        image: new AssetImage("images/map.png"),
                                        fit: BoxFit.cover,
                                      )
                                    : new DecorationImage(
                                        image: new NetworkImage(cover_picture),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),

                            /*new Container(
                            alignment: Alignment.center,
                            height: 150.0,
                            width: width12/1.1,
                            margin: EdgeInsets.only(left: 5.0),
                            decoration: new BoxDecoration(
                              border:
                              Border.all(color: Colors.red, width: 2.0),
                            ),
                            child: new Image.network(cover_picture,fit: BoxFit.fitWidth,),
                          ),*/
                            /*new Container(
                            alignment: Alignment.topCenter,
                            height: 150.0,
                            width: width12/1.1,

                            child: Image.network(cover_picture,
                              fit: BoxFit.cover,
                            ),

                            decoration: new BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2.0),
                            ),
                          ),*/
                            /* new Center(
                        //  child: new Image.asset("assets/photo_camera.png"),
                        child: Icon(Icons.perm_identity),
                      ),*/
                          ],
                        )
                      : new Container(
                          height: 150.0,
                          width: width12 / 1.1,
                          decoration: new BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: new DecorationImage(
                              image: new ExactAssetImage(_image_cover.path),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(color: Colors.red, width: 2.0),
                          ),
                        ),
                ),
                Container(
//          padding: const EdgeInsets.all(10.0),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 5.0, top: 5.0),
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        'Personalize your closet by adding a cover photo',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
//          padding: const EdgeInsets.all(10.0),

                          margin: EdgeInsets.all(10.0),
                          child: new Column(
                            children: <Widget>[
                              new TextFormField(
                                controller: _name,
                                keyboardType: TextInputType.text,
                                // Use email input type for emails.
                                // initialValue: Username,
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    labelText: 'Name',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                            ],
                          ),
                        ),
                        /* Container(
//          padding: const EdgeInsets.all(10.0),

                   margin: EdgeInsets.all(10.0),
                   child: new Column(
                     children: <Widget>[
                       new TextFormField(
                           controller: _username,

                           keyboardType: TextInputType.text,
                           // Use email input type for emails.
                           decoration: new InputDecoration(
                             labelText: 'Username',
                           )),
                     ],
                   ),
                 ),*/
                        Container(
//          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Column(
                            children: <Widget>[
                              new Text(
                                'You can only reserve your username once',
                                maxLines: 2,
                                style: TextStyle(fontSize: 13.0),
                              ),
                            ],
                          ),
                        ),
                        Container(
//          padding: const EdgeInsets.all(10.0),

                          margin: EdgeInsets.all(10.0),
                          child: new Column(
                            children: <Widget>[
                              new TextFormField(
                                controller: _country,
                                keyboardType: TextInputType.text,
                                // Use email input type for emails.
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    labelText: 'Location',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                            ],
                          ),
                        ),
                        Container(
//          padding: const EdgeInsets.all(10.0),

                          margin: EdgeInsets.all(10.0),
                          child: new Column(
                            children: <Widget>[
                              new TextFormField(
                                controller: _about_me,
                                keyboardType: TextInputType.text,
                                maxLines: 4,
                                // Use email input type for emails.
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    labelText: 'Bio',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                            ],
                          ),
                        ),
                        Container(
//          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Column(
                            children: <Widget>[
                              new Text(
                                'Tell us a bit about yourself',
                                maxLines: 2,
                                style: TextStyle(fontSize: 13.0),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30.0, left: 10.0),
                          child: new Row(
                            children: <Widget>[
                              Text(
                                "Private Info",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
//          padding: const EdgeInsets.all(10.0),

                          margin: EdgeInsets.all(10.0),
                          child: new Column(
                            children: <Widget>[
                              new TextFormField(
                                controller: _emailid,
                                keyboardType: TextInputType.text,
                                enabled: _isEnabled,

                                // Use email input type for emails.
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black87,
                                          style: BorderStyle.solid),
                                    ),
                                    labelText: 'Email Address',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),

                                validator: (val) => !val.contains('@')
                                    ? 'Not a valid email.'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        Container(
//          padding: const EdgeInsets.all(10.0),

                          margin: EdgeInsets.all(10.0),
                          child: new Column(
                            children: <Widget>[
                              new TextFormField(
                                controller: _password,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                enabled: _isEnabled,
                                enableInteractiveSelection: false,

                                // Use email input type for emails.
                                decoration: new InputDecoration(
                                  labelText: 'Password',

                                  /* suffixIcon: Padding(
                        padding: EdgeInsetsDirectional.zero,
                        child: GestureDetector(
                          child: Icon(
                            hidePassword ? Icons.visibility : Icons.visibility_off,
                            size: 20.0,
                            color: Colors.black,
                          ),
                        ),
                      ),*/
                                ),
                                validator: (val) => val.length < 6
                                    ? 'Password too short.'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.all(10.0),
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        String data = _password.text.toString();
                        sharedPreferences.setString('password', data);
                        MyNavigator.gotoChangePassword(
                            context, 'Change password');
                      },
                      child: Text(
                        'CHANGE PASSWORD',
                        style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      ),
                    )),
                new Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 40.0),
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
                          onPressed: () => handleSubmit(),
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
                                    "Submit",
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
            ),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 1,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  String _imageUrl;
  bool _loaded = false;

  _setImageData(dynamic url) {
    setState(() {
      _loaded = true;
      _imageUrl = url;
    });
  }

  _setError() {
    setState(() {
      _loaded = false;
    });
  }

  Future<String> _ProfileSaveImage(String foldername, File imagepath) async {
    if (Old_profile_name != "") {
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(Old_profile_name);
      // storageReference.delete().then(_setImageData).catchError((error)

      storageReference.delete().then(_setImageData).catchError((error) {
        // Uh-oh, an error occurred!
        // showInSnackBar('Uh-oh, an error occurred');
      });
      /* storageReference.delete().addOnSuccessListener(new OnSuccessListener<Void>() {
      @Override
      public void onSuccess(Void aVoid) {
      // File deleted successfully
      Log.d(TAG, "onSuccess: deleted file");
      }
      }).addOnFailureListener(new OnFailureListener() {
      @Override
      public void onFailure(@NonNull Exception exception) {
      // Uh-oh, an error occurred!
      Log.d(TAG, "onFailure: did not delete file");
      }
      });
      
      
      StorageReference reference1 = _storage.ref().child(foldername).child(Old_profile_name);

      reference1.delete().then(_setImageData).catchError((error) {
        // Uh-oh, an error occurred!
        showInSnackBar('Uh-oh, an error occurred');

      });*/
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/mm/yyyy kk:mm:ss a').format(now);

    Old_profile_name = DateTime.now().toString() + ".jpg";
    String foldername1 = "profile";

    String profil = Name + Old_profile_name;
    StorageReference reference = _storage.ref().child(foldername).child(profil);
    StorageUploadTask uploadTask = reference.putFile(imagepath);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();

    if (uploadTask.isComplete) {
      //Old_profile_name = _name.text+formattedDate+".jpg";

      profile_image = dowurl.toString();
      if (_image_cover == null) {
        UpdateDataPost();
      } else {
        _CoverSaveImage('profile', _image_cover);
      }
    } else {}
  }

  Future<String> _CoverSaveImage(String foldername, File imagepath) async {
    if (Old_cover_pic != "") {
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(Old_cover_pic);
      // storageReference.delete().then(_setImageData).catchError((error)

      storageReference.delete().then(_setImageData).catchError((error) {
        // Uh-oh, an error occurred!
        //   showInSnackBar('Uh-oh, an error occurred');
      });
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/mm/yyyy kk:mm:ss a').format(now);

    Old_cover_pic = DateTime.now().toString() + ".jpg";
    String foldername1 = "profile";

    String profil = Name + Old_cover_pic;
    StorageReference reference =
        _storage.ref().child(foldername1).child(profil);
    StorageUploadTask uploadTask = reference.putFile(imagepath);

    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    if (uploadTask.isComplete) {
      cover_picture = dowurl.toString();
      UpdateDataPost();
    } else {}
  }

  void handleSubmit() async {
    setState(() {
      _isInAsyncCall = true;
    });

    if (_image == null) {
      if (_image_cover == null) {
        UpdateDataPost();
      } else {
        _CoverSaveImage('profile', _image_cover);
      }
    } else {
      _ProfileSaveImage('profile', _image);
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  userImage(File _image) {
    setState(() {
      if (Flag == 0) {
        this._image = _image;
      } else {
        this._image_cover = _image;
      }
    });
  }
}
