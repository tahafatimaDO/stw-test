//
//  Effect.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

import Foundation

/// Defines an effect that changes countries.
public enum Effect: Codable, Equatable {
    
//    case changeEmissionsDirect(percentage: Double)
//    case changeGDPDirect(percentage: Double)
    case changeEmissionsTowardsTarget(percentageReductionPerYear: Double, target: Double)
    case extraEmissions(percentage: Double)
    case freePoints(points: Int)
    case extraGDP(percentage: Double)
    case extraGini(points: Double)
    case extraEDI(percentage: Double)
    case extraBudget(points: Double)
    
    /// A 'pretty' description of this effects consequences for a country, when applied.
    func description(level: Int = 1) -> String {
        switch self {
//        case .changeEmissionsDirect(let percentage):
//            return "Directly \(percentage > 0 ? "increases" : "decreases") emissions by \(percentage * Double(level))%"
//        case .changeGDPDirect(let percentage):
//            return "Directly \(percentage * Double(level)  > 0 ? "increases" : "decreases") GDP by \(percentage * Double(level))%"
        case .changeEmissionsTowardsTarget(let percentage, let target):
            return "Lowers emissions towards \(target * Double(level))% less than 2015 value by \(percentage * Double(level))% per year."
        case .freePoints(let points):
            return "Extra Country Points: \(points * level)"
        case .extraEmissions(let percentage):
            return "\(percentage * Double(level)  > 0 ? "Increases" : "Decreases") emissions at a rate of \(percentage * Double(level))% of 2015 per year."
        case .extraGDP(let percentage):
            return "\(percentage * Double(level)  > 0 ? "Increases" : "Decreases") GDP at a rate of \(percentage * Double(level))% of 2015 per year."
        case .extraGini(let points):
            return "\(points * Double(level)  > 0 ? "Increases" : "Decreases") inequality at a rate of \(points * Double(level)) points per year."
        case .extraEDI(let percentage):
            return "\(percentage * Double(level)  > 0 ? "Increases" : "Decreases") education development index at a rate of \(percentage * Double(level))% per year."
        case .extraBudget(let points):
            return "\(points * Double(level)  > 0 ? "Increases" : "Decreases") budget surplus by \(points * Double(level)) points per year."
        }
    }
    
    /// Applies the effect to a country.
    /// - Parameters:
    ///   - country: the `Country` to apply the effect to.
    ///   - earth: the `Earth` that provides context.
    ///   - level: the effect level to apply.
    /// - Returns: An updated `Country` with the effect applied.
    ///
    /// `level` should only be set for policies > 1
    func applyEffect(to country: Country, in earth: Earth, level: Int = 1) -> Country {
        var updatedCountry = country
        
        switch self {
//        case .changeEmissionsDirect(let percentage):
//            updatedCountry.yearlyEmissions = updatedCountry.baseYearlyEmissions * (1.0 + 0.01 * percentage * Double(level))
//        case .changeGDPDirect(let percentage):
//            updatedCountry.GDP = updatedCountry.baseGDP * (1.0 + 0.01 * percentage * Double(level))
        case .changeEmissionsTowardsTarget(let percentageReductionPerYear, let target):
            let targetEmissions = updatedCountry.baseYearlyEmissions * (1.0 - 0.01 * target * Double(level))
            if updatedCountry.yearlyEmissions > targetEmissions {
                /// `percentageReductionPerYear` is a yearly valuue and this update is erformed 24 times per year (once every hour). So we divide by 24. Note this is a small advantage to the player, as this includes "compound interest". (24 log pct is exact)
                let deltaEmissions = updatedCountry.baseYearlyEmissions * 0.01 * percentageReductionPerYear * Double(level) / 24.0
                updatedCountry.yearlyEmissions -= deltaEmissions
            }
        case .freePoints(let points):
            updatedCountry.countryPoints += points * level
            
        case .extraEmissions(let percentage):
            updatedCountry.yearlyEmissions += updatedCountry.baseYearlyEmissions * 0.01 * percentage * Double(level) / 24.0
            
        case .extraGDP(let percentage):
            updatedCountry.GDP += updatedCountry.baseGDP * 0.01 * percentage * Double(level) / 24.0
            
        case .extraGini(let points):
            updatedCountry.giniRating += points * Double(level) / 24.0
            
        case .extraEDI(let percentage):
            updatedCountry.educationDevelopmentIndex += percentage * 0.01 * updatedCountry.educationDevelopmentIndex * Double(level) / 24.0
        case .extraBudget(let points):
            updatedCountry.budgetSurplus += points * Double(level) / 24.0
        }
                
        return updatedCountry
    }
    
//    /// Reverses the effect for a country.
//    /// - Parameters:
//    ///   - country: the `Country` to reverse the effect in.
//    ///   - earth: the `Earth` that provides context.
//    ///   - level: the effect level to apply (defaults to 1)
//    /// - Returns: An updated `Country` with the effect reversed.
//    /// `level` should only be set for policies > 1
//    func reverseEffect(on country: Country, in earth: Earth, level: Int = 1) -> Country {
//        var updatedCountry = country
//        
//        switch self {
//        case .changeEmissionsDirect(let percentage):
//            updatedCountry.yearlyEmissions /= (1.0 + 0.01 * percentage * Double(level))
//        case .changeGDPDirect(let percentage):
//            updatedCountry.baseGDP /= (1.0 + 0.01 * percentage * Double(level))
//        case .changeEmissionsTowardsTarget(let percentageReductionPerYear, let target):
//            updatedCountry.
//        default:
//            break;
//        }
//        
//        return updatedCountry
//    }
}
