import Foundation
import Kitura
import KituraNet
import XCTest

@testable import AppsodyKitura

class RouteTests: XCTestCase {
    static var allTests : [(String, (RouteTests) -> () throws -> Void)] {
        return [
            ("testGetWelcomePage", testGetWelcomePage),
            ("testHealthRoute", testHealthRoute)
        ]
    }

    let app = App()

    /// Starts the Kitura server using the App's port and router
    override func setUp() {
        super.setUp()
        let server = Kitura.addHTTPServer(onPort: app.port, with: app.router)
        let startedExpectation = expectation(description: "Server started")
        server.started {
            startedExpectation.fulfill()
        }
        let failures = Kitura.startWithStatus()
        XCTAssertEqual(failures, 0)
        waitForExpectations(timeout: 3.0)
    }

    /// Stops the Kitura server
    override func tearDown() {
        Kitura.stop()
        super.tearDown()
    }

    /// Tests that the default welcome page served by Kitura can be obtained.
    func testGetWelcomePage() {
        let responseExpectation = expectation(description: "The / route will serve static HTML content.")

        URLRequest(forTestWithMethod: "GET", port: app.port, route: "/")?
            .responseFromKitura { responseString, statusCode in
                XCTAssertEqual(statusCode, .OK)
                guard let responseString = responseString else {
                    XCTFail("No response string returned")
                    return responseExpectation.fulfill()
                }
                XCTAssertTrue(responseString.contains("<html"))
                XCTAssertTrue(responseString.contains("</html>"))
                responseExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    /// Tests that the built-in health endpoint is responding correctly.
    func testHealthRoute() {
        let responseExpectation = expectation(description: "The /health route responds with UP, followed by a timestamp.")
        
        URLRequest(forTestWithMethod: "GET", port: app.port, route: "/health")?
            .responseFromKitura { responseString, statusCode in
                XCTAssertEqual(statusCode, .OK)
                guard let responseString = responseString else {
                    XCTFail("No response string returned")
                    return responseExpectation.fulfill()
                }
                XCTAssertTrue(responseString.contains("UP"), "Health status does not contain 'UP'.")
                let date = Date()
                let calendar = Calendar.current
                let yearString = String(describing: calendar.component(.year, from: date))
                XCTAssertTrue(responseString.contains(yearString), "Health timestamp does not contain the current year.")
                responseExpectation.fulfill()
        }
        waitForExpectations(timeout: 3.0)
    }

}

/// A simple HTTP client for use by the application tests.
private extension URLRequest {

    /// Creates a URLRequest with the specified method, server port and route. It is assumed
    /// that the server address is `localhost`.
    /// The `Content-Type` will be set to `application/json`, and a (JSON) message
    /// body may be supplied as a Data, suitable for testing PUT/POST routes.
    init?(forTestWithMethod method: String, port: Int, route: String, body: Data? = nil) {
        let urlString = "http://localhost:" + String(port) + route
        if let url = URL(string: urlString) {
            self.init(url: url)
            addValue("application/json", forHTTPHeaderField: "Content-Type")
            httpMethod = method
            cachePolicy = .reloadIgnoringCacheData
            if let body = body {
                httpBody = body
            }
        } else {
            XCTFail("Failed to create URL from string '\(urlString)'")
            return nil
        }
    }

    /// Makes a request to Kitura and calls a completion handler with the response body
    /// (if any) as a String, and the HTTP status code.  If no data is returned, the String will
    /// be empty.
    /// If a non-success status is returned, details of the response will also be printed.
    func responseFromKitura(completion: @escaping (String?, HTTPStatusCode) -> Void) {
        guard let method = httpMethod, var path = url?.path, let headers = allHTTPHeaderFields else {
            XCTFail("Invalid request params")
            return
        }

        if let query = url?.query {
            path += "?" + query
        }

        let requestOptions: [ClientRequest.Options] = [.method(method), .hostname("localhost"), .port(8080), .path(path), .headers(headers)]

        // Create a ClientRequest. Completion will be called when the server
        // responds.
        let req = HTTP.request(requestOptions) { response in
            guard let response = response else {
                return XCTFail("ClientResponse was nil")
            }
            var body = Data()
            do {
                try response.readAllData(into: &body)
            } catch {
                XCTFail("Failed to read response data: \(error)")
            }
            let responseString = String(data: body, encoding: .utf8)
            if responseString == nil {
                XCTFail("Unable to decode string from response data")
            }
            if response.statusCode.class != .successful {
                print("Non-success status code: \(response.statusCode)")
                if let str = responseString, str.count > 0 {
                    print("Response data: " + str)
                }
            }
            completion(responseString, response.statusCode)
        }

        // Send request to server
        if let dataBody = httpBody {
            req.end(dataBody)
        } else {
            req.end()
        }
    }
}
