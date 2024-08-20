import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class ConsumablesStockIssue extends StatefulWidget {
  const ConsumablesStockIssue({super.key});

  @override
  State<ConsumablesStockIssue> createState() => _ConsumablesStockIssueState();
}

class _ConsumablesStockIssueState extends State<ConsumablesStockIssue> {
  String _itemCategorySelectedItem = '';
  final List<String> _itemCategory = [''];
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  late String? selectedValue;
  String qty = "";

  String _locationSelectedItem = '';
  final List<String> _locationlist = [];

//dpt
  String _dptSelectedItem = '';
  final List<String> _dptlist = [];

  Future<void> getLocation(String _baseLocation) async {
    WaitDialog.waitDialog(context, loadingNote: 'LOADING');
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    _locationlist.clear();
    conn
        .execute("SELECT * FROM tbl_locations  where Dpt = '${_baseLocation}'")
        .then((results) {
      for (var row in results.rows) {
        _locationlist.add(row.assoc()["Location"].toString());
      }
      print(_locationlist);
      setState(() {});
    });
    Navigator.pop(context);
  }

  Future<void> getDpt() async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    _dptlist.clear();
    String query = "SELECT * FROM tbl_dpt";
    if (UserCredential().getUserType != "ADMIN") {
      query = "SELECT * FROM tbl_dpt where dpt='${UserCredential().getDpt}'";
    }
    conn.execute(query).then((results) {
      for (var row in results.rows) {
        _dptlist.add(row.assoc()["dpt"].toString());
      }
      print(_dptlist);
      setState(() {});
    });
  }

  Future<void> getCategory() async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    _itemCategory.clear();
    String query = "SELECT * FROM tbl_itemcategory Order By Location asc";
    if (UserCredential().getUserType != "ADMIN") {
      query =
          "SELECT * FROM tbl_itemcategory where Location='${UserCredential().getStockLoc}'";
    }
    conn.execute(query).then((results) {
      for (var row in results.rows) {
        _itemCategory.add(
            "${row.assoc()["Category"].toString()}  [Stock :${row.assoc()["QTY"].toString()}.${row.assoc()["UOM"].toString()}]Location ${row.assoc()["Location"].toString()}");
        print(_itemCategory);
      }
      print(_itemCategory);
      setState(() {});
    });
  }

  Future<void> getQty() async {
    try {
      if (_dptSelectedItem.length < 2) {
        ShowDialogs.showdialog(context,
            msg: "Please select Department",
            title: "Error",
            icons: Icon(Icons.error),
            iconColors: Colors.green);
      } else if (_locationSelectedItem.length < 2) {
        ShowDialogs.showdialog(context,
            msg: "Please select Location",
            title: "Error",
            icons: Icon(Icons.error),
            iconColors: Colors.green);
      } else if (_itemCategorySelectedItem.length <= 2) {
        ShowDialogs.showdialog(context,
            msg: "Please select a toner category",
            title: "Error",
            icons: Icon(Icons.error),
            iconColors: Colors.green);
      } else if (_quantityController.text.length < 1) {
        ShowDialogs.showdialog(context,
            msg: "Please enter Quantity",
            title: "Error",
            icons: Icon(Icons.error),
            iconColors: Colors.green);
      } else if (selectedValue.toString().length < 4) {
        ShowDialogs.showdialog(context,
            msg: "Please enter type",
            title: "Error",
            icons: Icon(Icons.error),
            iconColors: Colors.green);
      } else {
        WaitDialog.waitDialog(context, loadingNote: 'Recording..');
        final conn = await ConnectionManager.createConnection();
        await conn.connect();
        List<String> itemCategoryList =
            _itemCategorySelectedItem.toString().split('  ');
        String itemCategory = itemCategoryList[0].trim();
        List<String> locationList =
            _itemCategorySelectedItem.toString().split('Location ');
        String locationID = locationList[1].trim();
        String query =
            "SELECT * FROM tbl_itemcategory where  Category='$itemCategory' and Location='$locationID'";
        print(query);
        conn.execute(query).then((results) {
          for (var row in results.rows) {
            qty = row.assoc()["QTY"].toString();

            double qTY = double.parse(qty.toString());
            tonerIssue(itemCategory, qTY, locationID);
          }
          setState(() {});
        });
      }
    } catch (e) {}
  }

  Future<void> tonerIssue(
      String catagory, double qty, String locationID) async {
    try {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      double issuedQty = double.parse(_quantityController.text);
      double totalStock = 0;
      if (selectedValue == 'Issued') {
        totalStock = qty - issuedQty;
        issuedQty = -issuedQty;
      } else {
        totalStock = qty + issuedQty;
        issuedQty = issuedQty;
      }

      await conn.execute(
          "UPDATE tbl_itemcategory set QTY='${totalStock}' where StockID='${catagory}-${locationID}'");

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedTime = DateFormat('HH:mm:ss').format(now);
      await conn.execute(
          "INSERT INTO `tbl_itemiissuerecord`(`StockID`,`Dpt`,`Location`,`Remarks`,`Types`,`QTY`,`StockInHand`,`UOM`,`EnterDate`,`EnterTime`,`EnterBy`)VALUES('${catagory}-${locationID}','${_dptSelectedItem.toString()}','${_locationSelectedItem.toString()}','${_remarkController.text}','${selectedValue.toString()}','$issuedQty','$totalStock','NOS','$formattedDate','$formattedTime','${UserCredential().getUserId}');");

      Navigator.pop(context);
      ShowDialogs.showdialog(context,
          msg: "$catagory ISSUING TO $_locationSelectedItem.",
          title: "issued",
          icons: Icon(Icons.done),
          iconColors: Colors.green);
      conn.close();
      _quantityController.text = "";
      _remarkController.text = "";
      setState(() {});
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

  @override
  void initState() {
    super.initState();
    selectedValue = 'NA';
    if (_dptlist.isEmpty) {
      getDpt();
    }
    getCategory();
  }

  void handleRadioValueChanged(String? value) {
    setState(() {
      selectedValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
        appBar: CustomAppBar.appbar(
            sw: sw,
            titleText: 'Item Issue/consumable asset',
            icon: Icons.airplane_ticket),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Column(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return _dptlist.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String dptSelection) {
                        setState(() {
                          _dptSelectedItem = dptSelection;

                          getLocation(dptSelection);
                        });
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecorations.inputDecoration(
                            hinttext: 'DEPARTMENT',
                            labletext: '',
                            icons: const Icon(Icons.departure_board),
                          ),
                        );
                      },
                    ),
                    if (_dptSelectedItem.isNotEmpty)
                      (Text(
                        "Department. :" + _dptSelectedItem,
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
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return _locationlist.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _locationSelectedItem = selection;
                        });
                      },
                      fieldViewBuilder: (BuildContext context, _location,
                          FocusNode focusNode, VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: _location,
                          focusNode: focusNode,
                          decoration: InputDecorations.inputDecoration(
                            hinttext: 'LOCATION',
                            labletext: '',
                            icons: const Icon(Icons.location_off),
                          ),
                        );
                      },
                    ),
                    if (_locationSelectedItem.isNotEmpty)
                      Text(
                        "Location. :" + _locationSelectedItem,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                  ],
                ),
                Column(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return _itemCategory.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _itemCategorySelectedItem = selection;
                        });
                      },
                      fieldViewBuilder: (BuildContext context, _location,
                          FocusNode focusNode, VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: _location,
                          focusNode: focusNode,
                          decoration: InputDecorations.inputDecoration(
                            hinttext: 'Category',
                            labletext: '',
                            icons: const Icon(Icons.category),
                          ),
                        );
                      },
                    ),
                    if (_itemCategorySelectedItem.isNotEmpty)
                      Text(
                        "Selected Category: $_itemCategorySelectedItem",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _quantityController,
                      decoration: InputDecorations.inputDecoration(
                        hinttext: 'Quantity',
                        labletext: 'Quantity',
                        icons: const Icon(Icons.confirmation_num_sharp),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _remarkController,
                  decoration: InputDecorations.inputDecoration(
                    hinttext: 'Note comments etc.',
                    labletext: 'Remarks',
                    icons: const Icon(Icons.confirmation_num_sharp),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          List<String> itemCategoryList =
                              _itemCategorySelectedItem.toString().split('  ');
                          String itemCategory = itemCategoryList[0].trim();
                          YNDialogCon.ynDialogMessage(context,
                                  messageTitle: "Item Isseue",
                                  messageBody:
                                      "$selectedValue $itemCategory at $_locationSelectedItem \nQTY is ${_quantityController.text}",
                                  btnClose: "No",
                                  btnDone: "Yes",
                                  iconColor: Colors.black,
                                  iconFile: Icon(Icons.note_alt_sharp))
                              .then((value) {
                            if (value == "Y") {
                              getQty();
                            } else {}
                          });
                        },
                        child: Text('SAVE'))
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
