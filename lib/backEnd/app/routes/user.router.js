const express = require('express');
const NguoiDung = require('../controllers/user.controller');

//0. Tạo 1 router để quản lý tuyến đường
const router = express.Router();

//1.Tạo tài khoản
router.route('/register/').post(NguoiDung.addUser);

//2. Tìm, xóa và sửa thông người dùng
router.route('/:id')
    .get(NguoiDung.getUser)
    .delete(NguoiDung.deleteUser)
    .put(NguoiDung.updateUserInfomation);

//3. Thêm thông tin phản hồi
router.route('/phanhoi/:idUser/benhda/:idBenh').post(NguoiDung.addUserResponse);

//4. Lưu lịch sử chuẩn đoán bệnh về da
router.route('/lichSuChuanDoan/:idUser/benhda/:idBenh').post(NguoiDung.SaveDiagnosticHistory);

//5. Lấy danh sách chuẩn đoánbệnh về da dựa trên ID người dùng
router.route('/lichchuandoan/:id').get(NguoiDung.ListOfMedicalDiagnosisHistory);

// -----
module.exports = router;