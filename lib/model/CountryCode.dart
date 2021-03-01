class CountryCodeModel{
  String CountryName;
  String CountryCode;


  CountryCodeModel(this.CountryName, this.CountryCode);

  String get C_name => CountryName;

  set C_name(String value) => CountryName = value;

  String get lastName => CountryCode;

  set lastName(String value) => CountryCode = value;




}