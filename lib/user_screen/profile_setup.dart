import 'package:dart/widgets/system_functions_manager.dart';
import 'package:flutter/material.dart';
import '../widgets/input_style_decoration.dart';
import '../login/login.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({Key? key}) : super(key: key);

  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
  }

  void fetchUserProfileData() async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    String query =
        "SELECT * FROM tbl_userlist where UserID='${UserCredential().getUserId}'";
    conn.execute(query).then((results) {
      for (var row in results.rows) {
        _userName.text = (row.assoc()["Name"].toString());
        _email.text = (row.assoc()["Email"].toString());
        _phoneNumber.text = (row.assoc()["Mobile"].toString());
      }

      setState(() {});
    });
  }

  void saveProfileDetails() async {
    try {
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      await conn.execute(
          "update tbl_userlist set Name='${_userName.text}',Email='${_email.text}',Mobile='${_phoneNumber.text}' where UserID='${UserCredential().getUserId}");
      Navigator.pop(context);
      ShowDialogs.showdialog(context as BuildContext,
          msg: "Profile update successful",
          title: "successful",
          icons: Icon(Icons.person),
          iconColors: Colors.green);
      await conn.close();
    } catch (e) {
      ShowDialogs.showdialog(context,
          msg: "$e",
          title: "Profile setup error",
          icons: Icon(Icons.error),
          iconColors: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: CustomAppBar.appbar(
          sw: sw,
          titleText: 'Profile Setup/Customize you profile',
          icon: Icons.person_3),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _userName,
              decoration: InputDecorations.inputDecoration(
                labletext: 'Username',
                hinttext: 'username',
                icons: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _email,
              decoration: InputDecorations.inputDecoration(
                labletext: 'Email',
                hinttext: 'Enter',
                icons: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _phoneNumber,
              decoration: InputDecorations.inputDecoration(
                labletext: 'Phone Number',
                hinttext: 'phone number',
                icons: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveProfileDetails();
              },
              child: Text('Save'),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                YNDialogCon.ynDialogMessage(context,
                        messageBody:
                            'are you sure to log out user ${UserCredential().getUserId}',
                        messageTitle: 'Log Out',
                        iconFile: const Icon(Icons.exit_to_app),
                        iconColor: Colors.black26,
                        btnDone: 'Log Out',
                        btnClose: 'Stay')
                    .then((value) {
                  if (value == 'Y') {
                    addUserLast('NA', 'NA');
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  } else {}
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void logoutUser() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
