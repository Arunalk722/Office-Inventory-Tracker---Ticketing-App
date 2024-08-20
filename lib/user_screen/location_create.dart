import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class LocationCreate extends StatefulWidget {
  const LocationCreate({Key? key}) : super(key: key);

  @override
  State<LocationCreate> createState() => _LocationCreateState();
}

String _dptSelectedItem = '';

final TextEditingController _adminGroup =
    TextEditingController(text: "ADMIN_IT");

class _LocationCreateState extends State<LocationCreate> {
  final List<String> locations = [];
  String _locationText = '';
  String _dptText = "";
  final List<String> _locationlist = [];
  final List<String> _dptlist = [];

  @override
  void initState() {
    super.initState();
    if (_dptlist.isEmpty) {
      getDpt();
    }
  }

  Future<void> getLocation(String _baseLocation) async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    _locationlist.clear();
    conn
        .execute('SELECT * FROM tbl_locations WHERE Dpt="$_baseLocation"')
        .then((results) {
      for (var row in results.rows) {
        _locationlist.add(row.assoc()["Location"].toString());
      }
      setState(() {});
    });
  }

  Future<void> dptCreate(BuildContext context) async {
    try {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedTime = DateFormat('HH:mm:ss').format(now);
      await conn.execute(
          "INSERT INTO tbl_dpt (`dpt`,`AdminGroup`,`EnterDate`,`EnterTime`,`EnterBy`) VALUES ('${_dptText}', '${_adminGroup.text}', '$formattedDate', '$formattedTime', '${UserCredential().getUserId}' );");
      ShowDialogs.showdialog(context,
          msg: "NEW DEPARTMENT '${_dptText}' CREATED SUCCESSFULLY",
          title: "NEW DEPARTMENT SUCCESSFULLY",
          icons: Icon(Icons.done),
          iconColors: Colors.green);
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

  Future<void> locationCreate(BuildContext context) async {
    try {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedTime = DateFormat('HH:mm:ss').format(now);
      await conn.execute(
          "INSERT INTO tbl_locations (`Dpt`,`Location`,`AdminGroup`,`EnterDate`,`EnterTime`,`EnterBy`) VALUES ('${_dptSelectedItem}', '${_locationText}', '${_adminGroup.text}', '$formattedDate', '$formattedTime', '${UserCredential().getUserId}' );");
      ShowDialogs.showdialog(context,
          msg: "NEW LOCATION '${_locationText}' CREATED SUCCESSFULLY",
          title: "NEW LOCATION SUCCESSFULLY",
          icons: Icon(Icons.done),
          iconColors: Colors.green);
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

  Future<void> getDpt() async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    _dptlist.clear();
    _locationlist.clear();
    conn.execute('SELECT * FROM tbl_dpt').then((results) {
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
          titleText: 'LOCATION/CREATE A NEW DEPARTMENT',
          icon: Icons.location_city),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
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
            ],
          ),
          child: Column(
            children: [
              _buildTextField(
                  _adminGroup, 'ADMIN GROUP', 'ADMIN_IT', Icons.qr_code),
              SizedBox(height: 20),
              _buildAutocompleteDptField(
                  'PICK/CHECK AVAILABLE DEPARTMENT', _dptlist),
              SizedBox(height: 20),
              _buildButton('CREATE DEPARTMENT', Colors.cyan, Icons.create,
                  _createDepartment),
              SizedBox(height: 20),
              _buildAutocompleteLocationField(
                  'CHECK AVAILABLE LOCATION', _locationlist),
              SizedBox(height: 20),
              _buildButton('CREATE LOCATION', Colors.cyan,
                  Icons.location_on_sharp, _createLocation),
              SizedBox(height: 20),
              _buildButton('CLEAR', Colors.red, Icons.clear, clearText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            autocorrect: false,
            decoration: InputDecorations.inputDecoration(
              hinttext: hint,
              labletext: label,
              icons: Icon(icon),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
      String text, Color color, IconData icon, VoidCallback onPressed) {
    return Row(
      children: [
        Expanded(
          child: ButtonDecorations.buttonDecoration(
            btnText: text,
            tcolors: Colors.white,
            pcolors: color,
            btnIcon: Icon(icon),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }

  Widget _buildAutocompleteLocationField(String label, List<String> options) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return options.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String locationSelection) {
                  setState(() {
                    _locationText = locationSelection;
                    _locationText = locationSelection;
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(labelText: label),
                    onChanged: (value) {
                      setState(() {
                        _locationText = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutocompleteDptField(String label, List<String> options) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return options.where((String option) {
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
                    decoration: InputDecoration(labelText: label),
                    onChanged: (value) {
                      setState(() {
                        _dptText = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _createDepartment() {
    YNDialogCon.ynDialogMessage(context,
            messageBody: 'Would you like to create a new department?',
            messageTitle: 'Create',
            iconFile: Icon(Icons.upgrade),
            iconColor: Colors.black,
            btnDone: "YES",
            btnClose: "NO")
        .then((value) {
      if (value == "Y" && _dptText.isNotEmpty) {
        dptCreate(context);
      }
    });
  }

  void _createLocation() {
    YNDialogCon.ynDialogMessage(context,
            messageBody: 'New Location Create procedure',
            messageTitle: 'Location Create',
            iconFile: Icon(Icons.upgrade),
            iconColor: Colors.black,
            btnDone: "YES",
            btnClose: "NO")
        .then((value) {
      if (value == "Y" &&
          _locationText.isNotEmpty &&
          _dptSelectedItem.isNotEmpty) {
        locationCreate(context);
      }
    });
  }

  void clearText() {
    setState(() {
      _dptText = "";
      _locationlist.clear();
      _dptlist.clear();
      _locationText = "";
      _dptSelectedItem = "";
    });
  }
}
