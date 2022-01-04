//
//  Earth.swift
//  
//
//  Created by Maarten Engels on 23/11/2021.
//

import Foundation

/// This structure models the effects of carbon emissions and global warming on temperature and costs/damages.
///
/// The model takes into account:
/// - yearly emissions (or "scrubbing" as negative emissions)
/// - (change in) concentration of carbon in atmosphere
/// - effect on average global temperature
/// - economic damages of temperature increase (as percentage of GDP)
///
/// The model does not yet take into account:
/// - geographic differences in temperature rise/fall (i.e. some regions warm faster than others)
/// - geographic differences in damage (i.e. not all countries will suffer the same impact from temperature rise)
/// - sea level rise and impact on countries
///
/// The model will probably never take into account:
/// - differences in emissions (i.e. methane vs CO2)
///
public struct Earth {
    
    // MARK: Climate change model
    /// Model based on the Very Simple Climate Model https://scied.ucar.edu/interactive/simple-climate-model
    
    /// the start year of the simulation. Other initial values are based on this year.
    static let BASE_YEAR = 2015
    
    /// the concentration of carbon in the atmosphere in the base year (in ppm).
    static let BASE_CONCENTRATION_2015 = 399.4
    
    /// the average global temperature in the base year (in degrees C)
    static let BASE_TEMPERATURE_2015 = 14.65
    
    /// the average global emissions in the base year (in gigaton carbon)
    public static let BASE_GLOBAL_EMISSIONS_2015 = 10.34
    
    public init() {
        
    }
    
    /// how much do the extra giga tonnes of Carbon emissions alter the concentration of carbon in the atmosphere?
    private func concentrationIncreateForYearlyEmission(gigaTonnesCO2: Double) -> Double {
        let reductionOver5yrs = 1.1612 * gigaTonnesCO2 - 1.99999
        return reductionOver5yrs / 5.0
    }
    
    /// how much does temperature change based on a change in carbon concentration in the atmosphere? Where a doubling of concentration increases the temperature by 3 degrees C.
    private func temperatureIncreaseForConcentration(newConcentration: Double, oldConcentration: Double) -> Double {
        let ratio = newConcentration / oldConcentration
//        let log = log2(Float(ratio))
        let log = log2(ratio)
        return log * 3.0
    }
    
    /// Forecasts the expected temperature in the year, based on constant yearly emissions.
    /// - Parameters:
    ///   - year: the year to forecast to.
    ///   - yearlyEmissions: the constant yearly emissions to forecast with (in Gigatonnes Carbon)
    /// - Returns: expected temperature in the `year` in degrees C.
    public func forecastTemperature(to year: Int, yearlyEmissions: Double) -> Double {
        assert(year >= currentYear)
        
        var simulatedPlanet = self
        
        for _ in currentYear ..< year {
            simulatedPlanet.tick(yearlyEmission: yearlyEmissions)
        }
        
        return simulatedPlanet.currentTemperature
    }
    
    /// Forecasts the expected temperature in the year, based on constant yearly emissions. Returns all values during the forecast.
    /// - Parameters:
    ///   - year: the year to forecast to.
    ///   - yearlyEmissions: the constant yearly emissions to forecast with (in Gigatonnes Carbon)
    /// - Returns: an array of all simulated `Earth`s
    ///
    /// Useful for creating a time series.
    public func forecastSeries(to year: Int, yearlyEmissions: Double) -> [Earth] {
        assert(year >= currentYear) 
        
        var result = [Earth]()
        var simulatedPlanet = self

        for _ in currentYear ..< year {
            result.append(simulatedPlanet)
            simulatedPlanet.tick(yearlyEmission: yearlyEmissions)
        }

        return result
    }
    
    /// the (simulated) year
    public var currentYear = BASE_YEAR
    
    /// the average global temperature in degrees C
    public var currentTemperature = BASE_TEMPERATURE_2015
    
    /// the amount of carbon in the atmosphere (in ppm)
    public var currentConcentration = BASE_CONCENTRATION_2015
    
    /// This function advances the simulated earth with a year.
    /// - Parameter yearlyEmission: global emissions during year in gigaton carbon
    /// State is changed based on the carbon model.
    public mutating func tick(yearlyEmission: Double) {
        currentYear += 1
        let oldConcentration = currentConcentration
        currentConcentration = oldConcentration + concentrationIncreateForYearlyEmission(gigaTonnesCO2: yearlyEmission)
        let deltaTemp = temperatureIncreaseForConcentration(newConcentration: currentConcentration, oldConcentration: oldConcentration)
        
        currentTemperature += deltaTemp
    }
    
    // MARK: Cost of climate change model
    /// https://www.e-education.psu.edu/earth103/node/717
    /// Damage due to climate change as a function of temperature change
    /// in % global economy
    
    
//    static let BASE_GLOBAL_ECONOMY_2019: Double = 86_000_000_000_000 // dollars -> https://www.visualcapitalist.com/the-86-trillion-world-economy-in-one-chart/
    
    
    /// Calculates the cost of temperature increase for an amount of temperature increase.
    /// - Parameter deltaT: the change in temperature compared to the base temperature
    /// - Returns: the damage due to temperature increase in percentage of GDP
    ///
    /// This function assumes an even impact on GDP for all countries, without taking into account geographic and economic differences. This gross simplification will need to be fixed in the future.
//    public func costOfTemperatureChangePct(deltaT: Double) -> Double {
//        0.3098 * deltaT * deltaT + 0.614 * deltaT
//    }

//    public func costOfTemperatureChangeDollars(deltaT: Double) -> Double {
//        costOfTemperatureChangePct(deltaT: deltaT) / 100.0 * Self.BASE_GLOBAL_ECONOMY_2019
//    }
    
    /// The current cost/damages of temperature change (in percentage of GDP)
//    public var currentCostOfTemperatureChange: Double {
//        let deltaT = currentTemperature - Self.BASE_TEMPERATURE_2015
//        let cost = costOfTemperatureChangePct(deltaT: deltaT)
//        return max(0, cost)
//    }
    
    /// (Adverse) effects from increased global warming. These effects become more severe as the global average temperature increases.
    public var currentEffectsOfTemperatureChange: [Effect] {
        let deltaT = currentTemperature - Self.BASE_TEMPERATURE_2015
        switch deltaT {
        case 0 ..< 0.2:
            return [.extraGDP(percentage: -0.1)]
        case 0.2 ..< 0.4:
            return [.extraGDP(percentage: -0.5)]
        case 0.4 ..< 1.0:
            return [.extraGDP(percentage: -1.0)]
        case 1.0 ..< 1.5:
            return [.extraGDP(percentage: -1.5),
                    .extraGini(points: 0.02)]
        case 1.5 ..< 2:
            return [.extraGDP(percentage: -2),
                    .extraGini(points: 0.02),
                    .extraBudget(points: -0.01)]
        case 1.5 ..< 2:
            return [.extraGDP(percentage: -2.5),
                    .extraGini(points: 0.05),
                    .extraBudget(points: -0.02)]
        case 2 ..< 3:
            return [.extraGDP(percentage: -5),
                    .extraGini(points: 0.1),
                    .extraBudget(points: -0.02)]
        case 3 ..< 5:
            return [.extraGDP(percentage: -10),
                    .extraGini(points: 0.15),
                    .extraBudget(points: -0.04)]
        case 5 ..< Double.infinity:
            return [.extraGDP(percentage: -deltaT * 0.25),
                    .extraGini(points: deltaT * 0.075),
                    .extraBudget(points: -deltaT * 0.01)]
        default:
            return []
        }
    }
    
    public var effectDescription: String {
        let effects = currentEffectsOfTemperatureChange
        
        if effects.count > 0 {
            let effectDescriptions = effects.map { $0.description() }
            return effectDescriptions.joined(separator: "\n")
        } else {
            return "No effect"
        }
    }
    
    // MARK: Debug functions/variables
    public var debugVitals: String {
        "currentYear: \(currentYear), currentConcentration: \(currentConcentration), currentTemperature: \(currentTemperature)"
    }
}

extension Earth: Codable {
    
}
