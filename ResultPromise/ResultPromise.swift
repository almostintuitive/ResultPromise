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
  promise.executeOperation(operation)
  return promise
}


public class ResultPromise<T> {
  
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
  
  
  public func wrap<U>(f: (value: T, wrap: (Result<U> -> Void)) -> Void) -> ResultPromise<U> {
    let nextPromise = ResultPromise<U>()
    subscribe { result in
      switch result {
      case .Success(let value):
        f(value: value, wrap: { nextResult  in
          nextPromise.execute(nextResult)
        })
      case .Error(let error):
        nextPromise.execute(.Error(error))
      }
    }
    return nextPromise
  }
  
}

private extension ResultPromise {
  
  private func subscribe(callback: Result<T> -> Void) -> ResultPromise<T> {
    self.callback = callback
    return self
  }
  
  private func executeOperation(operation: ((completed:(result: Result<T>) -> Void) -> Void)) {
    func complete(result: Result<T>) {
      self.execute(result)
    }
    operation(completed: complete)
  }
  
  
  private func execute(value: Result<T>) {
    self.callback?(value)
    self.callback = nil
  }

}