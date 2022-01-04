//
//  Country.swift
//  
//
//  Created by Maarten Engels on 23/11/2021.
//

import Foundation

/// A country describes a country on an earth.
///
/// Countries impact the earth by emitting carbon emissions.
/// It is the main object players can interact with, by deciding where to invest to lower/increase emissions.
/// `Codable` conformance helps change these from and to JSON
public struct Country: Codable {
    
    // MARK: Data & Init
    /// assumed reduction in carbon emissions per thousand US$ (in gigaton).
    //public static let EMISSION_REDUCTION_PER_THOUSAND_USDOLLAR = 0.000001
    
    
    /// assumed extraction of carbon per thousand US$ (i.e. net negative emissions) in gigaton carbon.
    //public static let CARBON_SCRUBBED_PER_THOUSAND_USDOLLAR = 0.0000005
    
    
    /// The country name, as per ISO
    public let name: String
    
    /// ISO 2 letter country code
    /// Source: https://datahub.io/core/country-codes
    public let countryCode: String
    
    /// The countries base yearly emissions (in gigaton carbon) in 2015.
    /// Source: https://datahub.io/core/co2-fossil-by-nation (normalized to climate model)
    public var baseYearlyEmissions: Double
    
    /// The countries yearly emissions (in gigaton carbon).
    public var yearlyEmissions: Double
    
    /// The base GDP (in 1000 US$) in 2015
    /// Source: https://datahub.io/core/gdp
    public var baseGDP: Double
    
    // The current GDP (in 1000 US$)
    public var GDP: Double
    
    /// The current population of the country
    /// Source: https://datahub.io/core/population
    public var population: Int
    
    /// The current active policies
    public var activePolicies = [Policy]()
    
    /// The current available country points for the country - this is your main currency for enacting policies and levelling up.
    public var countryPoints = 1
    
    /// The budget surplus (positive values) or deficit (negative values) in % GDP
    /// Source: https://datahub.io/core/cash-surplus-deficit
    public var budgetSurplus: Double
    
    /// The amount of (in)equality in the country. Range: (0...1). Higher values indicate more inequality.
    /// Source: https://datahub.io/core/gini-index
    public var giniRating: Double
    
    /// The level of education in the country, as determined using the EDI. Range: (0...1). Higer values indicate better education.
    /// Source: http://www.unesco.org/new/en/archives/education/themes/leading-the-international-agenda/efareport/statistics/efa-development-index/edi-archive/ (Education For All Global Monitoring Report)
    public var educationDevelopmentIndex: Double
    
    /// Returns the net GDP this country has to spend, after 'paying' for damages caused by temperature increase.
    /// - Parameter earth: the simulated earth this country is a part of.
    /// - Returns: the GDP for this country in 1000 US$ (taking damages of temperature change into account).
    ///
    /// This function assumes a flat net impact of temperature change for each country. We know this is not correct and will improve this function to take geographical and economic differences into account.
//    public func getCorrectedGDP(_ earth: Earth) -> Double {
//        GDP * (1.0 - earth.currentCostOfTemperatureChange / 100.0)
//    }
    
    /// Creates a new country.
    /// - Parameters:
    ///   - name: Country name
    ///   - countryCode: ISO 2 letter country code
    ///   - baseYearlyEmissions: The base yearly emissions (in gigaton carbon).
    ///   - baseGDP: The base GDP (in 1000 US$)
    ///   - population: The current population of the country
    ///   - budgetSurplus: The budget surplus (positive values) or deficit (negative values) in % GDP
    ///   - giniRating: The equality of the country, measured using the gini index.
    ///   - educationDevelopmentIndex: The level of education in the country, as determined using the EDI. Range: (0...1). Higer values indicate better education.
    public init(name: String, countryCode: String, baseYearlyEmissions: Double, baseGDP: Double, population: Int, budgetSurplus: Double, giniRating: Double, educationDevelopmentIndex: Double) {
        self.name = name
        self.countryCode = countryCode
        self.baseYearlyEmissions = baseYearlyEmissions
        self.baseGDP = baseGDP
        self.population = population
        self.GDP = baseGDP
        self.yearlyEmissions = baseYearlyEmissions
        //self.availableCommands = Self.defaultCommands()
        self.budgetSurplus = budgetSurplus
        self.giniRating = giniRating
        self.educationDevelopmentIndex = educationDevelopmentIndex
    }
    
    /// The amount of country points you get in each update.
    public var countryPointsPerTick: Int {
        let earth = Earth()
        
        var updatedCountry = self
        updatedCountry.tick(in: earth)
        return updatedCountry.countryPoints - countryPoints
    }
    
    // MARK: Update
    
    /// Updates the country
    /// - Parameter earth: the `Earth` context for the country.
    public mutating func tick(in earth: Earth) {
        countryPoints += 1
        
        // Apply global warming effects.
        for effect in earth.currentEffectsOfTemperatureChange {
            self = effect.applyEffect(to: self, in: earth)
        }
        
//        let sortedActivePolicies = activePolicies.sorted {
//            $0.priority < $1.priority
//        }
        // Apply policy effects
        for policy in activePolicies {
            self = policy.applyEffects(to: self, in: earth)
        }
    }
    
    // MARK: Commands
    
    /// An array of all commands available to this country.
    public var availableCommands: [CountryCommand] {
        AllCommands.getCountryCommandsFor(self)
    }
    
    /// Execute a country command.
    /// - Parameters:
    ///   - command: the command to execute.
    ///   - earth: the earth this command is executed in.
    /// - Returns: an updated version of the country, with the effects of the command applied.
    public func executeCommand(_ command: CountryCommand, in earth: Earth) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard countryPoints >= command.cost else {
            return (false, self, "Not enough points to execute command \(command.name).")
        }
        
        var commandResult = command.applyEffect(to: self, in: earth)
        commandResult.updatedCountry.countryPoints -= command.cost
        
        return (true, commandResult.updatedCountry, commandResult.resultMessage)
    }
    
    // MARK: Policy
    
    /// The policies that can be enacted by this country, regardless of whether the are already enacted.
    public var availablePolicies: [Policy] {
        AllPolicies.getPolicyFor(self)
    }
    
    /// The policies this country can enact.
    /// The available policies for this country, without the ones that are already enacted.
    public var enactablePolicies: [Policy] {
        availablePolicies.filter { policy in
            activePolicies.contains(where: { $0.name == policy.name }) == false
        }
    }
    
    /// Enact a `Policy`.
    /// - Parameter policy: the `Policy` to enact.
    /// - Returns: an updated country and a message indicating the result of the action.
    public func enactPolicy(_ policy: Policy) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard policy.baseCost <= countryPoints else {
           return (false, self, "Not enough country points to enact policy \(policy).")
        }
        
        var updatedCountry = self
        
        let policiesInSameCategory = activePolicies.filter({$0.category == policy.category})
        
        if let limit = policy.category.policyLimit, policiesInSameCategory.count >= limit {
            return (false, self, "You already have the maximum (\(limit)) number of policies in the \(policy.category) category active.")
        }
        
        updatedCountry.countryPoints -= policy.baseCost
        updatedCountry.activePolicies.append(policy)

        return (true, updatedCountry, "Successfully enacted policy '\(policy.name)'")
    }
    
    /// Revoke a `Policy`
    /// - Parameter policy: the `Policy` to revoke
    /// - Returns: an updated country and a message indicating the result of the action.
    public func revokePolicy(_ policy: Policy) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard let index = activePolicies.firstIndex(of: policy) else {
            return (false, self, "Policy '\(policy.name)' is not enacted.")
        }
        
        var updatedCountry = self
        updatedCountry.activePolicies.remove(at: index)
        return (true, updatedCountry, "Successfully revoked policy '\(policy.name)'")
    }
    
    /// Bring a `Policy` to a higher level.
    /// - Parameter policy: the `Policy` to level up.
    /// - Returns: an updated country and a message indicating the result of the action.
    ///
    /// Each extra level increases the impact the `Policy` has.
    public func levelUpPolicy(_ policy: Policy) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard let index = activePolicies.firstIndex(of: policy) else {
            return (false, self, "Policy '\(policy.name)' is not enacted.")
        }
        
        var updatedCountry = self
        
        guard policy.upgradeCost <= updatedCountry.countryPoints else {
            return (false, self, "Not enough point to upgrade '\(policy.name)'.")
        }
        
        updatedCountry.countryPoints -= policy.upgradeCost
        updatedCountry.activePolicies[index].level += 1
        
        return (true, updatedCountry, "Successfully upgraded policy '\(policy.name)'")
    }
    
    // MARK: Forecasts
    
    /// Forecasts what the country would look like in the year requested, in a constant earth.
    /// - Parameters:
    ///   - year: the year to forecast to
    ///   - earth: the (constant) earth to simulate in.
    /// - Returns: a forecasted country in the year `year`.
    public func forecast(to year: Int, in earth: Earth) -> Country {
        var forecastCountry = self
        for _ in earth.currentYear ..< year {
            for _ in 0 ..< 24 {
                forecastCountry.tick(in: earth)
            }
        }
        return forecastCountry
    }

    /// Forecasts what the country would look like in the year requested, in a constant earth.
    /// - Parameters:
    ///   - year: the year to forecast to
    ///   - earth: the (constant) earth to simulate in.
    /// - Returns: an array of forecasted `Country`s to the specified.
    ///
    /// Useful for creating a time series.
    public func forecastSeries(to year: Int, in earth: Earth) -> [Country] {
        assert(year >= earth.currentYear)
        
        var result = [Country]()
        var forecastCountry = self
        for _ in earth.currentYear ..< year {
            result.append(forecastCountry)
            for _ in 0 ..< 24 {
                forecastCountry.tick(in: earth)
            }
        }
        return result
    }
}
