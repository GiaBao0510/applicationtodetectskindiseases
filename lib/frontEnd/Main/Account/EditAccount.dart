import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:session_manager/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:quickalert/quickalert.dart';

import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';
import 'package:applicationtodetectskindiseases/frontEnd/components/login.dart';
import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';
import 'package:applicationtodetectskindiseases/frontEnd/maindisplay.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Object/UserRegistration.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  final Map<String,dynamic> thongTinNguoiDungCanChinhSua = {
    'hoten': '',
    'email':'',
    'sdt':'',
    'diachi':''
  };

  runApp(
    MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: UserInformationEditingInterface(fcamera: firstCamera, thongTinCanChinhSua: thongTinNguoiDungCanChinhSua),
        ),
      ),
    )
  );
}

class UserInformationEditingInterface extends StatefulWidget{
  final CameraDescription fcamera;
  final Map<String,dynamic> thongTinCanChinhSua;

  const UserInformationEditingInterface({
    super.key,
    required this.fcamera,
    required this.thongTinCanChinhSua
  });

  @override
  State<StatefulWidget> createState() {
    return _UserInformationEditingInterface(fcamera: fcamera,thongTinCanChinhSua: thongTinCanChinhSua);
  }
}

class _UserInformationEditingInterface extends State<UserInformationEditingInterface>{
  final CameraDescription fcamera;
  final Map<String,dynamic> thongTinCanChinhSua;
  final _formKey = GlobalKey<FormState>();
  late userregistration user;

  _UserInformationEditingInterface({
    required this.fcamera,
    required this.thongTinCanChinhSua
  });

  @override
  void initState() {
    super.initState();
    user = userregistration(
        thongTinCanChinhSua['hoten'] ?? '',
        thongTinCanChinhSua['email'] ?? '',
        thongTinCanChinhSua['diachi'] ?? '',
        thongTinCanChinhSua['sdt'] ?? '',
        thongTinCanChinhSua['matkhau'] ?? ''
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Giao diện
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.blue[700],
              size: 28,
            ),
            title: Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.blue[700], fontSize: 25, fontFamily: 'Align', fontWeight: FontWeight.bold), ),
            flexibleSpace: Container(
              color: Colors.white,
            ),
          ),
          body: Material(
            child: Stack(
              children: [
                //Màu nền
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
                  ),
                ),

                //Khung đăng ký
                Align(
                  alignment: Alignment.center,
                  child: Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      children: <Widget>[
                        SizedBox( height: 20,),
                        Container(
                          width: double.infinity,
                          height: 100,
                          color: Colors.red,
                          child: Column(
                            children: [

                              //Ảnh đại diên
                              Flexible(
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  child: Image.asset('assets/image/AvatarBoy.png'),
                                ),
                              ),

                              //Biểu mẫu
                              Material(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [

                                      //Họ tên
                                      TextFormField(
                                        expands: false,
                                        obscureText: false,
                                        controller: TextEditingController(text: user.hoten),
                                        onChanged: (value){
                                          user.hoten = value;
                                        },
                                        //Xác thực
                                        validator: (value){
                                          if(value == null || value.isEmpty){
                                            return 'Vui lòng điền họ và tên';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: "Họ và tên",
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: Icon(Iconsax.user),
                                          enabledBorder: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}