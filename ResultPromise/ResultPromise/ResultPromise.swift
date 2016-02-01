//
//  ResultPromise.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

public class ResultPromise<T, Error: ErrorType> {
  
  internal var callback: (Result<T, Error> -> Void)?
  
  /// Executes function if the result is a Success. Returns a new ResultPromise with the same Result it was given.
  public func then(f: T -> Void) -> ResultPromise {
    guard callback == nil else { fatalError("promise already has a subscriber") }

    // create the next promise we'll return
    let nextPromise = ResultPromise()
    // when this current promise is executed with a result
    subscribe { result in
      // if result is a Success, execute function with the Value
      result.onSuccess { f($0) }
      // execute the next promise
      nextPromise.execute(result)
    }
    // return the next promise in the chain
    return nextPromise
  }
  
  /// Returns a new ResultPromise by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
  public func map<U>(f: T -> U) -> ResultPromise<U, Error> {
    guard callback == nil else { fatalError("promise already has a subscriber") }
    
    // create the next promise we'll return
    let nextPromise = ResultPromise<U, Error>()
    // when this current promise is executed with a result
    subscribe { result in
      // transforms current result with provided function
      let nextResult = result.map(f)
      // execute the next promise with the new, transformed result
      nextPromise.execute(nextResult)
    }
    // return the next promise in the chain
    return nextPromise
  }
  
  /// Returns a new ResultPromise that's returned from the function if the result is Success, re-wrapps `Failure`s’ errors.
  public func flatMap<U>(f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {
    guard callback == nil else { fatalError("promise already has a subscriber") }

    // create the next promise we'll return
    let nextPromise = ResultPromise<U, Error>()
    // when this current promise is executed with a result
    subscribe { result in
      
      switch result {
      // if it's a success, then 
      case .Success(let value):
        //
        let nestedPromise = f(value)
        nestedPromise.subscribe { result in
          nextPromise.execute(result)
        }
      // if it's a failure, re-wrap the error in a new Result.
      // this is needed, otherwise you'll get a compiler error complaining about type mis-match.
      case .Failure(let error):
        nextPromise.execute(Result.Failure(error))
      }
    }
    
    return nextPromise
  }

  
  public func catchError(f: ErrorType -> Void) -> ResultPromise {
    guard callback == nil else { fatalError("promise already has a subscriber") }

    let nextPromise = ResultPromise<T, Error>()
    subscribe { result in
      nextPromise.execute(result.mapError {
        f($0)
        return $0
      })
    }
    return nextPromise
  }

  
}

internal extension ResultPromise {
  
  internal func subscribe(callback: Result<T, Error> -> Void) {
    self.callback = callback
  }
  
  internal func execute(value: Result<T, Error>) {
    self.callback?(value)
    self.callback = nil
  }

}


