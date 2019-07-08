const app = require('express')()

app.get('/', (req, res) => {
  res.send("Hello from Appsody!");
});
 
module.exports.app = app;
