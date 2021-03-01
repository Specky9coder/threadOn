import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:custom_multi_image_picker/asset.dart';
// import 'package:custom_multi_image_picker/cupertino_options.dart';
// import 'package:custom_multi_image_picker/picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadon/firebase/firebase_firestore_service.dart';
// import 'package:threadon/image_picker/asset_view.dart';
import 'package:threadon/main.dart';
import 'package:threadon/model/Shipping.dart';
import 'package:threadon/utils/my_navigator.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

class CameraExampleHome extends StatefulWidget {
  List<CameraDescription> cameras;

  CameraExampleHome(this.cameras);

  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome> {
  CameraController controller;
  String imagePath;
  List<Asset> images = List<Asset>();
  List<File> fileImageArray = [];

  List<Asset> assets;
  List<String> ImageList = new List<String>();
  String _error;
  bool _hasFlash = false;
  bool _isOn = false;
  double _intensity = 1.0;
  List<String> listOfItem_fromGallery = [];
  List<String> listofItem_fromCamera = [];
  List<String> listOfImages = [];
  int Flag = 0;
  int CamerFlag = 1;

  var _loadImage = 'images/place_h.png';
  var _myEarth =
      new NetworkImage("http://qige87.com/data/out/73/wp-image-144183272.png");
  bool _checkLoaded = true;

  int _originalHeight;

  String _identifier = '';

  int _originalWidth;
  String Fistsave = "", Secondsave = "", Therdsave = "";

  List<Shipping_model> shipping_list;
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  StreamSubscription<QuerySnapshot> noteSub;
  SharedPreferences sharedPreferences;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  initPlatformState() async {}

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    initPlatformState();
    try {
      onCameraSelected(widget.cameras[0]);
    } catch (e) {
      print(e.toString());
    }
    super.initState();

    noteSub?.cancel();
    noteSub = db.getShippingList().listen((QuerySnapshot snapshot) {
      final List<Shipping_model> notes = snapshot.documents
          .map((documentSnapshot) =>
              Shipping_model.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        this.shipping_list = notes;
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
    controller?.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white70,
        elevation: 0.0,
        title: Text('Camera'),
        actions: <Widget>[
          Center(
            child: GestureDetector(
                child: Container(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500),
                    )),
                onTap: () async {
                  sharedPreferences = await SharedPreferences.getInstance();
                  sharedPreferences.setInt('cameraflag', CamerFlag);

                  if (listOfImages.length < 0) {
                    _showDialog(
                        "Please capture the photo and select photo for storage.");
                  } else {
                    if (listOfImages.length < 3) {
                      _showDialog("Please select minimum 3 photos.");
                    } else {
                      // if (Secondsave == "") {
                      //   _showDialog("Please select minimum 3 photos.");
                      // } else {
                      //   if (Therdsave == "") {
                      //     _showDialog("Please select minimum 3 photos.");
                      //   } else {

                      //   }
                      // }
                      MyNavigator.gotoAdd_Item_4_Screen(
                          context,
                          'Listing Details',
                          listofItem_fromCamera,
                          //  images,
                          listOfItem_fromGallery,
                          '',
                          '');
                    }
                  }

                  // switch (CamerFlag) {
                  //   case 1:
                  //     {
                  //       if (listofItem_fromCamera.length < 0) {
                  //         _showDialog(
                  //             "Please capture the photo and select photo for storage.");
                  //       } else {
                  //         if (Fistsave == "") {
                  //           _showDialog("Please select minimum 3 photos.");
                  //         } else {
                  //           if (Secondsave == "") {
                  //             _showDialog("Please select minimum 3 photos.");
                  //           } else {
                  //             if (Therdsave == "") {
                  //               _showDialog("Please select minimum 3 photos.");
                  //             } else {
                  //               MyNavigator.gotoAdd_Item_4_Screen(
                  //                   context,
                  //                   'Listing Details',
                  //                   listofItem_fromCamera,
                  //                   //  images,
                  //                   listOfItem_fromGallery,
                  //                   '',
                  //                   '');
                  //             }
                  //           }
                  //         }
                  //       }
                  //     }
                  //     break;

                  //   case 2:
                  //     {
                  //       if (listOfItem_fromGallery.length < 0) {
                  //         _showDialog(
                  //             "Please capture the photo and select photo for storage.");
                  //       } else {
                  //         if (Fistsave == null) {
                  //           _showDialog("Please select minimum 3 photos.");
                  //         } else {
                  //           if (Secondsave == null) {
                  //             _showDialog("Please select minimum 3 photos.");
                  //           } else {
                  //             if (Therdsave == null) {
                  //               _showDialog("Please select minimum 3 photos.");
                  //             } else {
                  //               MyNavigator.gotoAdd_Item_4_Screen(
                  //                   context,
                  //                   'Listing Details',
                  //                   listofItem_fromCamera,
                  //                   //images,
                  //                   listOfItem_fromGallery,
                  //                   '',
                  //                   '');
                  //             }
                  //           }
                  //         }
                  //       }
                  //     }
                  //     break;
                  // }
                }),
          )
        ],
        leading: GestureDetector(
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller)),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
              height: 70.0,
              alignment: Alignment.center,
              // child: images.length != 0
              //     ? getImageInGallery()
              //     : _getImageFromFile(listofItem_fromCamera),
              child:

                  // listOfItem_fromGallery.length != 0
                  //  ? getImageInGallery()
                  // : _getImageFromFile(listofItem_fromCamera),
                  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // itemCount: images.length,
                      itemCount: listOfImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            margin: EdgeInsets.all(5.0),
                            child: GestureDetector(
                                child: Container(
                                    height: 60.0,
                                    width: 50.0,
                                    // child: AssetView(index, images[index]),
                                    child:
                                        Image.file(File(listOfImages[index]))),
                                onTap: () {
                                  Flag = 1;
                                }));
                      })),
          _captureControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //  _cameraTogglesRowWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getImageFromFile(List<String> imagePath) {
    CamerFlag = 1;
    List<String> reversedAnimals = imagePath.reversed.toList();
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reversedAnimals.length,
        itemBuilder: (BuildContext context, int index) {
          String first = reversedAnimals[index].toString();
          return Container(
            margin: EdgeInsets.all(5.0),
            child: Image.asset(
              reversedAnimals[index],
              //fit: BoxFit.fill,
              fit: BoxFit.cover,
              width: 50.0,
              height: 60.0,
              //centerSlice: Rect.fromLTRB(2.0, 2.0, 2.0, 2.0),
              //colorBlendMode: BlendMode.srcOver,
              //color: Color.fromARGB(120, 20, 10, 40),
            ),
          );
          // if (first == "") {

          // } else {
          //   Fistsave = first;
          //   Secondsave = reversedAnimals[1].toString();
          //   Therdsave = reversedAnimals[2].toString();
          //   return Container(
          //       margin: EdgeInsets.all(5.0),
          //       child: GestureDetector(
          //           child: Image.file(
          //             File(
          //               reversedAnimals[index],
          //             ),
          //             fit: BoxFit.cover,
          //             width: 50.0,
          //             height: 60.0,
          //           ),
          //           onTap: () {
          //             setState(() {
          //               //  _showAlert(reversedAnimals[index].toString());
          //             });
          //           }));
          // }
        });
    /*
  */
  }

  Widget getImageInGallery() {
    CamerFlag = 2;
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        // itemCount: images.length,
        itemCount: listOfItem_fromGallery.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.all(5.0),
              child: GestureDetector(
                  child: Container(
                      height: 60.0,
                      width: 50.0,
                      // child: AssetView(index, images[index]),
                      child: Image.file(File(listOfItem_fromGallery[index]))),
                  onTap: () {
                    Flag = 1;
                  }));
        });
    /*
  */
  }

  Widget _captureControlRowWidget() {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            onTap: () {
              _captureImage();
            },
            child: Container(
              padding: EdgeInsets.all(4.0),
              child: Image.asset(
                'images/ic_shutter_1.png',
                width: 72.0,
                height: 72.0,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  child: SizedBox(
                height: 52.0,
                width: 52.0,
                child: IconButton(
                  icon: new Icon(Icons.image, color: Colors.grey),
                  onPressed: () {
                    //  print("hrre");
                    loadAssets();
                  },
                ),
              )),
            ),
          )),
    ]);
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) await controller.dispose();
    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showMessage('Camera Error: ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) setState(() {});
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          listofItem_fromCamera.add(imagePath);
          listOfImages.add(imagePath);
          _getImageFromFile(listofItem_fromCamera);
          showMessage('Picture saved to $filePath');
          // setCameraResult();
        }
      }
    });
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      onCameraSelected(widget.cameras[0]);
    }

    return Row(children: toggles);
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

/*  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }*/
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/thredon';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    print(message);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');

  ///

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
      // images = List<Asset>();
    });

    List resultList;
    String error;


FilePickerResult result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'pdf', 'doc'],
        );

 List<File> files = [];
if(result != null) {
  for (String filepath in result.paths){
    files.add(File(filepath));
  }
  //  files = result.paths.map((path) => File(path));
}


    // List<File> files = await FilePicker.getMultiFile(
    //   type: FileType.custom,
    //   allowedExtensions: ['jpg', 'pdf', 'doc'],
    // );

    for (File file in files) {
      listOfItem_fromGallery.add(file.path);
      listOfImages.add(file.path);
    }

    if (!mounted) return;

    setState(() {
      // images = resultList;
      // listOfItem_fromGallery = files;
      // print("images : $images");
      // print("listOfItem_fromGallery : $listOfItem_fromGallery");
      // if (images.length >= 8) {
      getImageInGallery();
      // } else {
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // images.add(Asset(_identifier, _originalWidth, _originalHeight));
      // getImageInGallery();
      // }
      //images.add('','',0,0,'','');

      if (error == null) _error = 'No Error Dectected';
    });

    return fileImageArray;
  }

  /*



  void _showAlert(String listname) {
    AlertDialog dialog = new AlertDialog(
      content: new Container(
        width: 260.0,
        height: 230.0,
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
                    alignment: Alignment.center,
                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Alert',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // dialog centre
               new Expanded(
              child: new Container(
                  alignment: Alignment.center,
                  child: new TextField(
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: new EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                      hintText: '',
                      hintStyle: new TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.0,
                      ),
                    ),
                  )),
              flex: 2,
            ),

            Divider(
              height: 10.0,
            ),
            // dialog bottom
            new Expanded(
                child: GestureDetector(
                  child: new Container(
                    alignment: Alignment.center,
                    padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'DELETE',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if(Flag == 1){
                        images.remove(listname);
                        images.join(',');
                        _getImageFromAsset();
                      }
                      else{
                        listofItem_fromCamera.remove(listname);
                        listofItem_fromCamera.join(',');
                        _getImageFromFile(listofItem_fromCamera);
                      }

                    });

                  },
                )),
          ],
        ),
      ),
    );

    showDialog(context: context, child: dialog);
  }
*/
  void _showDialog(String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Error ",
            style: TextStyle(color: Colors.red),
          ),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
