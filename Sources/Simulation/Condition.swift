//
//  Condition.swift
//  
//
//  Created by Maarten Engels on 28/12/2021.
//

import Foundation

/// An data structure that you can use to describe logical expressions about `Country`s.
/// Use 'composition' cases such as `.or`, `.and` and `.not` to express more complex conditions.
public enum Condition: Codable, Equatable {
    
    /// The empty case always evaluates to `true`
    case empty
    
    /// `or` returns true if one of the Conditions passed as an array evaluates to `true`. Returns `false` if none evaluate to `true`.
    indirect case or([Condition])
    
    /// `and` returns true if all of the Conditions passed as an array evaluate to `true`. Returns `false` if a single one evaluates to `false`.
    indirect case and([Condition])
    
    /// `not` returns the logical inverse of what `condition` evaluates to.
    indirect case not(Condition)
    
    /// `True` if the `Country`s wealth rating (GDP per capita) is less than or equal to `ranking`. False otherwise.
    case lessThanOrEqualWealth(ranking: Rating)
    
    /// `True` if the `Country`s wealth rating (GDP per capita) is greater than or equal to `ranking`. False otherwise.
    case greaterThanOrEqualWealth(ranking: Rating)
    
    /// `True` if the `Country`s Education Development Index rating is less than or equal to `ranking`. False otherwise.
    case lessThanOrEqualEDI(ranking: Rating)
    
    /// `True` if the `Country`s Education Development Index rating is greater than or equal to `ranking`. False otherwise.
    case greaterThanOrEqualEDI(ranking: Rating)
    
    /// `True` if the `Country`s emissions per capita rating is greater than or equal to `ranking`. False otherwise.
    case greaterThanOrEqualEmissionsPerCapita(ranking: Rating)
    
    /// `True` if the `Country`s budget rating (surpluss/deficit) is less than or equal to `ranking`. False otherwise.
    case lessThanOrEqualBudget(ranking: Rating)
    
    /// `True` if the `Country`s budget rating (surpluss/deficit) is greater than or equal to `ranking`. False otherwise.
    case greaterThanOrEqualBudget(ranking: Rating)

    /// `True` if the `Country`s equality rating ('Gini-index') is less than or equal to `ranking`. False otherwise.
    case lessThanOrEqualEquality(ranking: Rating)
    
    /// `True` if the `Country` has a policty with `name` currently active. False otherwise.
    case hasActivePolicy(policyName: String)
    
    
    /// Evaluates the expression
    /// - Parameter country: the country to evaluate the expression for.
    /// - Returns: the result of the expression.
    func evaluate(for country: Country) -> Bool {
        switch self {
        case .empty:
            return true
        case .or(let conditions):
            for condition in conditions {
                if condition.evaluate(for: country) {
                    return true
                }
            }
            return false
            
        case .and(let conditions):
            for condition in conditions {
                if condition.evaluate(for: country) == false {
                    return false
                }
            }
            return true
            
        case .not(let condition):
            return condition.evaluate(for: country) == false
            
        case .lessThanOrEqualWealth(let ranking):
            return Rating.wealthRatingFor(country) <= ranking
            
        case .greaterThanOrEqualWealth(let ranking):
            return Rating.wealthRatingFor(country) >= ranking
        
        case .lessThanOrEqualEDI(let ranking):
            return Rating.ediRatingFor(country) <= ranking
        
        case .greaterThanOrEqualEDI(let ranking):
            return Rating.ediRatingFor(country) >= ranking
            
        case .greaterThanOrEqualEmissionsPerCapita(let ranking):
            return Rating.emissionPerCapitaRatingFor(country) >= ranking
            
        case .greaterThanOrEqualBudget(let ranking):
            return Rating.budgetSurplusRatingFor(country) >= ranking
            
        case .lessThanOrEqualBudget(let ranking):
            return Rating.budgetSurplusRatingFor(country) <= ranking
            
        case .lessThanOrEqualEquality(let ranking):
            return Rating.equalityRatingFor(country) <= ranking
            
        case .hasActivePolicy(let policyName):
            return country.activePolicies.contains(where: { $0.name == policyName })
        }
    }
    
    /// Returns a "human readable" description of the condition.
    public var conditionDescription: String {
        switch self {
        case .empty:
            return "No requirement."
        case .and(let conditions):
            return "The following are all valid:\n" +
            conditions.map {$0.conditionDescription}.joined(separator: " & ")
        case .or(let conditions):
            return "At least one of the following are is valid:\n" + "\t" +
            conditions.map {$0.conditionDescription}.joined(separator: " or ")
        case .not(let condition):
            return "The following condition is false:\n \t\(condition.conditionDescription)"
        case .greaterThanOrEqualBudget(let ranking):
            return "Your budget ranking is at least: \(ranking.stringValue)"
        case .lessThanOrEqualBudget(let ranking):
            return "Your budget ranking is at most: \(ranking.stringValue)"
        case .lessThanOrEqualEquality(let ranking):
            return "Your equality ranking is at most: \(ranking.stringValue)"
        case .lessThanOrEqualWealth(let ranking):
            return "Your wealth per capita ranking is at most: \(ranking.stringValue)"
        case .greaterThanOrEqualWealth(let ranking):
            return "Your wealth per capita ranking is at least: \(ranking.stringValue)"
        case .lessThanOrEqualEDI(let ranking):
            return "Your education development index ranking is at most: \(ranking.stringValue)"
        case .greaterThanOrEqualEDI(let ranking):
            return "Your education development index ranking is at least: \(ranking.stringValue)"
        case .greaterThanOrEqualEmissionsPerCapita(let ranking):
            return "Your emissions per capita ranking is at least: \(ranking.stringValue)"
        case .hasActivePolicy(let policyName):
            return "You have '\(policyName)' enacted."
        }
    }
}
