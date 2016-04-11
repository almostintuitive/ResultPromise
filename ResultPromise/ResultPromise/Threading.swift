//
//  ResultPromise+Threading.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 17/12/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation

private func executeOnThread(thread: Thread, f: () -> Void) {
  guard let queue = thread.queue else {
    f()
    return
  }
  guard !(NSThread.currentThread() == NSThread.mainThread() && thread == .Main) else {
    f()
    return
  }
  dispatch_async(queue, f)
}


public enum Thread {
  case Main
  case Background
  case Same
  
  var queue: dispatch_queue_t? {
    switch self {
    case .Main:
      return dispatch_get_main_queue()
    case .Background:
      return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    default:
      return nil
    }
  }
}

public extension ResultPromise {
  
  public func on(thread: Thread) -> ResultPromise {
    let newPromise = ResultPromise()
    subscribe { result in
      executeOnThread(thread, f: {
        newPromise.execute(result)
      })
    }
    return newPromise
  }
  
  public func thenOn(thread: Thread, f: T -> Void) -> ResultPromise {
    return on(thread).then(f)
  }
  
  public func mapOn<U>(thread: Thread, f: T -> U) -> ResultPromise<U, Error> {
    return on(thread).map(f)
  }

  public func flatMapOn<U>(thread: Thread, f: T -> ResultPromise<U, Error>) -> ResultPromise<U, Error> {
    return on(thread).flatMap(f)
  }
  

  
}