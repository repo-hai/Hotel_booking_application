import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

double widthOfInputField = 430;
double paddingLeft = 15;
double paddingTop = 30;
double paddingRight = 15;
double paddingBottom = 0;

class EditProfileView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfileView> {
  String email = "";
  String name = "";
  String phone = "";

  Future<void> fetchUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
      name = prefs.getString('name')!;
      phone = prefs.getString('phone')!;
    });
  }
  @override
  void initState() {
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Chỉnh sửa thông tin"),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back,color: Colors.black,),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(paddingLeft, paddingTop, paddingRight, paddingBottom),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://m.media-amazon.com/images/I/71-OTwKLziL._AC_SL1500_.jpg",
                      )
                    )
                  ),
                  child: IconButton(
                    padding: EdgeInsetsGeometry.fromLTRB(50, 50, 50, 50),
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      size: 100,
                      color: Color.fromRGBO(177, 221, 255, 1),
                      fontWeight: FontWeight.w100,
                    ),
                    onPressed: (){
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blue,),
                title: Text("Tên đầy đủ"),
              ),
            ),
            SizedBox(
              width: widthOfInputField,
              child: TextField(
                onChanged: (String s){
                  setState(() {
                    name = s;
                  });
                },
                controller: TextEditingController(text: name),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.email_outlined, color: Colors.blue,),
                title: Text("Email"),
              ),
            ),
            SizedBox(
              width: widthOfInputField,
              child: TextField(
                onChanged: (String s){
                  setState(() {
                    email = s;
                  });
                },
                controller: TextEditingController(text: email),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.blue,),
                title: Text("Điện thoại"),
              ),
            ),
            SizedBox(
              width: widthOfInputField,
              child: TextField(
                onChanged: (String s){
                  setState(() {
                    phone = s;
                  });
                },
                controller: TextEditingController(text: phone),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 12),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 50, 10, 50),
              child: ElevatedButton(
                onPressed: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/edit-profile'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{'email': prefs.getString('email')!, 'password': prefs.getString('password')!, 'newEmail': email, 'newName': name, 'newPhoneNumber': phone}),
                  );
                  if(response.statusCode == 200){
                    showDialog(context: context, builder: (ctx) {
                      return AlertDialog(
                        title: Text('Đổi thông tin thành công'),
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
                        title: Text("Sai mật khẩu, vui lòng thử lại"),
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
                  "Cập nhật",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}