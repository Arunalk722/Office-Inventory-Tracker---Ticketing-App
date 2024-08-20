import 'package:dart/user_screen/inventory_register.dart';
import 'package:dart/user_screen/new_service_request.dart';
import 'package:dart/widgets/csv_class.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class AsssetListView extends StatefulWidget {
  const AsssetListView({Key? key}) : super(key: key);
  @override
  State<AsssetListView> createState() => _AsssetListViewState();
}

class _AsssetListViewState extends State<AsssetListView> {
  late List<List<dynamic>> employeeData;
  final TextEditingController _tagNo = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _sN = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _dpt = TextEditingController();
  final List<String> assetTagNo = [];
  final List<String> serialNumber = [];
  final List<String> location = [];
  final List<String> dpt = [];
  final List<String> descriptions = [];
  final List<String> typeOf = [];
  final List<String> remarks = [];
  final List<String> recMobile = [];
  final List<String> statusOf = [];
  final List<String> userName = [];
  final List<String> enterBy = [];
  final List<String> enterDate = [];
  final List<String> enterTime = [];
  List<String> limits = ['30', '60', '90', '100', '300', '900', '1800'];
  String limitSelNo = "30";

  String? code;

  @override
  void initState() {
    super.initState();
  }

  Future<void> csv() async {
    try {
      if (assetTagNo.length >= 1) {
        List<List<String>> data = [
          [
            'Tag No',
            'Serial No',
            'Location',
            'Department',
            'Description',
            'Type',
            'Remarks',
            'Receiver Mobile',
            'Status',
            'User Name',
            'Entered By',
            'Enter Date',
            'Enter Time'
          ],
          for (int i = 0; i < assetTagNo.length; i++)
            [
              assetTagNo[i],
              serialNumber[i],
              location[i],
              dpt[i],
              descriptions[i],
              typeOf[i],
              remarks[i],
              recMobile[i],
              statusOf[i],
              userName[i],
              enterBy[i],
              enterDate[i],
              enterTime[i],
            ]
        ];
        TOCSVFile().csv(data, 'AssetList', context);
      } else {
        ShowDialogs.showdialog(context,
            msg: 'there no record to export.Please reload data',
            title: 'empty records',
            icons: Icon(Icons.hourglass_empty),
            iconColors: Colors.green);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getDataFromDB() async {
    try {
      assetTagNo.clear();
      serialNumber.clear();
      location.clear();
      dpt.clear();
      descriptions.clear();
      typeOf.clear();
      remarks.clear();
      recMobile.clear();
      statusOf.clear();
      userName.clear();
      enterBy.clear();
      enterDate.clear();
      enterTime.clear();

      WaitDialog.waitDialog(context, loadingNote: 'GETTING DATA');
      final conn = await ConnectionManager.createConnection();
      await conn.connect();

      String query = "";
      if (UserCredential().getUserType == "ADMIN") {
        query =
            'SELECT inv.*, ul.Name FROM tbl_inventory AS inv JOIN tbl_userlist AS ul ON ul.UserID = inv.EnterBy where inv.InvIdString LIKE "%${_tagNo.text}%" and inv.Location like "%${_location.text}%" and inv.SerialNumber like"%${_sN.text}%" and ul.UserName like"%${_userName.text}%" and inv.Dpt like "%${_dpt.text}%" limit $limitSelNo';
      } else {
        query =
            'SELECT inv.*, ul.Name FROM tbl_inventory AS inv JOIN tbl_userlist AS ul ON ul.UserID = inv.EnterBy where inv.InvIdString LIKE "%${_tagNo.text}%" and inv.Location like "%${_location.text}%" and inv.SerialNumber like"%${_sN.text}%" and inv.Dpt="${UserCredential().getDpt}" limit $limitSelNo';
      }
      print(query);

      conn.execute(query).then((results) {
        for (var row in results.rows) {
          assetTagNo.add(row.assoc()["InvIdString"].toString());
          serialNumber.add(row.assoc()["SerialNumber"].toString());
          location.add(row.assoc()["Location"].toString());
          dpt.add(row.assoc()["Dpt"].toString());
          descriptions.add(row.assoc()["Descriptions"].toString());
          typeOf.add(row.assoc()["Typeof"].toString());
          remarks.add(row.assoc()["Remarks"].toString());
          recMobile.add(row.assoc()["RecMobile"].toString().length < 8
              ? "NA"
              : row.assoc()["RecMobile"].toString());
          statusOf.add(row.assoc()["StatusOf"].toString());
          userName.add(row.assoc()["UserName"].toString());
          enterBy.add(row.assoc()["Name"].toString() == 'null'
              ? ""
              : row.assoc()["Name"].toString());
          enterDate.add(row.assoc()["EnterDate"].toString());
          enterTime.add(row.assoc()["EnterTime"].toString());
        }
        setState(() {});
      });

      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: CustomAppBar.appbar(
          sw: sw,
          titleText: 'INVENTORY VIEW/',
          icon: Icons.inventory_2_outlined),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
          ),
          SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    child: TextFormField(
                      controller: _tagNo,
                      autocorrect: false,
                      decoration: TxtOnlyInputDecorations.inputDecorations(
                        labletext: 'Asset Tag No',
                        hinttext: '00001',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _sN,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: '',
                      labelText: 'SERIAL NUMBER',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _location,
                  autocorrect: false,
                  decoration: TxtOnlyInputDecorations.inputDecorations(
                    hinttext: "COLD ROOM",
                    labletext: "Location",
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: TextFormField(
                    controller: _dpt,
                    autocorrect: false,
                    decoration: TxtOnlyInputDecorations.inputDecorations(
                      labletext: 'Department',
                      hinttext: 'IT',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: limitSelNo,
                      onChanged: (String? statusValue) {
                        setState(() {
                          limitSelNo = statusValue!;
                        });
                      },
                      items: limits.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      decoration: InputDecoration(
                        labelText: "Limit",
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    child: TextFormField(
                      controller: _userName,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'John Doe',
                        labelText: 'User Name',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.location_city),
                          onPressed: () {
                            getDataFromDB();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: assetTagNo.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    YNSendToNewForm.ynDialogMessage(context,
                            messageBody:
                                'Would you like to create a new ticket?',
                            messageTitle: 'Ticket ${assetTagNo[index]}',
                            iconFile: Icon(Icons.airplane_ticket),
                            iconColor: Colors.black,
                            btnDone: 'Yes',
                            btnClose: 'No')
                        .then((value) {
                      if (value == "Y") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewTicket(
                                      tagNo: assetTagNo[index],
                                    )));
                      }
                    });
                  },
                  onLongPress: () {
                    if (UserCredential().getUserType == "ADMIN" ||
                        UserCredential().getUserType == "SUPPORT") {
                      YNSendToNewForm.ynDialogMessage(context,
                              messageBody:
                                  'Would you like to edit the inventory item?',
                              messageTitle: 'Edit ${assetTagNo[index]}',
                              iconFile: Icon(Icons.add_circle_outline_sharp),
                              iconColor: Colors.black,
                              btnDone: 'Edit',
                              btnClose: 'No')
                          .then((value) {
                        if (value == "Y") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InventoryRegister(
                                        tagNo: assetTagNo[index],
                                      )));
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Center(
                            child: Text(
                              'Asset Tag: ${assetTagNo[index]}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(137, 1, 4, 152),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          tileColor: Color.fromARGB(255, 250, 255, 179),
                        ),
                        _buildDetailRow('Serial No', '${serialNumber[index]}'),
                        _buildDetailRow(
                            'Location', '${location[index]} ${dpt[index]}'),
                        _buildDetailRow(
                            'Descriptions', '${descriptions[index]}'),
                        _buildDetailRow('Category', '${typeOf[index]}'),
                        _buildDetailRow('Remarks', '${remarks[index]}'),
                        _buildDetailRow('Status', '${statusOf[index]}'),
                        _buildDetailRow('Record', '${enterBy[index]}'),
                        _buildDetailRow('Enter Date',
                            '${enterDate[index]} ${enterTime[index]}'),
                        _buildDetailRow('Mobile',
                            '${recMobile[index] == "null" ? "Not yet updated" : recMobile[index]}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          csv();
        },
        tooltip: "Export",
        child: Text("CSV"),
      ),
    );
  }
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            ":" + value,
            style: TextStyle(
              fontSize: 16,
              color: value == "DAMAGE"
                  ? Colors.red
                  : value == "WORKING"
                      ? Colors.green
                      : Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
