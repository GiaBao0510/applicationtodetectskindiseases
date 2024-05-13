//import 'dart:js_interop_unsafe';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:session_manager/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';
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

  Future<Widget> KiemTraDaDangNhapHayChua(BuildContext context) async {
    //kiêm tra xem nguoi dung da dang nhap hay chua
    String taikhoan = await SessionManager().getString('taikhoan');
    String matkhau = await SessionManager().getString('matkhau');
    String role = await SessionManager().getString('role');
    String iduser = await SessionManager().getString('IDuser');

    //Nếu chưa có taài khoản
    if (taikhoan.isEmpty || matkhau.isEmpty || role.isEmpty || iduser.isEmpty) {
      return LoginPage(fcamera: fcamera,);
    } else {
      return TheInterfaceAlreadyHasAnAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
        future: KiemTraDaDangNhapHayChua(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else if (snapshot.hasError){
            return Text('Lỗi: ${snapshot.hasError}');
          }else{
            return CircularProgressIndicator();
          }
        }
    );
  }
}

//  ------ Phần này là giao diện sau khi người dùng đăng nhập -------
class TheInterfaceAlreadyHasAnAccount extends StatefulWidget{
  const TheInterfaceAlreadyHasAnAccount({super.key});

  @override
  State<TheInterfaceAlreadyHasAnAccount> createState() => _TheInterfaceAlreadyHasAnAccount();
}

class _TheInterfaceAlreadyHasAnAccount extends State<TheInterfaceAlreadyHasAnAccount>{
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Lưu thông tin người dùng vào 1 danh sách
  Future<Map<String,dynamic>> ThongTinNguoiDung() async{
    String iduser = await SessionManager().getString('IDuser');
    String path = '$url/user/$iduser';

    var res = await http.get( Uri.parse(path), headers: {"Content-Type": "application/json"} );
    Map<String,dynamic> ds = jsonDecode(res.body)[0];
    return ds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String,dynamic>>(
        future: ThongTinNguoiDung(),
        builder: (context, snapshot){
          //Đợi lâấy thông tin
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }else if (snapshot.hasError){
            return Text('Lỗi: ${snapshot.hasError} - ${snapshot.error}');
          }else{
            final Infomation = snapshot.data!;
            return Stack(
                children: [
                  //Bao quát khung hiình
                  Positioned(
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xff6181ff), Color(0xff3e56d0)],
                              stops: [0.25, 0.75],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                      )
                  ),

                  //Phần chưa thông tin
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        heightFactor: 0.9,
                        child: Container(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  )
                ],
            );
          }
        },
      )
    );
  }
}