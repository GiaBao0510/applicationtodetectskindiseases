const express = require('express');
var bcrypt = require('bcrypt');
const {ObjectId} = require('mongodb'); 

class DangNhap{
    //Hàm khởi tạo
    constructor(client){
        this.TaiKhoan = client.db().collection('TaiKhoan');
        this.NguoiDung = client.db().collection('NguoiDung');
    }

    async ThucHienDangNhap(input){
        //Thuộc tính
        let ID = -1;

        //Kiểm tra xem trong bảng tài khoản có tồn tại hay không
        const TimTaiKhoan = await this.TaiKhoan.findOne({taikhoan: input.taikhoan});
        if(!TimTaiKhoan){
            return -1;
        }

        //Nếu tồn tại thì so sánh mật khẩu có khớp  với nhau không
        const SoSanhMatKhau = await bcrypt.compare(input.matkhau, TimTaiKhoan.matkhau);
        if(!SoSanhMatKhau){
            return -2;
        }

        //Khớp thì Dò xem vai trò người là ai
        if(TimTaiKhoan.role == 2){
            ID = await this.NguoiDung.findOne({sdt: TimTaiKhoan.taikhoan});
            ID = ID.IDuser;
        }

        return {
            "id": ID,
            "role": TimTaiKhoan.role
        };
    }
}

module.exports = DangNhap;