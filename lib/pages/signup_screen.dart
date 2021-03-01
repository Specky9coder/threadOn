import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/FirebaseDatabaseUtil.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
import 'package:threadon/model/Signup.dart';
import 'package:threadon/pages/login_screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/utils/HexColor.dart';
import 'package:threadon/utils/ModalProgressHUD.dart';
import 'package:threadon/utils/my_navigator.dart';
import 'package:http/http.dart' as http;
// import 'package:device_id/device_id.dart';
import 'package:device_info/device_info.dart';
import 'package:random_string/random_string.dart';

class SignupPage extends StatefulWidget {
  static String tag = 'listadecompra';

  @override
  _SignupPageState createState() => new _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String _message = 'Log in/out by pressing the buttons below.';

  String device = "";
  var facebookLogin = FacebookLogin();
  bool isLoggedIn = false;
  var profileData;
  String _email, FbId = "";
  var profile_image;
  String fbName;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;

  final Username = TextEditingController(text: '');
  final Password = TextEditingController();
  final Name = TextEditingController();
  final Status = TextEditingController(text: '0');
  final Profile_picture = TextEditingController();
  final Latlong = TextEditingController(text: '');
  final Following = TextEditingController(text: '0');
  final Followers = TextEditingController(text: '0');
  final Facebook_id = TextEditingController(text: '');
  final Email_id = TextEditingController();
  var Device_id = TextEditingController();
  final Device = TextEditingController(text: '0');
  final Cover_picture = TextEditingController(text: '');
  final Country = TextEditingController(text: '');
  final About_me = TextEditingController(text: '');
  double latitude = 0.0; // Latitude, in degrees
  double longitude = 0.0;

  Signup_Modle signup_modle;

  String Emilid;
  String _password;
  String _firstname;
  String _deviceid = 'Unknown';
  String Uni_code = '';
  String token_id = '';

  Color color2 = HexColor("#3b5998");
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  SharedPreferences sharedPreferences;
  bool _isInAsyncCall = false;

  /* TextEditingController username = new TextEditingController();
  TextEditingController emile = new TextEditingController();
  TextEditingController password = new TextEditingController();

*/

  /* Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((location) {
      if (location != null) {
        print("Location: ${location.latitude},${location.longitude}");
       // locationRepository.store(location);
        latitude = location.latitude;
        longitude = location.longitude;
      }


      return location;
    });
  }*/

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId;
    }
  }

  Future<void> initDeviceId() async {
    String deviceid;
    // deviceid = await DeviceId.getID;
    deviceid = await _getId();

    if (!mounted) return;

    setState(() {
      _deviceid = deviceid;
    });
  }
/*
  Future<void> initDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    _deviceid = androidInfo.id;
    device = "0";
    print('Running on ${androidInfo.model} + ${device}');

    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    device = "1";
    print('Running on1 ${iosInfo.utsname.machine} + ${device}');
    _deviceid = androidInfo.id;
  //  locateUser();
  }*/

  void LocationplatformInit() {}

  Future handleSubmit() async {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();

      var words = Name.text.split(" ");
      print(words);

      Uni_code = words[0].toString() + randomAlphaNumeric(5);
      setState(() {
        _isInAsyncCall = true;
      });

      CollectionReference ref = Firestore.instance.collection('users');
      QuerySnapshot eventsQuery =
          await ref.where("email_id", isEqualTo: Email_id.text).getDocuments();

      if (eventsQuery.documents.isEmpty) {
        var db1 = Firestore.instance;
        noteSub?.cancel();
        db1.collection("users").add({
          "about_me": "",
          "country": "",
          "cover_picture": Cover_picture.text,
          "device": device,
          "device_id": _deviceid,
          "email_id": Email_id.text,
          "facebook_id": FbId,
          "followers": "0",
          "following": "0",
          "latlong": new GeoPoint(latitude, longitude),
          "name": Name.text,
          "password": Password.text,
          "profile_picture": Profile_picture.text,
          "refer_code": Uni_code,
          "status": "0",
          "username": Username.text,
          "token_id": token_id,
          "date": DateTime.now(),
        }).then((val) {
          sharedPreferences.setString('user_email', Email_id.text);
          var docId = val.documentID;
          // String user_id = sharedPreferences.getString(docId);

          var updateId = {"user_id": docId};
          sharedPreferences.setString('user_id', docId);

          db1
              .collection("users")
              .document(docId)
              .updateData(updateId)
              .then((val) {
            db1.collection("wallet").add({
              "available_amount": "0",
              "date": DateTime.now(),
              "lifetime_earning": "0",
              'pending_amount': "0",
              'site_credit': "0",
              'user_id': docId
            }).then((val) {
              var docId = val.documentID;
              var updateId = {"wallet_id": docId};

              db1
                  .collection("wallet")
                  .document(docId)
                  .updateData(updateId)
                  .then((val) {
                Navigator.of(context).pushAndRemoveUntil(
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new MyHome()),
                    (Route<dynamic> route) => false);
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
      } else {
        eventsQuery.documents.forEach((doc) async {
          setState(() {
            _isInAsyncCall = false;
          });
          showInSnackBar('This email id already exists.');
        });
      }
    } else {
      showInSnackBar('Please fix the errors in red before submitting.');
    }
  }

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
        setState(() {
          _showDialog1();
        });
        break;
      default:
        setState(() {
          _showDialog1();
        });
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
              child: new Text("Cancel"),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new SplashScreen()),
                      (Route<dynamic> route) => false);
                });
              },
            ),
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
    super.dispose();
    noteSub?.cancel();
  }

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  TextStyle style = TextStyle(fontSize: 16.0);

  @override
  Widget build(BuildContext context) {
    final loginButon = Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.black,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 13.0, 20.0, 13.0),
        onPressed: () {
          handleSubmit();
        },
        child: Text("Sign Up",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, color: Colors.white)),
      ),
    );

    final facbookButon = Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(10.0),
      color: color2,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 13.0, 20.0, 13.0),
        onPressed: () {
          _login();
        },
        child: Text("Connect with Facebook",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, color: Colors.white)),
      ),
    );

    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white70,
        // title: new Text("Join"),
        // backgroundColor: Colors.white70,
//        automaticallyImplyLeading: false,
      ),
      body: ModalProgressHUD(
        child: Container(
          color: Colors.white70,
          child: ListView(children: <Widget>[
            Container(
              color: Colors.white70,

//          padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: new Column(
                  children: <Widget>[
                    const SizedBox(height: 15.0),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Create new account',
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    TextFormField(
                      controller: Name,
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
                          icon: Icon(
                            Icons.person,
                            color: Colors.black38,
                          ),
                          hintText: 'Full name',
                          labelText: 'Full name',
                          labelStyle: TextStyle(color: Colors.black54)),
                      keyboardType: TextInputType.text,
                      validator: (val) =>
                          val.length < 1 ? 'Enter full name' : null,
                      onSaved: (val) => _firstname = val,
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: Email_id,
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
                          icon: Icon(
                            Icons.email,
                            color: Colors.black38,
                          ),
                          hintText: 'Your email address',
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.black54)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          !val.contains('@') ? 'Not a valid email.' : null,
                      onSaved: (val) => _email = val,
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: Password,
                      obscureText: true,
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
                          icon: Icon(
                            Icons.lock,
                            color: Colors.black38,
                          ),
                          hintText: 'Your password',
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.black54)),
                      validator: (val) =>
                          val.length < 6 ? 'Password too short.' : null,
                      onSaved: (val) => _password = val,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "have an account? ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                          new GestureDetector(
                              onTap: () {
                                MyNavigator.goToLogin(context);
                              },
                              child: new Text(
                                '   Log In',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.red,
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 35.0,
                    ),
                    new Container(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: loginButon,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(children: <Widget>[
                        Expanded(child: Divider()),
                        Text("OR"),
                        Expanded(child: Divider()),
                      ]),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    new Container(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: facbookButon,
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "By tapping Submit above you are agreeing to the ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 0.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new GestureDetector(
                              onTap: () {
                                MyNavigator.gotoWebViewScreen(context,
                                    'Terms of Service', "threadon.com/terms");
                              },
                              child: new Text(
                                ' Terms of Service',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.red,
                                ),
                              )),
                          Text(
                            " and",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                            ),
                            maxLines: 2,
                          ),
                          new GestureDetector(
                              onTap: () {
                                MyNavigator.gotoWebViewScreen(
                                    context,
                                    'Privacy Policy',
                                    "threadon.com/privacy.html");
                              },
                              child: new Text(
                                ' Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.red,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  Future<Null> _login() async {
    setState(() {
      _isInAsyncCall = true;
    });
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');

        FbId = facebookLoginResult.accessToken.userId;
        var profile = json.decode(graphResponse.body);
        Uni_code = profile['first_name'].toString() + randomAlphaNumeric(5);
        fbName = profile['name'].toString();
        Emilid = profile['email'].toString();
        profile_image = profile['picture']['data']['url'];
        print(profile.toString());

        FacbookLogin();
        break;

      /* case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('''
         Logged in!

         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        break;*/
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        _isInAsyncCall = false;
        break;
      case FacebookLoginStatus.error:
        _isInAsyncCall = false;
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${facebookLoginResult.errorMessage}');
        break;
    }
  }

  void FacbookLogin() async {
    final FormState form = formKey.currentState;

    Firestore.instance
        .collection('users')
        .where("facebook_id", isEqualTo: FbId)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) async {
        sharedPreferences = await SharedPreferences.getInstance();
        //Profile_image = profileData['picture']['data']['url'];
        isLoggedIn = true;
        sharedPreferences.setBool('check', isLoggedIn);
        sharedPreferences.setString('UserName', doc['name']);
        sharedPreferences.setString('loginname', doc["email_id"]);
        sharedPreferences.setString('profile_image', doc["profile_picture"]);
        sharedPreferences.setString('facebook_id', doc["facebook_id"]);
        sharedPreferences.setString('followers', doc["followers"]);
        sharedPreferences.setString('following', doc["following"]);
        sharedPreferences.setString('user_id', doc["user_id"]);
        sharedPreferences.setString('username', doc["username"]);
        sharedPreferences.setString('password', doc["password"]);
        sharedPreferences.setString('about_me', doc["about_me"]);
        sharedPreferences.setString('country', doc["country"]);
        sharedPreferences.setString('cover_picture', doc["cover_picture"]);
        sharedPreferences.setString('device_id', doc["device_id"]);
        sharedPreferences.setString('refer_code', doc['refer_code']);
        sharedPreferences.setString('user_email', doc["email_id"]);

        _isInAsyncCall = false;
        // showInSnackBar('Login successfully');
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (BuildContext context) => new MyHome()),
            (Route<dynamic> route) => false);
        form.reset();
      });
      if (data.documents.length == 0) {
        FBDataPostServer();
      }
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });

    // Logindone();
  }

  FBDataPostServer() async {
    String Username = "";
    String Password = "";
    String Status = "0";
    String Latlong = "";
    String Following = "0";
    String Followers = "0";
    String Device = "0";
    String Cover_picture = "";
    String Country = "";
    String About_me = "";

    var db1 = Firestore.instance;
    noteSub?.cancel();

    db1.collection("users").add({
      "about_me": "",
      "country": "",
      "cover_picture": Cover_picture,
      "device": device,
      "device_id": _deviceid,
      "email_id": Emilid,
      "facebook_id": FbId,
      "followers": "0",
      "following": "0",
      "latlong": new GeoPoint(latitude, longitude),
      "name": fbName,
      "password": Password,
      "profile_picture": profile_image,
      "refer_code": Uni_code,
      "status": "0",
      "username": Username,
      "token_id": token_id,
      "date": DateTime.now(),
    }).then((val) {
      var docId = val.documentID;
      String user_id = sharedPreferences.getString(docId);

      var updateId = {"user_id": docId};

      db1.collection("users").document(docId).updateData(updateId).then((val) {
        sharedPreferences.setString('user_email', Emilid);
        db1.collection("wallet").add({
          "available_amount": "0",
          "date": DateTime.now(),
          "lifetime_earning": "0",
          'pending_amount': "0",
          'site_credit': "0",
          'user_id': user_id
        }).then((val) {
          var docId = val.documentID;
          var updateId = {"wallet_id": docId};

          db1
              .collection("wallet")
              .document(docId)
              .updateData(updateId)
              .then((val) {
            Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(
                    builder: (BuildContext context) => new MyHome()),
                (Route<dynamic> route) => false);
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

    _navigator();
  }

  _navigator() {
    if (fbName.length != 0) {
      getCredential();
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(
              builder: (BuildContext context) => new MyHome()),
          (Route<dynamic> route) => false);
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          child: new CupertinoAlertDialog(
            content: new Text(
              "username or password \ncan't be empty",
              style: new TextStyle(fontSize: 16.0),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text("OK"))
            ],
          ));
    }
  }

  Future<Null> _logOut() async {
    await facebookLogin.logOut();
    _showMessage('Logged out.');
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    token_id = sharedPreferences.getString("token_id");
    // profile_image = profileData['picture']['data']['url'];
    // profile_image = Image.asset("images/placeholder_face.png");
    sharedPreferences.setBool('check', isLoggedIn);
    sharedPreferences.setString('UserName', fbName);
    sharedPreferences.setString('loginname', _email);
    // sharedPreferences.setString('profile_image', profile_image);
    sharedPreferences.setString('emile', Emilid);

    initDeviceId();
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}

/*    new Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        margin: const EdgeInsets.only(top: 35.0),
                        alignment: Alignment.center,
                        decoration: new BoxDecoration(color: Colors.black),
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new OutlineButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(
                                        2.0)),
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
                                              color: Colors.white,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),*/
/*  Container(
                        padding: EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 20.0),
                        child: new Divider(color: Colors.black),
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: new Padding(
                              padding: new EdgeInsets.symmetric(vertical: 20.0),
                              child: new RaisedButton(
                                  onPressed: _login,
                                  color: Colors.black,
                                  padding: new EdgeInsets.only(top: 15.0,
                                      bottom: 15.0,
                                      left: 25.0,
                                      right: 25.0),
                                  splashColor: Colors.grey,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(
                                          10.0)),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        "Connect with Facebook",
                                        style: new TextStyle(
                                            color: new Color(0xFFFFFFFF),
                                            fontSize: 18.0),
                                      ),
                                    ],
                                  )))
                      ),*/
