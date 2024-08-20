import 'package:dart/user_screen/service_view_logList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class TechnicalUpdate extends StatefulWidget {
  final String tktID;
  const TechnicalUpdate({Key? key, required this.tktID}) : super(key: key);

  @override
  State<TechnicalUpdate> createState() => _TechnicalUpdateState();
}

final TextEditingController _tikNo = TextEditingController();
final TextEditingController _assetTag = TextEditingController();
final TextEditingController _sN = TextEditingController();
final TextEditingController _dpt = TextEditingController();
final TextEditingController _location = TextEditingController();
final TextEditingController _detailsOfInsident = TextEditingController();
final TextEditingController _jobDetailsLog = TextEditingController();
final TextEditingController _notificationTo = TextEditingController();
final TextEditingController _assetDescryption = TextEditingController();

final List<String> idStringList = [];
final List<String> bodyText = [];

String prioritySelect = 'LOW';
List<String> priorityDropdownItems = [
  'LOW',
  'MEDIUM',
];

List<String> ticketStatusItem = ['', 'NEW', 'PENDING', 'HOLD', 'COMPLETED'];
String ticketStatusSelect = 'NEW';

List<String> adminGroupDrowpDownItems = ['ADMIN_IT', 'ADMIN_SUPPORT'];
String adminGroupSelect = 'ADMIN_IT';

List<String> adminNameDropDown = [''];
String adminNameSelection = '';

class _TechnicalUpdateState extends State<TechnicalUpdate> {
  bool isMarkedReceivdEnable = false;
  bool isMarkAsCompletedEnable = false;
  bool isMarkVisible = false;
  void btnMarkComStatus(String comDate) async {
    setState(() {
      if (comDate == "1900-01-01") {
        isMarkAsCompletedEnable = true;
      } else {
        isMarkAsCompletedEnable = false;
        ShowDialogs.showdialog(context,
            msg: 'TICKET ALREADY COMPLETED',
            title: 'COMPLETED',
            icons: Icon(Icons.info),
            iconColors: Colors.black);
      }
    });
  }

  void btnMarkRecivedStatus(String delTime) async {
    setState(() {
      if (delTime == "1900-01-01") {
        isMarkedReceivdEnable = true;
        isMarkVisible = false;
      } else {
        isMarkVisible = true;
        isMarkedReceivdEnable = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listAdminName();
    clearText();
    _tikNo.text = widget.tktID;
  }

  void scanTicketByID(BuildContext context) async {
    try {
      WaitDialog.waitDialog(context, loadingNote: 'LOADING');
      String formattedIDno;
      if (_tikNo.text.isNotEmpty) {
        if (int.tryParse(_tikNo.text) != null) {
          int idOnly = int.parse(_tikNo.text);
          formattedIDno =
              '0' * (5 - idOnly.toString().length) + idOnly.toString();
          _tikNo.text = formattedIDno;
        } else {
          formattedIDno = _tikNo.text;
        }
      } else {
        formattedIDno = '';
      }

      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      String query = "";
      if (UserCredential().getUserType == "ADMIN") {
        query = "SELECT * FROM tbl_ticket WHERE IdString='${_tikNo.text}'";
      } else {
        query =
            "SELECT * FROM tbl_ticket WHERE IdString='${_tikNo.text}' and AssingTo='${UserCredential().getUserId}'";
      }
      var checkSN = await conn.execute(query);
      if (checkSN.rows.isEmpty) {
        print("TAG NOT FOUND");
        clearText();
        Navigator.pop(context);
        ShowDialogs.showdialog(context,
            msg: "TICKET NOT FOUND ${_tikNo.text}.",
            title: "NOT FOUND",
            icons: Icon(Icons.stop),
            iconColors: Colors.red);
      } else {
        for (var chksn in checkSN.rows) {
          _sN.text = chksn.assoc()["SN"]!;
          _location.text = chksn.assoc()["Location"]!;
          _assetTag.text = chksn.assoc()["AssetID"]!;
          scanDecryption(_assetTag.text);
          _dpt.text = chksn.assoc()["Dpt"]!;
          _detailsOfInsident.text = chksn.assoc()["TkDetails"]!;
          _jobDetailsLog.text = chksn.assoc()["TktTechWork"].toString();
          _notificationTo.text =
              chksn.assoc()["TktNotificationTo"].toString() == "null"
                  ? ""
                  : chksn.assoc()["TktNotificationTo"].toString();
          String delevDate = chksn.assoc()["TktDeliveryDate"].toString();
          btnMarkRecivedStatus(delevDate);
          String comDate = chksn.assoc()["TkCompleteDate"].toString();

          Navigator.pop(context);
          btnMarkComStatus(comDate);
          setState(() {
            adminGroupSelect = chksn.assoc()["AdminGroup"]!;
            adminNameSelection = chksn.assoc()["AssingTo"]!;
            ticketStatusSelect = chksn.assoc()["TicketStatus"]!;
            prioritySelect = chksn.assoc()["TktPriority"]!;
          });
        }
      }
      conn.close();
      setState(() {});
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "DATA RECEIVING ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
      print("$e");
    }
  }

  Future<void> scanDecryption(String tag) async {
    try {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      String query =
          "SELECT Descriptions FROM tbl_inventory WHERE InvIdString='$tag'";
      print(query);
      var checkSN = await conn.execute(query);
      if (checkSN.rows.isEmpty) {
        Navigator.pop(context);
        ShowDialogs.showdialog(context,
            msg: "we cant found Asset tag on inventory list $tag.",
            title: "NOT FOUND",
            icons: Icon(Icons.stop),
            iconColors: Colors.red);
      } else {
        for (var chksn in checkSN.rows) {
          _assetDescryption.text = chksn.assoc()["Descriptions"].toString();
        }
      }
      conn.close();
      setState(() {});
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "DATA RECEIVING ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
      print("$e");
    }
  }

  void markReceivedTime() async {
    try {
      YNDialogCon.ynDialogMessage(context,
              messageBody: 'TICKET ${_tikNo.text} RECEIVED?',
              messageTitle: 'SUPPORTS',
              iconFile: Icon(Icons.timelapse),
              iconColor: Colors.black,
              btnDone: "RECEIVED",
              btnClose: "NO")
          .then((value) async {
        if (value == "Y") {
          if (_tikNo.text.length >= 5) {
            WaitDialog.waitDialog(context, loadingNote: 'LOADING');
            final conn = await ConnectionManager.createConnection();
            await conn.connect();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);
            String formattedTime = DateFormat('HH:mm:ss').format(now);
            await conn.execute(
                "UPDATE tbl_ticket SET TktDeliveryDate='${formattedDate}',TkDeliveryTime='${formattedTime}' WHERE IdString='${_tikNo.text}'");
            conn.close();
            DBWritting.eventCapture(
                context,
                "The support team has successfully received the ticket.",
                'Incident Intake',
                _notificationTo.text,
                _tikNo.text,
                formattedDate,
                formattedTime);
            ScanSMSNumber.scaningNumber(
                'Tkt ${_tikNo.text} attend by ${UserCredential().getUserId} at $formattedTime $formattedDate}',
                'ADMIN_IT',
                'Tkt');
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "TICKET RECEIVED TIME UPDATED",
                title: "UPDATED RECEIVED TIME",
                icons: Icon(Icons.support_agent),
                iconColors: Colors.green);
          } else {
            ShowDialogs.showdialog(context,
                msg: "PLEASE ENTER TICKET NUMBER",
                title: "ENTER TICKET NUMBER",
                icons: Icon(Icons.nearby_error),
                iconColors: Colors.green);
          }

          scanTicketByID(context);
        } else {}
      });
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  void markCompletedTime() async {
    try {
      YNDialogCon.ynDialogMessage(context,
              messageBody: 'TICKET ${_tikNo.text} COMPLETED?',
              messageTitle: 'UPGRADE RECORD',
              iconFile: Icon(Icons.upgrade),
              iconColor: Colors.black,
              btnDone: "COMPLETED",
              btnClose: "NO")
          .then((value) async {
        if (value == "Y") {
          if (_tikNo.text.length >= 5) {
            WaitDialog.waitDialog(context, loadingNote: 'LOADING');
            final conn = await ConnectionManager.createConnection();
            await conn.connect();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);
            String formattedTime = DateFormat('HH:mm:ss').format(now);
            await conn.execute(
                "UPDATE tbl_ticket SET TkCompleteDate='${formattedDate}',TkCompleteTime='${formattedTime}',TktFB='0' WHERE IdString='${_tikNo.text}'");
            conn.close();
            DBWritting.eventCapture(
                context,
                "The support team is completed the ticket",
                'Ticket Resolution',
                _notificationTo.text,
                _tikNo.text,
                formattedDate,
                formattedTime);
            ScanSMSNumber.scaningNumber(
                'Tkt ${_tikNo.text} Completed.by ${UserCredential().getUserId} at $formattedTime $formattedDate}',
                'ADMIN_IT',
                'Tkt');
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "TICKET COMPLETED",
                title: "TICKET COMPLETED",
                icons: Icon(Icons.support_agent),
                iconColors: Colors.green);
          } else {
            ShowDialogs.showdialog(context,
                msg: "PLEASE ENTER TICKET NUMBER",
                title: "ENTER TICKET NUMBER",
                icons: Icon(Icons.nearby_error),
                iconColors: Colors.red);
          }
          scanTicketByID(context);
        } else {}
      });
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  void changeAdmin(String adminName) async {
    try {
      YNDialogCon.ynDialogMessage(context,
              messageBody: 'TICKET ${_tikNo.text} SUPPORT NEED TO CHANGE?',
              messageTitle: 'SUPPORT',
              iconFile: Icon(Icons.upgrade),
              iconColor: Colors.black,
              btnDone: "CHANGE",
              btnClose: "NO")
          .then((value) async {
        if (value == "Y") {
          if (_tikNo.text.length >= 5) {
            WaitDialog.waitDialog(context, loadingNote: 'LOADING');
            final conn = await ConnectionManager.createConnection();
            await conn.connect();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);
            String formattedTime = DateFormat('HH:mm:ss').format(now);
            await conn.execute(
                "UPDATE tbl_ticket SET AssingTo='${adminName}' WHERE IdString='${_tikNo.text}'");
            conn.close();
            DBWritting.eventCapture(
                context,
                "this ticket was assigned to $adminName",
                'Ticket Assignment',
                _notificationTo.text,
                _tikNo.text,
                formattedDate,
                formattedTime);
            ScanUserInfo.ScanUserNumber(
                'Tkt No: ${_tikNo.text} assign by ${UserCredential().getUserId}.at DATE:$formattedDate $formattedTime',
                adminName);
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "TICKET ASSIGN TO " + adminName,
                title: "ASSIGN THE TICKET",
                icons: Icon(Icons.support_agent),
                iconColors: Colors.green);
          } else {
            ShowDialogs.showdialog(context,
                msg: "PLEASE ENTER TICKET NUMBER",
                title: "ENTER TICKET NUMBER",
                icons: Icon(Icons.nearby_error),
                iconColors: Colors.red);
          }
        } else {}
      });
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  void changeAdminGroup(String adminGroup) async {
    try {
      YNDialogCon.ynDialogMessage(context,
              messageBody: 'CHANGE ADMIN GROUP TO ${adminGroup}',
              messageTitle: 'SUPPORT',
              iconFile: Icon(Icons.upgrade),
              iconColor: Colors.black,
              btnDone: "CHANGE",
              btnClose: "NO")
          .then((value) async {
        if (value == "Y") {
          if (_tikNo.text.length >= 5) {
            WaitDialog.waitDialog(context, loadingNote: 'LOADING');
            final conn = await ConnectionManager.createConnection();
            await conn.connect();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);
            String formattedTime = DateFormat('HH:mm:ss').format(now);
            await conn.execute(
                "UPDATE tbl_ticket SET AdminGroup='${adminGroup}' WHERE IdString='${_tikNo.text}'");
            conn.close();
            DBWritting.eventCapture(
                context,
                "Successfully changed ticket admin group $adminGroup",
                'Admin Group Update',
                _notificationTo.text,
                _tikNo.text,
                formattedDate,
                formattedTime);
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "ADMIN GROUP CHANGE  SUCCESSFULLY " + adminGroup,
                title: "ADMIN GROUP CHANGE",
                icons: Icon(Icons.group),
                iconColors: Colors.green);
          } else {
            ShowDialogs.showdialog(context,
                msg: "PLEASE ENTER TICKET NUMBER",
                title: "ENTER TICKET NUMBER",
                icons: Icon(Icons.nearby_error),
                iconColors: Colors.red);
          }
        } else {}
      });
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  void changeStatus(String ticketStatus) async {
    try {
      YNDialogCon.ynDialogMessage(context,
              messageBody: 'TICKET NO ${_tikNo.text} CHANGE STATUS',
              messageTitle: 'SUPPORT',
              iconFile: Icon(Icons.upgrade),
              iconColor: Colors.black,
              btnDone: "YES",
              btnClose: "NO")
          .then((value) async {
        if (value == "Y") {
          if (_tikNo.text.length >= 5) {
            WaitDialog.waitDialog(context, loadingNote: 'LOADING');
            final conn = await ConnectionManager.createConnection();
            await conn.connect();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);
            String formattedTime = DateFormat('HH:mm:ss').format(now);
            await conn.execute(
                "UPDATE tbl_ticket SET TicketStatus='${ticketStatus}' WHERE IdString='${_tikNo.text}'");
            conn.close();

            DBWritting.eventCapture(
                context,
                "Changed ticket status to $ticketStatus",
                'Ticket Status Update',
                _notificationTo.text,
                _tikNo.text,
                formattedDate,
                formattedTime);
            ScanSMSNumber.scaningNumber(
                'Tkt ${_tikNo.text} Status change to .${ticketStatus}.by ${UserCredential().getUserId} at $formattedTime $formattedDate}',
                'ADMIN_IT',
                'Tkt');

            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "TICKET STATUS CHANGE  SUCCESSFULLY " + ticketStatus,
                title: "STATUS CHANGE",
                icons: Icon(Icons.real_estate_agent_sharp),
                iconColors: Colors.green);
          } else {
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "PLEASE ENTER TICKET NUMBER",
                title: "ENTER TICKET NUMBER",
                icons: Icon(Icons.nearby_error),
                iconColors: Colors.red);
          }
        } else {}
      });
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  void changePriority(String tktPriority) async {
    try {
      YNDialogCon.ynDialogMessage(context,
              messageBody: 'CHANGE TICKET PRIORITY',
              messageTitle: 'SUPPORT',
              iconFile: Icon(Icons.upgrade),
              iconColor: Colors.black,
              btnDone: "YES",
              btnClose: "NO")
          .then((value) async {
        if (value == "Y") {
          if (_tikNo.text.length >= 5) {
            WaitDialog.waitDialog(context, loadingNote: 'LOADING');
            final conn = await ConnectionManager.createConnection();
            await conn.connect();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);
            String formattedTime = DateFormat('HH:mm:ss').format(now);
            await conn.execute(
                "UPDATE tbl_ticket SET TktPriority='${tktPriority}' WHERE IdString='${_tikNo.text}'");
            conn.close();
            DBWritting.eventCapture(
                context,
                "Changed ticket priority to $tktPriority",
                'Priority Adjustment',
                _notificationTo.text,
                _tikNo.text,
                formattedDate,
                formattedTime);
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "TICKET PRIORITY CHANGE  SUCCESSFULLY " + tktPriority,
                title: "PRIORITY CHANGE",
                icons: Icon(Icons.support_agent),
                iconColors: Colors.green);
          } else {
            ShowDialogs.showdialog(context,
                msg: "PLEASE ENTER TICKET NUMBER",
                title: "ENTER TICKET NUMBER",
                icons: Icon(Icons.nearby_error),
                iconColors: Colors.red);
          }
        } else {}
      });
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  void jobDetailsUpdate() async {
    try {
      YNDialogCon.ynDialogMessage(context,
              messageBody: 'ARE YOU SURE TO UPGRADE JOB DETAILS',
              messageTitle: 'SUPPORT',
              iconFile: Icon(Icons.upgrade),
              iconColor: Colors.black,
              btnDone: "YES",
              btnClose: "NO")
          .then((value) async {
        if (value == "Y") {
          if (_tikNo.text.length >= 5) {
            WaitDialog.waitDialog(context, loadingNote: 'LOADING');
            final conn = await ConnectionManager.createConnection();
            await conn.connect();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);
            String formattedTime = DateFormat('HH:mm:ss').format(now);
            await conn.execute(
                "UPDATE tbl_ticket SET TktTechWork='${_jobDetailsLog.text}' WHERE IdString='${_tikNo.text}'");
            conn.close();

            DBWritting.eventCapture(
                context,
                _jobDetailsLog.text,
                'Technical update',
                _notificationTo.text,
                _tikNo.text,
                formattedDate,
                formattedTime);
            ScanSMSNumber.scaningNumber(
                'Tkt ${_tikNo.text} Job details update.by ${UserCredential().getUserId} at $formattedTime $formattedDate}',
                'ADMIN_IT',
                'Tkt');
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg: "TECHNICAL DETAILS UPDATE SUCCESSFULLY",
                title: "UPDATE TECHNICAL DETAILS",
                icons: Icon(Icons.support_agent),
                iconColors: Colors.green);
          } else {
            ShowDialogs.showdialog(context,
                msg: "PLEASE ENTER TICKET NUMBER",
                title: "ENTER TICKET NUMBER",
                icons: Icon(Icons.nearby_error),
                iconColors: Colors.red);
          }
        } else {}
      });
    } catch (e) {
      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "EVENT LOG ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  Future<void> listAdminName() async {
    try {
      if (adminNameDropDown.length <= 1) {
        final conn = await ConnectionManager.createConnection();
        await conn.connect();
        conn
            .execute(
                "SELECT UserName FROM tbl_userlist where UserType='ADMIN' or UserType='SUPPORT'")
            .then((results) {
          for (var row in results.rows) {
            adminNameDropDown.add(row.assoc()['UserName'].toString());
          }
          print(adminNameDropDown);
        });
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  void clearText() {
    _jobDetailsLog.text = "";
    _assetDescryption.text = "";
    _tikNo.text = "";
    _assetTag.text = "";
    _sN.text = "";
    _dpt.text = "";
    _location.text = "";
    _detailsOfInsident.text = "";
    _jobDetailsLog.text = "";
    _notificationTo.text = "";
    setState(() {
      ticketStatusSelect = 'NEW';
      prioritySelect = 'LOW';
      adminGroupSelect = 'ADMIN_IT';
      adminNameSelection = '';
    });
  }

  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: CustomAppBar.appbar(
          sw: sw,
          titleText: 'SERVICE REQUEST/TECHNICAL UPDATE',
          icon: Icons.engineering),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      autocorrect: false,
                      controller: _tikNo,
                      decoration: InputDecorations.inputDecoration(
                          hinttext: '000001',
                          labletext: 'TICKET ID',
                          icons: const Icon(Icons.add_chart)),
                    ),
                  ),
                  Expanded(
                      child: ElevatedButton(
                    child: Text("SCAN"),
                    onPressed: () {
                      scanTicketByID(context);
                    },
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    autocorrect: false,
                    controller: _assetTag,
                    decoration: InputDecorations.inputDecoration(
                        hinttext: '000009',
                        labletext: 'ASSET TAG NO',
                        icons: const Icon(Icons.qr_code_2_sharp)),
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    autocorrect: false,
                    controller: _sN,
                    decoration: InputDecorations.inputDecoration(
                        hinttext: 'SNXXXXX',
                        labletext: 'SERIAL NUMBER',
                        icons: const Icon(Icons.qr_code_2_sharp)),
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    autocorrect: false,
                    maxLines: 3,
                    controller: _assetDescryption,
                    decoration: InputDecorations.inputDecoration(
                        hinttext:
                            'DUAL CORE E5700 CPU RAM 4GB HARD 500GB WINDOWS 7',
                        labletext: 'DESCRIPTION',
                        icons: const Icon(Icons.description)),
                  ))
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    autocorrect: false,
                    controller: _dpt,
                    decoration: InputDecorations.inputDecoration(
                        hinttext: 'MEAT SHOP-OUTLET',
                        labletext: 'DEPARTMENT',
                        icons: const Icon(Icons.departure_board)),
                  ))
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    autocorrect: false,
                    controller: _location,
                    decoration: InputDecorations.inputDecoration(
                        hinttext: 'MAHARAGAMA MEAT SHOP',
                        labletext: 'LOCATION',
                        icons: const Icon(Icons.location_on_sharp)),
                  ))
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    autocorrect: false,
                    controller: _detailsOfInsident,
                    maxLines: null,
                    decoration: InputDecorations.inputDecoration(
                        hinttext: '',
                        labletext: 'DETAILS OF TICKET',
                        icons: const Icon(Icons.departure_board)),
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    autocorrect: false,
                    controller: _notificationTo,
                    decoration: InputDecorations.inputDecoration(
                        hinttext: '070XXXXXXX',
                        labletext: 'SEND NOTIFICATION TO OWNER',
                        icons: const Icon(Icons.phone)),
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ButtonDecorations.buttonDecoration(
                      btnText: 'MARK RECEIVED TIME',
                      btnIcon: Icon(Icons.lock_clock),
                      pcolors: Colors.blue,
                      tcolors: Colors.black,
                      onPressed: () {
                        if (isMarkedReceivdEnable) {
                          markReceivedTime();
                        }
                      },
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: isMarkVisible,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                                value: prioritySelect,
                                onChanged: (String? priorityText) {
                                  setState(() {
                                    prioritySelect = priorityText!;

                                    changePriority(priorityText);
                                  });
                                },
                                items: priorityDropdownItems
                                    .map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList()),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                                value: ticketStatusSelect,
                                onChanged: (String? statusValue) {
                                  setState(() {
                                    ticketStatusSelect = statusValue!;
                                    changeStatus(statusValue);
                                  });
                                },
                                items: ticketStatusItem
                                    .map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList()),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                                value: adminGroupSelect,
                                onChanged: (String? adminGropuValue) {
                                  setState(() {
                                    adminGroupSelect = adminGropuValue!;

                                    changeAdminGroup(adminGropuValue);
                                  });
                                },
                                items: adminGroupDrowpDownItems
                                    .map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList()),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                                value: adminNameSelection,
                                onChanged: (String? newAdmin) {
                                  setState(() {
                                    adminNameSelection = newAdmin!;
                                    changeAdmin(newAdmin);
                                  });
                                },
                                items: adminNameDropDown
                                    .map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList()),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: ButtonDecorations.buttonDecoration(
                                  btnText: 'Initiate Upgrade',
                                  btnIcon: Icon(Icons.inventory),
                                  pcolors: Colors.green,
                                  tcolors: Colors.black,
                                  onPressed: () {
                                    InputDialogWithText.inputDialog(context,
                                        TicketNo: _tikNo.text,
                                        assetTag: _assetTag.text,
                                        serialNumber: _sN.text,
                                        notificationTo: _notificationTo.text,
                                        icons: Icon(Icons.abc));
                                  }))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            maxLines: 5,
                            autocorrect: false,
                            controller: _jobDetailsLog,
                            decoration: InputDecorations.inputDecoration(
                                hinttext: 'RAM CHANGE',
                                labletext: 'UPDATE JOB DETAILS',
                                icons: const Icon(Icons.add_chart)),
                          )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: ButtonDecorations.buttonDecoration(
                                  btnText: 'JOB DETAILS UPDATE',
                                  btnIcon: Icon(Icons.update_outlined),
                                  pcolors: Colors.white12,
                                  tcolors: Colors.black,
                                  onPressed: () {
                                    jobDetailsUpdate();
                                    ;
                                  })),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: ButtonDecorations.buttonDecoration(
                                  btnText: 'MARK AS COMPLETED',
                                  btnIcon: Icon(Icons.done_all),
                                  pcolors: Colors.white12,
                                  tcolors: Colors.black,
                                  onPressed: () {
                                    if (isMarkAsCompletedEnable) {
                                      markCompletedTime();
                                    }
                                  }))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: ButtonDecorations.buttonDecoration(
                            btnText: 'SHOW EVENT LOG',
                            btnIcon: Icon(Icons.comment),
                            pcolors: Colors.black54,
                            tcolors: Colors.lime,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ServiceLogList(
                                            ticketNo: _tikNo.text,
                                          )));
                            },
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: ButtonDecorations.buttonDecoration(
                            btnText: 'CLEAR DATA',
                            btnIcon: Icon(Icons.clear_all),
                            pcolors: Colors.redAccent,
                            tcolors: Colors.black,
                            onPressed: () {
                              clearText();
                            },
                          ))
                        ],
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
