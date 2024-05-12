const ApiError = require('../api-error');
const UserService = require('../services/user.service');
const MongoDB = require('../utils/mongoDB.util');

    //      >>>>    PORT    <<<<
//1. Thêm tìa khoản người dùng
exports.addUser = async(req, res, next) =>{
    //Kiểm tra xem có trường nào bị thiếu thông tin không
    if(!req.body?.hoten){
        return next(new ApiError(400, 'Vui long dien day du thong tin ca nhan'));
    }
    try{
        const userservice = new UserService(MongoDB.client);
        const doc = await userservice.TaoTaiKhoanNguoiDung(req.body);
        if(doc == true){
            return res.status(200).send({message: "Tạo tài khoản thành công",value: 1});
        }
        return res.status(400).send({message: "Tạo tài khoản thất bại",value: 0});
    }catch(err){
        return res.status(500).send({message: `Lỗi khi tạo tài khoản: ${err.message}`,value: -1});
    }
}

//2. Thêm phản hồi từ người dùng
exports.addUserResponse =async(req, res, next) =>{
    try{
        const userservice = new UserService(MongoDB.client);
        const doc = await userservice.PhanHoiCuaNguoiDung(req.params.idUser,req.params.idBenh,req.body);
        
        if(doc == false){
            return res.status(400).send({message: "Lỗi khi thêm phản hồi từ người dùng",value: 0});
        }
        return res.status(200).send({message: "Gửi thành công",value: 1});
    }catch(err){
        return next(new ApiError(500, `Loi ben phía server. Khi thêm phản hồi từ người dùng: ${err.message}`));
    }
}

//3. Lưu thông tin lịch sử chuẩn đoán bệnh
exports.SaveDiagnosticHistory =async(req, res, next) =>{
    try{
        const userservice = new UserService(MongoDB.client);
        const doc = await userservice.LichSuChuanDoanBenh(req.params.idUser,req.params.idBenh);
        
        if(doc == false){
            return res.status(400).send({message: "Lỗi khi lưu lịch sử chuẩn đoán từ người dùng",value: 0});
        }
        return res.status(200).send({message: "Lưu lịch sử chuẩn đoán thành công",value: 1});
    }catch(err){
        return next(new ApiError(500, `Loi ben phía server. Khi lưu lịch sử chuẩn đoán từ người dùng: ${err.message}`));
    }
}

    //      >>>>    GET    <<<<
//1. Tìm thông tin người dùng thông qua ID người dùng
exports.getUser = async(req, res, next) =>{
    try{
        const userservice = new UserService(MongoDB.client);
        const doc = await userservice.TimNguoiDung_ID(req.params.id);
        if(!doc){
            return res.status(404).send({message: `ID người dùng ${req.params.id}' Không tồn tại`});
        }
        return res.send(doc);
    }catch(err){
        return next(new ApiError(500, `Loi xuat hien khi tim tai khoan nguoi dung: ${err.message}`));
    }
} 

//2. Lấy danh sách lịch sử chuẩn đoán dựa trên ID người dùng
exports.ListOfMedicalDiagnosisHistory = async(req, res, next) =>{
    try{
        const userservice = new UserService(MongoDB.client);
        const doc = await userservice.DanhSachLichSuChuanDoan_ID(req.params.id);
        if(doc == false){
            return res.status(404).send({message: `ID người dùng ${req.params.id}' Không tồn tại`});
        }
        return res.send(doc);
    }catch(err){
        return next(new ApiError(500, `Loi .Khi lấy danh sách lịch sử chuẩn đoán - ${err}`));
    }
}

    //      >>>>    PUT    <<<<
//1. Cập nhật thông tin người dùng thông qua ID
exports.updateUserInfomation = async (req, res, next) => {
    try{
        const userservice = new UserService(MongoDB.client);
        const doc = await userservice.CapNhatThongTinNguoiDung(req.params.id,req.body);
        //Nếu ID không tồn tại thì báo lỗi
        if(doc != true){
            return next(new ApiError(400, 'Khong tin thay ID nguoi dung'));
        }
        return res.send({message:`Cap nhat thong tin nguoi dung thanh cong: ${req.params.id} - ${doc}`});
    }catch(err){
        return next(new ApiError(500, `Loi. Khi dang cap nhat thong tin nguoi dung ${err}`));
    }
}
    //      >>>>    Delete    <<<<
//1. xóa thông tin người dùng dựa trên ID
exports.deleteUser = async (req, res, next) => {
    try{
        const userservice = new UserService(MongoDB.client);
        const doc = await userservice.xoaNguoiDung_ID(req.params.id);
        //Nếu ID không tồn tại thì báo lỗi
        if(doc == -1){
            return next(new ApiError(400, 'Khong tin thay ID nguoi dung'));
        }
        if(doc != true){
            return next(new ApiError(400, `Khong tin thay so dien thoai cua nguoi dung ${req.params.id}`));
        }
        return res.send({message:`Da xoa nguoi dung thanh cong co ID: ${req.params.id} - ${doc}`});
    }catch(err){
        return next(new ApiError(500, `Loi. Khi dang xoa thong tin nguoi dung ${err}`));
    }
}
