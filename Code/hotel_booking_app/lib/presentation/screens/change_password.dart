import 'package:flutter/material.dart';

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

  @override
  void initState(){
    super.initState();
    oldPasswordVisible=false;
    newPasswordVisible=false;
    confirmPasswordVisible=false;
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
          padding: EdgeInsetsGeometry.fromLTRB(15, 30, 15, 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.blue,),
                  title: Text("Nhập mật khẩu cũ"),
                ),
              ),
              SizedBox(
                width: width_of_input_field,
                child: TextField(
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
                ),
              ),
              SizedBox(
                width: width_of_input_field,
                child: TextField(
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
                ),
              ),
              SizedBox(
                width: width_of_input_field,
                child: TextField(
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
                  onPressed: (){},
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