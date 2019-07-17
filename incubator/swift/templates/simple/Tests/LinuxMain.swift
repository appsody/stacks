import XCTest

import simpleTests

var tests = [XCTestCaseEntry]()
tests += simpleTests.allTests()
XCTMain(tests)
