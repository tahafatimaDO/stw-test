//
//  CountryModel.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Foundation
import Vapor
import Simulation
import Fluent

/// The `CountryModel` is a wrapper for a `Country` that can be loaded and saved to the database.
final class CountryModel: Content, Model {
    static let schema = "country_model"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "country")
    var country: Country
    
    /// The earth this country is a part of.
    ///
    /// Because there are only about 200 countries on the earth and we need a single country for each player, we create more earths as player numbers increase. This `earthID` allows us to associate this country with a specific earth.
    @Field(key: "earthID")
    var earthID: UUID
    
    @Field(key: "playerID")
    var playerID: UUID?
    
    /// Parameterless initializer required by Fluent.
    init() {}
    
    /// Convenience initiazer to create new countries initialized with the correct data.
    init(id: UUID? = nil, country: Country, earthID: UUID, playerID: UUID? = nil) {
        self.id = id
        self.country = country
        self.earthID = earthID
        self.playerID = playerID
    }
}
