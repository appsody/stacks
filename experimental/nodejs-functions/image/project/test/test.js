const expect = require('chai').expect;
const request = require('request');

// Start the server before testing
const server = require('../server').server;
const PORT = require('../server').PORT;
const url = "http://localhost:" + PORT;

describe("Node.js Express stack", function () {

    // Testing /metrics enpoint, metrics are up
    describe('/metrics endpoint', function () {
        it('status', function (done) {
            request(url + '/metrics', function (error, response, body) {
                expect(response.statusCode).to.equal(200);
                done();
            });
        });
        // Systems CPU that is currently used exists
        it("contains os_cpu_used_ratio", function (done) {
            request(url + '/metrics', function (error, response, body) {
                expect(body).to.contains("os_cpu_used_ratio");
                done();
            });
        });
        // Process CPU that is currently used exists
        it("contains process_cpu_used_ratio", function (done) {
            request(url + '/metrics', function (error, response, body) {
                expect(body).to.contains("process_cpu_used_ratio");
                done();
            });
        });
    });

    // Testing /ready endpoint, should not return a 404
    describe('/ready endpoint', function () {
        it('status', function (done) {
            request(url + '/ready', function (error, response, body) {
                expect(response.statusCode).to.not.equal(404);
                done();
            });
        });
    });

    // Testing /live endpoint, sdhould not return a 404
    describe('/live endpoint', function () {
        it('status', function (done) {
            request(url + '/live', function (error, response, body) {
                expect(response.statusCode).to.not.equal(404);
                done();
            });
        });
    });

    // Testing /health endpoint, should not return a 404
    describe('/health endpoint', function () {
        it('status', function (done) {
            request(url + '/health', function (error, response, body) {
                expect(response.statusCode).to.not.equal(404);
                done();
            });
        });
    });

    // Testing a random endpoint, should return 404
    describe('/blah endpoint', function () {
        it('status', function (done) {
            request(url + '/blah', function (error, response, body) {
                expect(response.statusCode).to.equal(404);
                done();
            });
        });
    });
});

// Stop the server after testing
after(done => {
    server.close(done);
});