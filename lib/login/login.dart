import 'package:dart/user_screen/homeScreen.dart';
import 'package:dart/login/new_user_register.dart';
import 'package:dart/widgets/input_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../widgets/auto_login_function.dart';
import '../widgets/system_functions_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
//dd-mm-yy-vv
final String appversion = '07.13.24-01';

class _LoginScreenState extends State<LoginScreen> {
  Future<void> fetchData() async {
    final databaseDemo = AutoLoginDB.instance;
    final List<UserLoginInfo> data = await databaseDemo.readAllData();
    for (var item in data) {
      print('ID: ${item.id}, Name: ${item.name}, Password: ${item.password}');
      if (item.name == 'NA' || item.password == 'NA') {
        print('Auto login disable');
      } else {
        handleLoginButtonClicked(context, item.name, item.password);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromRGBO(63, 63, 156, 1),
                Color.fromRGBO(90, 70, 178, 1),
              ])),
              width: double.infinity,
              height: size.height * 0.3,
              child: Stack(
                children: [
                  Positioned(
                    child: boubleArt(),
                    top: 90,
                    left: size.height * 0.1,
                  ),
                  Positioned(
                    child: boubleArt(),
                    top: 20,
                    left: size.height * 0.2,
                  ),
                  Positioned(
                    child: boubleArt(),
                    top: 30,
                    left: size.height * 0.3,
                  ),
                  Positioned(
                    child: boubleArt(),
                    top: 50,
                    left: size.height * 0.15,
                  ),
                  Positioned(
                    child: boubleArt(),
                    top: 120,
                    left: size.height * 0.2,
                  ),
                ],
              ),
            ),
            SafeArea(
                child: Container(
              margin: EdgeInsets.only(top: 30),
              width: double.infinity,
              child: Icon(
                Icons.supervisor_account,
                color: Colors.white,
                size: 170,
              ),
            )),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 300),
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    width: double.infinity,
                    height: 500,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(20, 50),
                          )
                        ]),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  autocorrect: false,
                                  decoration: InputDecorations.inputDecoration(
                                    hinttext: 'Jhon123',
                                    labletext: 'ENTER YOUR USERNAME',
                                    icons: const Icon(Icons.email_sharp),
                                  ),
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  autocorrect: false,
                                  obscureText: true,
                                  decoration: InputDecorations.inputDecoration(
                                    hinttext: '******',
                                    labletext: 'ENTER YOUR PASSWORD',
                                    icons: const Icon(Icons.password_sharp),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  height: 50,
                                ),
                                ButtonDecorations.buttonDecoration(
                                  btnText: 'LOGIN',
                                  tcolors: Colors.white,
                                  pcolors: Colors.green,
                                  btnIcon: Icon(Icons.login_outlined),
                                  onPressed: () async {
                                    handleLoginButtonClicked(
                                        context,
                                        _usernameController.text,
                                        _passwordController.text);
                                  },
                                ),
                                SizedBox(height: 50),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterNewUser()),
                                    );
                                  },
                                  child: Text(
                                    'Register As a New Member',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  Text(
                    "APP VERSION: " + appversion,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
}

Container boubleArt() {
  return Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      color: Color.fromRGBO(255, 255, 255, 0.050),
    ),
  );
}

Future<void> handleLoginButtonClicked(
    BuildContext context, String userName, String password) async {
  try {
    int updateCheck = await getAppversion(context);
    if (updateCheck == 1) {
      WaitDialog.waitDialog(context, loadingNote: "login");
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      var result = await conn.execute(
          "SELECT * FROM tbl_userlist WHERE UserName = '${userName}' AND Password = MD5('${password}')");
      Navigator.pop(context);
      if (result.rows.isNotEmpty) {
        for (var row in result.rows) {
          UserCredential().setUserId =
              int.parse(row.assoc()['UserID'].toString());
          UserCredential().setUserName = row.assoc()['UserName'].toString();
          UserCredential().setAdmingroup = row.assoc()['admingroup'].toString();
          UserCredential().setMobileNo = row.assoc()['Mobile'].toString();
          UserCredential().setUserType = row.assoc()['UserType'].toString();
          UserCredential().setDpt = row.assoc()['Dpt'].toString();
          UserCredential().setStockLoc = row.assoc()["stockLoc"].toString();
          addUserLast(userName, password);
          _passwordController.text = "";
          _usernameController.text = "";
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        ShowDialogs.showdialog(context,
            msg: "PASSWORD ARE WORNG.",
            title: "LOGIN FAILD",
            icons: Icon(Icons.sms_failed),
            iconColors: Colors.red);
      }

      conn.close();
    } else {
      print("Update required");
    }
  } catch (e) {
    ShowDialogs.showdialog(context,
        msg: "$e",
        title: "LOGIN FAILD",
        icons: Icon(Icons.error),
        iconColors: Colors.red);
    print(e);
  }
}

Future addUserLast(String userName, String password) async {
  try {
    final userSave = UserLoginInfo(
      id: 1,
      name: userName,
      password: password,
    );

    final autoLogin = AutoLoginDB.instance;

    final existingUser = await autoLogin.getUserById(1);

    if (existingUser == null) {
      await autoLogin.create(userSave);
      print('User inserted.');
    } else {
      await autoLogin.updateUser(userSave);
      print('User updated.');
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<void> sendToURL(String url, BuildContext context) async {
  try {
    Uri targetUrl = Uri.parse(url);

    if (await launchUrl(
      targetUrl,
      mode: LaunchMode.inAppBrowserView,
      webViewConfiguration: WebViewConfiguration(),
    )) {
    } else {
      ShowDialogs.showdialog(
        context,
        msg: 'Open failed',
        title: 'App Update URL Open Failed',
        icons: Icon(Icons.error),
        iconColors: Colors.red,
      );
    }
  } catch (e) {
    ShowDialogs.showdialog(
      context,
      msg: e.toString(),
      title: 'Error while open',
      icons: Icon(Icons.error),
      iconColors: Colors.red,
    );
  }
}

Future<int> getAppversion(BuildContext context) async {
  int isUpdated = 0;
  WaitDialog.waitDialog(context, loadingNote: 'Check Application');
  final conn = await ConnectionManager.createConnection();
  await conn.connect();
  var appVersionQuery = await conn.execute("SELECT * FROM tbl_appversion");
  if (appVersionQuery.rows.isEmpty) {
    Navigator.pop(context);
    ShowDialogs.showdialog(context,
        msg: "PLEASE CHECK APP VERSION.",
        title: "NOT FOUND APP VERSION",
        icons: Icon(Icons.stop),
        iconColors: Colors.green);
  } else {
    for (var chkApp in appVersionQuery.rows) {
      String dbAppVersion = chkApp.assoc()["appVerison"]!.toString();
      if (appversion == dbAppVersion) {
        Navigator.pop(context);
        isUpdated = 1;
      } else {
        Navigator.pop(context);
        YNDialogCon.ynDialogMessage(context,
                messageBody: chkApp.assoc()["rlcNote"].toString() +
                    "\ndate :" +
                    chkApp.assoc()["rlcDate"].toString() +
                    "\npublish:\t" +
                    chkApp.assoc()["publishBy"].toString(),
                messageTitle: chkApp.assoc()["rlcNoteHader"].toString(),
                iconFile: Icon(Icons.update),
                iconColor: Colors.black,
                btnDone: "UPDATE NOW",
                btnClose: "UPDATE LATER")
            .then((value) {
          {
            if (value == "Y") {
              print('Y');
              String url = chkApp.assoc()["rlcURL"]!.toString();
              print(url);
              sendToURL(url, context);
            } else {}
          }
        });
        isUpdated = 0;
      }
    }
  }
  conn.close();
  return isUpdated;
}
