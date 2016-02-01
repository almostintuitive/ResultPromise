//
//  ResultPromiseTests.swift
//  ResultPromiseTests
//
//  Created by Mark Aron Szulyovszky on 10/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import XCTest
@testable import ResultPromise

enum TestError: ErrorType {
  case Test
}


class ResultPromiseTests: XCTestCase {
  
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
  
  // MARK: - Creation
  
  func testCreationWithCreatePromise() {
    let promise: ResultPromise<Int, TestError> = createPromise { (completed) in
      delay(0.1) {
        completed(.Success(1))
      }
    }
    
    promise.then { number in
      XCTAssert(number == 1)
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  func testCreationWithCreateResolve() {
    promise.then { number in
      XCTAssert(number == 1)
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  
  // MARK: - Map - single
  
  func testMapSuccess() {
    promise.map { number in
      XCTAssert(number == 1)
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Success(1))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
  }
  
  
  func testMapFailure() {
    promise.map { number in
      XCTAssert(false)
      self.readyExpectation.fulfill()
    }
    delay(0.08) {
      self.readyExpectation.fulfill()
    }
    promise.resolve(.Failure(TestError.Test))
    waitForExpectationsWithTimeout(0.1) { error in XCTAssertNil(error, "Timeout error") }
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

func delay(delay:Double, _ closure:()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(), closure)
}
