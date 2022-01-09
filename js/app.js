const express = require('express');
const morgan = require('morgan');
const cors = require('cors')
const crypto = require('crypto-js')

const app = express();

app.use(morgan('dev'));
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({extended: true}));

app.get('/encrypt', (req, res)=> {
    const encrypted = crypto.AES.encrypt(JSON.stringify({NASA: "THIS IS NASA TOP SECRET"}), "top secret" ).toString();
    res.json({encrypted});

});

app.post('/decrypt', (req, res) => {
    const cypherText = req.body.encrypted;
    const decrypted = crypto.AES.decrypt(cypherText, "top secret").toString(crypto.enc.Utf8);
    console.log(decrypted);

    const responseMessage = crypto.AES.encrypt("message has been recieved", "top secret").toString();

    res.json({message: responseMessage});
})

app.listen(6060, console.log('listening on ports 6060'))