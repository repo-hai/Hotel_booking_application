import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

double width_of_input_field = 430;

class ChangePasswordView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordView();
  }
}

class _ChangePasswordView extends State<ChangePasswordView> {
  // List of items in our dropdown menu
  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  String oldPassword = "";
  String newPassword = "";
  String confirmPassword = "";

  @override
  void initState(){
    super.initState();
    oldPasswordVisible=false;
    newPasswordVisible=false;
    confirmPasswordVisible=false;
    oldPassword = "";
    newPassword = "";
    confirmPassword = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Đổi mật khẩu"),
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.black,),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsetsGeometry.fromLTRB(25, 30, 25, 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.blue,),
                  title: Text("Nhập mật khẩu cũ"),
                  contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                ),
              ),
              SizedBox(
                width: width_of_input_field,
                child: TextField(
                  onChanged: (String s){
                    setState(() {
                      oldPassword = s;
                    });
                  },
                  obscureText: !oldPasswordVisible,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    helperStyle:TextStyle(color:Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(oldPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          oldPasswordVisible = !oldPasswordVisible;
                        },
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 10, 0, 0),
                child: ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.blue,),
                  title: Text("Nhập mật khẩu mới"),
                  contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                ),
              ),
              SizedBox(
                width: width_of_input_field,
                child: TextField(
                  onChanged: (String s){
                    setState(() {
                      newPassword = s;
                    });
                  },
                  obscureText: !newPasswordVisible,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    helperStyle:TextStyle(color:Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(newPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          newPasswordVisible = !newPasswordVisible;
                        },
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 10, 0, 0),
                child: ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.blue,),
                  title: Text("Nhập lại mật khẩu"),
                  contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                ),
              ),
              SizedBox(
                width: width_of_input_field,
                child: TextField(
                  onChanged: (String s){
                    setState(() {
                      confirmPassword = s;
                    });
                  },
                  obscureText: !confirmPasswordVisible,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    helperStyle:TextStyle(color:Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
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
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 50, 10, 50),
                child: ElevatedButton(
                  onPressed: () async {
                    if(confirmPassword != newPassword){
                      showDialog(context: context, builder: (ctx) => AlertDialog(
                        title: Text("Mật khẩu nhập lại không đúng"),
                        actions: [
                          TextButton(onPressed: (){
                            Navigator.pop(ctx);
                          }, child: Text("OK"))
                        ],
                      ));
                    } else {
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      print(prefs.getString('email')!);
                      final response = await http.post(
                        Uri.parse('http://localhost:3000/change-password'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(<String, String>{'email': prefs.getString('email')!, 'oldPassword': oldPassword, 'newPassword': newPassword}),
                      );
                      if(response.statusCode == 200){
                        showDialog(context: context, builder: (ctx) {
                          return AlertDialog(
                            title: Text('Đổi mật khẩu thành công'),
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
                            title: Text("Sai mật khẩu cũ, vui lòng thử lại"),
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
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(40, 83, 175, 1)),
                    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsetsGeometry.fromLTRB(30, 20, 30, 20)),
                  ),
                  child: Text(
                    "Cập nhật",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}