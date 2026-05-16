import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/presentation/screens/login.dart';
import 'package:hotel_booking_app/presentation/screens/privacy_view.dart';
import 'package:flutter/services.dart';
import 'package:hotel_booking_app/presentation/screens/authenticate_email.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyRegisterPage(),
    );
  }
}

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});



  @override
  State<MyRegisterPage> createState() => _MyRegisterPage();
}

class _MyRegisterPage extends State<MyRegisterPage> {
  final String registerState = "not register";
  bool passwordVisible = false;
  String username = "";
  String password = "";
  String phoneNumber = "";
  String rewritePassword = "";
  String name = "";
  bool confirmPasswordVisible = false;

  @override
  void initState(){
    super.initState();
    passwordVisible=false;
    confirmPasswordVisible = false;
    username = "";
    password = "";
    phoneNumber = "";
    rewritePassword = "";
    name = "";
  }

  void _onFaceBookLogin(){}

  void _onGoogleLogin(){}

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.fromRGBO(40, 83, 175, 1),
              Color.fromRGBO(105, 177, 241, 1),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(25, 40, 10, 30),
                  child: Text(
                    "Đăng kí",
                    selectionColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 600,
                  width: 450,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  padding: EdgeInsetsGeometry.fromLTRB(30, 30, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.person_outlined,
                          color: Colors.blue,
                        ),
                        title: Text("Tên đầy đủ"),
                        dense: true,
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
                          height: 30,
                          child: TextField(
                            onChanged: (String s){
                              setState(() {
                                name = s;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 12),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.email_outlined,
                          color: Colors.blue,
                        ),
                        title: Text("Email"),
                        dense: true,
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
                          height: 30,
                          child: TextField(
                            onChanged: (String s){
                              setState(() {
                                username = s;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 12),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.phone,
                          color: Colors.blue,
                        ),
                        title: Text("Số điện thoại"),
                        dense: true,
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
                          height: 30,
                          child: TextField(
                            onChanged: (String s){
                              setState(() {
                                phoneNumber = s;
                              });
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 12),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.lock,
                          color: Colors.blue,
                        ),
                        title: Text("Mật khẩu"),
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
                          height: 30,
                          child: TextField(
                            onChanged: (String s){
                              setState(() {
                                password = s;
                              });
                            },
                            obscureText: !passwordVisible,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsetsGeometry.all(0),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                                  size: 19,
                                ),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.lock,
                          color: Colors.blue,
                        ),
                        title: Text("Nhập lại mật khẩu"),
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
                          height: 30,
                          child: TextField(
                            onChanged: (String s){
                              setState(() {
                                rewritePassword = s;
                              });
                            },
                            obscureText: !confirmPasswordVisible,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsetsGeometry.all(0),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  size: 19,
                                ),
                                onPressed: () {
                                  setState(() {
                                    confirmPasswordVisible = !confirmPasswordVisible;
                                  },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(0, 10, 0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromRGBO(40, 83, 175, 1),
                                        Color.fromRGBO(105, 177, 241, 1),
                                      ],
                                      begin: AlignmentGeometry.centerLeft,
                                      end: AlignmentGeometry.centerRight,
                                    )
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if(rewritePassword != password){
                                      showDialog(context: context, builder: (ctx) => AlertDialog(
                                        title: Text("Mật khẩu nhập lại không khớp"),
                                        actions: [
                                          TextButton(onPressed: (){
                                            Navigator.pop(ctx);
                                          }, child: Text("OK"))
                                        ],
                                      ));
                                    } else {
                                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString('email', username);
                                      final response = await http.post(
                                        Uri.parse('http://localhost:3000/register'),
                                        headers: <String, String>{
                                          'Content-Type': 'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode(<String, String>{'email': username, 'password': password, 'name': name, 'phone': phoneNumber, 'role': prefs.getString('registry_role')!}),
                                      );
                                      if(response.statusCode == 200){
                                        showDialog(context: context, builder: (ctx) => AlertDialog(
                                          title: Text("Đăng kí thành công, vui lòng xác nhận mã được gửi qua email"),
                                          actions: [
                                            TextButton(onPressed: (){
                                              Navigator.pop(ctx);
                                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AuthenticateEmail()));
                                            }, child: Text("OK"))
                                          ],
                                        ));
                                      } else if (response.statusCode == 400){
                                        showDialog(context: context, builder: (ctx) => AlertDialog(
                                          title: Text("Email đã tồn tài, vui lòng sử dụng một email khác"),
                                          actions: [
                                            TextButton(onPressed: () {
                                              Navigator.pop(ctx);
                                            }, child: Text("OK"))
                                          ],
                                        ));
                                      } else {
                                        showDialog(context: context, builder: (ctx) => AlertDialog(
                                          title: Text("Lỗi hệ thống, vui lòng thử lại"),
                                          actions: [
                                            TextButton(onPressed: () {
                                              Navigator.pop(ctx);
                                            }, child: Text("OK"))
                                          ],
                                        ));
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsetsGeometry.fromLTRB(50, 17, 50, 17),
                                  ),
                                  child: Text(
                                    "Đăng kí",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(0, 20, 0, 5),
                              child: Text("hoặc đăng nhập sử dụng"),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(0, 5, 0, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              ElevatedButton(
                                onPressed: _onFaceBookLogin,
                                style: ButtonStyle(
                                  fixedSize: WidgetStatePropertyAll<Size>(Size(120, 35)),
                                  backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(38, 106, 209, 1)),
                                ),
                                child: Text(
                                  "FaceBook",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _onGoogleLogin,
                                style: ButtonStyle(
                                  fixedSize: WidgetStatePropertyAll<Size>(Size(120, 35)),
                                  backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(209, 68, 38, 1)),
                                ),
                                child: Text(
                                  "Google",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Khi tạo tài khoản mới, bạn đã đồng ý với "),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PrivacyView(),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsetsGeometry.zero)
                                    ),
                                    child: Text(
                                      "điều khoản",
                                      style: TextStyle(
                                        color: Color.fromRGBO(40, 83, 175, 1),
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Bạn đã có tài khoản?",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Login(),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsetsGeometry.zero)
                                      ),
                                      child: Text(
                                        " Đăng nhập",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color.fromRGBO(40, 83, 175, 1),
                                        ),
                                      )
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
            )
          ],
        ),
      ),
    );
    // appBar: AppBar(
    //   title: Text(widget.title),
    // ),
  }
}
