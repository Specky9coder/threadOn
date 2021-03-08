// import 'package:custom_multi_image_picker/asset.dart';
// import 'package:multi_image_picker/asset.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:threadon/model/Shell_Product.dart';
import 'package:threadon/model/Shipping.dart';

import 'package:threadon/pages/Add_Address_screen.dart';
import 'package:threadon/pages/Add_Item_Screen_1.dart';
import 'package:threadon/pages/Add_Item_Screen_2.dart';
import 'package:threadon/pages/Add_Item_Screen_3.dart';
import 'package:threadon/pages/Add_Item_Screen_4_Listing_details.dart';
import 'package:threadon/pages/Add_Payment_screen.dart';
import 'package:threadon/pages/Add_Share_List.dart';
import 'package:threadon/pages/AddressBook_screen.dart';
import 'package:threadon/pages/Brand_Search_Screen.dart';
import 'package:threadon/pages/Cart_screen.dart';
import 'package:threadon/pages/Change_Password.dart';
import 'package:threadon/pages/Coman_WebView_Screen.dart';
import 'package:threadon/pages/Company_screen.dart';
import 'package:threadon/pages/Compare_screen.dart';
import 'package:threadon/pages/Favorites_screen.dart';

import 'package:threadon/pages/Fliter1_screen.dart';
import 'package:threadon/pages/GridItemDetails.dart';
import 'package:threadon/pages/Lable_Screen.dart';
import 'package:threadon/pages/Patouts_Screen.dart';
import 'package:threadon/pages/PaymentMethods_screen.dart';
import 'package:threadon/pages/Purchases_screen.dart';
import 'package:threadon/pages/Refer_Screen.dart';
import 'package:threadon/pages/Report/Report1_submit_screen.dart';
import 'package:threadon/pages/Report/Report2_submit_screen.dart';
import 'package:threadon/pages/Report/Report_screen.dart';
import 'package:threadon/pages/Report/Report_submit_screen.dart';
import 'package:threadon/pages/Sales_screen.dart';
import 'package:threadon/pages/Secure_Checkout_Screen.dart';
import 'package:threadon/pages/Seller_User_Profile_Screen.dart';
import 'package:threadon/pages/Seller_User_Profile_Screen_1.dart';
import 'package:threadon/pages/Share_List_screen.dart';
import 'package:threadon/pages/Shipping_Address_List_Screen.dart';
import 'package:threadon/pages/User_Profile_Edit.dart';
import 'package:threadon/pages/department_detail.dart';

import 'package:threadon/pages/departments_screen.dart';
import 'package:threadon/pages/home_screen.dart';
import 'package:threadon/tab_screen/Share_List_Tab.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class MyNavigator {
  static void goToHome(BuildContext context) {
    Navigator.pushNamed(context, "/home");
  }

  static void goToIntro(BuildContext context) {
    Navigator.pushNamed(context, "/intro");
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushNamed(context, "/listadecompras");
  }

  static void goToSignup(BuildContext context) {
    Navigator.pushNamed(context, "/listadecompra");
  }

  static void goToSlider(BuildContext context) {
    Navigator.pushNamed(context, "/slider");
  }

  static void goToMain(BuildContext context) {
    Navigator.pushNamed(context, "/mainadecompras");
  }

  static void goToHomee(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  static void goToSell(BuildContext context) {
    Navigator.pushNamed(context, "/sell-page");
  }

  static void goToDepartments(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DepartmentScreen(tool_name: toolname)));
  }

  static void goToProfile(BuildContext context) {
    Navigator.pushNamed(context, "/profile");
  }

  static void goToDepartmentss(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DepartmentsScreen()));
  }

  static void goToTerms(BuildContext context) {
    Navigator.pushNamed(context, "/terms");
  }

  static void goToPrivacy(BuildContext context) {
    Navigator.pushNamed(context, "/privacy");
  }

  static void goToResetPass(BuildContext context) {
    Navigator.pushNamed(context, "/resetpassword");
  }

  static void goToUserProfile(BuildContext context) {
    Navigator.pushNamed(context, "/userprofile");
  }

  static void goToNewSignup(BuildContext context) {
    Navigator.pushNamed(context, "/signup");
  }

  static void goToProfileTab1(BuildContext context) {
    Navigator.pushNamed(context, "/profile_tab1");
  }

  static void goToCompany(BuildContext context, String toolname) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyScreen(
          tool_name: toolname,
        ),
      ),
    );
  }

  static void gotoDetils(BuildContext context, Shell_Product_Model item) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GridItemDetails(
                  item: item,
                )));
  }

  static void gotoAddress(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Address_Book(
                  tool_name: toolname,
                )));
  }

  static void gotoAddAddress(
      BuildContext context, String toolname, int flag, int exit_Flag) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Add_Address_Screen(
                  appbar_name: toolname,
                  Flag: flag,
                  exit_Flag: exit_Flag,
                )));
  }

  static void gotoShipping_Add_List(
      BuildContext context, String toolname, int flag) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Shipping_Address_List()));
  }

  static void gotoEditProfile(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Seller_Profile()));
  }

  static void gotoSEditProfile(
      BuildContext context, String toolname, String profileimage) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_Profile(
                  appbar_name: toolname,
                  profileimage: profileimage,
                )));
  }

  static void gotoChangePassword(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Change_Password_Screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoFavoriteScreen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Favorite_Screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoAddShareListScreen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Add_ShareList_Screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoPurchasesScreen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Purchases_Screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoOrderScreen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Lable_screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoSalesScreen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Sales_screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoPaymentMethodsScreen(
      BuildContext context, String toolname, List<String> d) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Payments_Methods(
                  tool_name: toolname,
                  shippingAdd: d,
                )));
  }

  static void gotoAddPaymentMethodsScreen(
      BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Add_Payment_Screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoPayoutScreen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PayOut_Screen(
                  appbar_name: toolname,
                )));
  }

  static void gotoWebViewScreen(
      BuildContext context, String toolname, String link) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebView_Screen(
                  appbar_name: toolname,
                  Link: link,
                )));
  }

  static void gotoAddItemScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Add_Item()));
  }

  static void gotoAdd_item_2Screen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Add_Item_2(appbar_name: toolname)));
  }

  static void gotoAdd_item_3Screen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Add_Item_3(appbar_name: toolname)));
  }

  /* static void gotoAdd_item_3_camera_Screen(BuildContext context,String toolname) {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>Add_Item_3_Camera(appbar_name:  toolname)));
  }*/

  static void gotoRefer_Screen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Refer_Screen(appbar_name: toolname)));
  }

  static gotoAdd_Item_4_Screen(
      BuildContext context,
      String toolname,
      List<String> cameraImageList,
      List<String> galeryImageList,
      // File galeryImageList;
      String Dname,
      String Size) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Add_Item_4_Listing_details(
                  appbar_name: toolname,
                  listOfCameraImage: cameraImageList,
                  listOfGalleryimage: galeryImageList,
                  Dname: Dname,
                  Size: Size,
                )));
  }

  static gotoFilter1_Screen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Filter1_Screen()));
  }

  static gotoReport_Screen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Report()));
  }

//  static  gotoReport_Submit_Screen(BuildContext context, String toolname) {
//    Navigator.push(context, MaterialPageRoute(builder: (context) =>Report_Submitscreen()));
//  }

  static void gotoReport_Submit_Screen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Report_Submitscreen(title: toolname)));
  }

  static void gotoReport1_Submit_Screen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Report1_Submitscreen(title: toolname)));
  }

  static void gotoReport2_Submit_Screen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Report2_Submitscreen(title: toolname)));
  }

  static gotoCompare_Screen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Compare_screen()));
  }

  static gotoShare_List_Screen(BuildContext context, String toolname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Share_List_Screen(title: toolname)));
  }

  static gotoCart_Screen(BuildContext context, String toolname) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CartScreen()));
  }

  static gotoCheckout_Screen(BuildContext context, String toolname) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Secure_Checkout_Screen()));
  }

  static gotoSeller_Profile_Screen(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Seller_Profile_screen()));
  }

  static gotoSeller_Profile_Screen1(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Seller_Profile()));
  }

  static gotoBrand_Screen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Brand_SearchList()));
  }
}
