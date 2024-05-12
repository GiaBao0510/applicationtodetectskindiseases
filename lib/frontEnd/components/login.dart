import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:camera/camera.dart';
import 'package:session_manager/session_manager.dart';

import 'package:applicationtodetectskindiseases/frontEnd/components/register.dart';
import 'package:applicationtodetectskindiseases/frontEnd/maindisplay.dart';
import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';
import '../Object/UserLogin.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
      MaterialApp(
        home: Material(
          child: SafeArea(
            child: Scaffold(
              body: LoginPage(fcamera: firstCamera),
            ),
          ),
        ),

        theme: ThemeData(
            fontFamily: 'Arial'
        ),
        debugShowCheckedModeBanner: false,
      )
  );
}

class LoginPage extends StatefulWidget{
  final CameraDescription fcamera;

  const LoginPage({
    super.key,
    required this.fcamera
  });

  @override
  State<StatefulWidget> createState() {
    return _register(fcamera: fcamera);
  }
}

class _register extends State<LoginPage>{
  //Thuộc tính
  bool chapNhanDK = false;
  final CameraDescription fcamera;
  final _formkey = GlobalKey<FormState>();
  userlogin user = userlogin('','');

  _register({required this.fcamera});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Phương thức kiểm tra dăng nhập
  Future login(BuildContext context) async{
    String path = url+"/login";
    var res = await http.post(Uri.parse(path),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'taikhoan': user.sdt,
          'matkhau': user.matkhau
        }));

    print(res.body);
    final thongtinphanhoi = jsonDecode(res.body);
    final value = thongtinphanhoi['value'] as int;
    final iduser = thongtinphanhoi['id'] as int;

    if(value == 1) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success",
          text: "Đăng nhập thành công",
          onConfirmBtnTap: () => {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HienThi(fcamera: fcamera,) ), // Sử dụng RegisterPage từ tệp tin register.dart
            )
          },
      );
      final vaitro = thongtinphanhoi['role'] as int;
      SessionManager().setString("taikhoan", user.sdt);
      SessionManager().setString("matkhau", user.matkhau);
      SessionManager().setString("role", vaitro.toString());
      SessionManager().setString("IDuser", iduser.toString());

    }else if(value == -1) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Oops...",
          text: "Số điện thoại không tồn tại. Vui lòng đăng ký"
      );
    }
    else if(value == -2) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Opps...",
          text: "Sai mật khẩu"
      );
    }
    else if(value == 0) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Opps...",
          text: "Vui lòng điền đầy đủ thông tin đăng nhập"
      );
    }
  }

  //Giao diện chính
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Positioned(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfffc466b), Color(0xff3f5efb)],
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

        ///Khung đang ky
        Align(
          alignment: Alignment.center,
          child: Scrollbar(
            child: ListView(
              padding: EdgeInsets.fromLTRB(15, 90, 15, 0),
              children: <Widget>[
                const SizedBox(height: 0,),
                Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 20,),
                          Image.asset('assets/image/dangnhap.png', width: 100, height: 100,),
                          Text("Đăng Nhập", style: TextStyle(fontFamily: 'Arial', fontSize: 27, fontWeight: FontWeight.bold), ),
                          const SizedBox(height: 32,),

                          Material(
                            child:Form(
                              key: _formkey,
                              child: Column(
                                children: [
                                  //So điện thoại
                                  TextFormField(
                                    controller:TextEditingController(text: user.sdt),
                                    onChanged: (value){
                                      user.sdt = value;
                                    },
                                    //Xác thuc so dien thoại
                                    validator: (value){
                                      if(value == null || value.isEmpty){
                                        return 'Vui lòng điền số điện thoại';
                                      }else if(!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)){
                                        return 'Số điện thoại không hợp lệ';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        labelText: "Số điện thoại",
                                        prefixIcon: Icon(Iconsax.call),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue, width: 2)
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red)
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.redAccent)
                                        ),
                                    ),
                                    obscureText: false,
                                  ),
                                  const SizedBox(height: 18,),

                                  //Mật khẩu
                                  TextFormField(
                                    obscureText: true,
                                    controller:TextEditingController(text: user.matkhau),
                                    onChanged: (value){
                                      user.matkhau = value;
                                    },
                                    //Xác thuc so dien thoại
                                    validator: (value){
                                      if(value == null || value.isEmpty){
                                        return 'Vui lòng điền mật khẩu';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        labelText: "Mật khẩu",
                                        prefixIcon: Icon(Iconsax.password_check),
                                        suffixIcon: Icon(Iconsax.eye_slash),
                                        enabledBorder: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue, width: 2)
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red)
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.redAccent)
                                        ),
                                    ),
                                  ),
                                  const SizedBox(height: 18,),

                                  //Nút gui
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        login(context);
                                        if (_formkey.currentState != null && _formkey.currentState!.validate()) {
                                          print("Hợp lệ");
                                          // Thêm xử lý đăng nhập ở đây
                                        } else {
                                          print("Không hợp lệ");
                                        }
                                        print('Đã bấm đăng nhập');
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.black,
                                          elevation: 8.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          )
                                      ),
                                      child: Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Align' ),),
                                    ),
                                  ),
                                  const SizedBox(height: 40,),
                                ],
                              )
                            ),
                          ),

                          Text("Bạn chưa có tài khoản?"),
                          const SizedBox(height: 5,),
                          //Nút chuyển về trang chủ
                          Container(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                print('Về trang đăng ký');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterPage(fcamera: fcamera,) ), // Sử dụng RegisterPage từ tệp tin register.dart
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.black,
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )
                              ),
                              child: Text('Đăng ký', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Align' ),),
                            ),
                          )
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}