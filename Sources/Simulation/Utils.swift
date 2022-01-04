//
//  Utils.swift
//  
//
//  Created by Maarten Engels on 19/12/2021.
//

import Foundation

/// Calculates the `n`th Fibonacci number
///
/// This function returns `0` for all negative numbers.
func fib(_ n: Int) -> Int {
    guard n > 0 else {
        return 0
    }
    
    if n == 1 {
        return 1
    } else {
        return fib(n - 1) + fib(n - 2)
    }
}

/// Calculates `n-factorial` (`n!`)
///
/// This function returns `0` for all negative numbers.
func faculty(_ n: Int) -> Int {
    guard n > 0 else {
        return 1
    }
    
    return n * faculty(n - 1)
}
