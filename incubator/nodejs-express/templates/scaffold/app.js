module.exports = (/*options*/) => {
  // Use options.server to access http.Server. Example of socket.io:
  //     const io = require('socket.io')(options.server)
  const app = require('express')()

  app.set('views', __dirname + "/views");
  app.set('view engine', 'pug');

  app.use('/', require('./routes'));
 
  return app;
};
