const app = require('./app');
const config = require('./app/config');
const MongoDB = require('./app/utils/mongoDB.util');

async function startServer(){
    try{
        //Kết nối đến CSDL
        await MongoDB.connect(config.db.mongodbcloud);
        console.log('Kết nối đến cở sở dữ liệu thành công');

        //Lắng nghe trên cổng
        app.listen(config.app.port, ()=>{
            console.log(`Server is running on port ${config.app.port}`);
        });
    }catch(err){
        console.log(`Kết nối đến cơ sở dữ liệu thất bại ${err}`);
        process.exit();
    }
}

startServer();