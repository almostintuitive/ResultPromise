//
//  Delay.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 27/04/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

public extension ResultPromise {
  
  public func delay(timeInterval: Double, on: Thread) -> ResultPromise {
    
    precondition(on != .Same, "Can't use Thread.Same with delay, please specify a thread!")
    
    // Create a new Promise
    let nextPromise = ResultPromise()
    //
    addCallback { result in
      switch result {
      case .Success:
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC))), on.queue!) {
          nextPromise.execute(result)
        }
      case .Failure:
        nextPromise.execute(result)
      }
    }
    return nextPromise
  }
  
}