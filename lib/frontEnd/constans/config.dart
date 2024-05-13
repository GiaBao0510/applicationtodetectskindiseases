import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:network_info_plus/network_info_plus.dart';

String _diaChiIPV4 = '';

Future<void> LayDiaChiIPv4() async {
  final info = NetworkInfo();
  final wifiIPv4 = await info.getWifiIP();
  _diaChiIPV4 = wifiIPv4?.toString() ?? '';
}

//Lấy địa chỉ IP cuủa thiết bị khi kết nối đển wifi
String url = "http://192.168.0.109:3001";

//Lấy địa chỉ IP cuủa thiết bị khi kết nối đển wifi
String get checkConnect {
  if (_diaChiIPV4.isEmpty) {
    return 'null';
  }
  return "http://$_diaChiIPV4:3001";
}
