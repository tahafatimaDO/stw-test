//
//  Rating.swift
//  
//
//  Created by Maarten Engels on 28/12/2021.
//

import Foundation

/// Describes a quality rating an indicator.
///
/// Contains functions for obtaining a rating for various country indicators. A rating is `Comparable`, so you can evaluate:
/// ```
/// .A > .B // true
/// .C < .D // false
/// ```
public enum Rating: Comparable, Codable {
    case undefined, F, E, D, C, B, A, S
    
    /// Returns the rating as a string.
    ///
    /// Relying on just `Codable` returns a JSON object.
    public var stringValue: String {
        switch self {
        case .S:
            return "S"
        case .A:
            return "A"
        case .B:
            return "B"
        case .C:
            return "C"
        case .D:
            return "D"
        case .E:
            return "E"
        case .F:
            return "F"
        case .undefined:
            return "undefined"
        }
    }
    
    /// How this country rates when it comes to per capita wealth (GDP/population). Higher wealth leads to higher ranking.
    /// - Parameter country: the country to rate
    /// - Returns: the rating.
    public static func wealthRatingFor(_ country: Country) -> Rating {
        let wealthPerCapita = country.GDP * 1000.0 / Double(country.population) / 365.0
        
        switch wealthPerCapita {
        case 0 ..< 3.2:
            return F
        case 3.2 ..< 5.5:
            return E
        case 5.5 ..< 15:
            return D
        case 15 ..< 40:
            return C
        case 40 ..< 120:
            return B
        case 120 ..< 200:
            return A
        case 200 ..< Double.infinity:
            return S
            
        default:
            return undefined
        }
    }
    
    /// How this country rates when it comes to budget surplus (or deficit). Lower deficit/higher surplus leads to higher ranking.
    /// - Parameter country: the country to rate
    /// - Returns: the rating.
    ///
    /// A surplus always leads to a rating at least A
    public static func budgetSurplusRatingFor(_ country: Country) -> Rating {
        switch country.budgetSurplus {
        case -Double.infinity ..< -10:
            return F
        case -10 ..< -7.5:
            return E
        case -7.5 ..< -5:
            return D
        case -5 ..< -2.5:
            return C
        case -2.5 ..< 0:
            return B
        case 0 ..< 5:
            return A
        case 5 ..< Double.infinity:
            return S
            
        default:
            return undefined
        }
    }
    
    /// How this country rates when it comes to equality (Gini-index). Lower Gini-index (means: more equality) leads to higher rating.
    /// - Parameter country: the country to rate
    /// - Returns: the rating.
    ///
    /// 37,5 is average
    public static func equalityRatingFor(_ country: Country) -> Rating {
        switch country.giniRating {
        case 50 ..< Double.infinity:
            return F
        case 45 ..< 50:
            return E
        case 40 ..< 45:
            return D
        case 37.5 ..< 40:
            return C
        case 30 ..< 37.5:
            return B
        case 25 ..< 30:
            return A
        case 0 ..< 25:
            return S
            
        default:
            return undefined
        }
    }
    
    /// How this country rates when it comes to education (Education Development Index). Higher EDI score leads to better rating.
    /// - Parameter country: the country to rate
    /// - Returns: the rating.
    ///
    /// average 0.899
    public static func ediRatingFor(_ country: Country) -> Rating {
        switch country.educationDevelopmentIndex {
        case 0 ..< 0.6:
            return F
        case 0.6 ..< 0.7:
            return E
        case 0.7 ..< 0.8:
            return D
        case 0.8 ..< 0.9:
            return C
        case 0.9 ..< 0.95:
            return B
        case 0.95 ..< 0.99:
            return A
        case 0.99 ..< Double.infinity:
            return S
            
        default:
            return undefined
        }
    }
    
    /// How this country rates when it comes to emissions per capita. Lower emissions lead to better scores.
    /// - Parameter country: the country to rate
    /// - Returns: the rating.
    public static func emissionPerCapitaRatingFor(_ country: Country) -> Rating {
        let emissionsPerCapita = country.yearlyEmissions * 1_000_000_000 / Double(country.population)
        
        switch emissionsPerCapita {
        case -Double.infinity ..< -4:
            return S
        case -4 ..< 0:
            return A
        case 0 ..< 1:
            return B
        case 1 ..< 2:
            return C
        case 2 ..< 5:
            return D
        case 5 ..< 10:
            return E
        case 10 ..< Double.infinity:
            return F
            
        default:
            return undefined
        }
        
    }
}


