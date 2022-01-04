//
//  UtilsTests.swift
//  
//
//  Created by Maarten Engels on 19/12/2021.
//

@testable import Simulation
import XCTVapor

final class UtilsTests: XCTestCase {
    
    func testFibbonaci() {
        XCTAssertEqual(fib(-1), 0)
        XCTAssertEqual(fib(0), 0)
        XCTAssertEqual(fib(1), 1)
        XCTAssertEqual(fib(2), 1)
        XCTAssertEqual(fib(3), 2)
        XCTAssertEqual(fib(4), 3)
        XCTAssertEqual(fib(5), 5)
        XCTAssertEqual(fib(6), 8)
        XCTAssertEqual(fib(7), 13)
        
    }
    
    func testFaculty() {
        XCTAssertEqual(faculty(-1), 1)
        XCTAssertEqual(faculty(0), 1)
        XCTAssertEqual(faculty(1), 1)
        XCTAssertEqual(faculty(2), 2)
        XCTAssertEqual(faculty(3), 6)
        XCTAssertEqual(faculty(4), 24)
        XCTAssertEqual(faculty(5), 120)
        XCTAssertEqual(faculty(6), 720)
        XCTAssertEqual(faculty(7), 5040)
    }
}
