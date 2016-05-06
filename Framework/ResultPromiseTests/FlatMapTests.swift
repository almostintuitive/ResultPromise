//
//  FlatMapTests.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 01/02/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import XCTest
@testable import ResultPromise

class FlatMapTests: XCTestCase {

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
  
  // MARK: - FlatMap - single
  
  func testFlatMapSuccess() {
    promise.flatMap { number -> ResultPromise<String, TestError> in
      XCTAssert(number == 1)
      self.readyExpectation.fulfill()
      return ResultPromise(value: .Success("String"))
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  func testFlatMapFailure() {
    promise.flatMap { number -> ResultPromise<String, TestError> in
      XCTAssert(false)
      return ResultPromise(value: .Success("String"))
    }
    delay(0.08) {
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Failure(TestError.Test))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
}
