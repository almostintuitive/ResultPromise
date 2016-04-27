//
//  Merge.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 26/04/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

extension ResultPromise {
  
  /// Use it to combine the previous Success value from another promise
  /// Returns:
  ///  if both were successful: a tuple with the success values of both the previous and the combined promise
  ///  if any of them failed:   it returns a Failure, with any of the Error objects
  public func zip<U>(f: () -> ResultPromise<U, Error>) -> ResultPromise<(T, U), Error> {
    
    // create the next promise we'll return
    let nextPromise = ResultPromise<(T, U), Error>()
    // when this current promise is executed with a result
    addCallback { result in
      
      switch result {
      // if it's a success, then
      case .Success(let value):
        //
        let nestedPromise = f()
        nestedPromise.subscribe { newResult in
          nextPromise.execute(newResult.map { (value, $0) })
        }
      // if it's a failure, re-wrap the error in a new Result.
      // this is needed, otherwise you'll get a compiler error complaining about type mis-match.
      case .Failure(let error):
        nextPromise.execute(Result.Failure(error))
      }
    }
    
    return nextPromise
  }
  
  public func zip<U>(promise: ResultPromise<U, Error>) -> ResultPromise<(T, U), Error> {
    return self.zip { promise }
  }
  
}