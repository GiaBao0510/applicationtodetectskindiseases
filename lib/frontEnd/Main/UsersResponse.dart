
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:session_manager/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:applicationtodetectskindiseases/frontEnd/Object/UserFeedback.dart';
import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  String AnhKetQua = "null";
  int STTbenh = -1;

  runApp(
    MaterialApp(
      home:  SafeArea(
          child: Scaffold(
            body: UserFeedbackPage(anhPhanHoi: AnhKetQua, SoThuTuBenh: STTbenh,),
          )
      ),
      theme: ThemeData(
        fontFamily: 'Arial'
      ),
      debugShowCheckedModeBanner: false,
    )
  );
}

class UserFeedbackPage extends StatefulWidget{
  final String anhPhanHoi;
  final int SoThuTuBenh;

  const UserFeedbackPage({
    super.key,
    required this.anhPhanHoi,
    required this.SoThuTuBenh
  });

  @override
  State<UserFeedbackPage> createState() => _UserFeedbackPage(anhPhanHoi: anhPhanHoi, SoThuTuBenh: SoThuTuBenh);
}

class _UserFeedbackPage extends State<UserFeedbackPage>{
  final _formkey = GlobalKey<FormState>();
  userfeedback user = userfeedback('','','','');
  final String anhPhanHoi;
  final int SoThuTuBenh;

  _UserFeedbackPage({
    required this.anhPhanHoi,
    required this.SoThuTuBenh
  }): super();

  //Khởi tạo
  @override
  void initState() {
    super.initState();
  }

  //Ngắt kết nối
  @override
  void dispose() {
    super.dispose();
  }

  //Phương thức
  Future GuiYKienPhanHoi(BuildContext context) async{
    //Lấy ID người dùng
    String IDuser = await SessionManager().getString('IDuser');
    String idBenh = SoThuTuBenh.toString();
    String path = url+'/user/phanhoi/$IDuser/benhda/$idBenh';

    var res = await http.post(Uri.parse(path),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'binhluan': user.binhluan,
        'hinhanh': anhPhanHoi.toString()
      })
    );

    print(res.body);
    final thongtinphanhoi = jsonDecode(res.body);
    final value = thongtinphanhoi['value'] as int;
    if(value == 0){
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
          title: "#404 .Oops...",
          text: "Lỗi khi gửi phản hồi"
      );
    }else if(value == 1){
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success",
          text: "Gửi phản hồi thành công",
          onConfirmBtnTap: () => {
            Navigator.pop(context)
          }
      );
    }
  }

  //Giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 28,
          ),
          title: Text('Thư viện ảnh', style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Align', fontWeight: FontWeight.bold), ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [ Colors.blueAccent, Colors.lightBlue ]
                )
            ),
          ),
        ),
        body:Stack(
        children: [
          Positioned(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffffffff), Color(0xffe0ebf0)],
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
                padding: EdgeInsets.fromLTRB(25, 30, 25, 0),
                children: <Widget>[
                  const SizedBox(height: 0,),
                  //Phần hiển thị ảnh kết quả
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                      height: 400,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(4,4),
                                spreadRadius: 2
                            )
                          ]
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.file(File(anhPhanHoi),),
                        ),
                      ),
                    ),
                  ),

                  //Thông tin phản hồi
                  const SizedBox(height: 65,),
                  Material(
                    color: Colors.transparent,
                    child:Form(
                        key: _formkey,
                        child: Row(
                          children: [
                            //Bình luận
                            Expanded(
                              flex:5,
                              child: TextFormField(
                                controller:TextEditingController(text: user.binhluan),
                                onChanged: (value){
                                  user.binhluan = value;
                                },
                                //bình luận
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Vui lòng điền thông tin phản hồi tước khi gửi';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "Ý kiến phản hồi",
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Iconsax.message_edit),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.purple)
                                  ),
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
                            ),
                            const SizedBox(width: 5,),
                            //Nút gui
                            Expanded(
                              flex:1,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xff2e96d6), Color(0xff45a4d3)],
                                    stops: [0.25, 0.75],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(4,4),
                                          spreadRadius: 2
                                      )
                                    ]
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    GuiYKienPhanHoi(context);
                                    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
                                      print("Hợp lệ");
                                      // Thêm xử lý đăng nhập ở đây
                                    } else {
                                      print("Không hợp lệ");
                                    }
                                    print('Đã bấm nút gửi phản hồi');
                                  },
                                  icon: Icon(Iconsax.send_2_copy, color: Colors.white,),
                                )
                              )
                            ),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}