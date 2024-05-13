import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:session_manager/session_manager.dart';
import 'package:applicationtodetectskindiseases/frontEnd/maindisplay.dart';
import 'package:applicationtodetectskindiseases/frontEnd/components/login.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Object/UserRegistration.dart';
import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      home: Material(
        child: SafeArea(
            child: Scaffold(
              body: RegisterPage(fcamera: firstCamera),
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

class RegisterPage extends StatefulWidget{
  final CameraDescription fcamera;
  const RegisterPage({
    super.key,
    required this.fcamera
  });

  @override
  State<StatefulWidget> createState() {
    return _register(fcamera: fcamera);
  }
}

class _register extends State<RegisterPage>{
  //Thuộc tính
  final CameraDescription fcamera;
  bool chapNhanDK = false;
  final _formkey = GlobalKey<FormState>();
  userregistration user = userregistration('','','','','');

  _register({required this.fcamera});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Phương thức
  Future save() async {
    String path = "$url/user/register/";
    print("Đã lấy URL: $url");
    print('Đường dẫn: $path');

    //Lấy địa chỉ IPV4 của máy tính để chạy
    var res = await http.post(Uri.parse(path),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'hoten': user.hoten,
          'email': user.email,
          'sdt': user.sdt,
          'diachi': user.diachi,
          'matkhau': user.matkhau
        }));
    print(res.body);
    final thongtinphanhoi = jsonDecode(res.body);
    final value = thongtinphanhoi['value'] as int;
    if(value == 1) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success",
          text: "Đăng ký tài khoản thành công"
      );
    }else if(value == 0) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Oops..",
          text: "Email hoặc số điện thoại đã tồn tại. Vui lòng kiểm tra lại"
      );
    }
    else if(value == -1) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "505",
          text: "Lỗi từ phía server!"
      );
    }
  }

  //Giao diện chính
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Material(
        child: Stack(
          children: [
            Positioned(
              child: Container(
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
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 20),

                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(4,8)
                            )
                          ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15,),
                          Row(
                            children: [
                              Flexible(
                                flex:1,
                                child: Text("Đăng ký", style: TextStyle(fontFamily: 'Arial', fontSize: 27, fontWeight: FontWeight.bold), ),
                              ),
                              Flexible(
                                  flex:1,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.fromLTRB(110, 0, 0, 0),
                                    width: 50,
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 2 ,color: Colors.black54),
                                        borderRadius: BorderRadius.all(Radius.circular(50))
                                    ),
                                    child: IconButton(
                                      onPressed: (){
                                        print('Về trang chủ');
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => HienThi(fcamera: fcamera,) ), // Sử dụng RegisterPage từ tệp tin register.dart
                                        );
                                      },
                                      icon: Icon(Icons.home, ),

                                    ),
                                  )
                              )
                            ],
                          ),
                          const SizedBox(height: 32,),

                           Material(
                             child:Form(
                               key: _formkey,
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
                                         return 'Vui lòng điền họ tên';
                                       }
                                       return null;
                                     },
                                     decoration: const InputDecoration(
                                         labelText: "Họ và tên",
                                         prefixIcon: Icon(Iconsax.user),
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
                                         fillColor: Colors.white,
                                         filled: true
                                     ),
                                   ),
                                   const SizedBox(height: 18,),

                                   //Ngày sinh
                                   //Giới tính

                                   //So điện thoại
                                   TextFormField(
                                     controller: TextEditingController(text: user.sdt),
                                     onChanged: (value){
                                       user.sdt = value;
                                     },
                                     //Xác thực
                                     validator: (value){
                                       if(value == null || value.isEmpty){
                                         return 'Vui lòng điền số điện thoại';
                                       }else if(!RegExp(r'^(09|08|07)[0-9]{8,}$').hasMatch(value)){
                                         return 'Số điện thoại không hợp lệ';
                                       }
                                       return null;
                                     },
                                     decoration: const InputDecoration(
                                         labelText: "Số điện thoại",
                                         prefixIcon: Icon(Iconsax.call),
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
                                     obscureText: false,
                                   ),
                                   const SizedBox(height: 18,),

                                   //Email
                                   TextFormField(
                                     controller: TextEditingController(text: user.email),
                                     onChanged: (value){
                                       user.email = value;
                                     },
                                     //Xác thực
                                     validator: (value){
                                       if(value == null || value.isEmpty){
                                         return 'Vui lòng điền email';
                                       }else if(!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)){
                                         return 'Email không hợp lệ';
                                       }
                                       return null;
                                     },
                                     decoration: const InputDecoration(
                                         labelText: "Điền Email",
                                         prefixIcon: Icon(Iconsax.direct),
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
                                     obscureText: false,
                                   ),
                                   const SizedBox(height: 18,),

                                   //Địa chỉ
                                   TextFormField(
                                     controller: TextEditingController(text: user.diachi),
                                     onChanged: (value){
                                       user.diachi = value;
                                     },
                                     //Xác thực
                                     validator: (value){
                                       if(value == null || value.isEmpty){
                                         return 'Vui lòng điền địa chỉ';
                                       }
                                       return null;
                                     },
                                     decoration: const InputDecoration(
                                         labelText: "Địa chỉ",
                                         prefixIcon: Icon(Iconsax.home),
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
                                     obscureText: false,
                                   ),
                                   const SizedBox(height: 18,),

                                   //Mật khẩu
                                   TextFormField(
                                     obscureText: true,
                                     controller: TextEditingController(text: user.matkhau),
                                     onChanged: (value){
                                       user.matkhau = value;
                                     },
                                     //Xác thực
                                     validator: (value){
                                       if(value == null || value.isEmpty){
                                         return 'Vui lòng điền mật';
                                       }else if(!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)){
                                         return 'Mật khẩu gồm có ít nhất: 1 chữ cái viết hoa, 1 chữ caái viết thường, 1 chữ số, 1 ký hiệu đặt biệt và phải tối thiểu 8 ký tự';
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

                                   //Phâng chấp nhận điều khoản
                                   Row(
                                     children: [
                                       SizedBox(
                                         width:24,
                                         height: 24,
                                         child: Checkbox(
                                             value: chapNhanDK,
                                             onChanged: (value){
                                               setState(() {
                                                 chapNhanDK = !chapNhanDK;
                                               });
                                             }
                                         ),
                                       ),
                                       const SizedBox( height: 24,),
                                       Text.rich(TextSpan(
                                           children: [
                                             TextSpan(text: "Tôi đồng ý ", style: Theme.of(context).textTheme.bodySmall,),
                                             TextSpan(text: "Chính sách ", style: Theme.of(context).textTheme.bodyMedium!.apply(
                                                 color: Colors.blue,
                                                 decoration: TextDecoration.underline
                                             )),
                                             TextSpan(text: "và ", style: Theme.of(context).textTheme.bodySmall,),
                                             TextSpan(text: "Điều khoản.", style: Theme.of(context).textTheme.bodyMedium!.apply(
                                                 color: Colors.blue,
                                                 decoration: TextDecoration.underline
                                             )),
                                           ]
                                       )),
                                     ],
                                   ),
                                   const SizedBox(height: 15,),

                                   //Nút gui
                                   Container(
                                     width: double.infinity,
                                     child: ElevatedButton(
                                       onPressed: (){
                                         save();
                                         if(_formkey.currentState !=null && _formkey.currentState!.validate()){
                                           print('Hợp lệ');
                                         }else{
                                           print('Không hợp lệ');
                                         }
                                         print('Đã bấm đăng ký');

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
                                       child: Text('Gửi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Align' ),),
                                     ),
                                   ),
                                   const SizedBox(height: 20,),

                                   //Nút chuyển về trang chủ
                                   Text('Bạn đã có tài khoản rồi?'),
                                   Container(
                                     width: 200,
                                     child: ElevatedButton(
                                       onPressed: (){
                                         print('Về trang đăng nhập');
                                         Navigator.pushReplacement(
                                           context,
                                           MaterialPageRoute(builder: (context) => LoginPage(fcamera: fcamera,) ), // Sử dụng RegisterPage từ tệp tin register.dart
                                         );
                                       },
                                       style: ElevatedButton.styleFrom(
                                           backgroundColor: Colors.redAccent,
                                           foregroundColor: Colors.white,

                                           shadowColor: Colors.black,
                                           elevation: 8.0,
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(10.0),
                                           )
                                       ),
                                       child: Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Align' ),),
                                     ),
                                   )
                                 ],
                              )
                             )
                           ),

                        ],
                      )
                    )
                    //Tiêu đề

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}