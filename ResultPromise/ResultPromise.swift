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
  
  public func then(f: T -> Void) -> ResultPromise {
    let nextPromise = ResultPromise()
    subscribe { result in
      nextPromise.execute(result.onSuccess(f))
    }
    return nextPromise
  }
  
  public func map<U>(f: T -> U) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()
    subscribe { result in
      nextPromise.execute(result.map(f))
    }
    return nextPromise
  }
  
  public func flatMap<U>(f: T -> ResultPromise<U>) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()
    subscribe { result in
      switch result {
      case .Success(let value):
        let nestedPromise = f(value)
        nestedPromise.subscribe{ result in
          nextPromise.execute(result)
        }
      case .Error(let error):
        nextPromise.execute(Result.Error(error))
      }
    }
    return nextPromise
  }

  
  public func catchAll(f: ErrorType -> Void) -> ResultPromise {
    let nextPromise = ResultPromise<T>()
    subscribe { result in
      nextPromise.execute(result.onError(f))
    }
    return nextPromise
  }
  
}

private extension ResultPromise {
  
  private func subscribe(closure: Result<T> -> Void) -> ResultPromise<T> {
    self.callback = closure
    return self
  }
  
  private func executeOperation() {
    func complete(result: Result<T>) {
      self.execute(result)
    }

    self.operationBlock?(completed: complete)
    self.operationBlock = nil
  }
  
  
  private func execute(value: Result<T>) {
    self.callback?(value)
    self.callback = nil
  }

}