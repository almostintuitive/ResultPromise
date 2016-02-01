//
//  CatchErrorTests.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 01/02/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import XCTest
@testable import ResultPromise

class CatchErrorTests: XCTestCase {
  
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

  // MARK: - CatchError - single
  
  func testCatchErrorSuccess() {
    promise.catchError { error in
      XCTAssert(error as! TestError == TestError.Test)
      self.readyExpectation.fulfill()
    }
    delay(0.08) {
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  func testCatchErrorFailure() {
    promise.catchError { error in
      XCTAssert(error as! TestError == TestError.Test)
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Failure(TestError.Test))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
}
