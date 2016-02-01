//
//  ThenTests.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 01/02/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import XCTest
@testable import ResultPromise

class ThenTests: XCTestCase {
  
  var readyExpectation: XCTestExpectation!
  var promise: ResultPromise<Int, TestError>!
  
  override func setUp() {
    super.setUp()
    readyExpectation = expectationWithDescription("ready")
    promise = ResultPromise<Int, TestError>()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: - Then - single
  
  func testThenSuccess() {
    promise.then { number in
      XCTAssert(number == 1)
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  func testThenFailure() {
    promise.then { number in
      XCTAssert(false)
    }
    delay(0.08) {
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Failure(TestError.Test))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }

}
