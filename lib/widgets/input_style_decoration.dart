import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'system_functions_manager.dart';

class InputDecorations {
  static InputDecoration inputDecoration(
      {required String hinttext,
      required String labletext,
      required Icon icons}) {
    return InputDecoration(
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.deepPurple,
          width: 2,
        ),
      ),
      hintText: hinttext,
      labelText: labletext,
      labelStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      prefixIcon: icons,
    );
  }
}

class TxtOnlyInputDecorations {
  static InputDecoration inputDecorations(
      {required String hinttext, required String labletext}) {
    return InputDecoration(
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.deepPurple,
          width: 2,
        ),
      ),
      hintText: hinttext,
      labelText: labletext,
      labelStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );
  }
}

class ButtonDecorations {
  static ElevatedButton buttonDecoration({
    required String btnText,
    required Icon btnIcon,
    required Color pcolors,
    required Color tcolors,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          btnIcon,
          SizedBox(width: 10),
          Text(
            btnText,
          ),
        ],
      ),
    );
  }
}

class ShowDialogs {
  static void showdialog(BuildContext context,
      {required String msg,
      required String title,
      required Icon icons,
      required iconColors}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Transform.scale(
                  scale: 2,
                  child: Icon(
                    icons.icon,
                    color: Colors.black54,
                    size: icons.size,
                  ),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Text(msg),
            /*
            icon: icons,iconColor: iconColors,*/
            iconPadding: EdgeInsets.all(70),
            actions: [
              Center(
                  child: IconButton(
                icon: Icon(Icons.expand_circle_down),
                color: Color.fromRGBO(13, 42, 209, 10),
                iconSize: 50,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ))
            ],
          );
        });
  }
}

class YNDialogCon {
  static String dialogStatus = '0';
  static Future<String> ynDialogMessage(
    BuildContext context, {
    required String messageBody,
    required String messageTitle,
    required Icon iconFile,
    required Color iconColor,
    required String btnDone,
    required String btnClose,
  }) async {
    final completer = Completer<String>();
    showDialog(
        useRootNavigator: false,
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: SafeArea(
                child: AlertDialog(
              title: Row(
                children: [
                  Transform.scale(
                    scale: 2,
                    child: iconFile,
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      messageTitle.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  messageBody,
                  maxLines: 10,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    dialogStatus = 'Y';
                    Navigator.pop(context);
                    completer.complete(dialogStatus.toString());
                  },
                  child: Row(
                    children: [
                      Icon(Icons.done_outline),
                      SizedBox(width: 8),
                      Text(
                        btnDone,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    iconColor: MaterialStateProperty.all(Colors.black),
                    iconSize: MaterialStateProperty.all<double>(30.0),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    dialogStatus = 'N';
                    Navigator.pop(context);
                    completer.complete(dialogStatus.toString());
                  },
                  child: Row(
                    children: [
                      Icon(Icons.disabled_by_default),
                      SizedBox(width: 8),
                      Text(
                        btnClose,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    iconColor: MaterialStateProperty.all(Colors.black),
                    iconSize: MaterialStateProperty.all<double>(30.0),
                  ),
                ),
              ],
            )),
          );
        });
    return completer.future;
  }
}

class InputDialogWithText {
  static int stateOfMessage = 9;
  static Future<int?> inputDialog(BuildContext context,
      {required String TicketNo,
      required String assetTag,
      required String serialNumber,
      required String notificationTo,
      required Icon icons}) {
    TextEditingController _upgradeNote = TextEditingController();
    TextEditingController _reference = TextEditingController();
    TextEditingController _cost = TextEditingController();

    return showDialog<int>(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              child: AlertDialog(
            title: Center(
              child: Text("TKT NO:" + TicketNo),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ASSET TAG :' + assetTag),
                Text('SERIAL NUMBER :' + serialNumber),
                TextField(
                  controller: _upgradeNote,
                  autocorrect: false,
                  decoration: InputDecorations.inputDecoration(
                    hinttext: 'RAM UPGRADE',
                    labletext: 'NOTE OF UPGRADES',
                    icons: Icon(Icons.room_preferences),
                  ),
                ),
                TextField(
                  controller: _reference,
                  autocorrect: false,
                  decoration: InputDecorations.inputDecoration(
                    hinttext: 'EG:SSD SN',
                    labletext: 'REFERENCE',
                    icons: Icon(Icons.room_preferences),
                  ),
                ),
                TextField(
                  controller: _cost,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecorations.inputDecoration(
                    hinttext: '1500',
                    labletext: 'COST(LKR)',
                    icons: Icon(Icons.room_preferences),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    if (TicketNo.length <= 4) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER TICKET NUMBER",
                          title: "ENTER TICKET NUMBER",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else if (_upgradeNote.text.length <= 1) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER NOTE OF UPGRADES",
                          title: "NOTE REQUIRED",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else if (_reference.text.length <= 1) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER REFERENCE",
                          title: "REFERENCE REQUIRED",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else if (_cost.text.length <= 1) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER REPAIR COST",
                          title: "COST REQUIRED",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else {
                      final conn = await ConnectionManager.createConnection();
                      await conn.connect();
                      DateTime now = DateTime.now();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(now);
                      String formattedTime = DateFormat('HH:mm:ss').format(now);
                      await conn.execute(
                          "INSERT INTO `tbl_addonitem`(`IdString`,`TktNo`,`SN`,`upgradeNote`,`reference`,`upgradeCost`,`EnterDate`,`EnterTime`,`EnterBy`)VALUES('${assetTag}','${TicketNo}','${serialNumber}','${_upgradeNote.text}','${_reference.text}','${_cost.text}','${formattedDate}','${formattedTime}','${UserCredential().getUserId}');");

                      DBWritting.eventCapture(
                          context,
                          'TICKET NO:' +
                              TicketNo +
                              ' ITEMS UPGRADE.\nREFERENCE :' +
                              _reference.text +
                              '\nUPGRADE COST IS :' +
                              _cost.text +
                              '.LKR',
                          'COMPONENT UPGRADE',
                          notificationTo,
                          TicketNo,
                          formattedDate,
                          formattedTime);

                      await SendSMS.sendSms(notificationTo,
                          "ITEM UPGRADE.REFERENCE :" + _reference.text);
                      conn.close();
                      Navigator.of(context).pop(stateOfMessage = 1);
                      ShowDialogs.showdialog(context,
                          msg: "UPGRADE RECORD",
                          title: "SAVED",
                          icons: Icon(Icons.upgrade),
                          iconColors: Colors.green);
                    }
                  } catch (e) {
                    ShowDialogs.showdialog(context,
                        msg: "$e",
                        title: "EVENT LOG ERROR",
                        icons: Icon(Icons.error),
                        iconColors: Colors.red);
                  }
                },
                child: Text('UPGRADE'),
              ),
              TextButton(
                onPressed: () {
                  _reference.text = "";
                  _cost.text = "";
                  _upgradeNote.text = "";
                },
                child: Text('CLEAR'),
              ),
            ],
            contentPadding: EdgeInsets.symmetric(vertical: 20.0),
          ));
        }).then((value) {
      return value;
    });
  }
}

class FeedbackDialog {
  static int stateOfMessage = 9;
  static Future<int?> feedbackDialog(BuildContext context,
      {required String ticketNo,
      required String location,
      required String compDate,
      required String dpt,
      required Icon icons}) {
    TextEditingController _feedback = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: SafeArea(
              child: AlertDialog(
            title: Center(
              child: Text("TICKET :" + ticketNo + " COMPLETED."),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  " CAN'T RAISE A NEW TICKET",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                Center(
                  child: Text(
                    "WITHOUT GIVING A FEEDBACK",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('LOCATION :' + location),
                Text('DPT :' + dpt),
                Text('COMPLEATED AT :' + compDate),
                TextField(
                  controller: _feedback,
                  autocorrect: false,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecorations.inputDecoration(
                    hinttext: 'GOOD SERVICE',
                    labletext: 'WRITE A NOTE..',
                    icons: Icon(Icons.room_preferences),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    if (ticketNo.length <= 4) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER TICKET NUMBER",
                          title: "ENTER TICKET NUMBER",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else {
                      final conn = await ConnectionManager.createConnection();
                      await conn.connect();
                      DateTime now = DateTime.now();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(now);
                      String formattedTime = DateFormat('HH:mm:ss').format(now);
                      await conn.execute(
                          "UPDATE tbl_ticket SET TktFBDate='${formattedDate}',TktFBTime='${formattedTime}',TktFB='${_feedback.text}' WHERE IdString='${ticketNo}'");
                      String eventText = "Give Feedback :" + _feedback.text;
                      await conn.execute(
                          "INSERT INTO `tbl_tkteventlog`(`TktIdString`,`TktLogHeader`,`TktEvent`,`EnterDate`,`EnterTime`,`EnterBy`)VALUES('${ticketNo}'"
                          ",'User Feedback','${eventText}','${formattedDate}','${formattedTime}','${UserCredential().getUserId}');");

                      conn.close();
                      Navigator.of(context).pop(stateOfMessage = 1);
                      ShowDialogs.showdialog(context,
                          msg: "FEEDBACK SUBMITTED",
                          title: "SAVED",
                          icons: Icon(Icons.upgrade),
                          iconColors: Colors.green);
                    }
                  } catch (e) {
                    ShowDialogs.showdialog(context,
                        msg: "$e",
                        title: "EVENT LOG ERROR",
                        icons: Icon(Icons.error),
                        iconColors: Colors.red);
                  }
                },
                child: Text('SUBMIT'),
              ),
              TextButton(
                onPressed: () {
                  _feedback.text = "";
                },
                child: Text('CLEAR'),
              ),
            ],
            contentPadding: EdgeInsets.symmetric(vertical: 20.0),
          )),
        );
      },
    ).then((value) {
      return value;
    });
  }
}

class WaitDialog {
  static void waitDialog(BuildContext context, {required String loadingNote}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Text('PLEASE WAIT..'),
            ],
          ),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(loadingNote.toUpperCase()),
            ],
          ),
        );
      },
    );
  }
}

class AddOnSubItemUpgrade {
  static int stateOfMessage = 9;
  static Future<int?> inputDialog(BuildContext context,
      {required String assetTag,
      required String serialNumber,
      required String notificationTo,
      required Icon icons}) {
    TextEditingController _upgradeNote = TextEditingController();
    TextEditingController _reference = TextEditingController();
    TextEditingController _cost = TextEditingController();
    final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

    return showDialog<int>(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Center(
              child: Text("ADD-IN ITEMS"),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ASSET TAG :' + assetTag),
                Text('SERIAL NUMBER :' + serialNumber),
                TextField(
                  controller: _upgradeNote,
                  autocorrect: false,
                  decoration: InputDecorations.inputDecoration(
                    hinttext: 'RAM UPGRADE',
                    labletext: 'NOTE OF UPGRADES',
                    icons: Icon(Icons.room_preferences),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _reference,
                        autocorrect: false,
                        decoration: InputDecorations.inputDecoration(
                          hinttext: 'EG:SSD SN',
                          labletext: 'REFERENCE',
                          icons: Icon(Icons.room_preferences),
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.qr_code),
                      onPressed: () {
                        _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) {
                            code = code;
                            _reference.text = code.toString();
                          },
                        );
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _cost,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecorations.inputDecoration(
                    hinttext: '1500',
                    labletext: 'COST(LKR)',
                    icons: Icon(Icons.room_preferences),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    if (assetTag.length <= 4) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER ASSET TAG",
                          title: "ENTER TICKET NUMBER",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else if (_upgradeNote.text.length <= 1) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER NOTE OF UPGRADES",
                          title: "NOTE REQUIRED",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else if (_reference.text.length <= 1) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER REFERENCE",
                          title: "REFERENCE REQUIRED",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else if (_cost.text.length <= 1) {
                      ShowDialogs.showdialog(context,
                          msg: "PLEASE ENTER REPAIR COST",
                          title: "COST REQUIRED",
                          icons: Icon(Icons.nearby_error),
                          iconColors: Colors.red);
                    } else {
                      WaitDialog.waitDialog(context, loadingNote: 'Loading');
                      final conn = await ConnectionManager.createConnection();
                      await conn.connect();
                      DateTime now = DateTime.now();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(now);
                      String formattedTime = DateFormat('HH:mm:ss').format(now);
                      await conn.execute(
                          "INSERT INTO `tbl_addonitem`(`IdString`,`TktNo`,`SN`,`upgradeNote`,`reference`,`upgradeCost`,`EnterDate`,`EnterTime`,`EnterBy`)VALUES('${assetTag}','ADD-ON-ITEM','${serialNumber}','${_upgradeNote.text}','${_reference.text}','${_cost.text}','${formattedDate}','${formattedTime}','${UserCredential().getUserId}');");

                      await SendSMS.sendSms(notificationTo,
                          "ITEM UPGRADE.REFERENCE :" + _reference.text);
                      conn.close();
                      Navigator.of(context).pop(stateOfMessage = 1);
                      Navigator.pop(context);
                      ShowDialogs.showdialog(context,
                          msg: "UPGRADE RECORD",
                          title: "SAVED",
                          icons: Icon(Icons.upgrade),
                          iconColors: Colors.green);
                    }
                  } catch (e) {
                    ShowDialogs.showdialog(context,
                        msg: "$e",
                        title: "EVENT LOG ERROR",
                        icons: Icon(Icons.error),
                        iconColors: Colors.red);
                  }
                },
                child: Text('UPGRADE'),
              ),
              TextButton(
                onPressed: () {
                  _reference.text = "";
                  _cost.text = "";
                  _upgradeNote.text = "";
                },
                child: Text('CLEAR'),
              ),
            ],
            contentPadding: EdgeInsets.symmetric(vertical: 20.0),
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }
}

class YNSendToNewForm {
  static String dialogStatus = '0';
  static Future<String> ynDialogMessage(
    BuildContext context, {
    required String messageBody,
    required String messageTitle,
    required Icon iconFile,
    required Color iconColor,
    required String btnDone,
    required String btnClose,
  }) async {
    final completer = Completer<String>();
    showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: SafeArea(
              child: AlertDialog(
            title: Row(
              children: [
                Transform.scale(
                  scale: 2,
                  child: iconFile,
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Text(
                    messageTitle.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                messageBody,
                maxLines: 10,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  dialogStatus = 'Y';
                  Navigator.pop(context);
                  completer.complete(dialogStatus.toString());
                },
                child: Row(
                  children: [
                    Icon(Icons.done_outline),
                    SizedBox(width: 8),
                    Text(
                      btnDone,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  iconColor: MaterialStateProperty.all(Colors.black),
                  iconSize: MaterialStateProperty.all<double>(30.0),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  dialogStatus = 'N';
                  Navigator.pop(context);
                  completer.complete(dialogStatus.toString());
                },
                child: Row(
                  children: [
                    Icon(Icons.disabled_by_default),
                    SizedBox(width: 8),
                    Text(
                      btnClose,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  iconColor: MaterialStateProperty.all(Colors.black),
                  iconSize: MaterialStateProperty.all<double>(30.0),
                ),
              ),
            ],
          )),
        );
      },
    );
    return completer.future;
  }
}

class CustomAppBar {
  static AppBar appbar({
    required double sw,
    required String titleText,
    required IconData icon,
  }) {
    return AppBar(
      backgroundColor: Colors.blue[500],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: sw * 0.05),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titleText.split('/')[0],
                style: TextStyle(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                titleText.split('/')[1],
                style: TextStyle(
                  fontSize: sw * 0.03,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
