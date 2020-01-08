import Foundation
import Kitura
import KituraNet
import XCTest
import AppsodyKitura
#if canImport(FoundationNetworking)
   import FoundationNetworking
#endif


@testable import Application

/// A set of tests to verify the features provided by the base Kitura stack.
class KituraStackTests: XCTestCase {
    static var allTests : [(String, (KituraStackTests) -> () throws -> Void)] {
        return [
            ("testHealthRoute", testHealthRoute),
            ("testOpenAPIRoute", testOpenAPIRoute),
            ("testMetricsRoute", testMetricsRoute)
        ]
    }

    let app = App()

    /// Starts the Kitura server using the App's port and router
    override func setUp() {
        super.setUp()
        let server = Kitura.addHTTPServer(onPort: AppsodyKitura.port, with: app.router)
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

    /// Tests that the built-in health endpoint is responding correctly.
    func testHealthRoute() {
        let responseExpectation = expectation(description: "The /health route responds with UP, followed by a timestamp.")

        URLRequest(forTestWithMethod: "GET", port: AppsodyKitura.port, route: AppsodyKitura.livenessPath)?
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

    /// Tests that the built-in OpenAPI endpoint is responding correctly.
    func testOpenAPIRoute() {
        let responseExpectation = expectation(description: "The /openapi route responds with a JSON document.")

        URLRequest(forTestWithMethod: "GET", port: AppsodyKitura.port, route: AppsodyKitura.openAPIPath)?
            .responseFromKitura { responseString, statusCode in
                defer { responseExpectation.fulfill() }
                XCTAssertEqual(statusCode, .OK)
                guard let responseString = responseString, let data = responseString.data(using: .utf8) else {
                    XCTFail("No response data returned")
                    return responseExpectation.fulfill()
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        return XCTFail("JSON object was not a dictionary")
                    }
                    // Check that OpenAPI document contains a basePath of /
                    guard let basePath = json["basePath"] as? String else {
                        return XCTFail("Document did not contain basePath")
                    }
                    XCTAssertEqual(basePath, "/")
                    // Check that the document contains a 'paths' section
                    guard let paths = json["paths"] as? [String: Any] else {
                        return XCTFail("Document did not contain 'paths' dictionary")
                    }
                    // Check that the paths include the /health route
                    guard (paths[AppsodyKitura.livenessPath] as? [String: Any]) != nil else {
                        return XCTFail("Document did not contain a '\(AppsodyKitura.livenessPath)' path dictionary")
                    }
                } catch {
                    return XCTFail("Invalid JSON document received: \(error)")
                }
        }
        waitForExpectations(timeout: 3.0)
    }

    /// Tests that the built-in Metrics endpoint is available and functioning correctly.
    func testMetricsRoute() {
        let responseExpectation = expectation(description: "The /metrics route will serve metrics content.")

        URLRequest(forTestWithMethod: "GET", port: AppsodyKitura.port, route: AppsodyKitura.metricsPath)?
            .responseFromKitura { responseString, statusCode in
                XCTAssertEqual(statusCode, .OK)
                guard let responseString = responseString else {
                    XCTFail("No response string returned")
                    return responseExpectation.fulfill()
                }
                // Note: there may be no actual metrics data returned yet as the server has
                // only recently started, however we should at least find a line containing
                // "HELP http_requests_total" followed by a description.
                XCTAssertTrue(responseString.contains("http_requests_total"))
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
        guard let url = url else {
            return XCTFail("URL is nil")
        }
        guard let method = httpMethod, let headers = allHTTPHeaderFields, let host = url.host, let port = url.port else {
            return XCTFail("Invalid request params")
        }

        var path = url.path
        if let query = url.query {
            path += "?" + query
        }

        let requestOptions: [ClientRequest.Options] = [.method(method), .hostname(host), .port(Int16(bitPattern: UInt16(port))), .path(path), .headers(headers)]

        // Create a ClientRequest. Completion will be called when the server
        // responds.
        let req = HTTP.request(requestOptions) { response in
            guard let response = response else {
                return XCTFail("ClientResponse was nil for \(method) on \(host):\(port)/\(path)")
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
