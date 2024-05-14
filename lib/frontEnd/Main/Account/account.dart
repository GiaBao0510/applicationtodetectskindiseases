//import 'dart:js_interop_unsafe';
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
import 'package:applicationtodetectskindiseases/frontEnd/Main/Account/EditAccount.dart';

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
      return TheInterfaceAlreadyHasAnAccount(fcamera: fcamera,);
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
  final CameraDescription fcamera;

  const TheInterfaceAlreadyHasAnAccount({
    super.key,
    required this.fcamera
  });

  @override
  State<TheInterfaceAlreadyHasAnAccount> createState() => _TheInterfaceAlreadyHasAnAccount(fcamera: fcamera);
}

class _TheInterfaceAlreadyHasAnAccount extends State<TheInterfaceAlreadyHasAnAccount>{
  final CameraDescription fcamera;

  _TheInterfaceAlreadyHasAnAccount({required this.fcamera});

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

  //Thực hiện đăng xuất
  Future<void> DangXuat() async{
    try{
      String path = '$url/exit';
      var res = await http.post(Uri.parse(path), headers: {"Content-Type": "application/json"} );
      print(res.body);
      SessionManager().setString('taikhoan', '');
      SessionManager().setString('matkhau', '');
      SessionManager().setString('role', '');
      SessionManager().setString('IDuser', '');

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: " Đăng xuất thành công",
        onConfirmBtnTap: () => {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HienThi(fcamera: fcamera,) ), // Sử dụng RegisterPage từ tệp tin register.dart
          )
        },
      );
    }catch(e){
      print('Lỗi khi hủy phiên: $e');
    }
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

                  //2. Phần thân
                  Align(
                    alignment: Alignment.center,
                    child: Scrollbar(

                      child: Container(
                        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Column(
                          children: [

                            //Hình ảnh đại diện
                            SizedBox(height: 70,),
                            Flexible(
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  child: Image.asset('assets/image/AvatarBoy.png'),
                                ),
                            ),

                            //Tên người dùng
                            SizedBox(height: 5,),
                            Flexible(
                              child: Text('${Infomation['hoten']}',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Arial", color: Colors.white)),
                            ),

                            //Email người dùng
                            SizedBox(height: 0,),
                            Flexible(
                              child: Text('${Infomation['email']}',style: TextStyle(fontSize: 18, fontFamily: "Arial", color: Colors.white)),
                            ),

                            //Chỉnh sửa thông tin cá nhân
                            SizedBox(height: 20,),
                            Flexible(
                                child: Material(
                                  color: Colors.amber[300],
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  child:  InkWell(
                                    onTap: (){
                                      print('Đã bâẫm nút sửa hồ sơ');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => UserInformationEditingInterface(fcamera: fcamera, thongTinCanChinhSua: Infomation,)),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                offset: Offset(4,8)
                                            )
                                          ]
                                      ),
                                      child: Text("Sửa hồ sơ",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,fontFamily: "Arial", color: Colors.black87),)
                                    ),
                                  ),
                                )
                            ),

                            //Cài đặt
                            SizedBox(height: 50,),
                            Flexible(
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  child:  InkWell(
                                    onTap: (){
                                      print('Đã bâẫm nút liên hệ');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                offset: Offset(4,8)
                                            )
                                          ]
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Icon(Iconsax.setting, color: Colors.blueAccent,)
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text("Cài đặt", style: TextStyle(fontSize: 18, fontFamily: "Arial", color: Colors.blueAccent),),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Icon(Icons.chevron_right, color: Colors.blueAccent,)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                            ),

                            //Chính sach
                            SizedBox(height: 20,),
                            Flexible(
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  child:  InkWell(
                                    onTap: (){
                                      print('Đã bâẫm nút xem chính sách');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                offset: Offset(4,8)
                                            )
                                          ]
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Icon(Icons.policy, color: Colors.blueAccent,)
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text("Chính sách", style: TextStyle(fontSize: 18, fontFamily: "Arial", color: Colors.blueAccent),),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Icon(Icons.chevron_right, color: Colors.blueAccent,)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                            ),

                            //Liên hệ
                            SizedBox(height: 20,),
                            Flexible(
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  child:  InkWell(
                                    onTap: (){
                                      print('Đã bâẫm nút liên hệ');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                offset: Offset(4,8)
                                            )
                                          ]
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Icon(Iconsax.send_2, color: Colors.blueAccent,)
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text("Liên hệ", style: TextStyle(fontSize: 18, fontFamily: "Arial", color: Colors.blueAccent),),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Icon(Icons.chevron_right, color: Colors.blueAccent,)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                            ),

                            //Đăng xuất
                            SizedBox(height: 20,),
                            Flexible(
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                child:  InkWell(
                                  onTap: (){
                                    print('Đã bâẫm nút đăng xuất');
                                    DangXuat();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 5,
                                              offset: Offset(4,8)
                                          )
                                        ]
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Icon(Iconsax.logout, color: Colors.redAccent,)
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text("Đăng xuất", style: TextStyle(fontSize: 18, fontFamily: "Arial", color: Colors.redAccent),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //1. Phần tiêu dề
                  Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      heightFactor: 0.07,
                      child: Container(
                        color: Colors.white,

                        child: Center(
                          child: Text("Hồ sơ", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Arial", color: Colors.blue[700]),),
                        ),
                      ),
                    ),
                  ),
                ],
            );
          }
        },
      )
    );
  }
}