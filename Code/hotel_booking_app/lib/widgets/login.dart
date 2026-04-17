import 'package:flutter/material.dart';
import 'package:hotel_booking_app/widgets/privacy_view.dart';
import 'package:hotel_booking_app/widgets/register.dart';
import 'package:hotel_booking_app/widgets/forgot_password.dart';
import 'package:hotel_booking_app/widgets/profile_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyLoginPage(title: 'Đăng nhập'),
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
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    passwordVisible=false;
    username = "";
    password = "";
    isLoading = false;
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
                  height: 600,
                  width: 450,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                  ),
                  padding: EdgeInsetsGeometry.fromLTRB(30, 50, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.email_outlined, color: Colors.blue,),
                        title: Text("Email"),
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
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
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: SizedBox(
                          width: 360,
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
                              padding: EdgeInsetsGeometry.fromLTRB(0, 15, 0, 8),
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
                              padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
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
                                  onPressed: () {
                                    print("username: " + username);
                                    print("password: " + password);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (ctx) =>
                                        AlertDialog(
                                          title: Text("Test dialog"),
                                          backgroundColor: Colors.white,
                                          actions: [
                                            TextButton(
                                              onPressed: (){
                                                Navigator.of(ctx).pop();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => ProfileView(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "OK",
                                                style: TextStyle(color: Colors.black),
                                              )
                                            )
                                          ],
                                        )
                                      // isLoading ? SpinKitPouringHourGlass(
                                      //   color: Colors.white,
                                      // ) : Text(""),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsetsGeometry.fromLTRB(60, 17, 60, 17),
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
                              padding: EdgeInsetsGeometry.fromLTRB(0, 70, 0, 10),
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
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => RegisterView(),
                                          ),
                                        );
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
