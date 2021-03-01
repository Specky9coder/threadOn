class Favorite {
  String _favourite_id;
  String _user_id;
  String _product_id;
  DateTime _date;
  String _status;
  String _favourite_name;

  Favorite(this._favourite_id, this._user_id, this._product_id, this._date,
      this._status, this._favourite_name);

  Favorite.map(dynamic obj) {
    this._favourite_id = obj['favourite_id'];
    this._user_id = obj['user_id'];
    this._product_id = obj['product_id'];
    this._date = obj['date'];
    this._status = obj['status'];
    this._favourite_name = obj['favourite_name'];
  }

  String get favourite_id => _favourite_id;
  String get user_id => _user_id;
  String get product_id => _product_id;
  DateTime get date => _date;
  String get status => _status;
  String get favourite_name => _favourite_name;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_favourite_id != null) {
      map['favourite_id'] = _favourite_id;
    }
    map['user_id'] = _user_id;
    map['product_id'] = _product_id;
    map['date'] = _date;
    map['status'] = _status;
    map['favourite_name'] = _favourite_name;

    return map;
  }

  Favorite.fromMap(Map<String, dynamic> map) {
    this._favourite_id = map['favourite_id'];
    this._user_id = map['user_id'];
    this._product_id = map['product_id'];
    this._date = map['date'].toDate();
    this._status = map['status'];
    this._favourite_name = map['favourite_name'];
  }
}
