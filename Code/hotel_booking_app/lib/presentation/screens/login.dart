import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hotel_booking_app/presentation/screens/privacy_view.dart';
import 'package:hotel_booking_app/presentation/screens/profile_view2.dart';
import 'package:hotel_booking_app/presentation/screens/register.dart';
import 'package:hotel_booking_app/presentation/screens/forgot_password.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hotel_booking_app/presentation/screens/admin/admin_main_screen.dart';
import 'package:hotel_booking_app/presentation/screens/owner/owner_home_screen.dart';
import 'package:hotel_booking_app/presentation/screens/booking_home_screen.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyLoginPage(title: 'Đăng nhập'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});
  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final String loginState = "not login";
  String username = "";
  String password = "";
  bool passwordVisible = false;

  @override
  void initState(){
    super.initState();
    passwordVisible=false;
    username = "";
    password = "";
  }
  void _onFaceBookLogin(){}

  void _onGoogleLogin(){}

  @override
  Widget build(BuildContext context) {
    // Ban dau la Material
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
                  padding: EdgeInsetsGeometry.fromLTRB(25, 130, 10, 30),
                  child: Text(
                    "Đăng nhập",
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
                  height: 640,
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                  padding: EdgeInsetsGeometry.fromLTRB(25, 50, 25, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.email_outlined, color: Colors.blue,),
                        title: Text("Email"),
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
                          height: 40,
                          child: TextField(
                            onChanged: (String s){
                              username = s;
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.lock, color: Colors.blue,),
                        title: Text("Mật khẩu"),
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
                          height: 40,
                          child: TextField(
                            obscureText: !passwordVisible,
                            onChanged: (String s){
                              password = s;
                            },
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              helperStyle:TextStyle(color:Colors.green),
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
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
                      Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(0, 10, 0, 0),
                              child: TextButton(
                                  onPressed: (){
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => MyForgotPasswordPage()),
                                    );
                                  },
                                  child: Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 73, 0, 1),
                                    ),
                                  )
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 35),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
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
                                  onPressed:  () async {
                                    final response = await http.post(
                                      Uri.parse('http://localhost:3000/login'),
                                      headers: <String, String>{
                                        'Content-Type': 'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(<String, String>{'email': username, 'password': password}),
                                    );
                                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                                    if(response.statusCode == 200){
                                      print(jsonDecode(response.body));
                                      await prefs.setString('userId', jsonDecode(response.body)["user_id"]);
                                      await prefs.setString('email', username);
                                      await prefs.setString('password', jsonDecode(response.body)["password"]);
                                      await prefs.setString('role', jsonDecode(response.body)["role"]);
                                      final String? role = prefs.getString('role');
                                      if(role == "admin"){
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => AdminMainScreen(),
                                          ),
                                        );
                                      } else if(role == "owner"){
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => OwnerHomeScreen(),
                                          ),
                                        );
                                      } else {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => BookingHomeScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    } else {
                                      showDialog(context: context, builder: (ctx) => AlertDialog(
                                        title: Text("Sai tên đăng nhập hoặc mật khẩu"),
                                        actions: [
                                          TextButton(onPressed: () {
                                            Navigator.pop(ctx);
                                          }, child: Text("OK"))
                                        ],
                                      ));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(220, 50),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                                  ),
                                  child: Text(
                                    "Đăng nhập",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(0, 40, 0, 10),
                              child: Text("hoặc đăng nhập sử dụng"),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              ElevatedButton(
                                onPressed: _onFaceBookLogin,
                                style: ButtonStyle(
                                  fixedSize: WidgetStatePropertyAll<Size>(Size(150, 35)),
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
                                  fixedSize: WidgetStatePropertyAll<Size>(Size(150, 35)),
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
                                Text(
                                    "Khi tạo tài khoản mới, bạn đã đồng ý với ",
                                  style: TextStyle(
                                    fontSize: 13.5
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ProfileView(),
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
                                        fontSize: 13.5
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(0, 25, 0, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Bạn chưa có tài khoản?",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        showDialog(context: context, builder: (ctx) => AlertDialog(
                                          title: Text("Chọn loại tài khoản"),
                                          actions: [
                                            TextButton(onPressed: () async {
                                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('registry_role', 'owner');
                                              Navigator.pop(ctx);
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => RegisterView(),
                                                ),
                                              );
                                            }, child: Text("Chủ khách sạn")),
                                            TextButton(onPressed: () async {
                                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('registry_role', 'user');
                                              Navigator.pop(ctx);
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => RegisterView(),
                                                ),
                                              );
                                            }, child: Text("Người dùng"))
                                          ],
                                        ));
                                      },
                                      style: ButtonStyle(
                                        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsetsGeometry.zero),
                                      ),
                                      child: Text(
                                        " Đăng kí",
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
