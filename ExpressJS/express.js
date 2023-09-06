var express = require('express');
var app = express();
var server = app.listen(8888);
const cwd = process.cwd();
    console.log(`current directory is ${cwd}`);
app.use(express.static('./public'));
const log_hoge = function(req, res, next){
    console.log('hoge');
    next();
};
app.use(log_hoge);
app.get('/fuga', function (req, res) {
    res.send('fuga requested!');
  });