//
//  CountryCommand.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

// TODO: need to change these to hard coded commands in seperate file 'allCommands' (like 'allPolicies')
// TODO: use Condition system (just like Policy), instead of 'prerequisites'.

import Foundation

/// Definition of all possible commands that can be performed by a country.
///
/// `Codable` conformance makes it easy to send and receive commands between backend and front-end.
public struct CountryCommand: Codable, Equatable {
    
    /// Errors associated with this command.
    public enum CountryCommandErrors: Error {
        
        /// The command cannot be found in the list of known commands.
        case commandNotFound
    }
    
    /// A descriptive name, that also acts as the primary key for the command.
    public let name: String
    
    /// A description of the command to show more information.
    public let description: String
    
    /// The various ways this command impacts `Country`s.
    public let effects: [Effect]
    
    /// If you want to override the default message that is shown when a `Country` executes a `CountryCommand`, set this property.
    public let customApplyMessage: String?
    
    /// The cost to execute this command, in Country points.
    public let cost: Int
    
    /// A condition that determines wether a country can execute this command.
    public let condition: Condition

    private enum CodingKeys: CodingKey {
        case name, description, effects, customApplyMessage, cost, condition
    }
    
    /// Codable based encode function.
    /// Use this to convert the command to JSON
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(effects, forKey: .effects)
        try container.encode(customApplyMessage, forKey: .customApplyMessage)
        try container.encode(cost, forKey: .cost)
        try container.encode(condition, forKey: .condition)
    }
    
    
    /// Codable based initiazer.
    /// Set's default values to keep JSON definition as short and simple as possible.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        description = (try? values.decode(String.self, forKey: .description)) ?? name
        effects = try values.decode([Effect].self, forKey: .effects)
        customApplyMessage = (try? values.decode(String?.self, forKey: .customApplyMessage)) ?? nil
        cost = (try? values.decode(Int.self, forKey: .cost)) ?? 0
        condition = (try? values.decode(Condition.self, forKey: .condition)) ?? .empty
    }
    
    /// Memberwise initiazer
    /// - Parameters:
    ///   - name: the descriptive name to use for this command. Make sure it's unique!
    ///   - description: more information about the command
    ///   - effects: the ways the command impacts a country, defined in `Effect`s
    ///   - customApplyMessage: if you want to use a custom apply message, set this value to a string.
    ///   - cost: the cost of this command in Country codes. Set to '0' for a free command
    ///   - condition: A condition that determines wether a country can execute this command. Default: .empty (no condition)
    init(name: String, description: String, effects: [Effect], cost: Int, customApplyMessage: String? = nil, condition: Condition = .empty) {
        self.name = name
        self.description = description
        self.effects = effects
        self.customApplyMessage = customApplyMessage
        self.cost = cost
        self.condition = condition
    }
    
    /// Applies this command's effects to a country in a world.
    /// - Parameters:
    ///   - country: the country to apply the effects to.
    ///   - earth: the earth that provides context for the country.
    /// - Returns: A tuple of an `updatedCountry: Country` and a `resultMessage: String`.
    func applyEffect(to country: Country, in earth: Earth) -> (updatedCountry: Country, resultMessage: String) {
        var updatedCountry = country
        
        for effect in effects {
            updatedCountry = effect.applyEffect(to: updatedCountry, in: earth)
        }
        
        return (updatedCountry, customApplyMessage ?? "\(name) succesfully applied.")
    }
    
    /// A string version that describes the various effects of this command.
    public var effectDescription: String {
        if effects.count > 0 {
            let effectDescriptions = effects.map { $0.description() }
            return effectDescriptions.joined(separator: "\n")
        } else {
            return "No effect"
        }
    }
}
