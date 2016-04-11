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


class CreationTests: XCTestCase {
  
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
  
  func testCreationWithCreateValue() {
    
    let promise = ResultPromise<Int,TestError>(value: Result.Success(100))
    
    promise.then { number in
      XCTAssert(number == 100)
      self.readyExpectation.fulfill()
    }
    
    
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
