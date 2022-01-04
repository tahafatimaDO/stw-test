//
//  PolicyTests.swift
//  
//
//  Created by Maarten Engels on 29/12/2021.
//

import Foundation

@testable import Simulation
import XCTVapor

final class PolicyTests: XCTestCase {
    var earth: Earth {
        return Earth()
    }
    
    func testPolicyEffect() {
        let policy = Policy(name: "test", effects: [.extraGini(points: 0.5)], baseCost: 0)
        
        let country = Country(name: "testCountry", countryCode: "XYZ", baseYearlyEmissions: 0, baseGDP: 0, population: 0, budgetSurplus: 0, giniRating: 0, educationDevelopmentIndex: 0)
        let updateCountry = policy.applyEffects(to: country, in: earth)
        
        XCTAssertGreaterThan(updateCountry.giniRating, country.giniRating)
    }
    
    func testPolicyCondition() {
        let policy = Policy(name: "test", effects: [.extraGini(points: 0.5)], baseCost: 0, condition: .greaterThanOrEqualBudget(ranking: .S))
        
        let country = Country(name: "testCountry", countryCode: "XYZ", baseYearlyEmissions: 0, baseGDP: 0, population: 0, budgetSurplus: -10, giniRating: 0, educationDevelopmentIndex: 0)
        
        XCTAssertFalse(policy.condition.evaluate(for: country))
    }
}
