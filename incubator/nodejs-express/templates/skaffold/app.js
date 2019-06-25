const app = require('express')()

app.set('views', __dirname + "/views");
app.set('view engine', 'pug');

app.use('/', require('./routes'));
 
module.exports.app = app;
  