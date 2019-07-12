const express = require('express');
const fs = require('fs');
var path = require('path');

const app = express();

const basePath = path.join(__dirname, 'functions');

var files = fs.readdirSync(basePath);
files.forEach(function(fileName) {
  if (!fileName.endsWith('.js')) return;
  var file = path.join(basePath, fileName);
  var exports = require(file);
  if (exports.url == undefined) return;
  if (exports.get != undefined) app.get(exports.url, exports.get); return;
  if (exports.put != undefined) app.put(exports.url, exports.get); return;
  if (exports.post != undefined) app.post(exports.url, exports.get); return;
  if (exports.patch != undefined) app.patch(exports.url, exports.get); return;
  if (exports.delete != undefined) app.delete(exports.url, exports.get); return;
  if (exports.head != undefined) app.head(exports.url, exports.get); return;
  if (exports.options != undefined) app.options(exports.url, exports.get); return;
  if (exports.connect != undefined) app.connect(exports.url, exports.get); return;
  if (exports.trace != undefined) app.trace(exports.url, exports.get); return;
  if (exports.all != undefined) app.all(exports.url, exports.get); return;
});

module.exports.app = app;