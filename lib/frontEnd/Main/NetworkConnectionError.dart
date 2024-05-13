import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:camera/camera.dart';
import 'package:quickalert/quickalert.dart';

import 'package:applicationtodetectskindiseases/frontEnd/maindisplay.dart';
import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: InterfaceConnectionError(fcamera: firstCamera),
        ),
      ),

      theme: ThemeData(
        fontFamily: 'Times New Roman'
      ),

      debugShowCheckedModeBanner: false,
    )
  );
}

class InterfaceConnectionError extends StatefulWidget{
  final CameraDescription fcamera;

  const InterfaceConnectionError({
    super.key,
    required this.fcamera
  });

  @override
  State<StatefulWidget> createState() {
    return _InterfaceConnectionError(fcamera: fcamera);
  }
}

class _InterfaceConnectionError extends State<InterfaceConnectionError>{
  //Thuộc tính
  final CameraDescription fcamera;

  _InterfaceConnectionError({required this.fcamera});

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
    return SafeArea(
        child: Scaffold(
          body:    Stack(
            children: [
              //Bao quát khung hiình
              Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff334d50), Color(0xff0f0f0f)],
                          stops: [0, 1],
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

              //Hoạt hình
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 150,),
                    Flexible(
                      child: Container(
                        child: FractionallySizedBox(
                          widthFactor: 0.9,
                          heightFactor: 0.9,
                          child: Lottie.asset(
                              'assets/animations/notConnectInternet.json',
                              repeat: true,
                              fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Flexible(
                        child: Text(
                            'Không có kết nối Internet',
                          style: TextStyle(color: Colors.white, fontFamily: 'Arial', fontWeight: FontWeight.bold, fontSize: 20),
                        )
                    ),
                    SizedBox(height: 10,),
                    Flexible(
                      child:TextButton(
                        onPressed: () async {
                          await LayDiaChiIPv4();
                          if(checkConnect == 'null'){
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.warning,
                              title: "Error",
                              text: " Không kết nối được mạng",
                            );
                          }else{
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HienThi(fcamera: fcamera,) ), // Sử dụng RegisterPage từ tệp tin register.dart
                            );
                          }
                        },
                        child: Container(
                            color: Colors.blue,
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Text('Thử lại', style: TextStyle(color: Colors.white,fontFamily: 'Arial', fontWeight: FontWeight.bold, fontSize: 18 ),)
                        ),
                      ),

                    )
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}