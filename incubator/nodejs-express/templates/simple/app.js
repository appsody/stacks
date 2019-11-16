module.exports = (/*options*/) => {
  // Use options.server to access http.Server. Example of socket.io:
  //     const io = require('socket.io')(options.server)
  const app = require('express')()

  app.get('/', (req, res) => {
    res.send("Hello from Appsody!");
  });

  return app;
};
