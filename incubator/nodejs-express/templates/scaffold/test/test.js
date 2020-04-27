var expect = require('chai').expect;
var request = require('request');

// Start the server before testing
const server = require('../../server').server;
const PORT = require('../../server').PORT;
const url = 'http://localhost:' + PORT;

// Testing / endpoint, should return 200
describe('Node.js Express Scaffold template', function () {
    describe('/ endpoint', function () {
        it('status', function (done) {
            request(url + '/', function (error, response, body) {
                expect(response.statusCode).to.equal(200);
                done();
            });
        });
    });
});

// Stop the server after testing
after(done => {
    server.close(done);
});
