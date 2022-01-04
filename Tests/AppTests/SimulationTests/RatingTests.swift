//
//  RatingTests.swift
//  
//
//  Created by Maarten Engels on 28/12/2021.
//

import Foundation

@testable import Simulation
import XCTVapor

final class RatingTests: XCTestCase {
    
    func testSGreaterThanA() {
        XCTAssertGreaterThan(Rating.S, Rating.A)
    }
    
    func testAGreaterThanB() {
        XCTAssertGreaterThan(Rating.A, Rating.B)
    }
    
    func testBGreaterThanC() {
        XCTAssertGreaterThan(Rating.B, Rating.C)
    }
    
    func testCGreaterThanD() {
        XCTAssertGreaterThan(Rating.C, Rating.D)
    }
    
    func testDGreaterThanE() {
        XCTAssertGreaterThan(Rating.D, Rating.E)
    }
    
    func testEGreaterThanF() {
        XCTAssertGreaterThan(Rating.E, Rating.F)
    }
    
    func testFGreaterThanUndefined() {
        XCTAssertGreaterThan(Rating.F, Rating.undefined)
    }
    
    func testUndefinedLessThanF() {
        XCTAssertLessThan(Rating.undefined, Rating.F)
    }
    
    func testFLessThanE() {
        XCTAssertLessThan(Rating.F, Rating.E)
    }
    
    func testELessThanD() {
        XCTAssertLessThan(Rating.E, Rating.D)
    }
    
    func testDLessThanC() {
        XCTAssertLessThan(Rating.D, Rating.C)
    }
    
    func testCLessThanB() {
        XCTAssertLessThan(Rating.C, Rating.B)
    }
    
    func testBLessThanA() {
        XCTAssertLessThan(Rating.B, Rating.A)
    }
    
    func testALessThanS() {
        XCTAssertLessThan(Rating.A, Rating.S)
    }
    
}
