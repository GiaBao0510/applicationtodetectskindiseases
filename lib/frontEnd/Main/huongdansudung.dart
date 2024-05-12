import 'package:flutter/material.dart';
import 'package:session_manager/session_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MaterialApp(
        home: const SafeArea(
          child: Scaffold(
              body: introduce()
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

class introduce extends StatefulWidget{
  const introduce({super.key});

  @override
  State<StatefulWidget> createState() {
    return IntroduceInterface();
  }
}
class IntroduceInterface extends State<introduce>{
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 28,
        ),
        title: Text('Hướng dẫn', style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Align', fontWeight: FontWeight.bold), ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [ Colors.blueAccent, Colors.lightBlue ]
              )
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff7a97f0), Color(0xff8b6bff)],
            stops: [0, 1],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          )


        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(width: 2 ,color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Scrollbar(
            child: ListView(

              children: [
                Text("Ứng dụng nhận dạng bệnh da này được xây dựng với mục đích hỗ "
                    "trợ người dùng trong việc phát hiện và đánh giá tình trạng bệnh "
                    "da một cách nhanh chóng và chính xác. Với công nghệ học sâu tiên tiến, "
                    "ứng dụng có khả năng phân tích hình ảnh và đưa ra dự đoán về "
                    "các bệnh da tiềm ẩn."),

                Text("\nHướng Dẫn Sử Dụng", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("\t 1.Tải và Cài Đặt Ứng Dụng Đầu tiên, bạn cần tải và cài "
                    "đặt ứng dụng nhận dạng bệnh da này trên thiết bị di động của"
                    " mình (điện thoại hoặc máy tính bảng). Ứng dụng có sẵn cho "
                    "cả hệ điều hành iOS và Android.", textAlign: TextAlign.start),
                Text("\t 2.Đăng Ký Tài Khoản .Sau khi cài đặt, bạn sẽ được yêu cầu "
                    "đăng ký một tài khoản cá nhân. Quá trình đăng ký đơn giản và "
                    "nhanh chóng, chỉ cần cung cấp một số thông tin cơ bản như họ "
                    "tên, số điện thoại, email và địa chỉ.", textAlign: TextAlign.start),
                Text("\t 3. Đăng Nhập .Sau khi đăng ký thành công, bạn có thể đăng "
                    "nhập vào ứng dụng bằng số điện thoại và mật khẩu đã tạo.", textAlign: TextAlign.start),
                Text("\t 4. Trang Chủ và Hướng Dẫn Sử Dụng"
                  "Khi đăng nhập, bạn sẽ được đưa đến trang chủ của ứng dụng. "
                    "Tại đây, bạn có thể nhấn vào biểu tượng '?' để truy cập "
                    "trang hướng dẫn sử dụng chi tiết. Trang hướng dẫn này sẽ "
                    "cung cấp thông tin về cách thức hoạt động và sử dụng các "
                    "tính năng của ứng dụng.", textAlign: TextAlign.start),
                Text("\t 5. Chụp Ảnh hoặc Chọn Ảnh từ Thư Viện Để sử dụng tính "
                    "năng phát hiện bệnh da, bạn có hai lựa chọn:", textAlign: TextAlign.start),
                Text("\t\t - Nhấn vào nút 'Chụp' để mở camera và chụp ảnh trực tiếp vùng da cần kiểm tra.", textAlign: TextAlign.start),
                Text("\t\t - Hoặc nhấn vào nút 'Thư Viện' để chọn một ảnh có sẵn trong thư viện ảnh trên thiết bị của bạn.", textAlign: TextAlign.start),

                Text("\t 6. Phân Tích Hình Ảnh và Kết Quả Sau khi chụp ảnh hoặc "
                    "chọn ảnh từ thư viện, ứng dụng sẽ tự động phân tích hình ảnh "
                    "đó và đưa ra dự đoán về tình trạng bệnh da. Kết quả sẽ được "
                    "hiển thị ngay trên giao diện ứng dụng.", textAlign: TextAlign.start),
                Text("\t 7. Phản Hồi và Hỗ Trợ Nếu bạn có bất kỳ câu hỏi, ý kiến đóng "
                    "góp hay phản hồi nào về ứng dụng, bạn có thể sử dụng chức năng "
                    "phản hồi để gửi đến nhà phát triển.", textAlign: TextAlign.start),

                Text("\n\t Với giao diện thân thiện, dễ sử dụng và tích hợp hướng dẫn chi tiết, "
                    "ứng dụng nhận dạng bệnh da này sẽ hỗ trợ bạn trong việc theo "
                    "dõi và chăm sóc sức khỏe da một cách hiệu quả.", textAlign: TextAlign.start),
              ],
            ),
          ),
        ),
      ),
    );

  }
}