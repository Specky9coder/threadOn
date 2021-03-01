class Share_List{
  String _share_list_id;
  String _user_id;
  String _product_id;
  String _share_id;
  DateTime _date;
  String _share_list_name;

  Share_List(this._share_list_id, this._user_id, this._product_id,this._share_id, this._date, this._share_list_name);

  Share_List.map(dynamic obj) {
    this._share_list_id = obj['share_list_id'];
    this._user_id = obj['user_id'];
    this._product_id = obj['product_id'];
    this._share_id = obj['share_id'];
    this._date = obj['date'];
    this._share_list_name = obj['share_list_name'];
  }

  String get share_list_id => _share_list_id;
  String get user_id => _user_id ;
  String get product_id => _product_id;
  String get share_id => _share_id;
  DateTime get date => _date;
  String get share_list_name => _share_list_name;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_share_list_id != null) {
      map['share_list_id'] = _share_list_id;
    }
    map['user_id'] = _user_id;
    map['product_id'] = _product_id;
    map['share_id'] = _share_id;
    map['date'] = _date;
    map['share_list_name'] = _share_list_name;

    return map;
  }

  Share_List.fromMap(Map<String, dynamic> map) {
    this._share_list_id= map['share_list_id'];
    this._user_id= map['user_id'];
    this._product_id= map['product_id'];
    this._share_id= map['share_id'];
    this._date= map['date'];
    this._share_list_name= map['share_list_name'];
  }
}