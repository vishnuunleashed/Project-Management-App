
import 'dart:io';

import 'package:flutter/cupertino.dart';

class MultipartBody {
  File filedata;
  String filename;
  String serialNo;
  bool isProfilePic;

  MultipartBody(
      {required this.filedata,
        required this.filename,
        required this.serialNo,
        this.isProfilePic =false
      });

  Map toMap() {
    var map = Map<String, dynamic>();
      map["serialno"] = serialNo;
      map["IsProfilePic"] = isProfilePic;
    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}