const {MongoClient} = require('mongodb');
require('mongodb').MongoClient;

const path = 'mongodb+srv://giabaodev:GiaBaodev2002@pgiabaodev.vtpstl5.mongodb.net/NhanDangBenhVeDa?retryWrites=true&w=majority&appName=pgiabaodev';

let client =null,
    db = null,
    collection = null;

async function main(){
    client = await MongoClient.connect(path);
    db = await client.db();
    BenhVeDa = await db.collection('BenhVeDa');
    NguoiDung = await db.collection('NguoiDung');
    LichSuChuanDoan = await db.collection('LichSuChuanDoan'); 

    //Kiểm tra kết quả
    console.log(await DanhSachLichSuChuanDoan_ID(0));
}

//Lấy ID cuối bệnh về da
async function IDCuoiBenhDa(){
    const kq = await BenhVeDa.find({}).project({id_benhda:1, _id:0}).sort({id_benhda:-1}).limit(1);
    const doc = await kq.next();
    return doc.id_benhda;
}

//Tìm kiếm xem
async function TimKiemTHongTin(number){
    const kq = await BenhVeDa.find({id_benhda:number}).toArray();
    return (kq.length>0)? true:false;
}

//Tạo id mơi
async function TimNGuoiDung(iduser){
    iduser = parseInt(iduser);
    let thongTin = await NguoiDung.aggregate([
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
    return thongTin[0].sdt;
}

//Danh sách lịch sử chuẩn đoán bệnh dựa trên ID người dùng
async function DanhSachLichSuChuanDoan_ID(idUser){
    idUser = parseInt(idUser);
    const JoinData = await LichSuChuanDoan.aggregate([
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

//======
main();