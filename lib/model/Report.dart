class Report{
  String _report_id;
  String _user_id;
  String _product_id;
  String _status;
  DateTime _date;
  String _authenticity_issue;
  String _image_issue;
  String _inaccurate_price_issue;

  Report(this._report_id, this._user_id, this._product_id, this._status, this._date,
  this._authenticity_issue, this._image_issue, this._inaccurate_price_issue);

  Report.map(dynamic obj) {
    this._report_id = obj['report_id'];
    this._user_id = obj['user_id'];
    this._product_id = obj['product_id'];
    this._status = obj['status'];
    this._date = obj['date'];
    this._authenticity_issue = obj['authenticity_issue'];
    this._image_issue = obj['image_issue'];
    this._inaccurate_price_issue = obj['inaccurate_price_issue'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_product_id != null) {
      map['report_id'] = _report_id;
    }
    map['user_id'] = _user_id;
    map['product_id'] = _product_id;
    map['status'] = _status;
    map['date'] = _date;
    map['authenticity_issue'] = _authenticity_issue;
    map['image_issue'] = _image_issue;
    map['inaccurate_price_issue'] = _inaccurate_price_issue;

    return map;
  }

  Report.fromMap(Map<String, dynamic> map) {
    this._report_id= map['report_id'];
    this._user_id= map['user_id'];
    this._product_id = map['product_id'];
    this._status= map['status'];
    this._date= map['date'];
    this._authenticity_issue= map['authenticity_issue'];
    this._image_issue= map['image_issue'];
    this._inaccurate_price_issue= map['inaccurate_price_issue'];
  }
}