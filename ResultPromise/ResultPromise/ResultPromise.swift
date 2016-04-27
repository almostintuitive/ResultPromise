//
//  ResultPromise.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

public class ResultPromise<T, Error: ErrorType> {
  
  internal var callbacks : [(Result<T, Error> -> Void)] = []
  
  /// Executes function if the result is a Success.
  public func then(f: T -> Void) -> ResultPromise {

    // create the next promise we'll return
    let nextPromise = ResultPromise()
    // when this current promise is executed with a result
    addCallback { result in
      // if result is a Success, execute function with the Value
      result.onSuccess { f($0) }
      // execute the next promise
      nextPromise.execute(result)
    }
    // return the next promise in the chain
    return nextPromise
  }
  
  /// Use it to transform the .Success value into a new .Success value. (potentially of a different type)
  /// Returns a new ResultPromise by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
  public func map<U>(f: T -> U) -> ResultPromise<U, Error> {
    
    // create the next promise we'll return
    let nextPromise = ResultPromise<U, Error>()
    // when this current promise is executed with a result
    addCallback { result in
      // transforms current result with provided function
      let nextResult = result.map(f)
      // execute the next promise with the new, transformed result
      nextPromise.execute(nextResult)
    }
    // return the next promise in the chain
    return nextPromise
  }
  

  public func mapError<Error2: ErrorType>(f: Error -> Error2) -> ResultPromise<T, Error2> {
    
    // create the next promise we'll return
    let nextPromise = ResultPromise<T, Error2>()
    // when this current promise is executed with a result
    addCallback { result in
      switch result {
      case .Failure(let error):
        nextPromise.execute(.Failure(f(error)))
      case .Success(let value):
        nextPromise.execute(.Success(value))
      }
    }
    // return the next promise in the chain
    return nextPromise
  }
  
  /// Use it to transform the .Success value into a new ResultPromise.
  /// Returns a new ResultPromise that's returned from the function if the result is Success, re-wrapps `Failure`s’ errors.
  public func flatMap<U>(f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {

    // create the next promise we'll return
    let nextPromise = ResultPromise<U, Error>()
    // when this current promise is executed with a result
    addCallback { result in
      
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

  /// Use it to subscribe to .Failure events
  public func catchError(f: ErrorType -> Void) -> ResultPromise {

    let nextPromise = ResultPromise<T, Error>()
    addCallback { result in
      nextPromise.execute(result.mapError {
        f($0)
        return $0
      })
    }
    return nextPromise
  }

  
  /// Executes function in any case. Chainable.
  public func subscribe(f: Result<T, Error> -> Void) -> ResultPromise {
    
    // create the next promise we'll return
    let nextPromise = ResultPromise()
    // when this current promise is executed with a result
    addCallback { result in
      f(result)
      // execute the next promise
      nextPromise.execute(result)
    }
    // return the next promise in the chain
    return nextPromise
  }
  
}

internal extension ResultPromise {
  
  internal func addCallback(callback: Result<T, Error> -> Void) {
    callbacks.append(callback)
  }
  
  internal func execute(value: Result<T, Error>) {
    callbacks.forEach { $0(value) }
    callbacks.removeAll()
  }

}


