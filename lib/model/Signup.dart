import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

final CollectionReference userlogin = Firestore.instance.collection('users');

class Signup_Modle {
  String Key;
  String Username;
  String Password;
  String Name;
  String Status;
  String Profile_picture;
  String Latlong;
  String Following;
  String Followers;
  String Facebook_id;
  String Email_id;
  String Device_id;
  String Device;
  String Cover_picture;
  String Country;
  String About_me;
  String  Refer_code;

  Signup_Modle(
      this.Key,
      this.Username,
      this.Password,
      this.Name,
      this.Status,
      this.Profile_picture,
      this.Latlong,
      this.Followers,
      this.Following,
      this.Facebook_id,
      this.Email_id,
      this.Device_id,
      this.Device,
      this.Cover_picture,
      this.Country,
      this.About_me,
      this.Refer_code);


  Signup_Modle.map(dynamic obj) {
    this.Key = obj['id'];
    this.Username = obj['language_name'];
  }


  String get _Key => Key;

  String get _Username => Username;

  String get _Password => Password;

  String get _Name => Name;

  String get _Status => Status;

  String get _Profile_picture => Profile_picture;

  String get _Latlong => Latlong;
  String get _Followers => Followers;
  String get _Following => Following;



  String get _Facebook_id => Facebook_id;

  String get _Email_id => Email_id;

  String get _Device_id => Device_id;

  String get _Device => Device;

  String get _Cover_picture => Cover_picture;

  String get _Country => Country;

  String get _About_me => About_me;




/*  User.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];
    _email = snapshot.value['email'];
    _age = snapshot.value['age'];
    _mobile = snapshot.value['mobile'];
  }*/



  Signup_Modle.fromMap(Map<String, dynamic> map) {
    this.Email_id = map['username'];
    this.Password = map['password'];
    this.Name = map['name'];
    this.Status = map['status'];
    this.Profile_picture = map['profile_picture'];
    this.Latlong = map['latlong'];
    this.Facebook_id = map['facebook_id'];
    this.Email_id = map['email_id'];
    this.Device_id = map['device_id'];
    this.Device= map['device'];
    this.Cover_picture = map['cover_picture'];
    this.Country = map['country'];
    this.About_me = map['bbout_me'];
    this.Refer_code = map['refer_code'];

  }


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Key != null) {
      map['user_id'] = Key;
    }
    map['username'] = Username;

    map['password'] = Password;
    map['name'] = Name;
    map['status'] = Status;
    map['profile_picture'] = Profile_picture;
    map['latlong'] = Latlong;
    map['following'] = Following;
    map['followers'] = Followers;
    map['facebook_id'] = Facebook_id;
    map['email_id'] = Email_id;
    map['device_id'] = Device_id;
    map['device'] = Device;
    map['cover_picture'] = Cover_picture;
    map['country'] = Country;
    map['about_me'] = About_me;
    map['refer_code'] = Refer_code;



    return map;
  }


  Signup_Modle.fromSnapshot(DataSnapshot snapshot){
    Key = snapshot.key;
    Username = snapshot.value["username"];
    Password = snapshot.value["password"];
    Name = snapshot.value["name"];
    Status = snapshot.value["status"];
    Profile_picture = snapshot.value["profile_picture"];
    Latlong = snapshot.value["latlong"];
    Following = snapshot.value["following"];
    Followers = snapshot.value["followers"];
    Facebook_id = snapshot.value["facebook_id"];
    Email_id = snapshot.value["email_id"];
    Device_id = snapshot.value["device_id"];
    Device = snapshot.value["device"];
    Cover_picture = snapshot.value["cover_picture"];
    Country = snapshot.value["country"];
    About_me = snapshot.value["about_me"];
    Refer_code = snapshot.value['refer_code'];
  }


  toJson() {
    return {
      "username": Username,
      "password": Password,
      "name": Name,
      "status": Status,
      "profile_picture": Profile_picture,
      "latlong": Latlong,
      "following": Following,
      "followers": Followers,
      "facebook_id": Facebook_id,
      "email_id": Email_id,
      "device_id": Device_id,
      "device": Device,
      "cover_picture": Cover_picture,
      "country": Country,
      "about_me": About_me,
      "refer_code":Refer_code
    };
  }

  Stream<QuerySnapshot> list({int limit, int offset}) {
    Stream<QuerySnapshot> snapshots = (userlogin.where('email_id', isEqualTo: this.Email_id)..where('password', isEqualTo: this.Password).snapshots) as Stream<QuerySnapshot>;
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }


}