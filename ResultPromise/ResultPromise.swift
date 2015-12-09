//
//  ResultPromise.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

func createPromise<T>(operation: (completed:(result: Result<T>) -> Void) -> Void) -> ResultPromise<T> {
  let promise = ResultPromise<T>()
  promise.operationBlock = operation
  promise.executeOperation()
  return promise
}


public class ResultPromise<T> {
  
  private var operationBlock: ((completed:(result: Result<T>) -> Void) -> Void)?
  private var callback: (Result<T> -> Void)?
  
  public func then(thenClosure: T -> Void) -> ResultPromise {
    let nextPromise = ResultPromise()
    subscribe { result in
      thenClosure(result.value!)
      nextPromise.execute(result)
    }
    return nextPromise
  }
  
  public func map<U>(mapClosure: T -> U) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()
    subscribe { result in
      nextPromise.execute(result.map(mapClosure))
    }
    return nextPromise
  }
  
  public func flatMap<U>(flatMapClosure: T -> ResultPromise<U>) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()
    subscribe { result in
      let nestedPromise = flatMapClosure(result.value!)
      nextPromise.subscribe{ result in
        nestedPromise.execute(result)
      }
    }
    return nextPromise
  }

  
//  func catchAll(catchAll: (error: ErrorType) -> Void) -> ResultPromise {
//    let nextPromise = ResultPromise<T>()
//    
//    nextPromise.catchBlock = catchAll
//    return nextPromise
//  }
//  
}

private extension ResultPromise {
  
  private func subscribe(closure: Result<T> -> Void) -> ResultPromise<T> {
    self.callback = closure
    return self
  }
  
  private func executeOperation() {
    func complete(result: Result<T>) {
      self.callback?(result)
    }

    self.operationBlock?(completed: complete)
  }
  
  
  private func execute(value: Result<T>) {
    self.callback?(value)
  }
  
//  func executeNext(result: Result<T>) {
//    
//    switch result {
//    case .Success(let value):
//      if let newValue = self.thenBlock?(value: value) {
//        self.nextFuture?.executeNext(.Success(newValue))
//      }
//      
//      if let nestedFuture = self.flatMapBlock?(value: value) {
//        nestedFuture.nextFuture = self.nextFuture
//      }
//      
//      if let finallyBlock = self.finallyBlock {
//        finallyBlock(value: value)
//      }
//      
//    case .Error(let error):
//      
//      if let catchBlock = catchBlock {
//        catchBlock(error: error)
//      } else {
//        self.nextFuture?.executeNext(result)
//      }
//      
//    }
//  }
}