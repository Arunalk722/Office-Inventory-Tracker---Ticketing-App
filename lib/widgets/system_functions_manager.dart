import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:http/http.dart' as http;
import 'input_style_decoration.dart';

final String userName = '';

class ConnectionManager {
  static Future<MySQLConnection> createConnection() async {
    return await MySQLConnection.createConnection(
        host: '192.168.50.180',
        port: 3309,
        userName: 'sa',
        password: 'passwords',
        databaseName: 'helpdesk_db');
  }
}

class UserCredential {
  int _userId = 0;
  String _admingroup = '';
  String _mobileNo = '';
  String _userType = '';
  String _dpt = '';
  String _stockLoc = "";
  String _userName = '';
  static final UserCredential _instance = UserCredential._privateConstructor();
  UserCredential._privateConstructor();
  factory UserCredential() {
    return _instance;
  }

  set setUserName(String userName) {
    _userName = userName;
  }

  String get getUserName {
    return _userName;
  }

  set setUserId(int value) {
    _userId = value;
  }

  int get getUserId {
    return _userId;
  }

  set setMobileNo(String mobileNo) {
    _mobileNo = mobileNo;
  }

  String get getMobileNo {
    return _mobileNo;
  }

  set setAdmingroup(String admingroup) {
    _admingroup = admingroup;
  }

  String get getAdmingroup {
    return _admingroup;
  }

  set setDpt(String dpt) {
    _dpt = dpt;
  }

  String get getDpt {
    return _dpt;
  }

  set setStockLoc(String stockLoc) {
    _stockLoc = stockLoc;
  }

  String get getStockLoc {
    return _stockLoc;
  }

  set setUserType(String userType) {
    _userType = userType;
  }

  String get getUserType {
    return _userType;
  }
}

class ScanSMSNumber {
  static Future<void> scaningNumber(
      String msg, String adminGroup, String jobRole) async {
    String number = '';

    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    var findNumber = await conn.execute(
        "select AdminGroup,SMSNumber,JobRole from tbl_smsnotificationalert where AdminGroup='${adminGroup}' AND JobRole='${jobRole}'");
    for (var row in findNumber.rows) {
      number = row.assoc()['SMSNumber']!;
      print('SMS SEND TO ' + number);
      if (number.length >= 10) {
        await SendSMS.sendSms(number, msg);
      }
    }
    await conn.close();
  }
}

class ScanUserInfo {
  static Future<void> ScanUserNumber(String msg, String adminName) async {
    String number = '';
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    var findNumber = await conn.execute(
        "select Mobile FROM pussalla_it.tbl_userlist where UserName='${adminName}'");
    for (var row in findNumber.rows) {
      number = row.assoc()['Mobile']!;
      print('SMS SEND TO ' + number);
      if (number.length >= 10) {
        await SendSMS.sendSms(number, msg);
      }
    }
    await conn.close();
  }
}

class SendSMS {
  static Future<void> sendSms(String receiver, String msg) async {
    //sms getaway credentinals
    final String baseUrl = 'http://192.168.50.180:8080/index.aspx';
    final String user = 'yourUserName';
    final String hash = 'HashKey';

    final Uri url =
        Uri.parse('$baseUrl?User=$user&Hash=$hash&Msg=$msg&Recever=$receiver');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      {
        if (responseBody['sCode'] == 200) {
          print('SMS sent successfully to number: $receiver');
        }
      }
    } else {
      print('Failed to send SMS.');
    }
  }
}

class SystemUser {}

class TechnicalAdmin {
  String technicalRole;

  TechnicalAdmin(this.technicalRole);
}

class SystemAdmin implements SystemUser, TechnicalAdmin {
  String username;
  String technicalRole;
  String adminRole;
  SystemAdmin(this.username, this.technicalRole, this.adminRole);
}

class DBWritting {
  static void eventCapture(
      BuildContext context,
      String eventText,
      String logHeader,
      String notificationTo,
      String ticktID,
      String eventDate,
      String eventTime) async {
    try {
      if (ticktID.length >= 5) {
        final conn = await ConnectionManager.createConnection();
        await conn.connect();
        await conn.execute(
            "INSERT INTO `tbl_tkteventlog`(`TktIdString`,`TktLogHeader`,`TktEvent`,`EnterDate`,`EnterTime`,`EnterBy`)VALUES('${ticktID}','${logHeader}','${eventText}','${eventDate}','${eventTime}','${UserCredential().getUserId}');");
        await SendSMS.sendSms(notificationTo, eventText);
        print(eventText);
        conn.close();
      } else {
        ShowDialogs.showdialog(context,
            msg: "PLEASE ENTER TICKET NUMBER",
            title: "ENTER TICKET NUMBER",
            icons: Icon(Icons.nearby_error),
            iconColors: Colors.red);
      }
    } catch (e) {
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }
}
