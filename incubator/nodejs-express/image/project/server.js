const express = require('express');
const health = require('@cloudnative/health-connect');
const fs = require('fs');
const http = require('http');

const app = express();
const server = http.createServer(app)

// Requires statements and code for non-production mode usage
if (process.env.NODE_ENV !== 'production') {
  require('appmetrics-dash').monitor({server, app});
}

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

// Register the users app. As this is before the health/live/ready routes,
// those can be overridden by the user
const userApp = require(basePath + getEntryPoint());
app.use('/', userApp({
  server: server,
  app: app,
}));

const healthcheck = new health.HealthChecker();
app.use('/live', health.LivenessEndpoint(healthcheck));
app.use('/ready', health.ReadinessEndpoint(healthcheck));
app.use('/health', health.HealthEndpoint(healthcheck));
app.use('/metrics', require('appmetrics-prometheus').endpoint());

app.get('*', (req, res) => {
  res.status(404).send("Not Found");
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`App started on PORT ${PORT}`);
});

// Export server for testing purposes
module.exports.server = server;
module.exports.PORT = PORT;
