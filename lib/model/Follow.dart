class FollowModel{


  DateTime Date;
  String Follower_id;
  String Following_id;
  String Key;
  String Status;


  FollowModel(this.Date, this.Follower_id, this.Following_id, this.Key,
      this.Status);

  FollowModel.map(dynamic obj) {
    this.Date = obj['date'];
    this.Follower_id = obj['follower_id'];
    this.Following_id = obj['following_id'];
    this.Key = obj['id'];
    this.Status = obj['status'];


  }


  DateTime get date => Date;
  String get  follower_id => Follower_id;
  String get following_id => Following_id ;
  String get key => Key;
  String get status => Status;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (Key != null) {
      map['id'] = Key;
    }

    map['follower_id'] = Follower_id;
    map['following_id'] = Following_id;
    map['date'] = Date;
    map['status'] = Status;

    return map;
  }

  FollowModel.fromMap(Map<String, dynamic> map) {
    this.Date= map['date'];
    this.Follower_id= map['follower_id'];
    this.Following_id= map['following_id'];
    this.Key = map['id'];
    this.Status= map['status'];

  }

}