// série que armazenará os resultados
import 'package:flutter/material.dart';
import 'package:mobifront/utils/utl.dart';

class DataValueModel {
  String data;
  double value;
  Widget? badge;
  bool? area;
  Color? color;
  DataValueModel(
      {this.data = "", this.value = 0, this.badge, this.color, this.area});

  factory DataValueModel.empty() {
    return DataValueModel(data: '', value: 0);
  }
  factory DataValueModel.fromJson(Map<String, dynamic> json) {
    return DataValueModel(
      data: Utl.asString(json['data']),
      value: Utl.asFloat(json['value']),
    );
  }
}

class DataValueXYModel {
  String data;
  double valuex;
  double valuey;
  DataValueXYModel({this.data = "", this.valuex = 0, this.valuey = 0});

  factory DataValueXYModel.empty() {
    return DataValueXYModel(data: '', valuex: 0, valuey: 0);
  }
  factory DataValueXYModel.fromJson(Map<String, dynamic> json) {
    return DataValueXYModel(
      data: Utl.asString(json['data']),
      valuex: Utl.asFloat(json['valuex']),
      valuey: Utl.asFloat(json['valuey']),
    );
  }
}

class DataValueXYZModel {
  String data;
  double valuex;
  double valuey;
  double valuez;
  DataValueXYZModel(
      {this.data = "", this.valuex = 0, this.valuey = 0, this.valuez = 0});

  factory DataValueXYZModel.empty() {
    return DataValueXYZModel(data: '', valuex: 0, valuey: 0, valuez: 0);
  }
  factory DataValueXYZModel.fromJson(Map<String, dynamic> json) {
    return DataValueXYZModel(
      data: Utl.asString(json['data']),
      valuex: Utl.asFloat(json['valuex']),
      valuey: Utl.asFloat(json['valuey']),
      valuez: Utl.asFloat(json['valuez']),
    );
  }
}
