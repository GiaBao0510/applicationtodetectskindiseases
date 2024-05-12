import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:session_manager/session_manager.dart';
//-----------------------
import 'package:applicationtodetectskindiseases/frontEnd/Main/home.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Main/chatwithai.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Main/notification.dart';
import 'package:applicationtodetectskindiseases/frontEnd/Main/account.dart';

void main() async{
  //Load thư vien truoc roi moi thuc hien thao tác khac
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: HienThi(fcamera: firstCamera,)
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

//Lớp hien thi
class HienThi extends StatefulWidget{
  final CameraDescription fcamera;

  //Hàm khởi tạo
  const HienThi({
    super.key,
    required this.fcamera
  });

  //Tạo trạng thái hiển thị
  @override
  State<StatefulWidget> createState() {
    return GiaoDienHienThiChinh( fcamera: fcamera );
  }
}

//Giao diện chính
class GiaoDienHienThiChinh extends State<HienThi>{
  final CameraDescription fcamera;
  int _CurrentIndex =0;
  late HomeInterface trangchu;
  late Account taikhoan ;
  late ChatAIInterface tuvan;
  late notificationInterface thongbao;

  Color NutHome = Colors.blueAccent;
  Color NutChatBot = Colors.black87;
  Color NutThongBao = Colors.black87;
  Color NutTaiKhoan = Colors.black87;

  GiaoDienHienThiChinh({required this.fcamera});

  //1.Phương thức khởi tạo
  @override
  void initState() {
    super.initState();
    tuvan = ChatAIInterface();
    thongbao = notificationInterface();
  }

  //2. Phương thưức dùng để xóa widget khỏi cây
  @override
  void dispose() {
    super.dispose();
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //Cac phuong thuc dung de di chuyen trang
  void HienThiCacThanhPhan(index){
    if(index == 0){
      trangchu = HomeInterface( fcamera: fcamera );
    }
    else if(index == 1){
      tuvan.build(context);
    }
    else if(index == 2){
      thongbao.build(context);
    }
    else if(index == 3){
      //taikhoan.build(context);
      taikhoan = Account(fcamera: fcamera);
    }
  }
    //Tiện ích chuyên trang
  Widget _buildScreen(){
    switch (_CurrentIndex){
      case 0:
        return  trangchu.build(context);
      case 1:
        return  tuvan.build(context);
      case 2:
        return  thongbao.build(context);
      case 3:
        return  taikhoan = Account(fcamera: fcamera);
      default:
        return Container();
    }
  }
  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  //3.Phương thức xây dụng giao diện
  @override
  Widget build(BuildContext context) {
    trangchu = HomeInterface( fcamera: fcamera );
    taikhoan = Account(fcamera: fcamera);
    return SafeArea(
      child:  Scaffold(
        body: Stack(
          children: [
            StatefulBuilder(
                builder: (context, setState){
                  HienThiCacThanhPhan(_CurrentIndex);
                  return _buildScreen();
                }
            ),

            // 3. Nav
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 55,
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                color: Colors.white,
                child: Row(
                  children: [
                    //Trang chủ
                    Flexible(
                      fit: FlexFit.tight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap:(){
                              setState(() {
                                _CurrentIndex = 0;
                                NutHome = Colors.blueAccent;
                                NutTaiKhoan = Colors.black87;
                                NutThongBao = Colors.black87;
                                NutChatBot = Colors.black87;
                              });
                              print('Home');
                            },
                            child: Column(
                              children: [
                                Icon(Iconsax.safe_home, color: NutHome,),
                                SizedBox(height: 1,),
                                Text('Trang chủ')
                              ],
                            ),
                          ),
                    ),

                    //Trò chuyện với chatbot
                    Flexible(
                        fit: FlexFit.tight,
                        child: GestureDetector(
                          onTap:(){
                            setState(() {
                              _CurrentIndex = 1;
                              NutHome = Colors.black87;
                              NutTaiKhoan = Colors.black87;
                              NutThongBao = Colors.black87;
                              NutChatBot = Colors.blueAccent;
                            });
                            print('ChatBot');
                          },
                          child: Column(
                            children: [
                              Flexible(
                                  child: Icon(Iconsax.message,color: NutChatBot,),
                              ),
                              Flexible(
                                child:  SizedBox(height: 1,),
                              ),
                              Flexible(
                                child: Text('Tư vấn')
                              ),
                            ],
                          ),
                        )
                    ),

                    //Thông báo
                    Flexible(
                        fit: FlexFit.tight,
                        child: GestureDetector(
                          onTap:(){
                            setState(() {
                              _CurrentIndex = 2;
                              NutHome = Colors.black87;
                              NutTaiKhoan = Colors.black87;
                              NutThongBao = Colors.blueAccent;
                              NutChatBot = Colors.black87;
                            });
                            print('notification');
                          },
                          child: Column(
                            children: [
                              Icon(Iconsax.notification, color: NutThongBao,),
                              SizedBox(height: 1,),
                              Text('Thông báo')
                            ],
                          ),
                        )
                    ),

                    //tài khoản
                    Flexible(
                        fit: FlexFit.tight,
                        child: GestureDetector(
                          onTap:(){
                            setState(() {
                              _CurrentIndex = 3;
                              NutHome = Colors.black87;
                              NutTaiKhoan = Colors.blueAccent;
                              NutThongBao = Colors.black87;
                              NutChatBot = Colors.black87;
                            });
                            print('Account');
                          },
                          child: Column(
                            children: [
                              Icon(Iconsax.user_octagon,color: NutTaiKhoan,),
                              SizedBox(height: 1,),
                              Text('Tài khoản')
                            ],
                          ),
                        )
                    ),
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