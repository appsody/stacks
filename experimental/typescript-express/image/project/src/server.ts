import express from "express";
import bodyParser from "body-parser";
import IndexController from "../user-app/src/index";
const health = require('@cloudnative/health-connect');
class App {
  public express: express.Application;
  constructor() {
    this.express = express();
    this.middleware();
    this.routes();
  }
  private middleware(): void {
    this.express.use(function(req, res, next) {
      res.header("Access-Control-Allow-Origin", "*");
      res.header(
        "Access-Control-Allow-Headers",
        "X-Requested-With,content-type"
      );
      res.header(
        "Access-Control-Allow-Methods",
        "GET, POST, OPTIONS, PUT, PATCH, DELETE"
      );
      next();
    });
    this.express.use(bodyParser.json());
    this.express.use(bodyParser.urlencoded({ extended: false }));
    this.express.use(express.static(__dirname + "/public"));
    const healthcheck = new health.HealthChecker();
    this.express.use("/live", health.LivenessEndpoint(healthcheck));
    this.express.use("/ready", health.ReadinessEndpoint(healthcheck));
    this.express.use("/health", health.HealthEndpoint(healthcheck));
    this.express.use("/metrics", require("appmetrics-prometheus").endpoint());
  }
  private routes(): void {
    this.express.get("/", function(_, res) {
      res.send("hi");
    });
    this.express.use("/", IndexController);
  }
}
export default new App().express;
