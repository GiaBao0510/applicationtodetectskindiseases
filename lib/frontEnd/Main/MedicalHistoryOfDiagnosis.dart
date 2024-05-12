import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:session_manager/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body:SeeMedicalDiagnosisHistory()
        ),
      ),
      theme: ThemeData(
          fontFamily: 'Arial'
      ),
      debugShowCheckedModeBanner: false,
    )
  );
}

class SeeMedicalDiagnosisHistory extends StatefulWidget{
  const SeeMedicalDiagnosisHistory({super.key});

  @override
  State<SeeMedicalDiagnosisHistory> createState() => _SeeMedicalDiagnosisHistory();
}

class _SeeMedicalDiagnosisHistory extends State<SeeMedicalDiagnosisHistory>{



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Phương thức
  Future<List<dynamic>> DiagnosticList() async{
    String IDuser = await SessionManager().getString('IDuser');
    String path = url + '/user/lichchuandoan/$IDuser';

    var res = await http.get( Uri.parse(path), headers: {"Content-Type": "application/json"} );

    List<dynamic> list = jsonDecode(res.body);
    return list;
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
        title: Text('Lịch sử chuẩn đoán', style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Align', fontWeight: FontWeight.bold), ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [ Colors.blueAccent, Colors.lightBlue ]
              )
          ),
        ),
      ),
      body:FutureBuilder<List<dynamic>>(
        future: DiagnosticList(),
        builder: (context, snapshot){
          //Chờ lấy dữ liệu
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }//Thông báo nếu có lỗi
          else if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error} '));
          }else{
            final diagnosticList = snapshot.data!;
            return Scrollbar(
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffededed), Color(0xffdee8e8)],
                    stops: [0.25, 0.75],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                ),
                child: ListView.builder(
                  itemCount: diagnosticList.length,
                    itemBuilder: (context, index){
                      return Container(
                          height: 80,
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(4,4),
                                  spreadRadius: 2
                              )
                            ],
                            gradient: LinearGradient(
                              colors: [Color(0xff306597),  Color(0xff85adff)],
                              stops: [0.25, 0.75],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Text('${diagnosticList[index]['BenhVeDa']}',style: TextStyle(color: Colors.white),),
                                  Text('${diagnosticList[index]['thoidiem']}',style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          )
                      );
                    }
                ),
              ),
            );
          }
        },
      ),
    );
  }
}