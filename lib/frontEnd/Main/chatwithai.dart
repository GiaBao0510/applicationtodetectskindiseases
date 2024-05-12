import 'package:flutter/material.dart';
import 'package:session_manager/session_manager.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MaterialApp(
        home: const SafeArea(
          child: Scaffold(
              body: ChatAI()
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

class ChatAI extends StatefulWidget{
  const ChatAI({super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatAIInterface();
  }
}
class ChatAIInterface extends State<ChatAI>{
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
    return Container(
      child: Text("Trang chat bot"),
    );

  }
}