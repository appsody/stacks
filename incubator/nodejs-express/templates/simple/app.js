const app = require('express')()

app.get('/', (req, res) => {
  res.send("Hello World!");
});
 
module.exports.app = app;
