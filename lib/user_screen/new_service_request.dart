import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class NewTicket extends StatefulWidget {
  final String tagNo;
  const NewTicket({Key? key, required this.tagNo}) : super(key: key);

  @override
  State<NewTicket> createState() => _NewTicketState();
}

final TextEditingController _assetID = TextEditingController();
final TextEditingController _sN = TextEditingController();
final TextEditingController _location = TextEditingController();
final TextEditingController _dpt = TextEditingController();
final TextEditingController _priority = TextEditingController();
final TextEditingController _details = TextEditingController();
final TextEditingController _notificationTo = TextEditingController();
final TextEditingController _des = TextEditingController();
String adminGroup = "";
String prioritySelect = 'LOW';
List<String> priorityDropdownItems = [
  'LOW',
  'MEDIUM',
];

class _NewTicketState extends State<NewTicket> {
  void scanAssets(BuildContext context) async {
    try {
      String formattedIDno;
      WaitDialog.waitDialog(context, loadingNote: 'LOADING');
      if (_assetID.text.isNotEmpty) {
        if (int.tryParse(_assetID.text) != null) {
          int idOnly = int.parse(_assetID.text);
          formattedIDno =
              '0' * (5 - idOnly.toString().length) + idOnly.toString();
          _assetID.text = formattedIDno;
        } else {
          formattedIDno = _assetID.text;
        }
      } else {
        formattedIDno = '';
      }
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      String query =
          "SELECT * FROM tbl_inventory WHERE InvIdString='${_assetID.text}'";
      var checkSN = await conn.execute(query);
      Navigator.pop(context);
      if (checkSN.rows.isEmpty) {
        print("TAG NOT FOUND");
        ShowDialogs.showdialog(context,
            msg: "TAG NUMBER NOT FOUND ${_assetID.text}.",
            title: "NOT FOUND",
            icons: Icon(Icons.stop),
            iconColors: Colors.green);
      } else {
        for (var chksn in checkSN.rows) {
          if (UserCredential().getUserType == "ADMIN") {
            _dpt.text = chksn.assoc()["Dpt"]!;
            _sN.text = chksn.assoc()["SerialNumber"]!;
            _location.text = chksn.assoc()["Location"]!;
            _des.text = chksn.assoc()["Descriptions"]!;
            adminGroup = chksn.assoc()["AdminGroup"]!;
            _notificationTo.text = chksn.assoc()["RecMobile"]!;
          } else {
            if (chksn.assoc()["Dpt"]! != UserCredential().getDpt) {
              ShowDialogs.showdialog(context,
                  msg:
                      "This Asset Register department is ${chksn.assoc()["Dpt"]!.toLowerCase()}.you can't submit ticket on this asset.",
                  title: "Not access",
                  icons: Icon(Icons.stop),
                  iconColors: Colors.green);
              clearData();
            } else {
              _dpt.text = chksn.assoc()["Dpt"]!;
              _sN.text = chksn.assoc()["SerialNumber"]!;
              _location.text = chksn.assoc()["Location"]!;
              _des.text = chksn.assoc()["Descriptions"]!;
              adminGroup = chksn.assoc()["AdminGroup"]!;
              _notificationTo.text = chksn.assoc()["RecMobile"]!;
            }
          }
        }
      }
      conn.close();
    } catch (e) {
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "SAVE ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
      print("$e");
    }
  }

  @override
  void initState() {
    super.initState();
    clearData();
    _assetID.text = widget.tagNo;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: CustomAppBar.appbar(
          sw: sw,
          titleText: 'NEW TICKETS/Create a new ticket',
          icon: Icons.new_releases),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _assetID,
                      autocorrect: false,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: '000001',
                        labletext: 'ASSET TAG',
                        icons: const Icon(Icons.add),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ButtonDecorations.buttonDecoration(
                        btnText: 'SCAN',
                        tcolors: Colors.white,
                        pcolors: Colors.cyan,
                        btnIcon: Icon(Icons.label),
                        onPressed: () {
                          scanAssets(context);
                        }),
                  )
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sN,
                      autocorrect: false,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: 'SNXXXXXX',
                        labletext: 'SERIAL NUMBER',
                        icons: const Icon(Icons.qr_code),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _location,
                      autocorrect: false,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: 'MEAT SHOP',
                        labletext: 'LOCATION',
                        icons: const Icon(Icons.location_city),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dpt,
                      autocorrect: false,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: 'MEAT SHOP',
                        labletext: 'DEPARTMENT',
                        icons: const Icon(Icons.departure_board),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _des,
                      autocorrect: false,
                      obscureText: false,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: 'DESCRIPTION',
                        labletext: 'DESCRIPTION OF THE ASSET',
                        icons: const Icon(Icons.details),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                        value: prioritySelect,
                        onChanged: (String? newValue) {
                          setState(() {
                            prioritySelect = newValue!;
                          });
                        },
                        items:
                            priorityDropdownItems.map<DropdownMenuItem<String>>(
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
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _details,
                      autocorrect: false,
                      obscureText: false,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: 'HARDWARE FALLER/NOT POWER ON ETC..',
                        labletext: 'DETAILS OF TICKET',
                        icons: const Icon(Icons.details),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _notificationTo,
                      autocorrect: false,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: '070xxxxxxx',
                        labletext: 'MOBILE NUMBER',
                        icons: const Icon(Icons.pending),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(adminGroup),
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ButtonDecorations.buttonDecoration(
                        btnText: 'SUMBIT REQUEST',
                        tcolors: Colors.white,
                        pcolors: Colors.cyan,
                        btnIcon: Icon(Icons.label),
                        onPressed: () {
                          if (_assetID.text.isEmpty ||
                              _sN.text.isEmpty ||
                              _location.text.isEmpty ||
                              _details.text.isEmpty) {
                          } else {
                            checkCompleatedTicket(context);
                          }
                        }),
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ButtonDecorations.buttonDecoration(
                        btnText: 'CLEAR',
                        tcolors: Colors.black,
                        pcolors: Colors.red,
                        btnIcon: Icon(Icons.clear),
                        onPressed: () {
                          clearData();
                        }),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

void clearData() {
  adminGroup = "";
  _assetID.text = '';
  _sN.text = '';
  _location.text = '';
  _dpt.text = '';
  _priority.text = '';
  _details.text = '';
  _notificationTo.text = '';
  _des.text = '';
}

Future<void> checkCompleatedTicket(BuildContext context) async {
  final conn = await ConnectionManager.createConnection();
  await conn.connect();
  var chkTicket = await conn.execute(
      "SELECT IdString,Location,TkCompleteDate,TkCompleteTime,Dpt FROM tbl_ticket WHERE TkSubmitBy='${UserCredential().getUserId}' and TktFB='0' and TicketStatus='COMPLETED'");
  if (chkTicket.rows.isEmpty) {
    tktAutoIDCreate(context);
  } else {
    for (var chktkts in chkTicket.rows) {
      FeedbackDialog.feedbackDialog(context,
          dpt: chktkts.assoc()["Dpt"].toString(),
          ticketNo: chktkts.assoc()["IdString"].toString(),
          location: chktkts.assoc()["Location"].toString(),
          compDate: chktkts.assoc()["TkCompleteDate"].toString() +
              "|" +
              chktkts.assoc()["TkCompleteTime"].toString(),
          icons: const Icon(Icons.add));
    }
  }
}

Future<void> tktAutoIDCreate(BuildContext context) async {
  try {
    WaitDialog.waitDialog(context, loadingNote: 'LOADING');
    String formattedIDno = '0';
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    var maxID = await conn.execute("select max(tktId) as ID from tbl_ticket");
    for (var max in maxID.rows) {
      var idString = max.assoc()["ID"];
      if (idString == null) {
        int idOnly = 1;
        String formattedIDno =
            '0' * (5 - idOnly.toString().length) + idOnly.toString();
        print(formattedIDno);
        tktRecord(context, idOnly, formattedIDno);
      } else {
        int selectdMaxID = int.parse(idString);
        int idOnly = selectdMaxID + 1;
        formattedIDno =
            '0' * (5 - idOnly.toString().length) + idOnly.toString();
        print(formattedIDno);
        tktRecord(context, idOnly, formattedIDno);
      }
    }
    conn.close();
  } catch (e) {
    ShowDialogs.showdialog(context,
        msg: "$e",
        title: "SAVE ERROR",
        icons: Icon(Icons.error),
        iconColors: Colors.red);
    print("$e");
  }
}

Future<void> tktRecord(
    BuildContext context, int idOnly, String formattedIDno) async {
  try {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    await conn.execute(
        "INSERT INTO tbl_ticket (`tktId`,`IdString`,`AssingTo`,`AdminGroup`,`AssetID`,`SN`,`Location`,`Dpt`,`TktPriority`,`TkDetails`,`TicketStatus`,`TktDeliveryDate`,`TkDeliveryTime`,`TkCompleteDate`,`TkCompleteTime`,`TkSubmitDate`,`TkSubmitTime`,`TkSubmitBy`,`TktTechWork`,`TktNotificationTo`)VALUES('${idOnly}','${formattedIDno}' ,'${""}' ,'${UserCredential().getAdmingroup}' ,'${_assetID.text}' ,'${_sN.text}','${_location.text}' ,'${_dpt.text}' ,'${prioritySelect}' ,'${_details.text}' ,'NEW' ,'${'1900-1-1'}' ,'${'12:00'}' ,'${'1900-1-1'}' ,'${'12:00'}' ,'${formattedDate}' ,'${formattedTime}' ,'${UserCredential().getUserId}','' ,'${_notificationTo.text}');");
    DBWritting.eventCapture(
        context,
        "Location:${_location.text} ${_dpt.text}\nIncident:${_details.text}\nPriority:${prioritySelect}",
        'New Incident #$formattedIDno submitted',
        _notificationTo.text,
        formattedIDno,
        formattedDate,
        formattedTime);

    ScanSMSNumber.scaningNumber(
        'NEW TICKET SUBMITTED.${formattedIDno} LOCATION ${_location.text + ' Dpt ' + _dpt.text + ' USER ' + UserCredential().getUserName.toString()}',
        'ADMIN_IT',
        'Tkt');

    if (_notificationTo.text.length == 10) {
      SendSMS.sendSms(_notificationTo.text,
          'NEW TICKET SUBMITTED.${formattedIDno} LOCATION ${_location.text + ' USER ' + UserCredential().getUserId.toString()} ');
    }
    Navigator.pop(context);
    ShowDialogs.showdialog(context as BuildContext,
        msg: "YOUR TICKET NO '${formattedIDno} SUBMITTED SUCCESSFULLY",
        title: "NEW TICKET SUBMITTED SUCCESSFULLY",
        icons: Icon(Icons.done),
        iconColors: Colors.green);
    conn.close();
    clearData();
  } catch (e) {
    Navigator.pop(context);
    ShowDialogs.showdialog(context,
        msg: "$e",
        title: "SAVE ERROR",
        icons: Icon(Icons.error),
        iconColors: Colors.red);
    print("$e");
  }
}
