module.exports = (app) => {

    app.set('views', __dirname + "/views");
    app.set('view engine', 'pug');

    app.use('/', require('./routes'));
    
}
  