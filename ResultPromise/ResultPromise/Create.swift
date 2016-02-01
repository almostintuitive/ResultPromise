//
//  ResultPromise+Create.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 31/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

public func createPromise<T, Error: ErrorType>(operation: (completed: Result<T, Error> -> Void) -> Void) -> ResultPromise<T, Error> {
  
  let promise = ResultPromise<T, Error>()
  func complete(result: Result<T, Error>) {
    promise.execute(result)
  }
  operation(completed: complete)
  return promise
  
}


public extension ResultPromise {
  
  public func resolve(value: Result<T, Error>) {
    self.execute(value)
  }
  
  public convenience init(value: Result<T, Error>) {
    self.init()
    resolve(value)
  }
  
  public class func immediateResolve(value: Result<T, Error>) -> ResultPromise<T, Error> {
    let promise = ResultPromise()
    promise.resolve(value)
    return promise
  }
}