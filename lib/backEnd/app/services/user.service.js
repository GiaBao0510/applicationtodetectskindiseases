const {ObjectId, ReturnDocument} = require('mongodb');
var bcrypt = require('bcrypt');

class UserService{
    constructor(client){
        this.BenhVeDa = client.db().collection('BenhVeDa');
        this.TaiKhoan = client.db().collection('TaiKhoan');
        this.PhanHoi = client.db().collection('PhanHoi');
        this.NguoiDung = client.db().collection('NguoiDung');
        this.LichSuChuanDoan = client.db().collection('LichSuChuanDoan');
    }

    //Tạo Id mới cho người dùng
    async newID_User(){
        let LaySoLuong = await this.NguoiDung.countDocuments({});
        
        //Nếu số lượng chưa có thì trả về luôn
        if(LaySoLuong < 1){
            return 0;
        }else{
            const idNew = LaySoLuong+1;

            //Kiểm tra xem nếu số lượng này có tồn tại hay chưa.Nếu chưa tông tài thì thêm vào
            const timID0 = await this.NguoiDung.find({IDuser: LaySoLuong}).toArray();
            if(timID0.length < 1){
                return LaySoLuong;
            }

            //Tìm id này đã tồn tại hay chưa
            const timID = await this.NguoiDung.find({IDuser: idNew}).toArray();

            //Nếu rồi thì lấy id cuối rồi cộng giá trị id cuối cho 1
            if(timID.length > 0){
                const LayIDcuoi = await this.NguoiDung.find({}).project({IDuser:1, _id:0}).sort({IDuser:-1}).limit(1);
                const doc = await LayIDcuoi.next();
                doc = parseInt(doc);
                return doc+1;
            }else{ //Nếu chưa thì thêm mới
                return idNew;
            }
        }
    }

    //1.Tạo người dùng
    async TaoTaiKhoanNguoiDung(payload){

        //Kiểm tra xem có trùng email hay số điện thoại không
        let TimEmail = await this.NguoiDung.findOne({email:payload.email });
        let TimSDT = await this.NguoiDung.findOne({sdt:payload.sdt });

        if(TimEmail != null || TimSDT != null){
            return false;
        }

        //Thông tin đầu vào
        const idMoi = await this.newID_User();
        const input ={
            IDuser: idMoi,
            hoten: payload.hoten,
            email: payload.email,
            diachi: payload.diachi,
            sdt: payload.sdt
        };

        //Băm mật khẩu người dùng
        let saltRounds = 10;
        let salt = await bcrypt.genSalt(saltRounds);
        let PW = await bcrypt.hash(payload.matkhau, salt);

        //Tài khoản người dùng
        const account = {
            taikhoan: payload.sdt,
            matkhau: PW,
            role: 2
        };

        await this.NguoiDung.insertOne(input);
        await this.TaiKhoan.insertOne(account);
        return true;
    }

    //2.Trả về số điện thoại người dùng thông qua ID người dùng
    async TimSoDienThoaiNguoiDung_ID(iduser){
        iduser = parseInt(iduser);
        let thongTin = await this.NguoiDung.aggregate([
            {
                $lookup:{
                    from: 'TaiKhoan',
                    localField: 'sdt',
                    foreignField:'taikhoan',
                    as:'ThongTinNguoiDung'
                }
            },{
                $unwind: '$ThongTinNguoiDung'
            },
            {
                $match:{
                    IDuser: iduser
                }
            }
            ,{
                $project:{
                    _id:0,
                    IDuser: '$IDuser',
                    hoten:"$hoten",
                    email:"$email",
                    sdt:"$sdt",
                    diachi:"$diachi",
                    matkhau:"$ThongTinNguoiDung.matkhau",
                }
            }
        ]).toArray();
        return thongTin[0].sdt.toString();
    }
    
    //3. Trả về số điện thoại người dùng thông qua ID người dùng
    async TimNguoiDung_ID(iduser){
        iduser = parseInt(iduser);
        let thongTin = await this.NguoiDung.aggregate([
            {
                $lookup:{
                    from: 'TaiKhoan',
                    localField: 'sdt',
                    foreignField:'taikhoan',
                    as:'ThongTinNguoiDung'
                }
            },{
                $unwind: '$ThongTinNguoiDung'
            },
            {
                $match:{
                    IDuser: iduser
                }
            }
            ,{
                $project:{
                    _id:0,
                    IDuser: '$IDuser',
                    hoten:"$hoten",
                    email:"$email",
                    sdt:"$sdt",
                    diachi:"$diachi",
                    matkhau:"$ThongTinNguoiDung.matkhau",
                }
            }
        ]).toArray();
        return thongTin;
    }

    //4. Xóa ngươi dùng thông qua id người dùng
    async xoaNguoiDung_ID(iduser){
        iduser = parseInt(iduser);
        let thongTin = await this.NguoiDung.aggregate([
            {
                $lookup:{
                    from: 'TaiKhoan',
                    localField: 'sdt',
                    foreignField:'taikhoan',
                    as:'ThongTinNguoiDung'
                }
            },{
                $unwind: '$ThongTinNguoiDung'
            },
            {
                $match:{
                    IDuser: iduser
                }
            }
            ,{
                $project:{
                    _id:0,
                    IDuser: '$IDuser',
                    hoten:"$hoten",
                    email:"$email",
                    sdt:"$sdt",
                    diachi:"$diachi",
                    matkhau:"$ThongTinNguoiDung.matkhau",
                }
            }
        ]).toArray();
        
        //Nếu người dùng không tồn tại thì trả về false
        if(thongTin.length < 1){
            return false;
        }

        //Ngược lại thì xóa
        const SDT = thongTin[0].sdt;

        await this.NguoiDung.deleteOne({sdt: SDT});
        await this.TaiKhoan.deleteOne({taikhoan: SDT});
        return true;
    }

    //5. Cập nhật thông tin người dùng
    async CapNhatThongTinNguoiDung(iduser, input) {
        //Nếu tìm không thấy ID thì không cập nhật
        iduser = parseInt(iduser);
        const TimID = this.TimNguoiDung_ID(iduser);
        if (TimID.length < 1) {
            return -1;
        }
    
        //Ngược lại cập nhật
        const SDT = await this.TimSoDienThoaiNguoiDung_ID(iduser);
        if (SDT) { // Kiểm tra xem SDT có giá trị hợp lệ hay không
            await this.NguoiDung.findOneAndUpdate(
                { IDuser: iduser },
                { $set: input },
                { returnDocument: "after" }
            );

            //Băm lại mật khẩu
            let saltRounds = 10;
            let salt = await bcrypt.genSalt(saltRounds);
            let PW = await bcrypt.hash(input.matkhau, salt);

            await this.TaiKhoan.findOneAndUpdate(
                { taikhoan: SDT },
                {
                    $set: {
                        matkhau: PW
                    }
                },
                { returnDocument: "after" }
            );
        } else {
            // Xử lý trường hợp không tìm thấy SDT hoặc trả về thông báo lỗi
            return false;
        }
    
        return true;
    }

    //6.Phản hồi
    async PhanHoiCuaNguoiDung(idUser, idBenh, payload){
        idBenh = parseInt(idBenh);
        idUser = parseInt(idUser);

        //Tìm id người dùng và id bệnh có tồn tại hay không
        let timBenhDa = await this.BenhVeDa.findOne({id_benhda: idBenh});
        let timNguoiDung = await this.NguoiDung.findOne({IDuser: idUser});

        if(!timBenhDa || !timNguoiDung){
            return false;
        }

        //Lấy thời điểm hiện tại
        let today = new Date();
        let currentDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());

        //Chuyển này về chuỗi
        currentDay = currentDay.toLocaleDateString();

        //Đầu vào
        const input = {
            binhluan: payload.binhluan,
            hinhanh: payload.hinhanh,
            thoigian: currentDay,
            IDuser: idUser,
            id_benhda: idBenh
        };

        //Thêm phản hồi
        await this.PhanHoi.insertOne(input);
        return true;
    }

    //7. Lịch sử khám bệnh
    async LichSuChuanDoanBenh(idUser, idBenh){
        idUser = parseInt(idUser);
        idBenh = parseInt(idBenh);

        //Tìm id người dùng và id bệnh có tồn tại hay không
        let timBenhDa = await this.BenhVeDa.findOne({id_benhda: idBenh});
        let timNguoiDung = await this.NguoiDung.findOne({IDuser: idUser});

        if(!timBenhDa || !timNguoiDung){
            return false;
        }

        //Lấy thời điểm hiện tại
        let today = new Date();
        let currentDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());

        //Chuyển này về chuỗi
        currentDay = currentDay.toLocaleDateString();

        //Đầu vào
        const input = {
            thoigian: currentDay,
            IDuser: idUser,
            id_benhda: idBenh
        };

        //Thêm phản hồi
        await this.LichSuChuanDoan.insertOne(input);
        return true;
    }

    //8.Danh sách lịch sử chuẩn đoán bệnh dựa trên ID người dùng
    async DanhSachLichSuChuanDoan_ID(idUser){
        idUser = parseInt(idUser);

        //Tìm id người dùng
        let TimNguoiDung = await this.NguoiDung.findOne({IDuser: idUser});
        if(!TimNguoiDung){
            return false;
        }

        const JoinData = await this.LichSuChuanDoan.aggregate([
            {
                $lookup:{
                    from:"NguoiDung",
                    localField: "IDuser",
                    foreignField: "IDuser",
                    as: "LSnguoidung"
                }
            },
            {
                $unwind: "$LSnguoidung"
            },
            {
                $lookup:{
                    from:"BenhVeDa",
                    localField: "id_benhda",
                    foreignField: "id_benhda",
                    as: "LSbenhda"
                }
            },
            {
                $unwind: "$LSbenhda"
            },
            {
                $match:{
                    IDuser: idUser
                }
            },
            {
                $project:{
                    _id:0,
                    BenhVeDa: "$LSbenhda.tenbenh",
                    thoidiem: "$thoigian",
                }
            }
        ]).toArray();
        return JoinData;
    }


}


module.exports = UserService;