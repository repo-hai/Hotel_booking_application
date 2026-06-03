import 'package:flutter/material.dart';
import 'package:hotel_booking_app/presentation/screens/login.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

double containerHeight = 640;
double containerWidth = 380;

// Stateless Widget cho trang xác thực email khi đăng ký
class AuthenticateEmail extends StatelessWidget {
  const AuthenticateEmail({super.key});

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyAuthenticateEmail(),
    );
  }
}

// Khai báo một StatefulWidget cho giao diện xác thực email
class MyAuthenticateEmail extends StatefulWidget {
  const MyAuthenticateEmail({super.key});

  // Định nghĩa lại phương thức createState()
  @override
  State<MyAuthenticateEmail> createState() => _MyAuthenticateEmail();
}

// Khai báo State cho giao diện xác thực email
class _MyAuthenticateEmail extends State<MyAuthenticateEmail> {
  late String code;

  // Định nghĩa lại hàm initState() - khởi gán giá trị ban đầu cho các biến
  @override
  void initState() {
    code = "";
  }

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
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
                  padding: EdgeInsetsGeometry.fromLTRB(25, 150, 10, 30),
                  child: Text(
                    "Xác thực tài khoản",
                    selectionColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 600,
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                  ),
                  padding: EdgeInsetsGeometry.fromLTRB(30, 50, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 20),
                        child: Text(
                          "Xác thực Email",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight(550),
                          ),
                        ),
                      ),
                      Text("Vui lòng nhập mã OTP được gửi tới email của bạn"),
                      OtpTextField(
                        numberOfFields: 4,
                        onSubmit: (String s){
                          setState(() {
                            code = s;
                          });
                        },
                        fieldWidth: 60,
                        textStyle: TextStyle(
                            fontSize: 25
                        ),
                        margin: EdgeInsetsGeometry.fromLTRB(10, 20, 10, 20),
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(0, 10, 0, 20),
                        child: Center(
                          child: Text("Không nhận được mã OTP?"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 30,
                        children: [
                          ElevatedButton(
                            onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(145, 35),
                              backgroundColor: Color.fromRGBO(40, 83, 175, 1),
                            ),
                            child: Text(
                              "Gửi lại",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                              // Hàm thực thi xác thực email
                              onPressed: () async {
                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                final response = await http.post(
                                  Uri.parse('http://localhost:3000/confirm-create-account'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode(<String, String>{'email': prefs.getString("email")!, 'confirmCode': code}),
                                );
                                print("gui request thanh cong");
                                if(response.statusCode == 200){
                                  showDialog(context: context, builder: (ctx) {
                                    return AlertDialog(
                                      title: Text("Tạo tài khoản thành công, vui lòng đăng nhập"),
                                      actions: [
                                        TextButton(onPressed: () {
                                          Navigator.pop(ctx);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) {
                                              return Login();
                                            },));
                                          },
                                          child: Text("Ok")
                                        ),
                                      ],
                                    );
                                  },);
                                } else {
                                  showDialog(context: context, builder: (ctx) {
                                    return AlertDialog(
                                      title: Text("Mã OTP không đúng, vui lòng thử lại"),
                                      actions: [
                                        TextButton(onPressed: () {
                                          Navigator.pop(ctx);
                                        }, child: Text("Ok")),
                                      ],
                                    );
                                  },);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(145, 35),
                                backgroundColor: Color.fromRGBO(0, 144, 255, 1),
                              ),
                              child: Text(
                                "Xác nhận",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              )
                          ),
                        ],
                      ),
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
