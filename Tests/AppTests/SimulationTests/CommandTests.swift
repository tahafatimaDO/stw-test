//
//  CommandTests.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

import XCTest
@testable import Simulation

class CommandTests: XCTestCase {

    var netherlands: Country {
        Country(name: "The Netherlands", countryCode: "NL", baseYearlyEmissions: 0.46, baseGDP: 90705, population: 16981295, budgetSurplus: -3.949727, giniRating: 28, educationDevelopmentIndex: 0.991817)
    }
    
    var earth: Earth {
        Earth()
    }
    
    var warmedEarth: Earth {
        var earth = Earth()
        
        for _ in earth.currentYear ..< 2050 {
            earth.tick(yearlyEmission: 10)
        }
        
        return earth
    }
    
    func testGetListOfAvailableCommands() {
        XCTAssertGreaterThan(netherlands.availableCommands.count, 0)
    }
    
    func testExampleCommand() throws {
        let command = CountryCommand(name: "Example command", description: "it does nothing!", effects: [], cost: 0)
        let result = netherlands.executeCommand(command, in: earth)
        XCTAssertEqual(result.resultMessage, "Example command succesfully applied.")
    }
        
//    func testSubsidiseFossilFuels() throws {
//        let command = try CountryCommand.getCommand("Subsidise fossil fuels")
//        let result = netherlands.executeCommand(command, in: earth)
//        XCTAssertGreaterThan(result.updatedCountry.baseGDP, netherlands.baseGDP)
//        XCTAssertGreaterThan(result.updatedCountry.yearlyEmissions, netherlands.yearlyEmissions)
//    }
    
//    func testReverseCommand() throws {
//        let command = try CountryCommand.getCommand("Subsidise fossil fuels")
//        let applyResult = netherlands.executeCommand(command, in: earth)
//
//        let reverseResult = applyResult.updatedCountry.reverseCommand(command, in: earth)
//
//        XCTAssertEqual(reverseResult.updatedCountry.baseGDP, netherlands.baseGDP)
//        XCTAssertEqual(reverseResult.updatedCountry.yearlyEmissions, netherlands.yearlyEmissions)
//    }
    
//    func testSerializeCommand() throws {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        let data = try encoder.encode(CountryCommand.example)
//        let string = String(data: data, encoding: .utf8)!
//        print(string)
//    }
}
