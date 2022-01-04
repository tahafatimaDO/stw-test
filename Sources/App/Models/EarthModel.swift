//
//  EarthModel.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Foundation
import Vapor
import Fluent
import Simulation

/// The `EarthModel` is a wrapper for an `Earth` that can be loaded and saved to the database.
final class EarthModel: Content, Model {
    static let schema = "earth_model"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "earth")
    var earth: Earth
    
    /// Becase scheduled tasks might run multiple times, we want to check the last time it was updated to prevent multiple updates.
//    @Field(key: "last_update")
//    var lastUpdate: Date
//
    init() {
        self.earth = Earth()
    //    self.lastUpdate = Date()
    }
}
