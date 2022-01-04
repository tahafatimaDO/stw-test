//
//  EarthTests.swift
//
//
//  Created by Maarten Engels on 28/11/2021.
//

@testable import Simulation
import XCTVapor

final class EarthTests: XCTestCase {
    
    func testUpdateIncreasesYear() {
        var earth = Earth()
        let baseYear = earth.currentYear
        
        earth.tick(yearlyEmission: 0)
        
        XCTAssertGreaterThan(earth.currentYear, baseYear)
    }
    
    func testEmissionsIncreaseTemperature() {
        var earth = Earth()
        let baseTemperature = earth.currentTemperature
        
        earth.tick(yearlyEmission: 10)
        
        XCTAssertGreaterThan(earth.currentTemperature, baseTemperature)
    }
    
    func testNoEmissionsDecreaseTemperature() {
        var earth = Earth()
        let baseTemperature = earth.currentTemperature
        
        earth.tick(yearlyEmission: 0)
        
        XCTAssertLessThan(earth.currentTemperature, baseTemperature)
    }
    
    func testForecastAndUpdateGiveSameResult() {
        var earth = Earth()
        
        let forecastToYear = 2050
        let yearlyEmissions = 10.0
        let forecastedTemp = earth.forecastTemperature(to: forecastToYear, yearlyEmissions: yearlyEmissions)
        
        for _ in earth.currentYear ..< forecastToYear {
            earth.tick(yearlyEmission: yearlyEmissions)
        }
        print(Earth.BASE_TEMPERATURE_2015, earth.currentTemperature)
        XCTAssertEqual(forecastToYear, earth.currentYear)
        XCTAssertEqual(forecastedTemp, earth.currentTemperature)
    }
}
