//File: home.dart
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:camera/camera.dart';
import 'package:lottie/lottie.dart';
import 'package:session_manager/session_manager.dart';

import 'package:applicationtodetectskindiseases/frontEnd/NhanDangBenhDa/camera.dart';
import 'package:applicationtodetectskindiseases/frontEnd/NhanDangBenhDa/librayimages.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Main/huongdansudung.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Main/MedicalHistoryOfDiagnosis.dart';
import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Main/NetworkConnectionError.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
      MaterialApp(
        home: SafeArea(
          child: Scaffold(
              body: Home(fcamera:  firstCamera,)
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

class Home extends StatefulWidget{
  final CameraDescription fcamera;

  const Home({
    super.key,
    required this.fcamera
  });

  @override
  State<StatefulWidget> createState() {
    return HomeInterface(fcamera: fcamera);
  }
}
class HomeInterface extends State<Home>{
  final CameraDescription fcamera;

  HomeInterface({required this.fcamera});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Truy cập đến chức năng xem lịch sử
  Future ViewMedicalDiagnosisHistory(BuildContext context) async{
    //kiêm tra xem nguoi dung da dang nhap hay chua
    String taikhoan = await SessionManager().getString('taikhoan');
    String matkhau = await SessionManager().getString('matkhau');
    String role = await SessionManager().getString('role');
    String iduser = await SessionManager().getString('IDuser');

    if(taikhoan.isEmpty || matkhau.isEmpty || role.isEmpty || iduser.isEmpty){
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Chưa đăng nhập",
          text: "Vui lòng đăng nhập để gửi phản hồi"
      );
      print('Chua co tai khoan');
    }else{
      print('Da co tai khoan');
      print('Tài khoản: $taikhoan');
      print('Mật khẩu : $matkhau');
      print('Vai trò: $role');
      print('ID: $iduser');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SeeMedicalDiagnosisHistory()),
      );
    }
  }
  //Giao diện
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        //Toàn màn hình
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

        //2. main
        Align(
          alignment: Alignment.center,
          child: Scrollbar(
            child: ListView(
                padding: const EdgeInsets.all(15),
                children: <Widget>[
                  SizedBox(height: 65,),

                  //Khung số 1
                  Container(
                    height: 450,
                    width: 330,
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
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  //Nút liên kết đến camera
                                  Expanded(
                                      flex: 1,
                                      child: TextButton(
                                        onPressed: (){
                                           print('Truy cập đến pần chụp hình ảnh');
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(builder: (context) => HienThi( camera: fcamera , )),
                                           );
                                        },
                                        child: SizedBox(
                                          height: 120,
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                  width: 60,
                                                  height: 70,
                                                  decoration: const BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: <Color>[Colors.lightBlueAccent, Colors.blueAccent]
                                                      ),
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black12,
                                                            blurRadius: 5,
                                                            offset: Offset(4,8)
                                                        )
                                                      ]
                                                  ),
                                                  child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 35),
                                              ),
                                              Text("Chụp ảnh", style: TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        ),
                                      )
                                  ),

                                  //Nút truy cập vào thư viện
                                  Expanded(
                                    flex: 1,
                                      child: TextButton(
                                        onPressed: (){
                                          print('Truy cập đến thư viện');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => pageLibraryImages()),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 120,
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                width: 60,
                                                height: 70,
                                                decoration: const BoxDecoration(
                                                    gradient: LinearGradient(
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                        colors: <Color>[Colors.lightBlueAccent, Colors.blueAccent]
                                                    ),
                                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 5,
                                                          offset: Offset(4,8)
                                                      )
                                                    ]
                                                ),
                                                child: Icon(Icons.photo_library_outlined, color: Colors.white, size: 35),
                                              ),
                                              Text("Thư viện", style: TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        ),
                                      )
                                  ),

                                  //Nút truy cập vào video
                                  Expanded(
                                    flex: 1,
                                    child: TextButton(
                                      onPressed: (){
                                        print('Truy cập đến lịch sử chuẩn đoán bệnh');
                                        ViewMedicalDiagnosisHistory(context);
                                      },
                                      child: SizedBox(
                                        height: 120,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 60,
                                              height: 70,
                                              decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: <Color>[Colors.lightBlueAccent, Colors.blueAccent]
                                                  ),
                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 5,
                                                        offset: Offset(4,8)
                                                    )
                                                  ]
                                              ),
                                              child: Icon(Icons.history_outlined, color: Colors.white, size: 35),
                                            ),
                                            Text("Lịch sử", style: TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.center,),
                                          ],
                                        ),
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              flex:1,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: TextButton(
                                          onPressed: (){
                                            print('Truy cập đến video');
                                          },
                                          child: SizedBox(
                                            height: 120,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  width: 60,
                                                  height: 70,
                                                  decoration: const BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: <Color>[Colors.lightBlueAccent, Colors.blueAccent]
                                                      ),
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black12,
                                                            blurRadius: 5,
                                                            offset: Offset(4,8)
                                                        )
                                                      ]
                                                  ),
                                                  child: Icon(Icons.ondemand_video, color: Colors.white, size: 35),
                                                ),
                                                Text("Video", style: TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.center,),
                                              ],
                                            ),
                                          ),
                                        )
                                    )
                                  ],
                                )
                            ),

                            //Vòng 2
                            Expanded(
                              flex: 2,
                                child: Lottie.asset(
                                    'assets/animations/AnimationChatDoctor.json',
                                    repeat: true,
                                    fit: BoxFit.contain,
                                    width: 300,
                                    height: 300
                                ),
                            )
                          ],
                        ),
                      )
                  ),
                  SizedBox(height: 15,),

                  //Khung số 2
                  Container(
                    height: 450,
                    width: 330,
                    color: Colors.amber[500],
                    child: const Center(child: Text('Entry B')),
                  ),
                  SizedBox(height: 15,),

                  //Khung số 3
                  Container(
                    height: 450,
                    width: 330,
                    color: Colors.amber[100],
                    child: const Center(child: Text('Entry C')),
                  ),
                  SizedBox(height: 55,),
                ],
              )
          )
        ),

        // 1. header
        Positioned(
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(4,8)
                    )
                  ]
              ),
              child:
              Row(
                children: [
                  //logo
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Image.asset('assets/image/medical_team.png',width: 45, height: 45,),
                    ),
                  ),

                  //Tên hệ thống
                  Expanded(
                    flex: 2,
                    child: Container(
                      child:const Center(
                        child: Text(
                          "Hệ thống nhận dạng bênh về da",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),

                  //Cách sử dụng
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.all(Radius.circular(100))
                      ),
                      child: IconButton(
                        onPressed: (){
                          print('Truy câập đến phần hướng dẫn');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => introduce( )),
                          );
                        },
                        icon: Icon(Icons.question_mark),

                      )
                    ),
                  ),
                ],
              ),
            )
        ),
      ],
    );
  }
}