const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
    res.render('index', {msg: "Hello Express!!!"});
});

module.exports = router;