/**
 * This source file is supplied by the appsody/kitura base image. DO NOT MODIFY.
 */

import Health
import Kitura

public let health = Health()

func initializeHealthRoutes(router: Router) {
    
    router.get("/health") { (respondWith: (Status?, RequestError?) -> Void) -> Void in
        if health.status.state == .UP {
            respondWith(health.status, nil)
        } else {
            respondWith(nil, RequestError(.serviceUnavailable, body: health.status))
        }
    }
    
}
