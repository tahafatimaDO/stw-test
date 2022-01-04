//
//  CountryTests.swift
//
//
//  Created by Maarten Engels on 28/11/2021.
//

@testable import Simulation
import XCTVapor

final class CountryTests: XCTestCase {
    
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
    
    func testCountry() {
        XCTAssertGreaterThan(netherlands.yearlyEmissions, 0)
    }
    
//    func testCountryInvestsInEmissionReduction() {
//        var country = netherlands
//
//        country.emissionReductionSpent = country.baseGDP * 0.01
//
//        XCTAssertGreaterThan(country.emissionReduction, 0)
//        XCTAssertLessThan(country.yearlyEmissions, country.yearlyEmissions)
//    }
    
    func testGlobalWarmingLowersGDP() {
        let originalGDP = netherlands.GDP
        var warmedNetherlands = netherlands
        warmedNetherlands.tick(in: warmedEarth)
        XCTAssertLessThan(warmedNetherlands.GDP, originalGDP)
    }
    
    func testTickIncreasesCountryPoints() {
        var country = netherlands
        
        country.tick(in: earth)
        
        XCTAssertGreaterThan(country.countryPoints, netherlands.countryPoints)
    }
    
    func testEnactPolicy() {
        var country = netherlands
        country.countryPoints = Int.max
        
        guard let policy = country.enactablePolicies.randomElement() else {
            XCTFail("No policy found.")
            return
        }
        
        XCTAssertFalse(country.activePolicies.contains(policy))
        
        let result = country.enactPolicy(policy)
        XCTAssertTrue(result.updatedCountry.activePolicies.contains(policy))
    }
    
    func testRevokePolicy() {
        var country = netherlands
        country.countryPoints = Int.max
        
        guard let policy = country.enactablePolicies.randomElement() else {
            XCTFail("No policy found.")
            return
        }
        
        XCTAssertFalse(country.activePolicies.contains(policy))
        
        let result = country.enactPolicy(policy)
        XCTAssertTrue(result.updatedCountry.activePolicies.contains(policy))
        
        let result2 = result.updatedCountry.revokePolicy(policy)
        XCTAssertFalse(result2.updatedCountry.activePolicies.contains(policy))
    }

    func testPolicyAffectsCountry() {
        var country = netherlands
        
        let policy = Policy(name: "testpolicy", effects: [.freePoints(points: 1)], baseCost: 0)
        
        var policyCountry = country.enactPolicy(policy).updatedCountry
        XCTAssertTrue(policyCountry.activePolicies.contains(policy))
        
        country.tick(in: earth)
        policyCountry.tick(in: earth)
        
        XCTAssertGreaterThan(policyCountry.countryPoints, country.countryPoints)
    }
}
