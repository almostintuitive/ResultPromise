//
//  ResultPromise+Wrap.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 09/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

public extension ResultPromise {
  
  public func promisify<U>(f: (value: T, completion: (Result<U, Error> -> Void)) -> Void) -> ResultPromise<U, Error> {
    let nextPromise = ResultPromise<U, Error>()
    subscribe(.Same) { result in
      switch result {
      case .Success(let value):
        f(value: value, completion: { nextResult  in
          nextPromise.execute(nextResult)
        })
      case .Failure(let error):
        nextPromise.execute(Result.Failure(error))
      }
    }
    return nextPromise
  }

  
}