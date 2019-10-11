import Foundation
import Configuration
import Kitura

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

    /// Creates a Kitura `Router` initialized with liveness and metrics endpoints.
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

        return router
    }

    public static func run(_ router: Router) {
        Kitura.addHTTPServer(onPort: port, with: router)
        Kitura.run(exitOnFailure: true)
    }

}
