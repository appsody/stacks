// Requires statements and code for non-production mode usage
if (!process.env.NODE_ENV || !process.env.NODE_ENV === 'production') {
    require('appmetrics-dash').attach();
}

const Prometheus = require('prom-client')
const RED = require('node-red');
const express = require('express');
const health = require('@cloudnative/health-connect');
const fs = require('fs');
const path = require('path');

Prometheus.collectDefaultMetrics();

const requestHistogram = new Prometheus.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['code', 'handler', 'method'],
    buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5]
})

const requestTimer = (req, res, next) => {
  const path = new URL(req.url, `http://${req.hostname}`).pathname
  const stop = requestHistogram.startTimer({
    method: req.method,
    handler: path
  })
  res.on('finish', () => {
    stop({
      code: res.statusCode
    })
  })
  next()
}

const PORT = process.env.PORT || 3000;

const app = express();
const server = require('http').createServer(function(req,res) {app(req,res);});

app.get('/metrics', (req, res, next) => {
  res.set('Content-Type', Prometheus.register.contentType)
  res.end(Prometheus.register.metrics())
})

const basePath = path.join(__dirname,'/user-app/');
const userDir = basePath;

// Default flow file
let flowFile = path.join(basePath, 'flow.json');

// Load project package file
let rawPackage = fs.readFileSync(path.join(basePath, 'package.json'));
let package = JSON.parse(rawPackage);

if (package['node-red']) {
    let nrSettings = package['node-red'].settings || {};
    if (nrSettings.flowFile) {
        flowFile = path.resolve(path.join(basePath,nrSettings.flowFile));
    }
}

let appSettings = {};

// Load runtime settings
try {
    appSettings = require(path.relative(__dirname, path.join(basePath,"settings.js")));
} catch(err) {
    // No app-specific settings
}

if (!appSettings.flowFile) {
    appSettings.flowFile = flowFile;
}
appSettings.userDir = userDir;


appSettings.httpAdminRoot = false;

// Requires statements and code for non-production mode usage
if (!process.env.NODE_ENV || !process.env.NODE_ENV === 'production') {
    appSettings.httpAdminRoot = '/admin';
}

RED.init(server,appSettings);
if (appSettings.httpAdminRoot) {
    app.use(appSettings.httpAdminRoot,RED.httpAdmin);
}

const healthcheck = new health.HealthChecker();

app.use('/live', health.LivenessEndpoint(healthcheck));
app.use('/ready', health.ReadinessEndpoint(healthcheck));
app.use('/health', health.HealthEndpoint(healthcheck));
app.use(requestTimer);
app.use('/',RED.httpNode);
app.get('*', (req, res) => {
  res.status(404).send("Not Found");
});

const STARTED = new Promise((resolve,reject) => {
    RED.start().then(function() {
        server.on('error', function(err) {
            if (err.stack) {
                RED.log.error(err.stack);
            } else {
                RED.log.error(err);
            }
            reject();
            process.exit(1);
        });
        server.listen(PORT,function() {
            RED.log.info(RED.log._("server.now-running"));
            resolve();
        });
    });
});

// Export server for testing purposes
module.exports.STARTED = STARTED;
module.exports.SERVER = server;
module.exports.RED = RED;
module.exports.PORT = PORT;
