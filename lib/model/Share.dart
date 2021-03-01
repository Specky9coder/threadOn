class Share{
  String _share_id;
  String _user_id;
  DateTime _date;
  String _share_list_name;
  List share_product_id;


  Share(this._share_id, this._user_id, this._date, this._share_list_name,
      this.share_product_id);

  Share.map(dynamic obj) {
    this._share_id = obj['share_id'];
    this._user_id = obj['user_id'];
    this._date = obj['date'];
    this._share_list_name = obj['share_list_name'];

    this.share_product_id = List<String>.from(obj['share_product_id']);
  }

  String get share_id => _share_id;
  String get user_id => _user_id ;
  DateTime get date => _date;
  String get share_list_name => _share_list_name;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_share_id != null) {
      map['share_id'] = _share_id;
    }
    map['user_id'] = _user_id;
    map['date'] = _date;
    map['share_list_name'] = _share_list_name;

    map['share_product_id']=share_product_id;


    return map;
  }

  Share.fromMap(Map<String, dynamic> map) {
    this._share_id= map['share_id'];
    this._user_id= map['user_id'];
    this._date= map['date'];
    this._share_list_name= map['share_list_name'];
    this.share_product_id = List<String>.from(map['share_product_id']);
  }
}