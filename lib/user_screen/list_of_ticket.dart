import 'package:dart/user_screen/service_technical_support.dart';
import 'package:dart/user_screen/service_view_logList.dart';
import 'package:dart/widgets/csv_class.dart';
import 'package:flutter/material.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class ListOfTickets extends StatefulWidget {
  const ListOfTickets({super.key});

  @override
  State<ListOfTickets> createState() => _ListOfTicketsState();
}

final TextEditingController _ticktId = TextEditingController();
final TextEditingController _sN = TextEditingController();
final TextEditingController _dpt = TextEditingController();
final TextEditingController _location = TextEditingController();

final List<String> ticketNo = [];
final List<String> assetTag = [];
final List<String> serialNumber = [];
final List<String> location = [];
final List<String> department = [];
final List<String> ticketInfo = [];
final List<String> techInfo = [];
final List<String> assignTo = [];
final List<String> adminGroup = [];
final List<String> deliveryDate = [];
final List<String> deliveryTime = [];
final List<String> completeDate = [];
final List<String> completeTime = [];
final List<String> recordDate = [];
final List<String> recordTime = [];
final List<String> submitBy = [];

List<String> limits = ['30', '60', '90', '100', '300'];
String limitSelNo = "30";

List<String> ticketStatusItem = ['', 'NEW', 'PENDING', 'HOLD', 'COMPLETED'];
String ticketStatusSelect = 'NEW';

class _ListOfTicketsState extends State<ListOfTickets> {
  void clearArrays() {
    ticketNo.clear();
    assetTag.clear();
    serialNumber.clear();
    location.clear();
    department.clear();
    ticketInfo.clear();
    techInfo.clear();
    assignTo.clear();
    adminGroup.clear();
    deliveryDate.clear();
    deliveryTime.clear();
    completeDate.clear();
    completeTime.clear();
    recordDate.clear();
    recordTime.clear();
    submitBy.clear();
  }

  Future<void> getTicketList() async {
    WaitDialog.waitDialog(context, loadingNote: 'LOADING');
    clearArrays();
    final conn = await ConnectionManager.createConnection();
    await conn.connect();

    String query = "";
    if (UserCredential().getUserType == "ADMIN") {
      query =
          "SELECT t.*, u.UserName FROM tbl_ticket t JOIN tbl_userlist u ON t.TkSubmitBy = u.UserID WHERE t.IdString LIKE '%${_ticktId.text}%' AND t.Location LIKE '%${_location.text}%' AND t.Dpt LIKE '%${_dpt.text}%' AND t.SN LIKE '%${_sN.text}%' AND t.TicketStatus LIKE '%${ticketStatusSelect}%' ORDER BY t.IdString DESC LIMIT $limitSelNo";
    } else if (UserCredential().getUserType == "SUPPORT") {
      query =
          "SELECT t.*, u.UserName FROM tbl_ticket t JOIN tbl_userlist u ON t.TkSubmitBy = u.UserID WHERE t.IdString LIKE '%${_ticktId.text}%' AND t.Location LIKE '%${_location.text}%' AND t.Dpt LIKE '%${_dpt.text}%' AND t.AssingTo='${UserCredential().getUserName}' AND t.SN LIKE '%${_sN.text}%' AND t.TicketStatus LIKE '%${ticketStatusSelect}%' ORDER BY t.IdString DESC LIMIT $limitSelNo";
    }

    conn.execute(query).then((results) {
      for (var row in results.rows) {
        ticketNo.add(row.assoc()["IdString"].toString());
        assetTag.add(row.assoc()["AssetID"].toString());
        serialNumber.add(row.assoc()["SN"].toString());
        location.add(row.assoc()["Location"].toString());
        department.add(row.assoc()["Dpt"].toString());
        ticketInfo.add(row.assoc()["TkDetails"].toString());
        techInfo.add(row.assoc()["TktTechWork"].toString());
        assignTo.add(row.assoc()["AssingTo"].toString());
        adminGroup.add(row.assoc()["AdminGroup"].toString());
        deliveryDate.add(row.assoc()["TktDeliveryDate"].toString());
        deliveryTime.add(row.assoc()["TkDeliveryTime"].toString());
        completeDate.add(row.assoc()["TkCompleteDate"].toString());
        completeTime.add(row.assoc()["TkCompleteTime"].toString());
        recordDate.add(row.assoc()["TkSubmitDate"].toString());
        recordTime.add(row.assoc()["TkSubmitTime"].toString());
        submitBy.add(row.assoc()["UserName"].toString());
      }
      conn.close();
      setState(() {});
    });
    Navigator.pop(context);
  }

  Future<void> csv() async {
    try {
      if (ticketNo.length >= 1) {
        List<List<String>> data = [
          [
            'Ticket No',
            'Asset Tag',
            'Serial Number',
            'Location',
            'Department',
            'Ticket Info',
            'Tech Info',
            'Assign To',
            'Admin Group',
            'Delivery Date',
            'Delivery Time',
            'Complete Date',
            'Complete Time',
            'Record Date',
            'Record Time',
            'Submit By'
          ],
          for (int i = 0; i < ticketNo.length; i++)
            [
              ticketNo[i],
              assetTag[i],
              serialNumber[i],
              location[i],
              department[i],
              ticketInfo[i],
              techInfo[i],
              assignTo[i],
              adminGroup[i],
              deliveryDate[i],
              deliveryTime[i],
              completeDate[i],
              completeTime[i],
              recordDate[i],
              recordTime[i],
              submitBy[i],
            ]
        ];

        await TOCSVFile().csv(data, 'TicketList', context);
      } else {
        ShowDialogs.showdialog(
          context,
          msg: 'There is no record to export. Please reload data',
          title: 'Empty Records',
          icons: Icon(Icons.hourglass_empty),
          iconColors: Colors.green,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar.appbar(
          sw: sw,
          titleText: 'LIST OF TICKETS/',
          icon: Icons.airplane_ticket_sharp),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            _buildSearchFields(),
            const SizedBox(height: 10),
            _buildDropdowns(),
            Expanded(child: _buildTicketList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          csv();
        },
        tooltip: "Export to",
        child: Text("CSV"),
      ),
    );
  }

  Widget _buildSearchFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ticktId,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: TxtOnlyInputDecorations.inputDecorations(
                  hinttext: "00001",
                  labletext: "ASSET TAG",
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                autocorrect: false,
                controller: _sN,
                decoration: TxtOnlyInputDecorations.inputDecorations(
                  hinttext: "SNXXXXXXX",
                  labletext: "SERIAL NUMBER",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                autocorrect: false,
                controller: _location,
                decoration: TxtOnlyInputDecorations.inputDecorations(
                  hinttext: "LOCATION",
                  labletext: "KOSGAMA",
                ),
              ),
            ),
            Expanded(
              child: TextField(
                autocorrect: false,
                controller: _dpt,
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  labelText: 'User Name',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      getTicketList();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: ticketStatusSelect,
            onChanged: (String? statusValue) {
              setState(() {
                ticketStatusSelect = statusValue!;
              });
            },
            items: ticketStatusItem.map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            decoration: InputDecoration(
              labelText: "Ticket Status",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: limitSelNo,
            onChanged: (String? limitValue) {
              setState(() {
                limitSelNo = limitValue!;
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
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: ticketNo.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(
              'Ticket No:#${ticketNo[index]}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Asset Tag', assetTag[index]),
                _buildDetailRow('Serial Number', serialNumber[index]),
                _buildDetailRow('Location', location[index]),
                _buildDetailRow('Department', department[index]),
                _buildDetailRow('Ticket Info', ticketInfo[index]),
                _buildDetailRow(
                    'Tech Info',
                    techInfo[index].length < 2
                        ? 'Not yet updated'
                        : techInfo[index]),
                _buildDetailRow(
                    'Assigned To',
                    assignTo[index].length < 2
                        ? 'Not Assigned'
                        : assignTo[index]),
                _buildDetailRow('Admin Group', adminGroup[index]),
                _buildDetailRow(
                    'Delivery Date',
                    deliveryDate[index] == '1900-01-01'
                        ? 'Not delivered'
                        : '${deliveryDate[index]} ${deliveryTime[index]}'),
                _buildDetailRow(
                    'Complete Date',
                    completeDate[index] == '1900-01-01'
                        ? 'Not completed'
                        : '${completeDate[index]} ${completeTime[index]}'),
                _buildDetailRow(
                    'Record Date', '${recordDate[index]} ${recordTime[index]}'),
                _buildDetailRow('Submitted By', submitBy[index]),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              if (UserCredential().getUserType == "ADMIN" ||
                  UserCredential().getUserType == "SUPPORT") {
                YNSendToNewForm.ynDialogMessage(
                  context,
                  messageBody:
                      'Would you like to VIEW ticket log or EDIT ticket ${ticketNo[index]} log?',
                  messageTitle: 'Show Ticket',
                  iconFile: Icon(Icons.view_agenda),
                  iconColor: Colors.black,
                  btnDone: 'View',
                  btnClose: 'Edit',
                ).then((value) {
                  if (value == "Y") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceLogList(
                          ticketNo: ticketNo[index],
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TechnicalUpdate(
                          tktID: ticketNo[index],
                        ),
                      ),
                    );
                  }
                });
              }
            },
          ),
        );
      },
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
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: value == "Not delivered"
                  ? Colors.red
                  : value == "Not completed"
                      ? Colors.red
                      : value == "Not yet updated"
                          ? Colors.red[300]
                          : value == "Not Assigned"
                              ? Colors.red[400]
                              : Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
