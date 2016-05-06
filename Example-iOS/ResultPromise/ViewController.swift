//
//  ViewController.swift
//  ResultPromise
//
//  Created by Mark Aron Szulyovszky on 19/11/2015.
//  Copyright © 2015 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

enum FutureError: ErrorType {
  case Fail, NoError
}


class ViewController: UIViewController {
  


  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create a Promise by initializaing a ResultPromise and resolve it later
    let promise = ResultPromise<String, FutureError>()
    
    promise.then {
      // When the promise is fullfilled/resolved, it'll print out the success value.
      // Then ignore the Failure case.
      print($0)
    }
    // This will print out "make" to the console, since resolve just executes whatever is in the then/flatmap, etc. blocks.
    promise.resolve(Result.Success("make"))
    
    
    // Create a Promise in-line! All you need is to call the completed() function that was provided.
    createPromise { completed in
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        completed(Result.Success(false))
      })
      
    }.map { value -> Bool in

      // Map transforms the Success value into another Success value.
      // In this case, we had a false and we transform it into a true.
      // You can also have a different return value, like a String.
      
      // It ignores the Failure case.
      print("1: \(value)")
      return true
      
    }.then {
      
      // Then just gets the Success value and does whatever you want with it.
      // It ignores the Failure case.
      print("2: \($0)")
      
    }.flatMap { value -> ResultPromise<String, FutureError> in
      
      // FlatMap transforms the Success value into another Promise.
      // This is how you chain Promises, which is kind of currently the only way to avoid nested callbacks.
      return self.stringTask(value)
      
    }.then { value in
      
      print("3: \(value)")

    }.on(.Main).then {
      
      // use on(ThreadType) to switch to a different thread, if you want to.
      print("4: \($0)")
      
    }.promisify { (value, completion) -> Void in
      
      // Promisify is for turning methods working with completion block easily into Promises.
      // Here I'm calling longTaskWithCompletionBlock and passing the provided completion block to it.
      // Nothing else here you need to take care of!
      self.longTaskWithCompletionBlock(code: value, completion: completion)
      
    }.promisify { (value, completion)  in
      
      // You can also simplify the function definition ^^
      self.longTaskWithCompletionBlock(code: value, completion: completion)
    
    }.then {
      
      
      print("5: \($0)")
    }

    
    // Create a promise and resolve it with an error!
    let _: ResultPromise<String, FutureError> = createPromise { completed in
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        completed(Result.Failure(FutureError.Fail))
      })
      
    }.map { (value: Bool) -> String in
      
      // This will never gets executed. When we fail a Promise, its execution path will skip all flatMap, map, then, etc.
      // functions, and jump ahead to...
      print(value)

      return "hahhaha"
    }.catchError { error in
      
      // Instead, execution will jump to the next "catchError" function. So this will get executed instead of "map".
      print("error detected")
    }
    
  }


  
  func stringTask(value: Bool) -> ResultPromise<String, FutureError> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(.Success("string!"))
      })
    }
  }
  
  
  func errorTask(value: Bool) -> ResultPromise<String, FutureError> {
    return createPromise { (completed) -> Void in
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        completed(.Failure(FutureError.Fail))
      })
    }
  }
  
  func longTaskWithCompletionBlock(code code: String, completion: (result: Result<Bool, FutureError>) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      completion(result: .Success(true))
    })
  }
  
  func longTaskWithCompletionBlock(code code: Bool, completion: (result: Result<Bool, FutureError>) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      completion(result: .Success(true))
    })
  }
  


}

