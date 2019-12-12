import AppsodyKitura
import Configuration
import Kitura

public let projectPath = ConfigurationManager.BasePath.project.path

public class App {
    let router: Router
    let manager: ConfigurationManager

    public init() {
        self.router = AppsodyKitura.createRouter()
        self.manager = AppsodyKitura.manager
    }

    public func setUpRoutes() {
        router.get("/hello") { request, response, next in
            response.send("Hello, World!")
            next()
        }
    }

    public func run() {
        AppsodyKitura.run(self.router)
    }

}
