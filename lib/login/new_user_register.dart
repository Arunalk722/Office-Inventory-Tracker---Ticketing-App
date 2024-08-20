import 'package:flutter/material.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class RegisterNewUser extends StatefulWidget {
  const RegisterNewUser({Key? key}) : super(key: key);

  @override
  State<RegisterNewUser> createState() => _RegisterNewUserState();
}

final TextEditingController _userName = TextEditingController();
final TextEditingController _password = TextEditingController();
final TextEditingController _confPassword = TextEditingController();
final TextEditingController _name = TextEditingController();
final TextEditingController _email = TextEditingController();
final TextEditingController _phoneNo = TextEditingController();

class _RegisterNewUserState extends State<RegisterNewUser> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'REGISTRATION',
          style: TextStyle(color: Colors.black, fontSize: 30),
        ),
        iconTheme: IconThemeData(color: Colors.black54, weight: 20),
        backgroundColor: Colors.cyanAccent,
      ),
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black38,
                          Colors.black,
                        ],
                      ),
                    ),
                    width: double.infinity,
                    height: size.height * 0.1,
                    child: Center(
                      child: Text(
                        'NEW USER REGISTRATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Container(
                        margin: EdgeInsets.only(top: 0),
                        width: double.infinity,
                        child: Icon(
                          Icons.supervisor_account,
                          color: Colors.black12,
                          size: 170,
                        )),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          height: 700,
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
                                height: 10,
                              ),
                              Text(
                                'REGISTER',
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
                                        controller: _userName,
                                        autocorrect: false,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: 'Jhone',
                                          labletext: 'USER NAME',
                                          icons: const Icon(Icons.email_sharp),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _password,
                                        autocorrect: false,
                                        obscureText: true,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: '******',
                                          labletext: 'PASSWORD',
                                          icons:
                                              const Icon(Icons.password_sharp),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _confPassword,
                                        autocorrect: false,
                                        obscureText: true,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: '******',
                                          labletext: 'CONFIRAMTION PASSWORD',
                                          icons:
                                              const Icon(Icons.password_sharp),
                                        ),
                                      ),
                                      TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: _name,
                                        autocorrect: false,
                                        obscureText: false,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: 'NAME',
                                          labletext: 'NAME',
                                          icons: const Icon(Icons.person_2),
                                        ),
                                      ),
                                      TextFormField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: _email,
                                        autocorrect: false,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: 'EMAIL',
                                          labletext: 'EMAIL',
                                          icons: const Icon(Icons.email),
                                        ),
                                      ),
                                      TextFormField(
                                        keyboardType: TextInputType.phone,
                                        controller: _phoneNo,
                                        autocorrect: false,
                                        decoration:
                                            InputDecorations.inputDecoration(
                                          hinttext: '070 XXX XXXX',
                                          labletext: 'MOBILE NO',
                                          icons: const Icon(Icons.phone),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        height: 50,
                                      ),
                                      ButtonDecorations.buttonDecoration(
                                        btnText: 'REGISTER',
                                        tcolors: Colors.white,
                                        pcolors: Colors.green,
                                        btnIcon: Icon(Icons.app_registration),
                                        onPressed: () {
                                          handleRegisterButton(context);
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
}

Future<void> handleRegisterButton(BuildContext context) async {
  try {
    if (_userName.text.length < 5) {
      ShowDialogs.showdialog(context,
          msg: "Please provide a username with more than 5 characters",
          title: "user name requrid",
          icons: Icon(Icons.password_sharp),
          iconColors: Colors.red);
    } else if (_password.text.length < 6) {
      ShowDialogs.showdialog(context,
          msg: "Please provide a password with more than 6 characters",
          title: "Password requrid",
          icons: Icon(Icons.password_sharp),
          iconColors: Colors.red);
    } else if (_confPassword.text.length < 6) {
      ShowDialogs.showdialog(context,
          msg:
              "Please provide a confirmation password that matches the password field.",
          title: "Password requrid",
          icons: Icon(Icons.password_sharp),
          iconColors: Colors.red);
    } else if (_name.text.length < 8) {
      ShowDialogs.showdialog(context,
          msg: "Please provide a name  with more than 8 characters",
          title: "name requrid",
          icons: Icon(Icons.password_sharp),
          iconColors: Colors.red);
    } else if (!isValidEmail(_email.text)) {
      ShowDialogs.showdialog(context,
          msg: "Please provide a email",
          title: "email requrid",
          icons: Icon(Icons.password_sharp),
          iconColors: Colors.red);
    } else if (_phoneNo.text.length == 9) {
      ShowDialogs.showdialog(context,
          msg: "Please provide a valid phone number",
          title: "phone No requrid",
          icons: Icon(Icons.password_sharp),
          iconColors: Colors.red);
    } else if (_password.text == _confPassword.text) {
      WaitDialog.waitDialog(context, loadingNote: 'REGISTRATION');
      final conn = await ConnectionManager.createConnection();
      await conn.connect();
      var result = await conn.execute(
          "SELECT * FROM tbl_userlist WHERE UserName = '${_userName.text}'");
      if (result.rows.isNotEmpty) {
        Navigator.pop(context);
        ShowDialogs.showdialog(context,
            msg: "user " +
                _userName.text +
                " Already registered. Please use a different username.",
            title: "Active users found",
            icons: Icon(Icons.error_outline),
            iconColors: Colors.red);
      } else {
        await conn.execute(
            "INSERT INTO tbl_userlist(UserName,UserType,Password,Name,Email,Mobile,Dpt,IsActive,AutoLogin,AndroidID) VALUES('${_userName.text}','USER',MD5('${_password.text}'),'${_name.text}','${_email.text}','${_phoneNo.text}','DPT','1','NA','NA')");
        Navigator.pop(context);
        ShowDialogs.showdialog(context,
            msg: "user " + _userName.text + " Registration is successful.",
            title: "successful",
            icons: Icon(Icons.done),
            iconColors: Colors.green);
        _password.clear();
        _confPassword.clear();
        _name.clear();
        _userName.clear();
        _phoneNo.clear();
        _email.clear();
      }
      conn.close();
    } else {
      ShowDialogs.showdialog(context,
          msg: "Please check and verify passwords.",
          title: "Password does not match",
          icons: Icon(Icons.password_sharp),
          iconColors: Colors.red);
    }
  } catch (e) {
    ShowDialogs.showdialog(context,
        msg: "$e",
        title: "LOGIN FAILD",
        icons: Icon(Icons.error),
        iconColors: Colors.red);
  }
}

bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return emailRegex.hasMatch(email);
}
