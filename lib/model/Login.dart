import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

final CollectionReference userlogin = Firestore.instance.collection('users');

class Login_Modle {
  String Key;
  String Username;
  String Password;
  String Name;
  String Status;
  String Profile_picture;
  GeoPoint Latlong;
  String Following;
  String Followers;
  String Facebook_id;
  String Email_id;
  String Device_id;
  String Device;
  String Cover_picture;
  String Country;
  String About_me;
  String Refer_code;
  String Token;

  Login_Modle(
      this.Key,
      this.Username,
      this.Password,
      this.Name,
      this.Status,
      this.Profile_picture,
      this.Latlong,
      this.Following,
      this.Followers,
      this.Facebook_id,
      this.Email_id,
      this.Device_id,
      this.Device,
      this.Cover_picture,
      this.Country,
      this.About_me,
      this.Refer_code,
      this.Token);

  Login_Modle.fromMap(Map<String, dynamic> map) {
    this.Key = map['user_id'];
    this.Email_id = map['email_id'];
    this.Name = map['name'];
    this.Status = map['status'];
    this.Username = map['username'];
    this.Password = map['password'];
    this.Profile_picture = map['profile_picture'];
    this.Latlong = map['latlong'];
    this.Following = map['following'];
    this.Followers = map['followers'];
    this.Facebook_id = map['facebook_id'];
    this.Email_id = map['email_id'];
    this.Device_id = map['device_id'];
    this.Device = map['device'];
    this.Cover_picture = map['cover_picture'];
    this.Country = map['country'];
    this.About_me = map['about_me'];
    this.Refer_code = map['refer_code'];
    this.Token = map['token_id'];
  }

  Login_Modle.fromSnapshot(DataSnapshot snapshot)
      : Key = snapshot.key,
        Username = snapshot.value["username"],
        Password = snapshot.value["password"],
        Name = snapshot.value["name"],
        Status = snapshot.value["status"],
        Profile_picture = snapshot.value["profile_picture"].toList(),
        Latlong = snapshot.value["latlong"],
        Following = snapshot.value["following"],
        Followers = snapshot.value["followers"],
        Facebook_id = snapshot.value["facebook_id"],
        Email_id = snapshot.value["email_id"],
        Device_id = snapshot.value["device_id"],
        Device = snapshot.value["device"],
        Cover_picture = snapshot.value["cover_picture"],
        Country = snapshot.value["country"],
        About_me = snapshot.value["about_me"],
        Refer_code = snapshot.value['refer_code'],
        Token = snapshot.value['token_id'];

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
      "refer_code": Refer_code,
      "token_id": Token
    };
  }

  Stream<QuerySnapshot> list({int limit, int offset}) {
    Stream<QuerySnapshot> snapshots =
        (userlogin.where('email_id', isEqualTo: this.Email_id)
              ..where('password', isEqualTo: this.Password).snapshots)
            as Stream<QuerySnapshot>;
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }
}
