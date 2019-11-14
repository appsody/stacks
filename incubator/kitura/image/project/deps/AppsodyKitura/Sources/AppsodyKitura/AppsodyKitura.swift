/**
 * This source file is supplied by the appsody/kitura base image. DO NOT MODIFY.
 */

import Foundation
import Configuration
import Kitura
import KituraOpenAPI

public class AppsodyKitura {

    static var _manager: ConfigurationManager?

    /// Returns a ConfigurationManager that provides access to environment variables.
    /// 
    /// Example:
    /// ```swift
    /// let value = manager["MY_VALUE"] as? String ?? "default value"
    /// ```
    public static var manager: ConfigurationManager {
        if let manager = _manager {
            return manager
        }
        let manager = ConfigurationManager()
        manager.load(.environmentVariables)
        _manager = manager
        return manager
    }

    /// Returns the port that the Kitura server should listen on - this can be
    /// specified via  the `PORT` environment variable. Defaults to 8080.
    public static var port: Int {
        return Int(AppsodyKitura.manager["PORT"] as? String ?? "8080") ?? 8080
    }

    /// Returns the path configured for serving the OpenAPI document.
    public static let openAPIPath = "/openapi"

    /// Returns the path configured for serving the Swagger UI tool.
    public static let swaggerUIPath = "/openapi/ui"

    /// Returns the path configured for serving the liveness (health) endpoint.
    public static let livenessPath = "/health"

    /// Returns the path configured for serving the Prometheus metrics endpoint.
    public static let metricsPath = "/metrics"

    /// Creates a Kitura `Router` initialized with liveness, metrics and OpenAPI endpoints.
    /// Logging will be enabled at a default level of `info`, which can be customized
    /// by setting the `LOG_LEVEL` environment variable.
    public static func createRouter(mergeParameters: Bool = false, enableWelcomePage: Bool = true) -> Router {

        // Configure logging
        initializeLogging(value: AppsodyKitura.manager["LOG_LEVEL"] as? String)

        let router = Router(mergeParameters: mergeParameters, enableWelcomePage: enableWelcomePage)

        // Run the metrics initializer
        initializeMetrics(router: router)

        // Add health monitoring endpoint
        initializeHealthRoutes(router: router)

        // Add OpenAPI endpoints
        let config = KituraOpenAPIConfig(apiPath: self.openAPIPath, swaggerUIPath: self.swaggerUIPath)
        KituraOpenAPI.addEndpoints(to: router, with: config)

        return router
    }

    public static func run(_ router: Router) {
        Kitura.addHTTPServer(onPort: port, with: router)
        Kitura.run(exitOnFailure: true)
    }

}
