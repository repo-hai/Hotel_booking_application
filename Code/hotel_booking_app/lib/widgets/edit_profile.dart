import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

double width_of_input_field = 430;
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
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blue,),
                title: Text("Tên đầy đủ"),
              ),
            ),
            SizedBox(
              width: width_of_input_field,
              child: TextField(
                controller: TextEditingController(text: "John Smith"),
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
              width: width_of_input_field,
              child: TextField(
                controller: TextEditingController(text: "abcd@gmail.com"),
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
              width: width_of_input_field,
              child: TextField(
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
                onPressed: (){},
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