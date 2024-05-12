//1.Khai báo thư viên
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
//import 'package:ungdung/icons/my_flutter_app_icons.dart';

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
  final firstcamera = cameras.first;

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
  State<StatefulWidget> createState() {
    return ThuNghiem();
  }
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

  //Load modoel
  Future loadModel() async{
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/NhanDanglogoxe.tflite",              //Mo hinh tflite
        labels: "assets/labelsCarLogo.txt"                     //Nhan
    ))!;
    print("Model loading status: $res");
  }

  //2. phương thức này được gọi khi xóa widget khỏi cây widget
  @override
  void dispose() {
    //Loại bỏ bộ điều khiển khi widget được xử lý
    _controller.dispose();
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

      ImageClassification(File(image.path));

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

        ImageClassification(File(DaChonTapTin.path));  //>>>Gán lấy tệp tin
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
    setState(() {
      _result = recognitions!;
      _image = image;
      imageSelect = true;
    });
  }

  //3.Phương thức xây dựng giao diện
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
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
                  decoration: const BoxDecoration(
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
                      const Expanded(
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
                              icon: const Icon(Icons.menu, color: Colors.white),
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
                  decoration: BoxDecoration(
                      border: Border.all(width: 2 ,color: Colors.white),
                      borderRadius: const BorderRadius.all(Radius.circular(15))
                  ),
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: const Text("Nhấn vào nút để chuẩn đoán", style: TextStyle(color: Colors.white, fontSize: 18),),
                ),
              ),

              //2. >>>>> Bên dưới
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Row(
                      children: [
                        //Thư viện ảnh
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 5, 10),
                            child: ElevatedButton(
                              onPressed: (){
                                HienThiThuVienAnh();
                                print("Truy cập vào thư viện ảnh");
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0x00000000)
                              ),
                              //Chuyển đổi giữa icon và hình ảnh nho
                              child: Icon(IconThuVienAnh, size: 35,),
                            ),
                          ),
                        ),

                        //Nút chụp ảnh
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2, color: Colors.white, ),
                                borderRadius: const BorderRadius.all(Radius.circular(100), ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: IconButton(
                                    onPressed: (){ ChupAnh();},
                                    icon:  const Icon(Icons.search, size: 35,),
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
                      margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      padding: const EdgeInsets.fromLTRB(2, 8, 1, 8),
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
                                    child: const Text('Gửi ý kiến phản hồi.', style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.left,),
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
                                    child:const Text('Quảng lý quyền.', style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.left,),
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
                                    child:const Text('Chính sách quyền riêng tư.', style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.left,),
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
    );
  }
}

//>>>>> 1. Lớp hiển thị hình ảnh được chụp bởi người dùng
class DisplayPictureScreen extends StatelessWidget{
  //Thuộc tính
  final String imagePath;
  final bool ImageSelected;
  final List Results;
  String? ketQuaTimKiem;

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

  //Hàm xây dụng giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Chuẩn đoán.')),
        //Hình ảnh đã đươc lưu dưới dạng tệp tin sử dụng hàm tạo Image.file() với đường dẫn đã biết để hiển thị hình ảnh
        body: FutureBuilder<ui.Image>(
          future: _loadImageDimension(),  //Thuộc tính future
          builder: (context, snapshot){
            if(snapshot.hasData && imagePath.isEmpty){
              return Column(
                children: [
                  Flexible(
                      flex: 2,
                      child: ListView(
                        children: [
                          (ImageSelected)?Container(
                            color: Colors.black54,
                            width: double.infinity,
                            height: 300,
                            child: Center(
                                child: Image.file(File(imagePath),)//asset( imagePath, fit: BoxFit.cover),
                            ),
                          ):Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey,
                              alignment: Alignment.center,
                              child: const Column(
                                children: [
                                  Expanded(
                                      flex:2,
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                  ),
                                  Expanded(
                                      flex:1,
                                      child: Text(
                                        "#411 Error 'Not Found Image'",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25
                                        ),
                                      )
                                  ),
                                ],
                              )
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: (ImageSelected)?Results.map((result){
                                ketQuaTimKiem = result['label'][0];
                                return Card(
                                  child: Container(
                                    child: Text(
                                      "${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
                                      style: const TextStyle(color: Colors.black, fontSize: 18),
                                    ),
                                  ),
                                );
                              }).toList():[],
                            ),
                          )
                        ],
                      )
                  ),
                  //-------- Hiển thị danh sách kết quả tim kiếm tren gg
                  Flexible(
                      flex: 1,
                      child:
                      Text('Kích cỡ ảnh: ${snapshot.data!.width} x ${snapshot.data!.height}')
                  ),
                ],
              );
            }else{
              return const Center(
                  child: Text('Đưuòng dẫn không hợp lệ')

              );
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