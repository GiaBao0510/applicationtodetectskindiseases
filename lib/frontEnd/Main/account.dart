import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:session_manager/session_manager.dart';
import 'package:applicationtodetectskindiseases/frontEnd/components/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  //Kiêm tra neu nguoi dung chua dang nhap thì hien thị dang nhap, Nguoc lại hien thi thong tin tai khoan nguoi dung

  runApp(
      MaterialApp(
        home:  SafeArea(
          child: Scaffold(
              body: Account(fcamera: firstCamera,)
          ),
        ),

        theme: ThemeData(
            fontFamily: 'Times New Roman'
        ),

        //Xóa nhãn giới thiệu
        debugShowCheckedModeBanner: false,
      )
  );
}

class Account extends StatefulWidget{
  final CameraDescription fcamera;

  const Account({
    super.key,
    required this.fcamera
  });


  @override
  State<StatefulWidget> createState() {
    return AccountInterface(fcamera: fcamera);
  }
}
class AccountInterface extends State<Account>{
  final CameraDescription fcamera;

  AccountInterface({required this.fcamera});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage(fcamera: fcamera,);
  }
}