//
//  ResultPromise+Create.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 31/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Dispatch

// Returns a ResultPromise that'll be fullfilled as soon as the completed function is called
public func createPromise<T, Error: ErrorType>(operation: (completed: Result<T, Error> -> Void) -> Void) -> ResultPromise<T, Error> {
  
  // Create a new promise
  let promise = ResultPromise<T, Error>()
  
  // Create a function we'll pass the the creation block.
  // This will execute the promise as soon as the passed 'completed' function is called inside the creation block.
  func complete(result: Result<T, Error>) {
    promise.execute(result)
  }
  operation(completed: complete)
  return promise
  
}


public extension ResultPromise {
  
  // Fullfill a ResultPromise immediately with a Result
  // This will be passed on immediately to the next promise in the chain.
  public func resolve(value: Result<T, Error>) {
    self.execute(value)
  }
  
  // Initialize and fullfill ResultPromise with a result.
  // This will be passed on immediately to the next promise in the chain.
  public convenience init(value: Result<T, Error>) {
    self.init()
    dispatch_async(dispatch_get_main_queue()) {
      self.resolve(value)
    }
  }

}