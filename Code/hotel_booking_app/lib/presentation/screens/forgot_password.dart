import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Định nghĩa một stateless widget cho giao diện quên mật khẩu
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyForgotPasswordPage(),
    );
  }
}

// Khai báo một StatefulWidget cho giao diện quên mật khẩu
class MyForgotPasswordPage extends StatefulWidget {
  const MyForgotPasswordPage({super.key});

  // Định nghĩa lại phương thức createState()
  @override
  State<MyForgotPasswordPage> createState() => _MyForgotPasswordPage();
}

// Khai báo State cho giao diện đổi mật khẩu
class _MyForgotPasswordPage extends State<MyForgotPasswordPage> {
  String email = "";

  // Định nghĩa lại hàm initState() - khởi gán giá trị ban đầu cho các biến
  @override
  void initState() {
    email = "";
  }

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Quên mật khẩu?",
          style: TextStyle(
            fontWeight: FontWeight(700),
          ),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          icon: Icon(
            Icons.arrow_back,color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Padding(
          padding: EdgeInsetsGeometry.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              SizedBox(
                width: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(0, 50, 0, 30),
                      child: Text(
                        "Vui lòng nhập vào email của bạn để thục hiện lấy lại mật khẩu",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight(500),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: Colors.blue,),
                      title: Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 17
                        ),
                      ),
                      contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                    ),
                    TextField(
                      onChanged: (String s){
                        email = s;
                      },
                    ),
                  ],
                ),
              ),
              Center(
                child:  Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(10, 50, 10, 50),
                      child: Container(
                        child: ElevatedButton(
                          // Thực thi chức năng quên mật khẩu
                          onPressed: () async {
                            final response = await http.post(
                              Uri.parse('http://localhost:3000/forgot-password'),
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(<String, String>{'email': email}),
                            );
                            print("gui request thanh cong");
                            if(response.statusCode == 200){
                              showDialog(context: context, builder: (ctx) {
                                return AlertDialog(
                                  title: Text('Mật khẩu mới đã được gửi tới email của bạn'),
                                  actions: [
                                    TextButton(onPressed: () {
                                      Navigator.pop(ctx);
                                    },
                                        child: Text("Ok")
                                    ),
                                  ],
                                );
                              },);
                            } else if(response.statusCode == 400){
                              showDialog(context: context, builder: (ctx) {
                                return AlertDialog(
                                  title: Text("Email không tồn tại trong hệ thống, vui lòng thử lại"),
                                  actions: [
                                    TextButton(onPressed: () {
                                      Navigator.pop(ctx);
                                    }, child: Text("Ok")),
                                  ],
                                );
                              },);
                            } else {
                              showDialog(context: context, builder: (ctx) {
                                return AlertDialog(
                                  title: Text("Đã có lỗi phía hệ thống, vui lòng thử lại"),
                                  actions: [
                                    TextButton(onPressed: () {
                                      Navigator.pop(ctx);
                                    }, child: Text("Ok")),
                                  ],
                                );
                              },);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(40, 83, 175, 1)),
                            padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsetsGeometry.fromLTRB(30, 20, 30, 20)),
                          ),
                          child: Text(
                            "Gửi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
