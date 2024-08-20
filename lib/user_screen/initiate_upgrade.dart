import 'package:flutter/material.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class InitiateUpgrade extends StatefulWidget {
  final String stringAssetID, sn, location, dpt, description, remarks;

  const InitiateUpgrade({
    required this.stringAssetID,
    required this.sn,
    required this.location,
    required this.dpt,
    required this.description,
    required this.remarks,
    Key? key,
  }) : super(key: key);

  @override
  State<InitiateUpgrade> createState() => _InitiateUpgradeState();
}

class _InitiateUpgradeState extends State<InitiateUpgrade> {
  final List<String> haderText = [];
  final List<String> recordID = [];
  final List<int> isActive = [];
  final List<String> sN = [];
  final List<String> upgradeNote = [];
  final List<String> reference = [];
  final List<String> upgradeCost = [];
  final List<String> enterDate = [];
  final List<String> enterTime = [];
  final List<String> name = [];

  final TextEditingController _assetTag = TextEditingController();
  final TextEditingController _sN = TextEditingController();
  final TextEditingController _dpt = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _descryption = TextEditingController();
  final TextEditingController _remarks = TextEditingController();
  final TextEditingController _cost = TextEditingController();

  @override
  void initState() {
    super.initState();
    _assetTag.text = widget.stringAssetID;
    _sN.text = widget.sn;
    _location.text = widget.location;
    _descryption.text = widget.description;
    _dpt.text = widget.dpt;
    _remarks.text = widget.remarks;
    getDataFromDB(context);
  }

  Future<void> getDataFromDB(BuildContext context) async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();

    haderText.clear();
    recordID.clear();
    isActive.clear();
    sN.clear();
    upgradeNote.clear();
    reference.clear();
    upgradeCost.clear();
    enterDate.clear();
    enterTime.clear();
    name.clear();

    String query = "";
    if (UserCredential().getUserType == "ADMIN") {
      query =
          "SELECT ai.*, ul.Name FROM tbl_addonitem AS ai JOIN tbl_userlist AS ul ON ul.UserID = ai.EnterBy WHERE IdString = '${_assetTag.text}'";
    }

    await conn.execute(query).then((results) {
      for (var row in results.rows) {
        recordID.add(row.assoc()["idtbl_assetinitiateupgrade"].toString());
        haderText.add(row.assoc()["TktNo"].toString());
        isActive.add(int.parse(row.assoc()["IsActive"].toString()));
        sN.add(row.assoc()["SN"].toString());
        upgradeNote.add(row.assoc()["upgradeNote"].toString());
        reference.add(row.assoc()["reference"].toString());
        upgradeCost.add(row.assoc()["upgradeCost"].toString());
        enterDate.add(row.assoc()["EnterDate"].toString());
        enterTime.add(row.assoc()["EnterTime"].toString());
        name.add(row.assoc()["Name"].toString());
      }
      conn.close();
      setState(() {});
    });

    await getCost(context);
  }

  Future<void> getCost(BuildContext context) async {
    WaitDialog.waitDialog(context, loadingNote: 'GETTING DATA');
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    var checkCost = await conn.execute(
        "SELECT SUM(upgradeCost) as UCost FROM tbl_addonitem where IdString= '${_assetTag.text}'");
    if (checkCost.rows.isEmpty) {
      _cost.text = '0';
    } else {
      for (var costs in checkCost.rows) {
        _cost.text = costs.assoc()["UCost"].toString();
      }
      conn.close();
    }
    Navigator.pop(context);
  }

  Future<void> changeState(String IdNum) async {
    print(IdNum);
    WaitDialog.waitDialog(context, loadingNote: 'loading');
    try {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      await conn.execute(
          "UPDATE tbl_addonitem set IsActive='0' WHERE idtbl_assetinitiateupgrade=$IdNum");
      conn.close();
    } catch (e) {}
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar.appbar(
          sw: sw,
          titleText: 'ASSETS/LIST OF UPGRADE',
          icon: Icons.list_alt_outlined),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _assetTag,
                    autocorrect: false,
                    enabled: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecorations.inputDecoration(
                      hinttext: "00001",
                      labletext: "ASSET TAG",
                      icons: Icon(Icons.tag),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    autocorrect: false,
                    enabled: false,
                    controller: _sN,
                    decoration: InputDecorations.inputDecoration(
                      hinttext: "SNXXXXXXX",
                      labletext: "SERIAL NUMBER",
                      icons: Icon(Icons.qr_code_2_sharp),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    autocorrect: false,
                    controller: _location,
                    decoration: InputDecorations.inputDecoration(
                      hinttext: "KOSGAMA",
                      labletext: "LOCATION",
                      icons: Icon(Icons.location_city),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    enabled: false,
                    autocorrect: false,
                    controller: _dpt,
                    decoration: InputDecorations.inputDecoration(
                      hinttext: "ACCOUNT",
                      labletext: "DEPARTMENT",
                      icons: Icon(Icons.local_fire_department),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    autocorrect: false,
                    controller: _cost,
                    decoration: InputDecorations.inputDecoration(
                      hinttext: "",
                      labletext: "TOTAL COST(IN LKR)",
                      icons: Icon(Icons.local_fire_department),
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: haderText.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          haderText[index] == "ADD-ON-ITEM"
                              ? "ADD-ON-ITEM"
                              : 'Ticket No :${haderText[index]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('SERIAL NO', sN[index]),
                            _buildDetailRow('UPGRADE NOTE', upgradeNote[index]),
                            _buildDetailRow('REFERENCE', reference[index]),
                            _buildDetailRow(
                                'COST', '${upgradeCost[index]}.LKR'),
                            _buildDetailRow('User Name', name[index]),
                            _buildDetailRow('RECORD INFO',
                                '${enterDate[index]} | ${enterTime[index]}'),
                            _buildDetailRow('Active State',
                                isActive[index] == 1 ? 'YES' : 'NO'),
                          ],
                        ),
                      ),
                      onLongPress: () {
                        YNDialogCon.ynDialogMessage(
                          context,
                          messageBody:
                              'Are you sure to inactive this add-on record?',
                          messageTitle: 'Inactive Record',
                          iconFile: Icon(Icons.question_answer),
                          iconColor: Colors.black,
                          btnDone: 'Yes',
                          btnClose: 'No',
                        ).then((value) {
                          if (value == "Y") {
                            changeState(recordID[index]);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
              color: value == "NO"
                  ? Colors.red
                  : value == "YES"
                      ? Colors.green
                      : Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
