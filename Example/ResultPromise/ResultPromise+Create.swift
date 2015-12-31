//
//  ResultPromise+Create.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 31/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

public func createPromise<T, Error: ErrorType>(operation: (completed:(result: Result<T, Error>) -> Void) -> Void) -> ResultPromise<T, Error> {
  
  let promise = ResultPromise<T, Error>()
  func complete(result: Result<T, Error>) {
    promise.execute(result)
  }
  operation(completed: complete)
  return promise
  
}


public extension ResultPromise {
  
  func resolve(value: Result<T, Error>) {
    self.execute(value)
  }
  
}