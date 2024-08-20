import 'package:dart/user_screen/initiate_upgrade.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class InventoryRegister extends StatefulWidget {
  final String tagNo;
  const InventoryRegister({Key? key, required this.tagNo}) : super(key: key);
  @override
  State<InventoryRegister> createState() => _InventoryRegisterState();
}

final TextEditingController _sN = TextEditingController();
final TextEditingController _userName = TextEditingController();
final TextEditingController _desc = TextEditingController();
final TextEditingController _remarks = TextEditingController();
final TextEditingController _receiverPhoneNo = TextEditingController();
final TextEditingController _tagNO = TextEditingController();
bool showQRScanner = false;
String _locationSelectedItem = '';
final List<String> _locationlist = [];
String _dptSelectedItem = '';
final List<String> _dptlist = [];
String? code;
final List<String> typeOfAssetList = [];
final List<String> typeDropdownItems = [];
List<String> statusDropdownItems = [
  'WORKING',
  'DAMAGE',
];
String statusSelect = 'WORKING';
String typeSelect = '';
String locationSelectItem = '';
String dptSelectdItem = '';

class _InventoryRegisterState extends State<InventoryRegister> {
  @override
  void initState() {
    super.initState();
    listTypeofAssetFromDB();
    if (_dptlist.isEmpty) {
      getDpt();
    }
    clearText();
    _tagNO.text = widget.tagNo;
  }

  Future<void> listTypeofAssetFromDB() async {
    try {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      typeDropdownItems.clear();
      var lists = "";

      conn.execute('SELECT * FROM tbl_assettype').then((results) {
        for (var row in results.rows) {
          lists = (row.assoc()['TypeOf'].toString());
          typeDropdownItems.add(lists);
        }
        print(typeDropdownItems);
      });

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void resetDropdownValues() {
    setState(() {
      typeSelect = '';
      statusSelect = 'WORKING';
    });
  }

  void scanAssets(BuildContext context) async {
    try {
      WaitDialog.waitDialog(context, loadingNote: 'LOADING');

      String formattedIDno;

      if (_tagNO.text.isNotEmpty) {
        if (int.tryParse(_tagNO.text) != null) {
          int idOnly = int.parse(_tagNO.text);
          formattedIDno =
              '0' * (5 - idOnly.toString().length) + idOnly.toString();
          _tagNO.text = formattedIDno;
        } else {
          formattedIDno = _tagNO.text;
        }
      } else {
        formattedIDno = '';
      }
      String querySelection = "";
      if (_sN.text.length > 4) {
        querySelection =
            "SELECT * FROM tbl_inventory WHERE SerialNumber='${_sN.text}'";
      } else if (_tagNO.text.length >= 2) {
        querySelection =
            "SELECT * FROM tbl_inventory WHERE InvIdString='${_tagNO.text}'";
      }
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      var checkDATA = await conn.execute(querySelection);
      if (checkDATA.rows.isEmpty) {
        print("TAG NOT FOUND");

        Navigator.pop(context);
        ShowDialogs.showdialog(context,
            msg: "TAG/SERIAL NUMBER NOT FOUND ${_tagNO.text}.",
            title: "NOT FOUND",
            icons: Icon(Icons.stop),
            iconColors: Colors.red);
      } else {
        for (var chksn in checkDATA.rows) {
          Navigator.pop(context);
          if (UserCredential().getUserType != "ADMIN" &&
              UserCredential().getDpt != chksn.assoc()["Dpt"].toString()) {
            ShowDialogs.showdialog(context,
                msg: 'ITEM NOT REGISTERED TO DIFFERENT DEPARTMENT',
                title: 'NOT VALID',
                icons: Icon(Icons.stop),
                iconColors: Colors.red);
            clearText();
          } else {
            _tagNO.text = chksn.assoc()["InvIdString"].toString();
            _sN.text = chksn.assoc()["SerialNumber"].toString();
            _desc.text = chksn.assoc()["Descriptions"].toString();
            _dptSelectedItem = (chksn.assoc()["Dpt"].toString());
            _locationSelectedItem = chksn.assoc()["Location"].toString();
            _userName.text = chksn.assoc()["UserName"].toString() == 'null'
                ? ""
                : chksn.assoc()["UserName"].toString();
            setState(() {
              typeSelect = chksn.assoc()["Typeof"].toString();
              statusSelect = chksn.assoc()["StatusOf"].toString();
            });
            _remarks.text = chksn.assoc()["Remarks"].toString();
            _receiverPhoneNo.text =
                chksn.assoc()["RecMobile"].toString() == 'null'
                    ? ""
                    : chksn.assoc()["RecMobile"].toString();
          }
        }
      }
      conn.close();
      setState(() {});
    } catch (e) {
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "SCANING ERROR",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
      print("$e");
    }
  }

  Future<void> getLocation(String _baseLocation) async {
    WaitDialog.waitDialog(context, loadingNote: 'LOADING');

    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    _locationlist.clear();
    conn
        .execute('SELECT * FROM tbl_locations  where Dpt="$_baseLocation"')
        .then((results) {
      for (var row in results.rows) {
        _locationlist.add(row.assoc()["Location"].toString());
      }

      setState(() {});
    });
    Navigator.pop(context);
  }

  Future<void> getDpt() async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    _dptlist.clear();
    String query = "";
    if (UserCredential().getUserType != 'ADMIN') {
      query = "SELECT * FROM tbl_dpt where dpt='${UserCredential().getDpt}'";
    } else {
      query = 'SELECT * FROM tbl_dpt';
    }
    conn.execute(query).then((results) {
      for (var row in results.rows) {
        _dptlist.add(row.assoc()["dpt"].toString());
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: CustomAppBar.appbar(
          sw: sw,
          titleText: 'INVENTORY MANAGE/Assets',
          icon: Icons.inventory_sharp),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 1,
                                  offset: Offset(10, 10),
                                )
                              ]),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                child: Form(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _tagNO,
                                              autocorrect: false,
                                              decoration: InputDecorations
                                                  .inputDecoration(
                                                hinttext: '000001',
                                                labletext: 'TAG NO',
                                                icons:
                                                    const Icon(Icons.qr_code),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              textStyle:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                            onPressed: () {
                                              scanAssets(context);
                                            },
                                            child: const Text('SCAN'),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _sN,
                                              autocorrect: false,
                                              decoration: InputDecorations
                                                  .inputDecoration(
                                                hinttext: 'SNXXXXXX',
                                                labletext: 'SERIAL NUMBER',
                                                icons:
                                                    const Icon(Icons.qr_code),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            iconSize: 30,
                                            icon: const Icon(Icons.qr_code),
                                            onPressed: () async {
                                              var res = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SimpleBarcodeScannerPage()));
                                              setState(() {
                                                if (res is String) {
                                                  _sN.text = res.toString();
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Column(
                                        children: [
                                          Autocomplete<String>(
                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              return _dptlist
                                                  .where((String option) {
                                                return option
                                                    .toLowerCase()
                                                    .contains(textEditingValue
                                                        .text
                                                        .toLowerCase());
                                              });
                                            },
                                            onSelected: (String dptSelection) {
                                              setState(() {
                                                _dptSelectedItem = dptSelection;
                                                getLocation(dptSelection);
                                              });
                                            },
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                TextEditingController
                                                    textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextFormField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                decoration: InputDecorations
                                                    .inputDecoration(
                                                  hinttext: 'DEPARTMENT',
                                                  labletext: '',
                                                  icons: const Icon(
                                                      Icons.departure_board),
                                                ),
                                              );
                                            },
                                          ),
                                          if (_dptSelectedItem.isNotEmpty)
                                            (Text(
                                              "REG DPT. :" + _dptSelectedItem,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Autocomplete<String>(
                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              return _locationlist
                                                  .where((String option) {
                                                return option
                                                    .toLowerCase()
                                                    .contains(textEditingValue
                                                        .text
                                                        .toLowerCase());
                                              });
                                            },
                                            onSelected: (String selection) {
                                              setState(() {
                                                _locationSelectedItem =
                                                    selection;
                                              });
                                            },
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                _location,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextFormField(
                                                controller: _location,
                                                focusNode: focusNode,
                                                decoration: InputDecorations
                                                    .inputDecoration(
                                                  hinttext: 'LOCATION',
                                                  labletext: '',
                                                  icons: const Icon(
                                                      Icons.location_off),
                                                ),
                                              );
                                            },
                                          ),
                                          if (_locationSelectedItem.isNotEmpty)
                                            Text(
                                              "REG LOC. :" +
                                                  _locationSelectedItem,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )
                                        ],
                                      ),
                                      TextFormField(
                                        controller: _desc,
                                        autocorrect: false,
                                        obscureText: false,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: 'DESCRIPTIONS',
                                          labletext: 'DESCRIPTIONS',
                                          icons: const Icon(Icons.description),
                                        ),
                                      ),
                                      DropdownButtonFormField<String>(
                                          value: statusSelect,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              statusSelect = newValue!;
                                            });
                                          },
                                          items: statusDropdownItems
                                              .map<DropdownMenuItem<String>>(
                                            (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            },
                                          ).toList()),
                                      DropdownButtonFormField<String>(
                                          value: typeSelect,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              typeSelect = newValue!;
                                            });
                                          },
                                          items: typeDropdownItems
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList()),
                                      TextFormField(
                                        controller: _remarks,
                                        autocorrect: false,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: 'REMARKS',
                                          labletext: 'REMARKS',
                                          icons: const Icon(
                                              Icons.remove_from_queue_sharp),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _receiverPhoneNo,
                                        autocorrect: false,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: '071xxxxxxx',
                                          labletext: 'RECEIVER MOBILE',
                                          icons: const Icon(Icons.phone),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _userName,
                                        autocorrect: false,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: 'Sam wilson',
                                          labletext: 'User Name',
                                          icons: const Icon(Icons.person),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        height: 50,
                                      ),
                                      ButtonDecorations.buttonDecoration(
                                        btnText: 'REGISTER NEW ITEM',
                                        tcolors: Colors.white,
                                        pcolors: Colors.green,
                                        btnIcon: Icon(Icons.new_label),
                                        onPressed: () {
                                          insertCheck(context);
                                        },
                                      ),
                                      SizedBox(
                                        width: 40,
                                        height: 20,
                                      ),
                                      ButtonDecorations.buttonDecoration(
                                        btnText: 'UPDATE INVENTORY',
                                        tcolors: Colors.white,
                                        pcolors: Colors.cyan,
                                        btnIcon: Icon(Icons.update),
                                        onPressed: () {
                                          upgradeConf(context);
                                        },
                                      ),
                                      SizedBox(
                                        width: 40,
                                        height: 20,
                                      ),
                                      ButtonDecorations.buttonDecoration(
                                        btnText: 'Item Add-On',
                                        tcolors: Colors.white,
                                        pcolors: Colors.indigo,
                                        btnIcon: Icon(Icons.add_box_rounded),
                                        onPressed: () {
                                          AddOnSubItemUpgrade.inputDialog(
                                              context,
                                              assetTag: _tagNO.text,
                                              serialNumber: _sN.text,
                                              notificationTo:
                                                  _receiverPhoneNo.text,
                                              icons:
                                                  Icon(Icons.inbox_outlined));
                                        },
                                      ),
                                      SizedBox(
                                        width: 40,
                                        height: 20,
                                      ),
                                      ButtonDecorations.buttonDecoration(
                                        btnText: 'UPGRADE LIST',
                                        tcolors: Colors.white,
                                        pcolors: Colors.black26,
                                        btnIcon: Icon(Icons.inventory),
                                        onPressed: () {
                                          if (_tagNO.text.length >= 5) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InitiateUpgrade(
                                                          stringAssetID:
                                                              _tagNO.text,
                                                          description:
                                                              _desc.text,
                                                          dpt: _dptSelectedItem,
                                                          location:
                                                              _locationSelectedItem,
                                                          remarks:
                                                              _remarks.text,
                                                          sn: _sN.text,
                                                        )));
                                          } else {
                                            ShowDialogs.showdialog(context,
                                                msg:
                                                    "PLEASE ENTER TAG NUMBER FOR SCANNING.",
                                                title: "TAG NUMBER REQUIRED",
                                                icons: Icon(Icons.read_more),
                                                iconColors: Colors.red);
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        width: 40,
                                        height: 20,
                                      ),
                                      ButtonDecorations.buttonDecoration(
                                        btnText: 'CLEAR TEXT',
                                        tcolors: Colors.white,
                                        pcolors: Colors.red,
                                        btnIcon: Icon(Icons.cleaning_services),
                                        onPressed: () {
                                          YNDialogCon.ynDialogMessage(context,
                                                  messageBody:
                                                      'WOULD YOU LIKE TO CLEAR THE LAYOUT IN SELECTED ITEM RECORDS?',
                                                  messageTitle: 'CLEAR LAYOUT',
                                                  iconFile: Icon(
                                                      Icons.cleaning_services),
                                                  iconColor: Colors.black,
                                                  btnDone: "CLEAR",
                                                  btnClose: "NO")
                                              .then((value) {
                                            if (value == "Y") {
                                              WaitDialog.waitDialog(context,
                                                  loadingNote: 'LOADING');
                                              clearText();
                                              Navigator.pop(context);
                                            } else {}
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clearText() {
    _tagNO.clear();
    _sN.clear();
    _desc.clear();
    resetDropdownValues();
    _remarks.text = '';
    _userName.text = '';
    _receiverPhoneNo.clear();
    _locationlist.clear();
    _locationSelectedItem = "";
    _dptSelectedItem = "";
    getDpt();
  }
}

int loggedUserName = UserCredential().getUserId;

Future<void> insertCheck(BuildContext context) async {
  try {
    WaitDialog.waitDialog(context, loadingNote: 'LOADING');
    if (_sN.text.isEmpty) {
      ShowDialogs.showdialog(context,
          msg: "SERIAL NUMBER IS EMPTY",
          title: "EMPTY STRING",
          icons: Icon(Icons.error),
          iconColors: Colors.blue);
    } else if (_locationSelectedItem.isEmpty) {
      ShowDialogs.showdialog(context,
          msg: "LOCATION IS EMPTY",
          title: "EMPTY STRING",
          icons: Icon(Icons.error),
          iconColors: Colors.blue);
    } else if (_dptSelectedItem.isEmpty) {
      ShowDialogs.showdialog(context,
          msg: "DEPARTMENT IS EMPTY",
          title: "EMPTY STRING",
          icons: Icon(Icons.error),
          iconColors: Colors.blue);
    } else if (_desc.text.isEmpty) {
      ShowDialogs.showdialog(context,
          msg: "DESCRIPTIONS IS EMPTY",
          title: "EMPTY STRING",
          icons: Icon(Icons.error),
          iconColors: Colors.blue);
    } else if (_remarks.text.isEmpty) {
      ShowDialogs.showdialog(context,
          msg: "REMARKS IS EMPTY",
          title: "EMPTY STRING",
          icons: Icon(Icons.error),
          iconColors: Colors.blue);
    } else {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      var checkSN = await conn.execute(
          "SELECT * FROM tbl_inventory WHERE SerialNumber='${_sN.text}'");
      if (checkSN.rows.isEmpty) {
        print("SERIAL NOT FOUND");
        Navigator.pop(context);
        createNewRecord(context);
      } else {
        for (var chksn in checkSN.rows) {
          var idString = chksn.assoc()["ID"];
          if (idString != null) {
            Navigator.pop(context);
            ShowDialogs.showdialog(context,
                msg:
                    "SERIAL NUMBER ALREADY REGISTED TO TAG NUMBER ${chksn.assoc()['InvIdString']}.",
                title: "FOUND SERIAL NUMBER",
                icons: Icon(Icons.stop),
                iconColors: Colors.red);
          }
        }
      }

      conn.close();
    }
  } catch (e) {
    ShowDialogs.showdialog(context,
        msg: "$e",
        title: "SAVE ERROR",
        icons: Icon(Icons.error),
        iconColors: Colors.red);
    print("$e");
  }
}

Future<void> createNewRecord(BuildContext context) async {
  YNDialogCon.ynDialogMessage(context,
          messageBody: 'ARE YOU SURE TO INSERT NEW INVENTORY?',
          messageTitle: 'NEW ITEM RECORD',
          iconFile: Icon(Icons.add),
          iconColor: Colors.black,
          btnDone: "YES",
          btnClose: "NO")
      .then((value) {
    if (value == "Y") {
      WaitDialog.waitDialog(context, loadingNote: 'LOADING');
      idCreate(context);
    } else {}
  });
}

Future<void> idCreate(BuildContext context) async {
  try {
    String formattedIDno = '0';
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    var maxID = await conn.execute("select max(ID) from tbl_inventory");
    for (var max in maxID.rows) {
      var idString = max.assoc()["max(ID)"];
      if (idString == null) {
        int idOnly = 1;
        String formattedIDno =
            '0' * (5 - idOnly.toString().length) + idOnly.toString();
        print(formattedIDno);
        insetDataInventory(context, idOnly, formattedIDno);
      } else {
        int selectdMaxID = int.parse(idString);
        int idOnly = selectdMaxID + 1;
        formattedIDno =
            '0' * (5 - idOnly.toString().length) + idOnly.toString();
        print(formattedIDno);
        insetDataInventory(context, idOnly, formattedIDno);
      }
    }
    conn.close();
  } catch (e) {
    ShowDialogs.showdialog(context,
        msg: "$e",
        title: "ID ERROR",
        icons: Icon(Icons.error),
        iconColors: Colors.red);
    print("$e");
  }
}

Future<void> insetDataInventory(
    BuildContext context, int idOnly, String formattedIDno) async {
  try {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    await conn.execute(
        "INSERT INTO tbl_inventory(`ID`,`InvIdString`,`SerialNumber`,`Location`,`Dpt`,`AdminGroup`,`Descriptions`,`Typeof`,`StatusOf`,`Remarks`,`RecMobile`,`UserName`,`EnterBy`,`EnterDate`,`EnterTime`)VALUES('${idOnly}','${formattedIDno}','${_sN.text}','${_locationSelectedItem}','${_dptSelectedItem}','${UserCredential().getAdmingroup}','${_desc.text}','${typeSelect}','${statusSelect}','${_remarks.text}','${_receiverPhoneNo.text}','${_userName.text}','${UserCredential().getUserId}','${formattedDate}','${formattedTime}');");
    await conn.execute(
        "INSERT INTO tbl_inventoryold(`InvIdString`,`SerialNumber`,`Location`,`Dpt`,`AdminGroup`,`Descriptions`,`Typeof`,`StatusOf`,`Remarks`,`RecMobile`,`UserName`,`EnterBy`,`EnterDate`,`EnterTime`)VALUES('${formattedIDno}','${_sN.text}','${_locationSelectedItem}','${_dptSelectedItem}','${UserCredential().getAdmingroup}','${_desc.text}','${typeSelect}','${statusSelect}','${_remarks.text}','${_receiverPhoneNo.text}','${_userName.text}','${UserCredential().getUserId}','${formattedDate}','${formattedTime}');");

    await ScanSMSNumber.scaningNumber(
        'ITEM REGISTRATION SUCCESSFUL TAG NO ${formattedIDno} LOCATION ${_locationSelectedItem} ${_dptSelectedItem} SN :${_sN.text}',
        UserCredential().getAdmingroup,
        "II");
    Navigator.pop(context);
    if (_receiverPhoneNo.text.length == 10) {
      await SendSMS.sendSms(_receiverPhoneNo.text,
          'ITEM REGISTRATION SUCCESSFUL TAG NO ${formattedIDno} LOCATION ${_locationSelectedItem} ${_dptSelectedItem} SN :${_sN.text}');
      Navigator.pop(context);
    }
    ShowDialogs.showdialog(context as BuildContext,
        msg: "ITEM REGISTRATION SUCCESSFUL TAG NO '${formattedIDno}.",
        title: "SUCCESSFUL INVENTORY INSERT",
        icons: Icon(Icons.done),
        iconColors: Colors.green);
    Navigator.pop(context);

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

Future<void> upgradeConf(BuildContext context) async {
  YNDialogCon.ynDialogMessage(context,
          messageBody: 'ARE YOU SURE TO UPDATE EXISTING INVENTORY RECORDS?',
          messageTitle: 'UPGRADE RECORD',
          iconFile: Icon(Icons.upgrade),
          iconColor: Colors.black,
          btnDone: "YES",
          btnClose: "NO")
      .then((value) {
    if (value == "Y") {
      WaitDialog.waitDialog(context, loadingNote: 'LOADING');
      updateInventory(context);
    } else {}
  });
}

Future<void> updateInventory(BuildContext context) async {
  try {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    await conn.execute(
        "UPDATE tbl_inventory SET SerialNumber = '${_sN.text}', Location = '${_locationSelectedItem}', Dpt = '${_dptSelectedItem}', AdminGroup = '${UserCredential().getAdmingroup}', Descriptions = '${_desc.text}', Typeof = '${typeSelect}', StatusOf = '${statusSelect}', Remarks = '${_remarks.text}', RecMobile = '${_receiverPhoneNo.text}', EnterBy = '${UserCredential().getUserId}',UserName='${_userName.text}', EnterDate = '${formattedDate}', EnterTime = '${formattedTime}' WHERE InvIdString = '${_tagNO.text}';");
    await conn.execute(
        "INSERT INTO tbl_inventoryold(`InvIdString`,`SerialNumber`,`Location`,`Dpt`,`AdminGroup`,`Descriptions`,`Typeof`,`StatusOf`,`Remarks`,`RecMobile`,`UserName`,`EnterBy`,`EnterDate`,`EnterTime`)VALUES('${_tagNO.text}','${_sN.text}','${_locationSelectedItem}','${_dptSelectedItem}','${UserCredential().getAdmingroup}','${_desc.text}','${typeSelect}','${statusSelect}','${_remarks.text}','${_receiverPhoneNo.text}','${_userName.text}','${UserCredential().getUserId}','${formattedDate}','${formattedTime}');");
    await ScanSMSNumber.scaningNumber(
        'ITEM REGISTRATION SUCCESSFUL TAG NO ${_tagNO.text} LOCATION ${_locationSelectedItem} Dpt ${_dptSelectedItem}',
        UserCredential().getAdmingroup,
        "II");
    if (_receiverPhoneNo.text.length == 10) {
      await SendSMS.sendSms(_receiverPhoneNo.text,
          'ITEM REGISTRATION ON TAG NO ${_tagNO.text} LOCATION ${_locationSelectedItem} Dpt ${_dptSelectedItem}');
    }
    Navigator.pop(context);
    ShowDialogs.showdialog(context as BuildContext,
        msg: "ITEM UPDATE SUCCESSFUL TAG NO '${_tagNO.text}.",
        title: "SUCCESSFUL INVENTORY UPDATE",
        icons: Icon(Icons.done),
        iconColors: Colors.green);
    await conn.close();
  } catch (e) {
    ShowDialogs.showdialog(context,
        msg: "$e",
        title: "UPDATE ERROR",
        icons: Icon(Icons.error),
        iconColors: Colors.red);
    print("$e");
  }
}
