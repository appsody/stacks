const express = require('express');
const vhost = require('vhost');
const health = require('@cloudnative/health-connect');
const fs = require('fs');

require('appmetrics-prometheus').attach();

const app = express();

const basePath = __dirname + '/user-app/';

function getEntryPoint() {
    let rawPackage = fs.readFileSync(basePath + 'package.json');
    let package = JSON.parse(rawPackage);
    if (!package.main) {
        console.error("Please define a primary entrypoint of your application by agdding 'main: <entrypoint>' to package.json.")
        process.exit(1)
    }
    return package.main;
}

const healthcheck = new health.HealthChecker();
app.use('/live', health.LivenessEndpoint(healthcheck));
app.use('/ready', health.ReadinessEndpoint(healthcheck));
app.use('/health', health.HealthEndpoint(healthcheck));

const userApp = require(basePath + getEntryPoint()).app;
app.use(vhost('*', userApp));

app.get('*', (req, res) => {
  res.status(404).send("Not Found");
});

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
  console.log(`App started on PORT ${PORT}`);
});

// Export server for testing purposes
module.exports.server = server;
module.exports.PORT = PORT;