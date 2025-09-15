import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Util {
  static bool isStringNotNull(str) {
    if (str is String) {
      str = str.trim();
      if (str.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  static bool isValidList(List? list) {
    if (list != null && list.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static List<String> csvToList(String csv) {
    if (csv.endsWith(",")) {
      csv = csv.substring(0, csv.length - 1);
    }
    List<String> list = csv.split(",");
    return list;
  }

  static String getInitialFromFullName({required String fullName}) {
    return (fullName.split(" ").first[0] + fullName.split(" ")[1][0])
        .toUpperCase();
  }

  static void showToast({required String msg}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
