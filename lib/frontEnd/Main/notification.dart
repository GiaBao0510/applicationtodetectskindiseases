import 'package:flutter/material.dart';
import 'package:session_manager/session_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MaterialApp(
        home: const SafeArea(
          child: Scaffold(
              body: notification()
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

class notification extends StatefulWidget{
  const notification({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return notificationInterface();
  }
}
class notificationInterface extends State<notification>{
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Trang thông báo"),
    );

  }
}