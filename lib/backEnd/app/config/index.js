const config = {
    app:{
        port: 3001 || process.env.PORT,
    },
    db:{
        mongodblocal: process.env.MONGODB_URI || 'mongodb://localhost:27017',
        mongodbcloud: process.env.MONGODB_URI || "mongodb+srv://giabaodev:GiaBaodev2002@pgiabaodev.vtpstl5.mongodb.net/NhanDangBenhVeDa?retryWrites=true&w=majority&appName=pgiabaodev",
    }
};

//TK: giabaodev
//mk: GiaBaodev2002
//NameKeyAPI: BaoMatGiaBao
//APIkey: k5Trc4YQFEXjRlB0uwwBGvulOtI0JEOp7lGgb2V0u2J4KtJBAO9XgmP0ewG9N1BL
/*
curl --location --request POST 'https://ap-southeast-1.aws.data.mongodb-api.com/app/data-ereoutd/endpoint/data/v1/action/findOne' \
--header 'Content-Type: application/json' \
--header 'Access-Control-Request-Headers: *' \
--header 'api-key: k5Trc4YQFEXjRlB0uwwBGvulOtI0JEOp7lGgb2V0u2J4KtJBAO9XgmP0ewG9N1BL' \
--data-raw '{
    "collection":"<COLLECTION_NAME>",
    "database":"<DATABASE_NAME>",
    "dataSource":"pgiabaodev",
    "projection": {"_id": 1}
}'
*/
//uriCloud: mongodb+srv://giabaodev:***@pgiabaodev.vtpstl5.mongodb.net//?retryWrites=true&w=majority&appName=pgiabaodev
// >>> Không đẩy file này lên github <<<<

module.exports = config;
