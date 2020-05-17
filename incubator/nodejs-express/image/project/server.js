const Prometheus = require('prom-client')
const express = require('express');
const fs = require('fs');
const health = require('@cloudnative/health-connect');
const http = require('http');

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

const app = express();
const server = http.createServer(app)

// Administrative routes are not timed or logged, but for non-admin routes, pino
// overhead is included in timing.
const healthcheck = new health.HealthChecker();
app.use('/live', health.LivenessEndpoint(healthcheck));
app.use('/ready', health.ReadinessEndpoint(healthcheck));
app.use('/health', health.HealthEndpoint(healthcheck));
app.get('/metrics', (req, res, next) => {
  res.set('Content-Type', Prometheus.register.contentType)
  res.end(Prometheus.register.metrics())
})

// See: http://expressjs.com/en/4x/api.html#app.settings.table
const PRODUCTION = app.get('env') === 'production';
if (!PRODUCTION) {
  require('appmetrics-dash').monitor({server, app});
}

// Time routes after here.
app.use(requestTimer);

// Log routes after here.
const pino = require('pino')({
  level: PRODUCTION ? 'info' : 'debug',
});
app.use(require('pino-http')({logger: pino}));

// Register the user's app.
const basePath = __dirname + '/user-app/';

function getEntryPoint() {
    let rawPackage = fs.readFileSync(basePath + 'package.json');
    let package = JSON.parse(rawPackage);
    if (!package.main) {
        console.error("Please define a primary entrypoint of your application by adding 'main: <entrypoint>' to package.json.")
        process.exit(1)
    }
    return package.main;
}

const userApp = require(basePath + getEntryPoint());
app.use('/', userApp({
  server: server,
  app: app,
  log: pino,
}));

app.get('*', (req, res) => {
  res.status(404).send("Not Found");
});

// Listen and serve.
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`App started on PORT ${PORT}`);
});

// Export server for stack testing purposes.
module.exports.server = server;
module.exports.PORT = PORT;
