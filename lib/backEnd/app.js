//Thêm module
const express = require('express');
const session = require('express-session');
const cors = require('cors');
const ApiError = require('./app/api-error');
const MongoDB = require('./app/utils/mongoDB.util');
const cookieSession = require('cookie-session');
const DangNhap = require('./app/services/login');

//

var bodyParser = require('body-parser');

const user = require('./app/routes/user.router');

const app = express();

app.use(
    session({
        secret: "somescret",        //Chuỗi bí mật dùng để mã hóa và giải mã dữ liệu phiên. Lưu ý: chọn chuỗi bí mật mạnh và bí mật
        cookie: {maxAge: 60000},    // Phần này xác định thời gian tồn tại của cookie phiên
        resave: true,               //Trường hợp này đảm bảo rằng dữ liệu phiên được lưu trữ ngay cả khi không thay đổi
        saveUninitialized: false,           //Trường hợp này cho phép người dùng lưu trữu phiên ngay cả khi chưa đăng nhập
    })
);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({extended: true}));
app.use('/user', user);

//đăng nhập
app.post('/login',
    async(req, res, next) =>{
        try{
            const {taikhoan, matkhau} = req.body;

            //Nếu 1 trong 2 trường bị rỗng thì báo lỗi
            if( taikhoan && matkhau ){
                //Nếu người dùng đã đăng nhập rồi
                if(req.session.authenticated){
                    return res.json(session);
                }else{
                    const DN = new DangNhap(MongoDB.client);
                    const doc = await DN.ThucHienDangNhap(req.body);

                    //DK: không thấy tài khoản
                    if(doc == -1){
                        return res.status(401).send({message: "Số điện thoại không tồn tại", value:-1});
                    }

                    //DK: sai mật khẩu
                    if(doc == -2){
                        return res.status(401).send({message: "Sai mật khẩu", value:-2});
                    }
                    req.session.authenticated = true;
                    req.session.user = doc;
                    req.session.SDT = doc.taikhoan;
                    req.session.role = doc.role;
                    req.session.ID = doc.id;
                    req.secure.code = 'GOOD_REQUEST';
                    return res.status(200).json({id: doc.id, role: doc.role, value: 1});
                }
            }else{
                return res.status(403).json({msg:`Thiếu thông tin đăng nhập: ${taikhoan} - ${matkhau} `, value:0});
            }
        }catch(err){
            return next(new ApiError(500, `Loi xuat hien khi thuc hien dang nhap: ${err}`));
        }
    }
)

//Xóa phiên
app.get('/exit', function(req, res){
    req.session.destroy();
});

//Xử lý lỗi từ phía client
app.use((req, res, next)=>{
    return next(new ApiError(404, "Resource not found!"));
});

//Xử lý lỗi từ server
app.use((err, req, res, next)=>{
    return res.status(err.statusCode || 500).json({
        message: err.message || 'Internal server error',
    });
});

module.exports = app;