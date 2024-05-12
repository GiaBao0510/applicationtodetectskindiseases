//1.Khai báo thư viên
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:css_colors/css_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tflite/tflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camera/camera.dart';
import 'package:quickalert/quickalert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:session_manager/session_manager.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:lottie/lottie.dart';

import 'package:applicationtodetectskindiseases/frontEnd/Main/UsersResponse.dart';
import 'package:applicationtodetectskindiseases/frontEnd/constans/config.dart';

//2. chạy trên hàm main
void main() async{

  /*
    - WidgetsFlutterBinding.ensureInitialized(): được sử dụng để đảm bảo rằng Flutter engine đã được khởi tạo trước khi thực hiện bất kỳ thao tác nào khác.
    - Để đảm bảo rằng các thư viện Flutter đã được tải trước khi sử dụng:
    - Một số thư viện Flutter cần được tải trước khi bạn có thể sử dụng chúng.
  */
  WidgetsFlutterBinding.ensureInitialized();

  //Lấy danhsacsch camera
  final cameras = await availableCameras();

  //Lay camera đầu tiên
  final firstcamera = await cameras.first;

  //Hàm này giúp khởi động app
  runApp(
    MaterialApp(
      // Ghi ở phần thân, Thẻ home là thuộc tính trong MaterialApp
      home: SafeArea(     //GIao diện maàn hình
        child: Scaffold(  //Scaffold: Đại dienj cho toàn bộ khung màn hình
          body: HienThi(
            //Chuyển máy ảnh thích hợp vào tiện ích HienThi
            camera: firstcamera,
          ),
        ),
      ),

      //Định dạng phông chữ cho toàn màn hình
      theme: ThemeData(
          fontFamily: 'Times New Roman'
      ),

      //Xóa nhãn bên góc phải
      debugShowCheckedModeBanner: false,
    ),
  );
}

//---Bước 1: tạo lớp con từ lớp StatefulWidget dùng để hiển thi
class HienThi extends StatefulWidget{
  //Thuộc tính
  //.......

  //Hàm khởi tao
  const HienThi({
    /*
      Đây là cách gọi đến constructor của lớp cha StatefulWidget.
    Nó là bắt buộc đối với tất cả các contructor của StatefulWidget
    */
    super.key,
    /*
        Khai báo đây là tham số camera bắt buôc cho haàm khởi tạo. Tham số này có kiểu là
      CameraDescription và chưứa thông tin về camera mn hình sử dụng.
    */
    required this.camera,
  });

  //Đây là biến thành viên khong đôi(final). Biến này lưu trữ thông tin camera được truyền vao
  final CameraDescription camera;

  //Phải ghi đè lên hàm createState(). Và kiểu trả về là State<StatefulWidget>
  @override
  State<HienThi> createState() => ThuNghiem();
}

//---Bước 2: Lớp xây dựng thông tin tại đây
class ThuNghiem extends  State<HienThi>{
  //Thuộc tính
  late CameraController _controller;              //Biến này dùng để đều kiển camera. Và nó sẽ khơi tạo trước khi sử dụng [late]
  late Future<void> _initializeControlerFlutter;  //Biến này dùng để chứa kết quả của việc khỏi tạo camera controler
  IconData DenFlash = Icons.flash_off;            //Icon cua den flash
  IconData IconThuVienAnh = Icons.photo_library_outlined; //Icon cảu thư vện khi chưa mở
  File? ThuVienHinhAnh;                           //Biến này dùng để lưu trữ hình ảnh từ thư viện
  final NguoiNhanAnh = ImagePicker();         //Biến này dùng để truy cập vào chức năng chọn ảnh từ thư viện
  bool _isVisible = false;                    //Biến này dùng để kiểm tra xem người dùng có click vao menu hay chưa.
  late File _image;
  List _result = [];
  var imageSelect = false;

  //1.Phương thức khởi tạo
  @override
  void initState() {
    super.initState();

    if(mounted) {
      //Hien thi đầu ra hiện tại tù camera
      //Tạo 1 camera controller
      _controller = CameraController(
        //Lấy 1 camera cụ thể từ danh sách camera co sắn
          widget.camera,

          //Xác định độ phân giải để sử dụng
          ResolutionPreset.medium
      );

      //Tiếp theo là khởi tạo bộ điều khiển, trả về future
      _initializeControlerFlutter = _controller.initialize();

      //Load model truoc
      loadModel();
    }
  }

  //Load modoel
  Future loadModel() async{

    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/Mobilenet.tflite",              //Mo hinh tflite
        labels: "assets/labels.txt"                     //Nhan
    ))!;
    print("Model loading status: $res");
  }

  //2. phương thức này được gọi khi xóa widget khỏi cây widget
  @override
  void dispose() {
    if(mounted){
      //Loại bỏ bộ điều khiển khi widget được xử lý
      _controller.dispose();
    }
    super.dispose();
  }

  //--- Tạo hàm hỗ trợ

  //>1. Tương tác với đèn Flash
  Future<void> BatTatDenFlash() async{
    //Kiểm tra xem camera có được khởi tạo thành công hay chưa. Trước khi để thưc hiện thao tác nào khác
    if(_controller.value.isInitialized){
      if(_controller.value.flashMode == FlashMode.off){   //Nếu che độ Flash tắt thì thực hiện bật
        await _controller.setFlashMode(FlashMode.torch);  //Nếu đèn flash đang tắt, thay đổi trạng thái thành FlashMode.torch để bật đèn.
        setState(() {
          DenFlash = Icons.flash_on;
        });
      }else{    //Ngược lại nếu đèn đang bật thì tắt nó
        await _controller.setFlashMode(FlashMode.off);
        setState(() {
          DenFlash = Icons.flash_off;
        });

      }
    }
  }

  //>2.Hàm Chup anh
  Future<void> ChupAnh() async{
    //chụp 1 tam ảnh bằng cach su dụng try-catch. Nếu có lỗi thì ném ra ngoài
    try{
      //Đảm bảo rẳng camera sẽ được khởi động
      await _initializeControlerFlutter;

      //Cố gắng chụp ảnh và lấy nó nơi mà vị trí tệp hình ảnh đã được lưu
      final image = await _controller.takePicture();  //takePicture(): Phương thức này dùng để chụp ảnh

      ImageClassification(new File(image.path));

      //Nếu không được gắn kết thì trả về
      if(!mounted) return;

      //HIển thị giao diện
      await GiaoDienTimKiemAnh(image.path);
    }catch(e){
      //Nếu có lỗi xuất hiện thì hiển thị và xem nó
      print(e);
    }
  }

  //>3. Hàm xử việc chọn ảnh từ thư viện hoặc camera. Với tham so đầu vào ImageSource img ,để xác định nguồn của hình ảnh
  Future getImage(ImageSource img,) async{
    final DaChonTapTin = await NguoiNhanAnh.pickImage(source: img);   //Biến này dùng để lưu kết quả cua viec chon anh. Với NguoiNhanAnh.pickImage(source: img): dùng để mở thư viện ảnh hoặc trên camera dựa trên tham số img và trả về đối tượng cho DaChonTapTin
    XFile? TepTinDaChonX = DaChonTapTin;

    //Cập nhật trạng thái của bien
    setState(() {
      //Nếu không NULL .Thì tạo đối tượng File từ đường dẫn ảnh để gaán cho biến ThuVienHinhAnh
      if(TepTinDaChonX != null){
        //ThuVienHinhAnh = File(DaChonTapTin!.path);
        GiaoDienTimKiemAnh(DaChonTapTin!.path);

        ImageClassification(new File(DaChonTapTin!.path));  //>>>Gán lấy tệp tin
      }
      else{  //Ngược lại hiển thị thống báo "không có ảnh nào được chọn" .Trên thanh snackbar
        ScaffoldMessenger.of(context).showSnackBar(   //Truy cập SnackBar của widget Scaffold gần nhất trong cây widget. Để hiển thị nội dung
            const SnackBar(content: Text("Không có ảnh nào được chọn."))
        );
      }
    });
  }

  //>4. Phương thức hiển thị thư viện ảnh và chọn 1 ảnh
  void HienThiThuVienAnh(){ //Với tham số context để xác định vi trí hiển thị bảng chọn
    getImage(ImageSource.gallery);
  }

  //>> 5. Giao diện sau khi chup anh với choọn ảnh từ thư viện. Với tham số imgpath dùng dể lấy đường dẫn đã chụp hoặc chọn ảnh
  Future<void> GiaoDienTimKiemAnh(imgpath) async{
    //Nếu đã chụp ảnh thì hiển thi nó dưới màn hình mới
    await Navigator.of(context).push(       //Phương thức push dùng đê đều hướng đến màn hình mới. Sử dụng từ khóa await vì phương thức push trả về Future

      //MaterialPageRoute: Dùng để điêu hường đến màn hình mới
        MaterialPageRoute(

          //builder: Hàm xây dựng giao diện của màn hình mới.
            builder: (context) => DisplayPictureScreen(
              imagePath: imgpath,  //Chuyển hương đêến đường dẫn được tạo tự động bằng tiện ích  DisplayPictureScreen
              ImageSelected: imageSelect,
              Results: _result,
            )
        )
    );
  }

  //>> Phân lớp dụa trên hình ảnh
  Future ImageClassification(File image) async{
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 6,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5
    );

    //Tìm kiếm kết quả có độ chính xác cao nhất
    var maxAccuracy = recognitions!.fold<double?>(
      null,
          (prev, element) => prev != null
          ? (element['confidence'] > prev ? element['confidence']: prev)
          : element['confidence'],
    );

    var maxConfidenceLabel = recognitions.firstWhere((element) => element['confidence'] == maxAccuracy)['label'];
    //Lấy teen c độ chính xác cao nhất

    setState(() {
      _result = recognitions!;
      _image = image;
      imageSelect = true;
      //ketQuaTimKiem = maxConfidenceLabel.toString();
    });
  }

  //3.Phương thức xây dựng giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 28,
        ),
        title: Text('chụp ảnh', style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Align', fontWeight: FontWeight.bold), ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [ Colors.blueAccent, Colors.lightBlue ]
            )
          ),
        ),
      ),
      body: FutureBuilder<void>(
        //Chỉ định Future mà FutureBuilder sẽ theo dõi.
        //Trong trường hợp này, _initializeControllerFuture đại diện cho quá trình khởi tạo camera controller.
        future: _initializeControlerFlutter,
      
        //Hàm này được gọi mỗi khi trạng thái thay đổi
        builder: (context, snapshot){
          //Nếu khởi tạo camera thành công, hiển thi bản xem trước của camera
          if(snapshot.connectionState == ConnectionState.done){
            return Stack(
              children: [
                //0. >>>>Toàn màn hình
                Positioned(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child:CameraPreview( //HIển thị cammera trước
                      _controller,
                    ),
                  ),
                ),
      
                // 1. >>>> Bên trên
                Positioned(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.transparent
                            ]
                        )
                    ),
                    child: Row(
                      children: [
                        //3.1.1 cột 1: đèn flash
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            onPressed: (){
                              BatTatDenFlash();
                            },
                            icon: Icon(DenFlash, color: Colors.white,),
                          ),
                        ),
      
                        //3.1.2 Ống kính
                        Expanded(
                          flex: 1,
                          child: Text("Ống kính", style: TextStyle(fontSize:20 , color: Colors.white),),
                        ),
      
                        //3.1.3 menu
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                },
                                icon: Icon(Icons.menu, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      
                Positioned(
                  bottom: 150,
                  right: 25,
                  child: Container(
                    child: Text("Nhấn vào nút để chuẩn đoán", style: TextStyle(color: Colors.white, fontSize: 18),),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2 ,color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(15))
                    ),
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  ),
                ),
      
                //2. >>>>> Bên dưới
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Row(
                        children: [
                          //Thư viện ảnh
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                              child: ElevatedButton(
                                onPressed: (){
                                  HienThiThuVienAnh();
                                  print("Truy cập vào thư viện ảnh");
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Color(0000000000)
                                ),
                                //Chuyển đổi giữa icon và hình ảnh nho
                                child: Icon(IconThuVienAnh, size: 35,),
                              ),
                            ),
                          ),
      
                          //Nút chụp ảnh
                          Flexible(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: Colors.white, ),
                                  borderRadius: BorderRadius.all(Radius.circular(100), ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: IconButton(
                                      onPressed: (){ ChupAnh();},
                                      icon:  Icon(Icons.search, size: 35,),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                ),
      
                //**Hiển thị danh sách menu **
                Visibility(
                    visible: _isVisible,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                        padding: EdgeInsets.fromLTRB(2, 8, 1, 8),
                        height: 120,
                        color: Colors.black54,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Container(
                                    child: TextButton(
                                      onPressed: (){
                                        print(" Ý kiến phản hồi");
                                      },
                                      child: Text('Gửi ý kiến phản hồi.', style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.left,),
                                    )
                                )
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    child: TextButton(
                                      onPressed: (){
                                        print("Quảng lý quyền");
                                      },
                                      child:Text('Quảng lý quyền.', style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.left,),
                                    )
                                )
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    child:TextButton(
                                      onPressed: (){
                                        print(" Chính sách quyền riêng tư");
      
                                      },
                                      child:Text('Chính sách quyền riêng tư.', style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.left,),
                                    )
                                )
                            ),
                          ],
                        ),
                      ),
                    )
                ),
              ],
            ) ;
      
          }else{  //Ngược lại sẽ  chỉ báo tải camera
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
  }
}

//>>>>> 1. Lớp hiển thị hình ảnh được chụp bởi người dùng
class DisplayPictureScreen extends StatelessWidget{
  //Thuộc tính
  final String imagePath;
  final bool ImageSelected;
  final List Results;

  //-------------------------
  String? ketQuaTimKiem;
  String? doChinhXac;
  int SoThuTuBenh = -1;
  //Hàm khoi tạo
  DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.ImageSelected,
    required this.Results
  });

  //Hàm tìm kiến ket qua trên google
  void TimKiemTrenGoogle(String keyword) async{
    String urlString = 'https://www.google.com/search?q=$keyword';
    Uri url = Uri.parse(urlString);

    if( await canLaunchUrl( url )){
      await launchUrl(url);
    }else{
      throw " Could not lauch $url";
    }
  }

  //Phươn thuc thuc hien phan hoi
  Future response(BuildContext context) async{
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
        MaterialPageRoute(builder: (context) => UserFeedbackPage(anhPhanHoi: imagePath, SoThuTuBenh: SoThuTuBenh,)),
      );
    }
  }

  //Lưu lịch sử nhận dạng từ phía người dùng
  Future SaveDiagnosticHistory(BuildContext context) async{
    String IDuser = await SessionManager().getString('IDuser');
    String idBenh = SoThuTuBenh.toString();
    String path = url+'/user/lichSuChuanDoan/$IDuser/benhda/$idBenh';

    var res = await http.post(Uri.parse(path), headers: {"Content-Type": "application/json"});
    print(res.body);

  }

  //Tạo tien ich hien thi ket qua
  List<Object> _buildScreen( ketQuaTimKiem, void Function(void Function()) setState){
    switch(ketQuaTimKiem){
      case "BenhBachBien":
        return [Text("Bệnh bạch biến làm mất hoặc suy giảm sắc tố ở da, khiến các "
            "vùng da bị ảnh hưởng sẽ có biểu hiện nhạt màu hơn so với vị trí khác "
            "trên cơ thể. Ở những vùng da bị bạch biến, không những màu da mà màu "
            "tóc hoặc lông cũng có thể bị bạc theo. Tuy nhiên tính chất của da "
            "cũng tương tự như những vùng lành (không bị sần sùi, mụn nhọt hay nhăn nheo,...)."
            "Bạch biến xuất hiện ở mọi độ tuổi và trẻ em trước 12 tuổi là đối tượng "
            "phổ biến mắc căn bệnh này (chiếm khoảng 25 - 30%). Tỷ lệ bị bạch biến "
            "ở nam và nữ là tương đương nhau. Bệnh thường được tìm thấy ở các khu vực"
            " có khí hậu nhiệt đới và người da màu có xu hướng mắc bệnh này nhiều "
            "hơn so với những chủng tộc khác.."), 5];
      case  "DaBinhThuong":
        return [Text("Da thường là làn da ở trạng thái cân bằng được độ nhờn và độ "
            "ẩm với bề mặt da không bị quá khô hoặc đổ dầu. Nhìn bằng mắt thông "
            "thường sẽ ít thấy lỗ chân lông, khuyết điểm trên bề mặt làn da thường."
            " Đồng thời màu sắc trên da cũng có độ đồng đều cao, ít gặp tình trạng"
            " da có vùng sáng tối khác nhau."), 1];
      case  "munCoc":
        return [Text("mụn cóc là một dạng tăng sinh bất thường của da. Mụn hạt cơm"
            " là một khối u xấu xí, sần sùi, nhiều khi mụn nổi giống như một bông"
            " súp lơ ở nhiều vị trí khác nhau. Mụn có màu trắng, to nhỏ khác nhau "
            "nhưng thường có kích thước tương đương với hột cơm (vì vậy còn được gọi với cái tên hạt cơm)."
            "Tác nhân gây bệnh là do virus HPV - Human Papilloma Virus, thuộc loại"
            " Papova Virus có ADN. Hiện nay có hơn 60 chủng HPV khác nhau, trong đó"
            " các type thường gặp là 6 và 11. Đôi khi vẫn gặp các virus thuộc type "
            "16, 18, 31, 33 và 35 gây ra các chứng rối loạn sinh sản, mụn sinh dục "
            "(sùi mào gà) hay ung thư tử cung. Các type này thường được tìm thấy "
            "trong các tế bào biểu mô tăng sinh hay khối u trên da bị nhiễm.",),2 ];
      case  "NotRuoi":
        return [Text("Các nốt ruồi trên cơ thể chúng ta được hình thành từ phần "
            "dưới lớp biểu bì, khi những sắc tố da không được phân bố đồng đều trên "
            "da, nó phát triển thành một cụm tạo ra những nốt có màu đậm hơn da "
            "bình thường, có thể mang màu nâu, đen, hay xanh,…"
            "Các chuyên gia Da liễu giải thích về vấn đề nốt ruồi có màu sắc khác "
            "nhau như sau: Bên trong các tế bào sắc tố luôn có chứa các hoạt chất"
            " và chúng thường mang màu sắc khác nhau. Vì thế, do vị trí, mức độ tăng "
            "sắc tố khác nhau, hay độ nông, sâu của nốt ruồi mà nốt ruồi sẽ mang "
            "màu sắc khác nhau và đa số là màu đen."),0];
      case  "UngThuHacTo":
        return [Text("Ung thư hắc tố là một loại ung thư phát triển từ tế bào chứa"
            " hắc tố, gồm melanocytes. Melanocytes là các tế bào sản xuất hắc tố "
            "melanin, quyết định màu sắc của da, tóc và mắt. Khi tế bào melanocytes "
            "trở nên không bình thường và không kiểm soát được quá trình tăng trưởng,"
            " chúng có thể phát triển thành khối u ác tính, gọi là ung thư hắc tố"
            ".Ung thư hắc tố có thể xuất hiện trên da hoặc trong các cơ quan nội "
            "tạng như mắt, niêm mạc miệng, niêm mạc tiết niệu, niêm mạc ruột non "
            "và niêm mạc hệ hô hấp. Loại ung thư da melanoma là dạng phổ biến nhất "
            "của ung thư hắc tố, trong khi các loại ung thư hắc tố nội tạng khác là hiếm gặp."
            "Ung thư hắc tố có thể lan rộng và xâm lấn vào các cơ quan và mô xung quanh, "
            "gây ra những biến chứng và ảnh hưởng nghiêm trọng đến sức khỏe. Điều "
            "quan trọng là phát hiện sớm, chẩn đoán chính xác và điều trị kịp thời "
            "để cải thiện tỷ lệ sống sót và chất lượng cuộc sống của người bệnh."),3];
      case  "LopBu":
        return [Text("Không xác định."),-1];
      case  "KhongXacDinh":
        return  [Text("Không xác định."),-1];
      case  "ZonaThanKinh":
        return [Text("Bệnh zona thần kinh (Zona) còn có tên gọi dân gian là bệnh "
            "Giời Leo. Bệnh là kết quả của sự tái hoạt động của virus Herpes Zoster"
            " (Varicella-Zoster Virus hoặc VZV). Đây cũng là virus gây nên bệnh thủy "
            "đậu. Những người nhiễm loại virus này lúc còn nhỏ, sau khi lành bệnh"
            " virus vẫn không bị tiêu diệt, chúng tồn tại trong các tế bào thần kinh, "
            "hạch thần kinh dưới dạng không hoạt động. Sau một thời gian dài, khi gặp "
            "điều kiện thuận lợi: hệ miễn dịch bị suy yếu, tinh thần bị chấn động, "
            "hoặc suy nhược cơ thể, virus sẽ tái hoạt động thành bệnh zona. "
            "Virus nhân lên và lan truyền theo dây thần kinh, rồi bộc phát ở vùng "
            "da tương ứng với khu vực của dây thần kinh đó, gây ra các phát ban đỏ "
            "rộp và đau đớn. Thời gian bị bệnh kéo dài từ khoảng 2 - 3 tuần. Bệnh "
            "có thể tái phát lại vào các thời điểm sau này, đối với người từng bị nhiễm VZV."),4];
      default:
        return [Container(),-2];
    }
  }

  //Hàm xây dụng giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 28,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text('Chuẩn đoán', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Align', fontWeight: FontWeight.bold), ),
              ),
              Expanded(
                  child: TextButton(
                    onPressed: (){
                      response(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          gradient: LinearGradient(
                            colors: [Color(0xfff5ee14), Color(0xffb39b00)],
                            stops: [0.25, 0.75],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(4,4),
                                spreadRadius: 2
                            )
                          ]
                      ),
                      child: Text("Gửi ý kiến", style: TextStyle(fontSize: 15, fontFamily: 'Align', fontWeight: FontWeight.bold),),
                    ),
                  )
              )
            ],
          ),
          flexibleSpace: Container(
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [ Colors.blueAccent, Colors.lightBlue ]
                )
            ),
          ),
        ),
        //Hình ảnh đã đươc lưu dưới dạng tệp tin sử dụng hàm tạo Image.file() với đường dẫn đã biết để hiển thị hình ảnh
        body: FutureBuilder<ui.Image>(
          future: _loadImageDimension(),  //Thuộc tính future
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Column(
                children: [
                  Flexible(
                      flex: 2,
                      child: ListView(
                        children: [
                          (ImageSelected)?Container(
                              child: Stack(
                                children: [
                                  Positioned(
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                      )
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      width: 263,
                                      height: 360,
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
                                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                            child: Image.file(File(imagePath),)
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ):Container(
                              height: 300,
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xff8e9eab), Color(0xff5a5d5e)],
                                    stops: [0, 1],
                                    begin: Alignment.bottomRight,
                                    end: Alignment.topLeft,
                                  )
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex:1,
                                    child: Lottie.asset(
                                        'assets/animations/AnimationOpps.json',
                                        repeat: false,
                                        fit: BoxFit.contain,
                                        width: 300,
                                        height: 400
                                    ),
                                  ),
                                ],
                              )
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: (ImageSelected) ? Results.map((result){
                                ketQuaTimKiem = Results.first['label'].toString();
                                doChinhXac = Results.first['confidence'].toStringAsFixed(2);
                                return Card();
                              }).toList():[],
                            ),
                          ),

                          //Thông tin về bệnh
                          StatefulBuilder(builder: (context, setState){
                            List<Object> result = _buildScreen(ketQuaTimKiem, setState);
                            Widget diseaseInfo = result[0] as Widget;
                            int diseaseIndex = result[1] as int;
                            SoThuTuBenh = diseaseIndex;
                            print("Số thứ tự bệnh: $SoThuTuBenh");
                            //Lưu thông tin bệnh đã chuẩn đoán
                            SaveDiagnosticHistory(context);
                            return Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: diseaseInfo
                            );
                          }),
                        ],
                      )
                  ),

                  //-------- Hiển thị danh sách kết quả tim kiếm tren gg
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child:Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xff396afc), Color(0xff2948ff)],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text('Kết quả: \n$ketQuaTimKiem \n - \n Độ chính xác: \n$doChinhXac %',
                                  style: TextStyle( color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Arial'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: Lottie.asset(
                              'assets/animations/AnimationDoctor.json',
                              repeat: false,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }else{
              return const Center(child: CircularProgressIndicator());
            }
          },
        )
    );
  }

  //hàm này dùng để lấy kích thước của hình ảnh và trả về đối tượng ui.Image trong tuương lai [Hàm bất đồng bộ]
  Future<ui.Image> _loadImageDimension() async{

    //Biến completer có kiểu Completer<ui.Image>. Hàm Completer sẽ kích hoạt khi tác vụ bất đồng bo hoan thanh
    final completer = Completer<ui.Image>();
    //Tạo một biến file kiểu File từ đường dẫn ảnh lưu trữ trong biến imagePath
    final file = File(imagePath);
    //Dọc nội dung file thành 1 mảng bytes. (Đảm bảo hàm này sẽ chờ đợi thực thi xong rồi mới thực thi câu lệnh khác )
    final bytes = await file.readAsBytes();

    /*
      ui.decodeImageFromList(bytes, (image) {...}
        + Hàm decodeImageFromList từ thư viện "dart:ui". Dùng để giải mã mảng bytes thành 1 đối tượng ui.Image
        + Đây là 1 hàm bất đồng bộ. Vì vậy sẽ mất một khoảng thoời gian để giải mã
        + image: Tham so này là 1 hàm callback sẽ được gọi lại khi mã hóa thành công
     */
    ui.decodeImageFromList(bytes, (image) {
      /*
        - Bên trong hàm callback, khi việc giải mã hình ảnh hoàn thành, đối tượng image
        (kiểu ui.Image) sẽ được sử dụng để kích hoạt completer.
        - Bằng cách gọi completer.complete(image), bạn cung cấp dữ liệu là đối tượng image
        cho Future được trả về bởi completer
      */
      completer.complete(image);
    });
    return completer.future;  //Trả về 1 future được tạo bới completer
  }
}