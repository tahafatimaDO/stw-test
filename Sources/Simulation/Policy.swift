//
//  Policy.swift
//  
//
//  Created by Maarten Engels on 20/12/2021.
//

import Foundation

/// A policy a Country can enact (or retract) to change how it performs in the world.
public struct Policy: Codable, Equatable {
    /// A descriptive name for this policy, working as a sort of "primary key".
    public let name: String
    
    /// A description providing further info about the policy.
    public let description: String
    
    /// The level for this policy. Higher levels make policy effects more profound.
    public var level: Int
    
    /// The way the policy affects a country, defined by an array of `Effect`s
    public let effects: [Effect]
    
    /// The cost for a 'lv 1' version of this Policy (in Country Points)
    public let baseCost: Int
    
    /// The cost in Country Points to go to the next level.
    public var upgradeCost: Int {
        baseCost * faculty(level)
    }
    
    /// Determines the sequence in which policies are applied to a country during an update. Lower values are applied first. `0` indicated 'neutral'.
    ///
    /// I.e. if you have something you want to apply first, give a big negative value. If you want something to be applied last, give a big positive number.
    //let priority: Int
    
    /// the condition that determines when this policy can be applied by a country.
    public let condition: Condition

    /// the category this policy falls under. Used to determine the maximum number of policies of a certain category a country can have enacted.
    public let category: PolicyCategory

    /// For Codable confomance
    enum CodingKeys: CodingKey {
        case name, description, level, effects, baseCost, //priority,
             condition, category
    }
    
    /// Codable `encode` function.
    ///
    /// We use a custom `encode` function to allow for adding and removing properties, without reseeding the database.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(level, forKey: .level)
        try container.encode(effects, forKey: .effects)
        try container.encode(baseCost, forKey: .baseCost)
        //try container.encode(priority, forKey: .priority)
        try container.encode(condition, forKey: .condition)
        try container.encode(category, forKey: .category)
    }
    
    /// Codable initializer.
    ///
    /// We use a custom Codable `init` to allow for adding and removing properties, without reseeding the database.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        level = try values.decode(Int.self, forKey: .level)
        effects = try values.decode([Effect].self, forKey: .effects)
        baseCost = try values.decode(Int.self, forKey: .baseCost)
        //priority = try values.decode(Int.self, forKey: .priority)
        condition = (try? values.decode(Condition.self, forKey: .condition)) ?? .empty
        category = (try? values.decode(PolicyCategory.self, forKey: .category)) ?? .miscelaneous
    }


    /// Initialize a new Policy.
    /// - Parameters:
    ///   - name: The name of the policy. Needs to be unique.
    ///   - description: A longer description of the policy. Perhaps contains hints of usage.
    ///   - level: The level you want to start this policy. Default: 1
    ///   - effects: The way this policy affects countries, defined as an array of `Effect`.
    ///   - baseCost: The cost of this policy to enact it.
    ///   - condition: A `Condition` that describes when this policy can be applied. Default: .empty
    ///   - policyCategory: The category to assign this policy to. Default: .miscelaneous
    ///
    ///   Policies are applied to countries in sequence of priority from low to high. If you have something you want to apply first, give a big negative value. If you want something to be applied last, give a big positive number.
    public init(name: String, description: String? = nil, level: Int = 1, effects: [Effect], baseCost: Int, condition: Condition = .empty, policyCategory: PolicyCategory = .miscelaneous) {
        self.name = name
        self.description = description ?? name
        self.level = level
        self.effects = effects
        self.baseCost = baseCost
        self.condition = condition
        self.category = policyCategory
    }
    
    /// Apply this policies effects to a `Country`.
    /// - Parameters:
    ///   - country: the country to apply the effects to.
    ///   - earth: the earth that provides context.
    /// - Returns: an updated country with the effects applied.
    func applyEffects(to country: Country, in earth: Earth) -> Country {
        var updatedCountry = country
        
        for effect in effects {
            updatedCountry = effect.applyEffect(to: updatedCountry, in: earth, level: level)
        }
        
        return updatedCountry
    }
    
    /// A string version that describes the various effects of this policy.
    public func effectDescription() -> String {
        if effects.count > 0 {
            let effectDescriptions = effects.map { $0.description(level: level) }
            return effectDescriptions.joined(separator: "\n")
        } else {
            return "No effect"
        }
    }
}

/// A datastructure to organize policies.
///
/// Can be used to determine the maximum number of policies in a certain category a country can have active.
public enum PolicyCategory: String, Codable {
    case emissionTarget = "Emission Target"
    case co2storage = "CO2 storage"
    case miscelaneous
    case economic
    case education
    case political
    case emissionTrade = "Emission Trade"
    
    /// The maximum number of active policies of a category a country can have active. `nil` means: no maximum.
    var policyLimit: Int? {
        switch self {
        case .emissionTarget:
            return 1
        case .economic:
            return 1
        case .education:
            return 1
        case .political:
            return 1
        case .emissionTrade:
            return 1
        case .co2storage:
            return 3
        default: 
            return nil
        }
    }
}
