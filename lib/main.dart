import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:threadon/pages/Add_Address_screen.dart';
import 'package:threadon/pages/Add_Item_Screen_3_Camera.dart';
import 'package:threadon/pages/category.dart';
import 'package:threadon/pages/department_detail.dart';
import 'package:threadon/pages/departments_screen.dart';
import 'package:threadon/pages/home_screen.dart';
import 'package:threadon/pages/login_screen.dart';
import 'package:threadon/pages/main_screen.dart';
import 'package:threadon/pages/privacy.dart';
import 'package:threadon/pages/profile_screen.dart';
import 'package:threadon/pages/reset_password.dart';
import 'package:threadon/pages/signup_screen.dart';
import 'package:threadon/pages/slider_screen.dart';
import 'package:threadon/pages/splesh_screen.dart';
import 'package:threadon/pages/terms_service.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    //logError(e.code, e.description);
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.white,
          primaryColorDark: Colors.black,
          accentColor: Colors.black,
          brightness: Brightness.light),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        "/home": (BuildContext context) => HomeScreen(),
        "/listadecompras": (BuildContext context) => LoginPage(),
        "/listadecompra": (BuildContext context) => SignupPage(),
        "/slider": (BuildContext context) => ImageCarousel(),
        "/mainadecompras": (BuildContext context) => MyHome(),
        "/category-page": (BuildContext context) => CategoryScreen(),
        "/departments": (BuildContext context) => DepartmentScreen(),
        "/profile": (BuildContext context) => ProfileScreen(),
        "/departmentss": (BuildContext context) => DepartmentsScreen(),
        "/terms": (BuildContext context) => TermsServiceScreen(),
        "/privacy": (BuildContext context) => PrivacyScreen(),
        "/resetpassword": (BuildContext context) => Reset_PasswordPage(),
        "/address_screen": (BuildContext context) => Add_Address_Screen(),
        "/view_screen": (BuildContext context) => Add_Address_Screen(),
        "/CAMERA_SCREEN": (BuildContext context) => CameraExampleHome(cameras),
      },
    ),
  );
  /*Text('We can\'t reach our network right now.',style: TextStyle(color: Colors.white),),
  Text('Please check your connection.',style: TextStyle(color: Colors.white)),*/
}
