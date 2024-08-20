import 'package:dart/widgets/csv_class.dart';
import 'package:flutter/material.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class ConsumablesStockIssueRecord extends StatefulWidget {
  const ConsumablesStockIssueRecord({super.key});

  @override
  State<ConsumablesStockIssueRecord> createState() =>
      _ConsumablesStockIssueRecordState();
}

class _ConsumablesStockIssueRecordState
    extends State<ConsumablesStockIssueRecord> {
  final TextEditingController _itemName = TextEditingController();
  final TextEditingController _dpt = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final List<String> categoryText = [];
  final List<String> locationText = [];
  final List<String> dptText = [];
  final List<String> stockLocation = [];
  final List<String> issuedDate = [];
  final List<String> issedBy = [];
  final List<String> qty = [];
  final List<String> remarks = [];
  final List<String> issueTime = [];
  final List<String> typeOf = [];
  final List<String> stockInHand = [];
  late String? selectedValue;

  List<String> limits = ['30', '60', '90', '100', '300'];
  String limitSelNo = "30";

  Future<void> getRecord() async {
    try {
      WaitDialog.waitDialog(context, loadingNote: 'LOADING');
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      categoryText.clear();
      locationText.clear();
      dptText.clear();
      remarks.clear();
      stockLocation.clear();
      issuedDate.clear();
      issedBy.clear();
      qty.clear();
      stockInHand.clear();
      issueTime.clear();
      typeOf.clear();
      String query = "";
      if (UserCredential().getUserType == "ADMIN") {
        query =
            "SELECT isr.*,ic.Category,ic.Location as icl,ul.Name from tbl_itemiissuerecord as isr join  tbl_itemcategory as ic join tbl_userlist as ul on ic.StockID=isr.StockID and isr.EnterBy=ul.UserID where  isr.Location like '%${_location.text}%' and isr.Dpt like '%${_dpt.text}%' and ic.Category like '%${_itemName.text}%' and isr.Types='${selectedValue}'order by EnterDate DESC limit ${limitSelNo}";
      }
      conn.execute(query).then((results) {
        for (var row in results.rows) {
          dptText.add(row.assoc()["Dpt"].toString());
          categoryText.add(row.assoc()["Category"].toString());
          locationText.add(row.assoc()["Location"].toString());
          remarks.add(row.assoc()["Remarks"].toString());
          stockLocation.add(row.assoc()["icl"].toString());
          issuedDate.add(row.assoc()["EnterDate"].toString());
          issedBy.add(row.assoc()["Name"].toString());
          qty.add(row.assoc()["QTY"].toString());
          issueTime.add(row.assoc()["EnterTime"].toString());
          typeOf.add(row.assoc()["Types"].toString());
          stockInHand.add(row.assoc()["StockInHand"].toString());
        }
        conn.close();
        setState(() {});
      });
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> csv() async {
    try {
      if (categoryText.length >= 1) {
        List<List<String>> data = [
          [
            'Stock Location',
            'Category',
            'Location',
            'Department',
            'Quantity',
            'Stock In Hand',
            'Remarks',
            'Type Of',
            'Issued Date',
            'Issue Time',
            'Issued By'
          ],
          for (int i = 0; i < categoryText.length; i++)
            [
              stockLocation[i],
              categoryText[i],
              locationText[i],
              dptText[i],
              qty[i],
              stockInHand[i],
              remarks[i],
              typeOf[i],
              issuedDate[i],
              issueTime[i],
              issedBy[i],
            ]
        ];

        await TOCSVFile().csv(data, 'ConsumblesReport', context);
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
  void initState() {
    super.initState();
    selectedValue = 'NA';
  }

  void handleRadioValueChanged(String? value) {
    setState(() {
      selectedValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appbar(
          icon: Icons.print,
          sw: MediaQuery.sizeOf(context).width,
          titleText: "Item issue Report/Consumable asset"),
      body: Container(
        padding: EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      controller: _itemName,
                      autocorrect: false,
                      decoration: TxtOnlyInputDecorations.inputDecorations(
                        labletext: 'Category',
                        hinttext: 'LQ310',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
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
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: TextFormField(
                        controller: _location,
                        autocorrect: false,
                        decoration: TxtOnlyInputDecorations.inputDecorations(
                          labletext: 'Location',
                          hinttext: 'Kosgama',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: double.infinity,
                      child: TextFormField(
                        controller: _dpt,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: 'IT',
                          labelText: 'Department',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.location_city),
                            onPressed: () {
                              getRecord();
                            },
                          ),
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
                  child: Row(
                    children: [
                      Radio(
                        value: 'Issued',
                        groupValue: selectedValue,
                        onChanged: handleRadioValueChanged,
                      ),
                      Text('Issued'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                        value: 'New Stock',
                        groupValue: selectedValue,
                        onChanged: handleRadioValueChanged,
                      ),
                      Text('New Stock'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: categoryText.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '${categoryText[index]} : ${typeOf[index]}',
                              style: TextStyle(
                                color: typeOf[index] == "New Stock"
                                    ? Color.fromARGB(255, 2, 206, 2)
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildDetailRow('Department', dptText[index]),
                          _buildDetailRow('Location', locationText[index]),
                          _buildDetailRow('Issued By', issedBy[index]),
                          _buildDetailRow('Issue Time',
                              "${issueTime[index]} ${issuedDate[index]}"),
                          _buildDetailRow('Quantity', '${qty[index]} NOS'),
                          _buildDetailRow(
                              'Stock In Hand', '${stockInHand[index]} NOS'),
                          _buildDetailRow('Remarks', remarks[index]),
                          _buildDetailRow(
                              'Transaction Location', stockLocation[index]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
