const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
    // Use req.log (a `pino` instance) to log JSON:
    req.log.info({message: 'Hello Express!!!'});
    res.render('index', {msg: 'Hello Express!!!'});
});

module.exports = router;
