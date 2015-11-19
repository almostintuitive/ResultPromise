//
//  ResultPromise.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

import Foundation

enum FutureError: ErrorType {
  case Fail
}


enum ResultPromiseStatus { case Pending, Fulfilled }


class ResultPromise<T, U: ErrorType> {
  
  var thenBlock: ((value: T) ->  T)?
  var finallyBlock: ((value: T) ->  Void)?
  var flatMapBlock: ((value: T) ->  ResultPromise<T, U>)?
  var catchBlock: ((error: U) -> Void)?
  
  var nextFuture: ResultPromise<T, U>?
  
  
  init(operation: (completed:(result: Result<T, U>) -> Void) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      operation(completed: self.complete)
    })
  }
  
  func then(then: (value: T) -> T) -> ResultPromise {
    self.nextFuture = ResultPromise(then: then)
    return self.nextFuture!
  }
  
  func flatMap(flatMap: (value: T) -> ResultPromise<T, U>) -> ResultPromise {
    self.nextFuture = ResultPromise(flatMap: flatMap)
    return self.nextFuture!
  }
  
  func finally(finally: (value: T) -> Void) {
    self.nextFuture = ResultPromise(finally: finally)
  }
  
  func catchAll(catchAll: (error: U) -> Void) {
    self.nextFuture = ResultPromise(catchAll: catchAll)
  }
  
  
  private init(finally: (T -> Void)) {
    self.finallyBlock = finally
  }
  
  private init(then: (T -> T)) {
    self.thenBlock = then
  }
  
  private init(flatMap: (T ->  ResultPromise<T, U>)) {
    self.flatMapBlock = flatMap
  }
  
  private init(catchAll: (U -> Void)) {
    self.catchBlock = catchAll
  }
  
}

extension ResultPromise {
  
  
  
  private func complete(result: Result<T, U>) {
    self.nextFuture?.executeNext(result)
  }
  
  private func executeNext(result: Result<T, U>) {
    
    switch result {
    case .Success(let value):
      if let newValue = self.thenBlock?(value: value) {
        self.nextFuture?.executeNext(.Success(newValue))
      }
      
      if let nestedFuture = self.flatMapBlock?(value: value) {
        nestedFuture.nextFuture = self.nextFuture
      }
      
      if let finallyBlock = self.finallyBlock {
        finallyBlock(value: value)
      }
      
    case .Failure(let error):
      
      if let catchBlock = catchBlock {
        catchBlock(error: error)
      } else {
        self.nextFuture?.executeNext(result)
      }
      
    }
    
    
  }
}